import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:confetti/confetti.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB3a5Yjs2knhSsk1sK4oB8sfUPqzi66b1g",
      authDomain: "meove-53c46.firebaseapp.com",
      databaseURL: "https://meove-53c46-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "meove-53c46",
      storageBucket: "meove-53c46.firebasestorage.app",
      messagingSenderId: "977041101576",
      appId: "1:977041101576:web:4b7a33894f5a0b17ff92bd",
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const LoveStationApp());
}

class LoveStationApp extends StatelessWidget {
  const LoveStationApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.pink),
      home: const LovePage(),
    );
  }
}

class LovePage extends StatefulWidget {
  const LovePage({super.key});
  @override
  State<LovePage> createState() => _LovePageState();
}

class _LovePageState extends State<LovePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _chatCtrl = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('messages');
  final DatabaseReference _presRef = FirebaseDatabase.instance.ref('presence');
  late ConfettiController _confettiCtrl;

  // --- DATA RNG 100 ĐIỀU ---
  List<int> _doneList = [];
  String _spinContent = "Hôm nay tụi mình làm gì đây ta? ❤️";
  final List<String> _allChallenges = [
    "Có người yêu đã nha 🤣", "Ngắm Sài Gòn từ Bitexco", "Thả diều Thủ Thiêm", "Thử cafe cóc, cafe bệt", "Hoàng hôn cầu Phú Mỹ", "Bánh tráng phố đi bộ", "Đường sách Nguyễn Văn Bình", "Bánh mì Hoà Mã", "Nhà thờ Đức Bà", "Hầm Thủ Thiêm", "Địa đạo Củ Chi", "Bảo tàng TP.HCM", "Cafe cao tầng", "Water Bus", "Khám phá Thảo Điền", "Bùi Viện đêm", "Cầu Ánh Sao", "TTM Takashimaya", "Nhà Hát Lớn", "Chợ Bến Thành", "Cầu duyên Chùa Ngọc Hoàng", "Ăn cơm tấm", "Hồ Bán Nguyệt", "Đi Bar cùng nhau", "Phúc Long", "Bánh tráng Nguyễn Thượng Hiền", "Phá lấu Q4", "Dimsum Q5", "Cháo Triều Châu Q6", "Trái cây tô Q10", "Sủi cảo Hà Tôn Quyền", "Mì muối ớt Phú Nhuận", "Xôi xá xíu Bình Thạnh", "Lẩu dê Lâm Ký", "Cơm tấm chuẩn vị", "Hủ tiếu Nam Vang", "Gỏi bò Lê Văn Tám", "Bột chiên Võ Văn Tần", "Phố trà sữa Q1", "Dậy sớm ngắm Sài Gòn", "Hẻm 144 Pasteur", "Chung cư cũ", "Dinh Độc Lập", "Tắm mưa", "Cafe ngắm mưa", "Đường hoa Tết", "Thảo Cầm Viên", "Vi vu xe máy đêm", "Hủ tiếu gõ hẻm", "Nhạc sáng nhà hát", "Bến Bạch Đằng", "Check-in ga 3A", "Karaoke dở", "Dạo phố lúc ngập", "Chợ hoa Hồ Thị Kỳ 4h sáng", "Xóm đạo Giáng Sinh", "Phố đèn lồng Q5", "Xem kịch", "Sân bay Tân Sơn Nhất", "Bến phà cũ", "Bò bía dạo", "Cafe Vợt", "Nhà thờ Tân Định", "Bánh craft", "Đại lộ Đông Tây", "Phố Tây", "Hồ Con Rùa", "Three O'Clock đêm", "Chợ đêm Nguyễn Trãi", "Ngắm cầu về đêm", "Bún mọc Thanh Mai", "Lẩu gà ớt hiểm", "Bánh canh cua", "Trà sữa KOI", "Bánh xèo", "Bún mắm", "Lẩu tôm ri", "Cơm gà xối mỡ", "Bánh canh gánh", "Bánh tráng nướng đêm", "Nhà hàng trên cao", "Công viên Thỏ Trắng", "Thả diều Q7", "Chợ đồ cũ", "Cafe Acoustic", "Out Cast & En Dee", "Check-in Graffiti", "Rubik Zoo", "Dạo phố tan tầm", "Kẹt xe Sài Gòn", "The New Play Ground", "Takashimaya", "Sữa tươi Mười", "Phố người Hoa", "Chợ Miên", "Phố ẩm thực", "Bánh tráng nướng Cao Thắng", "Xóm Chiếu Q4", "Hột vịt lộn Q2"
  ];

  String _userName = "Vô danh";
  String _statusBeTrang = "offline";
  String _statusAnhTan = "offline";
  final String _sheetUrl = "https://script.google.com/macros/s/AKfycbzVao5FEHrhIl9EdXbubjUwyMihQyvm2ZmBi5MWkLPQEt2yxDUCb1-TjWxm2djASoWX/exec";

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
    _loadDoneList();
    _initPushNotifications();
    
    _dbRef.limitToLast(1).onChildAdded.listen((event) {
      if (_userName == "Vô danh") return;
      var data = event.snapshot.value as Map?;
      if (data != null && data['sender'] != _userName) {
        HapticFeedback.vibrate(); 
        _audioPlayer.play(AssetSource('notification.mp3'));
      }
    });

    Future.delayed(Duration.zero, () => _showNameDialog());
  }

  // --- LOGIC XỬ LÝ ---
  Future<void> _loadDoneList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList('doneChallenges');
    if (savedList != null) {
      setState(() {
        _doneList = savedList.map(int.parse).toList();
        if (_doneList.isNotEmpty) _spinContent = "Tụi mình đã xong ${_doneList.length}/100 điều! ❤️";
      });
    }
  }

  void _spinChallenge() async {
    if (_doneList.length >= _allChallenges.length) {
      setState(() => _spinContent = "🎉 Đã hoàn thành 100 điều!"); return;
    }
    int nextIndex;
    do { nextIndex = Random().nextInt(_allChallenges.length); } while (_doneList.contains(nextIndex));
    HapticFeedback.heavyImpact(); _confettiCtrl.play();
    setState(() {
      _doneList.add(nextIndex);
      _spinContent = "Thử thách #${nextIndex + 1}: ${_allChallenges[nextIndex]}";
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('doneChallenges', _doneList.map((e) => e.toString()).toList());
    _sendAction("Quay trúng thử thách: ${_allChallenges[nextIndex]}", isSilent: true);
  }

  void _initPushNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  void _setupPresence() {
    _presRef.child(_userName).set("online");
    _presRef.child(_userName).onDisconnect().set("offline");
    _presRef.child('Bé Trắng 1 tuổi rưỡi').onValue.listen((e) => setState(() => _statusBeTrang = e.snapshot.value?.toString() ?? "offline"));
    _presRef.child('Gấu bông 3 tuổi rưỡi').onValue.listen((e) => setState(() => _statusAnhTan = e.snapshot.value?.toString() ?? "offline"));
  }

  Future<void> _sendAction(String title, {String? sound, bool isSilent = false}) async {
    HapticFeedback.heavyImpact();
    if (!isSilent) _confettiCtrl.play();
    if (sound != null) _audioPlayer.play(AssetSource(sound));
    _dbRef.push().set({"sender": _userName, "text": "💖 $title", "timestamp": DateTime.now().millisecondsSinceEpoch});
    try { await http.post(Uri.parse(_sheetUrl), body: jsonEncode({"loinhan": "$_userName gửi: $title"})); } catch (_) {}
  }

  void _sendMessage() async {
    if (_chatCtrl.text.trim().isEmpty) return;
    String txt = _chatCtrl.text;
    _dbRef.push().set({"sender": _userName, "text": txt, "timestamp": DateTime.now().millisecondsSinceEpoch});
    _chatCtrl.clear();
    try { await http.post(Uri.parse(_sheetUrl), body: jsonEncode({"loinhan": "$_userName nhắn: $txt"})); } catch (_) {}
  }

  // --- GIAO DIỆN CHÍNH ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.jpg'), fit: BoxFit.cover))),
          Container(color: Colors.black.withOpacity(0.5)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildRNGCard(),
                _buildActionStrip(),
                _buildChatSection(), // KHUNG CHAT MỚI ĐÃ FIX
              ],
            ),
          ),
          Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confettiCtrl, blastDirectionality: BlastDirectionality.explosive)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _avatarNode("Bé Trắng", "thuongembe.png", _statusBeTrang == "online", "MorningVo.mp3", "G9VK.mp3"),
          const Icon(Icons.favorite, color: Colors.redAccent, size: 30),
          _avatarNode("Gấu bông", "thuonggaubong.png", _statusAnhTan == "online", "hello.mp3", "sleep.mp3"),
        ],
      ),
    );
  }

  Widget _avatarNode(String label, String ava, bool online, String mS, String nS) {
    return Column(children: [
      Stack(children: [
        CircleAvatar(radius: 35, backgroundImage: AssetImage("assets/$ava")),
        Positioned(right: 2, bottom: 2, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: online ? Colors.green : Colors.grey, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
      ]),
      const SizedBox(height: 5),
      Row(children: [
        IconButton(icon: const Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 20), onPressed: () => _sendAction("Chào buổi sáng ☀️", sound: mS)),
        IconButton(icon: const Icon(Icons.nightlight_round, color: Colors.blueAccent, size: 20), onPressed: () => _sendAction("Chúc ngủ ngon 🌙", sound: nS)),
      ]),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildRNGCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))),
      child: Column(children: [
        Text(_spinContent, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(onPressed: _spinChallenge, style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, padding: const EdgeInsets.symmetric(horizontal: 20)), child: Text("Hôm nay đi đâu? (${_doneList.length}/100)", style: const TextStyle(color: Colors.white, fontSize: 11))),
          IconButton(onPressed: () async {
            final prefs = await SharedPreferences.getInstance(); await prefs.remove('doneChallenges');
            setState(() { _doneList = []; _spinContent = "Đã reset hành trình! ❤️"; });
          }, icon: const Icon(Icons.refresh, color: Colors.white24, size: 18))
        ]),
      ]),
    );
  }

  Widget _buildActionStrip() {
    final acts = [
      {"n": "Ôm cái nè", "i": "omcaine.png"}, {"n": "Nhõng nhẽo", "i": "Nhongnheo.png"}, {"n": "Măm măm", "i": "mammam.png"},
      {"n": "Hôn nè", "i": "hon.png"}, {"n": "Đòi uống", "i": "doiuong.png"}, {"n": "Mua đồ", "i": "doimuado.png"},
      {"n": "Massage", "i": "doimassage.png"}, {"n": "Đi dạo", "i": "chodidao.png"}, {"n": "Đòi hôn", "i": "Doihon.png"},
    ];
    return SizedBox(height: 85, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10), itemCount: acts.length, itemBuilder: (ctx, i) => GestureDetector(onTap: () => _sendAction(acts[i]['n']!), child: Container(width: 70, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset("assets/${acts[i]['i']}", width: 35), const SizedBox(height: 4), Text(acts[i]['n']!, style: const TextStyle(color: Colors.white, fontSize: 9))])))));
  }

  // --- KHUNG CHAT SECTION ĐÃ ĐƯỢC FIX LỖI VÀ TỐI ƯU ---
  Widget _buildChatSection() {
    return Expanded(
      flex: 3,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text("Hộp thư bí mật 💌", 
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w300)),
            ),
            Divider(color: Colors.white10, height: 1),
            
            Expanded(
              child: StreamBuilder(
                stream: _dbRef.limitToLast(20).onValue,
                builder: (ctx, snap) {
                  if (!snap.hasData || snap.data!.snapshot.value == null) {
                    return const Center(child: Text("❤️ Trạm Sạc Online", style: TextStyle(color: Colors.white24)));
                  }
                  Map v = snap.data!.snapshot.value as Map;
                  var l = v.values.toList()..sort((a,b) => a['timestamp'].compareTo(b['timestamp']));
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: l.length,
                    itemBuilder: (ctx, i) {
                      bool isMe = l[i]['sender'] == _userName;
                      return _buildMessageBubble(l[i]['text'], isMe);
                    },
                  );
                }
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isMe ? Colors.pinkAccent.withOpacity(0.8) : Colors.blueGrey.withOpacity(0.6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Nhắn tin cho người ấy...",
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_rounded, color: Colors.pinkAccent, size: 28),
          ),
        ],
      ),
    );
  }

  void _showNameDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: const Text("Ai đang vào trạm sạc đây?"),
      actions: [
        TextButton(onPressed: () { setState(() => _userName = "Gấu bông 3 tuổi rưỡi"); _setupPresence(); Navigator.pop(ctx); }, child: const Text("Gấu bông")),
        TextButton(onPressed: () { setState(() => _userName = "Bé Trắng 1 tuổi rưỡi"); _setupPresence(); Navigator.pop(ctx); }, child: const Text("Bé Trắng")),
      ]
    ));
  }
}