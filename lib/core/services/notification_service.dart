import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/notification_model.dart';

/// Notification Service
///
/// Manages notifications with Firestore backend.
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firestore.collection('notifications');

  /// Get notifications for a user
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Stream of user notifications (real-time updates)
  Stream<List<NotificationModel>> getUserNotificationsStream(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Stream of unread count
  Stream<int> getUnreadCountStream(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });
      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read for a user
  Future<bool> markAllAsRead(String userId) async {
    try {
      final snapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      debugPrint('Marked ${snapshot.docs.length} notifications as read');
      return true;
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications for a user
  Future<bool> deleteAllNotifications(String userId) async {
    try {
      final snapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint('Deleted ${snapshot.docs.length} notifications');
      return true;
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
      return false;
    }
  }

  /// Create a notification (usually called from backend/cloud functions)
  Future<NotificationModel?> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      final now = DateTime.now();
      final notificationData = {
        'userId': userId,
        'title': title,
        'message': message,
        'type': type.name,
        'isRead': false,
        'createdAt': Timestamp.fromDate(now),
        'data': data,
        'imageUrl': imageUrl,
      };

      final docRef = await _notificationsCollection.add(notificationData);
      final doc = await docRef.get();

      debugPrint('Notification created: ${docRef.id}');
      return NotificationModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error creating notification: $e');
      return null;
    }
  }

  /// Create order-related notification
  Future<void> createOrderNotification({
    required String userId,
    required String orderNumber,
    required String title,
    required String message,
  }) async {
    await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.order,
      data: {'orderNumber': orderNumber},
    );
  }

  /// Seed sample notifications for development
  Future<void> seedNotifications(String userId) async {
    final notifications = [
      {
        'title': 'Order Delivered!',
        'message': 'Your order #GG78901234 has been delivered. Enjoy your gongura!',
        'type': NotificationType.delivery,
        'data': {'orderNumber': 'GG78901234'},
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'title': 'Weekend Special!',
        'message': 'Get 20% off on all pickles this weekend. Use code: WEEKEND20',
        'type': NotificationType.promotion,
        'data': {'couponCode': 'WEEKEND20'},
        'createdAt': DateTime.now().subtract(const Duration(hours: 6)),
      },
      {
        'title': 'Order Shipped',
        'message': 'Your order #GG78912345 is on the way!',
        'type': NotificationType.order,
        'data': {'orderNumber': 'GG78912345'},
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'title': 'New Product Alert!',
        'message': 'Try our new Mango Gongura Pachadi - Limited Edition!',
        'type': NotificationType.product,
        'data': {'productSlug': 'mango-gongura-pachadi'},
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'title': 'Welcome to Gongura Griha!',
        'message': 'Thank you for joining us. Explore our authentic Andhra pickles.',
        'type': NotificationType.system,
        'createdAt': DateTime.now().subtract(const Duration(days: 7)),
      },
    ];

    final batch = _firestore.batch();

    for (final notification in notifications) {
      final docRef = _notificationsCollection.doc();
      batch.set(docRef, {
        'userId': userId,
        'title': notification['title'],
        'message': notification['message'],
        'type': (notification['type'] as NotificationType).name,
        'isRead': false,
        'createdAt': Timestamp.fromDate(notification['createdAt'] as DateTime),
        'data': notification['data'],
      });
    }

    await batch.commit();
    debugPrint('Seeded ${notifications.length} notifications for user $userId');
  }
}
