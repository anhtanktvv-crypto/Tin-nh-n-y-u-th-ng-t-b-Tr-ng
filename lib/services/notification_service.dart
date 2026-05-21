import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  bool _initialized = false;
  bool _permissionGranted = false;
  String _lastMessageId = "";
  String _userName = "";

  /// Khởi tạo notification service
  Future<void> init(String userName) async {
    _userName = userName;
    if (_initialized) return;
    _initialized = true;
    
    if (html.Notification.supported) {
      final status = html.Notification.permission;
      if (status == 'default') {
        final result = await html.Notification.requestPermission();
        _permissionGranted = result == 'granted';
      } else {
        _permissionGranted = status == 'granted';
      }
    }
  }

  /// Hiển thị notification trên browser như Messenger
  void showNotification(String title, String body, {String? tag}) {
    if (!_permissionGranted || !html.Notification.supported) return;
    
    try {
      final notification = html.Notification(
        title,
        body: body,
        icon: 'assets/lulu_icon.png',
        tag: tag ?? 'love_station',
      );
      
      notification.onClick.listen((_) {
        // ignore: focus on click is optional
      });
    } catch (e) {
      // ignore notification errors
    }
  }

  /// Lắng nghe tin nhắn mới từ Firebase và bật notification đẩy
  void listenToMessages(DatabaseReference dbRef) {
    dbRef.child('messages').limitToLast(1).onChildAdded.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      
      final messageId = event.snapshot.key ?? '';
      final sender = data['sender']?.toString() ?? '';
      final text = data['text']?.toString() ?? '';
      
      if (messageId == _lastMessageId) return;
      _lastMessageId = messageId;
      
      if (sender == _userName) return;
      
      showNotification(
        "💖 $sender vừa nhắn",
        text,
        tag: 'msg_$messageId',
      );
    });
  }
}