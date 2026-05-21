class Notification {
  Notification(String title, {String? body, String? icon, String? tag});

  static bool get supported => false;

  static String get permission => 'default';

  static Future<String> requestPermission() async => 'denied';

  Stream<void> get onClick => const Stream<void>.empty();
}
