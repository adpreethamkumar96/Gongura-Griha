/**
 * Firebase Cloud Functions for Gongura Griha
 *
 * SETUP:
 * 1. cd functions && npm install
 * 2. Create .env file with: RAZORPAY_SECRET=your_secret
 * 3. Deploy: firebase deploy --only functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');

// Load environment variables from .env file
require('dotenv').config();

admin.initializeApp();

const db = admin.firestore();

/**
 * Verify Razorpay Payment Signature
 *
 * SECURITY CRITICAL: This function verifies the payment signature
 * using the Razorpay secret key stored securely in Firebase Secrets.
 *
 * Call from Flutter:
 * ```dart
 * final result = await FirebaseFunctions.instance
 *     .httpsCallable('verifyPayment')
 *     .call({
 *       'orderId': razorpayOrderId,
 *       'paymentId': razorpayPaymentId,
 *       'signature': razorpaySignature,
 *       'internalOrderId': yourOrderId,
 *     });
 * ```
 */
exports.verifyPayment = functions
  .runWith({ secrets: ['RAZORPAY_SECRET'] })
  .https.onCall(async (data, context) => {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to verify payment'
    );
  }

  const { orderId, paymentId, signature, internalOrderId } = data;

  // Validate required fields
  if (!orderId || !paymentId || !signature) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required payment data'
    );
  }

  try {
    // Get Razorpay secret from environment variable
    const razorpaySecret = process.env.RAZORPAY_SECRET;

    if (!razorpaySecret) {
      console.error('Razorpay secret not configured!');
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Payment verification not configured'
      );
    }

    // Generate expected signature
    const body = orderId + '|' + paymentId;
    const expectedSignature = crypto
      .createHmac('sha256', razorpaySecret)
      .update(body)
      .digest('hex');

    // Verify signature
    if (expectedSignature !== signature) {
      console.error('Payment signature mismatch!', {
        orderId,
        paymentId,
        userId: context.auth.uid,
      });

      throw new functions.https.HttpsError(
        'permission-denied',
        'Invalid payment signature'
      );
    }

    // Signature verified - update order in Firestore
    if (internalOrderId) {
      await db.collection('orders').doc(internalOrderId).update({
        paymentVerified: true,
        razorpayPaymentId: paymentId,
        razorpayOrderId: orderId,
        paymentVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log('Payment verified successfully', {
        orderId,
        paymentId,
        internalOrderId,
        userId: context.auth.uid,
      });
    }

    return { success: true, verified: true };
  } catch (error) {
    console.error('Payment verification error:', error);

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
      'internal',
      'Payment verification failed'
    );
  }
});

/**
 * Send Order Status Notification
 *
 * Triggered when an order's status changes.
 * Sends FCM push notification to the user's devices.
 */
exports.onOrderStatusChange = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger if status changed
    if (before.status === after.status) {
      return null;
    }

    const orderId = context.params.orderId;
    const userId = after.userId;
    const orderNumber = after.orderNumber;
    const newStatus = after.status;

    // Get notification content based on status
    const notificationContent = getOrderStatusNotification(newStatus, orderNumber);
    if (!notificationContent) {
      return null;
    }

    try {
      // Get user's FCM tokens
      const userDoc = await db.collection('users').doc(userId).get();
      const fcmTokens = userDoc.data()?.fcmTokens || [];

      if (fcmTokens.length === 0) {
        console.log('No FCM tokens for user:', userId);
        return null;
      }

      // Send FCM notification
      const message = {
        notification: {
          title: notificationContent.title,
          body: notificationContent.body,
        },
        data: {
          type: 'order_status',
          orderId: orderId,
          orderNumber: orderNumber,
          status: newStatus,
        },
        tokens: fcmTokens,
      };

      const response = await admin.messaging().sendEachForMulticast(message);

      // Clean up invalid tokens
      if (response.failureCount > 0) {
        const invalidTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            invalidTokens.push(fcmTokens[idx]);
          }
        });

        if (invalidTokens.length > 0) {
          await db.collection('users').doc(userId).update({
            fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
          });
        }
      }

      console.log('Order status notification sent:', {
        orderId,
        orderNumber,
        status: newStatus,
        successCount: response.successCount,
      });

      return { success: true };
    } catch (error) {
      console.error('Error sending order notification:', error);
      return null;
    }
  });

/**
 * Get notification content for order status
 */
function getOrderStatusNotification(status, orderNumber) {
  const notifications = {
    confirmed: {
      title: 'Order Confirmed!',
      body: `Your order #${orderNumber} has been confirmed.`,
    },
    processing: {
      title: 'Order Being Prepared',
      body: `Your order #${orderNumber} is being prepared with care.`,
    },
    shipped: {
      title: 'Order Shipped!',
      body: `Your order #${orderNumber} is on its way!`,
    },
    outForDelivery: {
      title: 'Out for Delivery',
      body: `Your order #${orderNumber} will arrive today!`,
    },
    delivered: {
      title: 'Order Delivered!',
      body: `Your order #${orderNumber} has been delivered. Enjoy!`,
    },
    cancelled: {
      title: 'Order Cancelled',
      body: `Your order #${orderNumber} has been cancelled.`,
    },
    refunded: {
      title: 'Refund Processed',
      body: `Refund for order #${orderNumber} has been initiated.`,
    },
  };

  return notifications[status] || null;
}

/**
 * Cleanup expired coupons (scheduled function)
 *
 * Runs daily to deactivate expired coupons.
 */
exports.cleanupExpiredCoupons = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();

    const expiredCoupons = await db
      .collection('coupons')
      .where('isActive', '==', true)
      .where('validUntil', '<', now)
      .get();

    const batch = db.batch();
    expiredCoupons.docs.forEach((doc) => {
      batch.update(doc.ref, { isActive: false });
    });

    await batch.commit();

    console.log(`Deactivated ${expiredCoupons.size} expired coupons`);
    return null;
  });
