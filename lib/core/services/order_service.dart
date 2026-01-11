import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/notification_model.dart';
import '../data/models/order_model.dart';
import '../di/injection.dart';
import 'inventory_service.dart';

/// Order Service
///
/// Manages orders with Firestore backend.
class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('orders');

  /// Generate a unique order number
  String _generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'GG$timestamp$random'.substring(0, 12).toUpperCase();
  }

  /// Create a new order
  Future<OrderModel> createOrder({
    required String userId,
    required List<OrderItem> items,
    required OrderAddress deliveryAddress,
    required double subtotal,
    required double deliveryCharge,
    double discount = 0,
    required double total,
    required PaymentMethod paymentMethod,
    String? paymentId,
  }) async {
    try {
      final orderNumber = _generateOrderNumber();
      final now = DateTime.now();

      final orderData = {
        'orderNumber': orderNumber,
        'userId': userId,
        'items': items.map((item) => item.toMap()).toList(),
        'deliveryAddress': deliveryAddress.toMap(),
        'subtotal': subtotal,
        'deliveryCharge': deliveryCharge,
        'discount': discount,
        'total': total,
        'paymentMethod': paymentMethod.name,
        'paymentId': paymentId,
        'paymentStatus': paymentId != null ? 'paid' : 'pending',
        'status': OrderStatus.confirmed.name,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _ordersCollection.add(orderData);
      final doc = await docRef.get();
      final order = OrderModel.fromFirestore(doc);

      debugPrint('Order created: $orderNumber');

      // Send order confirmation notification
      await _sendOrderCreatedNotification(order);

      return order;
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  /// Send notification when order is created
  Future<void> _sendOrderCreatedNotification(OrderModel order) async {
    try {
      const title = 'Order Placed Successfully!';
      final message = 'Your order #${order.orderNumber} has been placed. We\'ll notify you when it\'s on the way!';

      // Create in-app notification
      await notificationService.createNotification(
        userId: order.userId,
        title: title,
        message: message,
        type: NotificationType.order,
        data: {
          'orderId': order.id,
          'orderNumber': order.orderNumber,
          'status': order.status.name,
        },
      );

      // Show local push notification
      await pushNotificationService.showLocalNotification(
        title: title,
        body: message,
        payload: {
          'type': 'order_created',
          'orderId': order.id,
          'orderNumber': order.orderNumber,
        },
      );

      debugPrint('Order created notification sent for ${order.orderNumber}');
    } catch (e) {
      debugPrint('Error sending order created notification: $e');
    }
  }

  /// Get orders for a user
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching user orders: $e');
      return [];
    }
  }

  /// Stream of user orders (real-time updates)
  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  /// Get a single order by ID
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (!doc.exists) return null;
      return OrderModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching order: $e');
      return null;
    }
  }

  /// Get order by order number
  ///
  /// [userId] is required for Firestore security rules compliance.
  /// The query must include userId to match the security rule that
  /// verifies resource.data.userId == request.auth.uid
  Future<OrderModel?> getOrderByNumber(String orderNumber, {required String userId}) async {
    try {
      final snapshot = await _ordersCollection
          .where('orderNumber', isEqualTo: orderNumber)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return OrderModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      debugPrint('Error fetching order by number: $e');
      return null;
    }
  }

  /// Stream of a single order (real-time updates)
  Stream<OrderModel?> getOrderStream(String orderId) {
    return _ordersCollection.doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return OrderModel.fromFirestore(doc);
    });
  }

  /// Update order status
  Future<bool> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? trackingNumber,
    bool sendNotification = true,
  }) async {
    try {
      // Get order details for notification
      final order = await getOrder(orderId);
      if (order == null) {
        debugPrint('Order not found: $orderId');
        return false;
      }

      final updateData = <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (trackingNumber != null) {
        updateData['trackingNumber'] = trackingNumber;
      }

      if (status == OrderStatus.delivered) {
        updateData['deliveredAt'] = FieldValue.serverTimestamp();
      }

      await _ordersCollection.doc(orderId).update(updateData);
      debugPrint('Order status updated: $orderId -> ${status.name}');

      // Send notification for status update
      if (sendNotification) {
        await _sendOrderStatusNotification(order, status);
      }

      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  /// Send notification for order status change
  Future<void> _sendOrderStatusNotification(
    OrderModel order,
    OrderStatus status,
  ) async {
    final notificationData = _getOrderStatusNotificationData(status, order.orderNumber);
    if (notificationData == null) return;

    final title = notificationData['title'] as String;
    final message = notificationData['message'] as String;
    final type = notificationData['type'] as NotificationType;

    try {
      // Create in-app notification in Firestore
      await notificationService.createNotification(
        userId: order.userId,
        title: title,
        message: message,
        type: type,
        data: {
          'orderId': order.id,
          'orderNumber': order.orderNumber,
          'status': status.name,
        },
      );

      // Show local push notification
      await pushNotificationService.showLocalNotification(
        title: title,
        body: message,
        payload: {
          'type': 'order_status',
          'orderId': order.id,
          'orderNumber': order.orderNumber,
        },
      );

      debugPrint('Order status notification sent for ${order.orderNumber}');
    } catch (e) {
      debugPrint('Error sending order status notification: $e');
    }
  }

  /// Get notification content for each order status
  Map<String, dynamic>? _getOrderStatusNotificationData(
    OrderStatus status,
    String orderNumber,
  ) {
    switch (status) {
      case OrderStatus.confirmed:
        return {
          'title': 'Order Confirmed!',
          'message': 'Your order #$orderNumber has been confirmed.',
          'type': NotificationType.order,
        };
      case OrderStatus.processing:
        return {
          'title': 'Order Being Prepared',
          'message': 'Your order #$orderNumber is being prepared with care.',
          'type': NotificationType.order,
        };
      case OrderStatus.shipped:
        return {
          'title': 'Order Shipped!',
          'message': 'Your order #$orderNumber is on its way!',
          'type': NotificationType.order,
        };
      case OrderStatus.outForDelivery:
        return {
          'title': 'Out for Delivery',
          'message': 'Your order #$orderNumber will arrive today!',
          'type': NotificationType.delivery,
        };
      case OrderStatus.delivered:
        return {
          'title': 'Order Delivered!',
          'message': 'Your order #$orderNumber has been delivered. Enjoy your gongura!',
          'type': NotificationType.delivery,
        };
      case OrderStatus.cancelled:
        return {
          'title': 'Order Cancelled',
          'message': 'Your order #$orderNumber has been cancelled.',
          'type': NotificationType.order,
        };
      case OrderStatus.refunded:
        return {
          'title': 'Refund Processed',
          'message': 'Refund for order #$orderNumber has been initiated.',
          'type': NotificationType.order,
        };
      case OrderStatus.pending:
        return null; // No notification for pending status
    }
  }

  /// Cancel an order and restore inventory
  Future<bool> cancelOrder(
    String orderId, {
    String? reason,
    InventoryService? inventoryService,
  }) async {
    try {
      // Get order details first to restore inventory
      final order = await getOrder(orderId);
      if (order == null) {
        debugPrint('Order not found for cancellation: $orderId');
        return false;
      }

      // Only allow cancellation of orders that haven't been shipped
      if (order.status == OrderStatus.shipped ||
          order.status == OrderStatus.delivered) {
        debugPrint('Cannot cancel shipped/delivered order: $orderId');
        return false;
      }

      // Update order status
      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'cancellationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Restore inventory if service is provided
      if (inventoryService != null) {
        final validationItems = order.items
            .map((item) => CartValidationItem(
                  productSlug: item.productSlug,
                  productName: item.productName,
                  sizeCode: item.sizeCode,
                  quantity: item.quantity,
                ))
            .toList();

        await inventoryService.releaseInventory(validationItems);
        debugPrint('Inventory restored for cancelled order: $orderId');
      }

      debugPrint('Order cancelled: $orderId');
      return true;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return false;
    }
  }

  /// Get order count for a user
  Future<int> getUserOrderCount(String userId) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting order count: $e');
      return 0;
    }
  }

  /// Get active orders (not delivered or cancelled)
  Future<List<OrderModel>> getActiveOrders(String userId) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .where('status', whereNotIn: ['delivered', 'cancelled', 'refunded'])
          .orderBy('status')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching active orders: $e');
      return [];
    }
  }
}
