import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();
  factory FirebaseService() => _instance;
  FirebaseService._();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // ================== PRESENCE ==================
  void setOnline(String userName) {
    _dbRef.child('presence').child(userName).child('online').set(true);
    _dbRef.child('presence').child(userName).child('online').onDisconnect().set(false);
  }

  Stream<DatabaseEvent> listenOnline(String userName) =>
      _dbRef.child('presence').child(userName).child('online').onValue;

  Stream<DatabaseEvent> listenConnected() =>
      _dbRef.child('.info/connected').onValue;

  // ================== MESSAGES ==================
  Future<void> sendMessage(String sender, String text) async {
    await _dbRef.child('messages').push().set({
      'sender': sender,
      'text': text,
      'timestamp': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> listenMessages() =>
      _dbRef.child('messages').onChildAdded;

  Stream<DatabaseEvent> listenRecentMessages() =>
      _dbRef.child('messages').limitToLast(20).onValue;

  // ================== TYPING ==================
  void setTyping(String userName, bool typing) {
    _dbRef.child('typing').child(userName).set(typing);
  }

  Stream<DatabaseEvent> listenTyping(String partnerName) =>
      _dbRef.child('typing').child(partnerName).onValue;

  // ================== ACTIONS ==================
  Future<void> sendAction(Map<String, String> actionData) async {
    await _dbRef.child('actions_log').set({
      'name': actionData['n'],
      'i': actionData['i'],
      'e': actionData['e'],
      'ts': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> listenActions() =>
      _dbRef.child('actions_log').onValue;

  // ================== REMINDERS ==================
  Future<void> setBeReminder(String text) async {
    await _dbRef.child('be_reminder').set(text);
  }

  Stream<DatabaseEvent> listenBeReminder() =>
      _dbRef.child('be_reminder').onValue;

  Future<void> setReminder(String text) async {
    await _dbRef.child('reminder').set(text);
  }

  Stream<DatabaseEvent> listenReminder() =>
      _dbRef.child('reminder').onValue;

  // ================== WISH ==================
  Future<void> setWish(String text) async {
    await _dbRef.child('currentWish').set(text);
  }

  Stream<DatabaseEvent> listenWish() =>
      _dbRef.child('currentWish').onValue;

  // ================== GIFT ==================
  Future<void> sendGift(String content) async {
    await _dbRef.child('gift').set({
      'available': true,
      'content': content,
      'opened': false,
    });
  }

  Future<void> openGift() async {
    await _dbRef.child('gift').set({
      'available': false,
      'content': '',
      'opened': true,
    });
  }

  Stream<DatabaseEvent> listenGift() =>
      _dbRef.child('gift').onValue;

  // ================== SAD DAYS ==================
  Future<void> setSadDays(int days) async {
    await _dbRef.child('sadDays').set(days);
  }

  Stream<DatabaseEvent> listenSadDays() =>
      _dbRef.child('sadDays').onValue;

  // ================== EVENTS ==================
  Future<void> addEvent({
    required String title,
    required String desc,
    required String dateTime,
    required String date,
    required String time,
    required String createdBy,
  }) async {
    await _dbRef.child('events').push().set({
      'title': title,
      'desc': desc,
      'datetime': dateTime,
      'date': date,
      'time': time,
      'createdBy': createdBy,
      'timestamp': ServerValue.timestamp,
    });
  }

  // ================== FEATURE REQUESTS ==================
  Future<void> sendFeatureRequest(String content, String sender) async {
    await _dbRef.child('featureRequests').push().set({
      'content': content,
      'sender': sender,
      'timestamp': ServerValue.timestamp,
    });
  }
}