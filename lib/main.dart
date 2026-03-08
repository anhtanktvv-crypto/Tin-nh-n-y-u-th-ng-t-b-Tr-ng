import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';

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
  runApp(const LoveStationApp());
}

class LoveStationApp extends StatelessWidget {
  const LoveStationApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.pink, brightness: Brightness.dark),
      home: const LovePage(),
    );
  }
}

class LovePage extends StatefulWidget {
  const LovePage({super.key});
  @override
  State<LovePage> createState() => _LovePageState();
}

class _LovePageState extends State<LovePage> with TickerProviderStateMixin {
  final AudioPlayer _actionPlayer = AudioPlayer();
  final AudioPlayer _notiPlayer = AudioPlayer();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('messages');
  final DatabaseReference _presenceRef = FirebaseDatabase.instance.ref('presence');
  final DatabaseReference _moodRef = FirebaseDatabase.instance.ref('moods');
  final DatabaseReference _hapticRef = FirebaseDatabase.instance.ref('haptic_touch');
  
  final TextEditingController _chatCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  
  late ConfettiController _confettiCtrl;
  late AnimationController _fallingEffectCtrl;
  late AnimationController _pulseCtrl;
  
  String _userName = "";
  bool _isGauOnline = false, _isBeOnline = false;
  String _gauMood = "😊", _beMood = "😊";
  bool _isSomeoneTouching = false; // Trạng thái có ai đó đang chạm tim
  final DateTime _startDate = DateTime(2025, 10, 20);
  
  List<String> _challenges = [];
  int _challengeIdx = 0;

  final List<Map<String, String>> actions = [
    {"n": "Anh đừng bùn", "i": "anh_dung_bun.png", "s": "anh_dung_bun.mp3"},
    {"n": "Anh là số 1", "i": "anh_la_so_1.png", "s": "anh_la_so_1.mp3"},
    {"n": "Anh ơi", "i": "anh_oi.png", "s": "anh_oi.mp3"},
    {"n": "Vất vả òi", "i": "anh_vat_va_roi.png", "s": "anh_vat_va_roi.mp3"},
    {"n": "Sáng vui vẻ", "i": "buoi_sang_vui_ve.png", "s": "buoi_sang_vui_ve.mp3"},
    {"n": "Trưa vui vẻ", "i": "mammam.png", "s": "buoi_trua_vui_ve.mp3"},
    {"n": "Giỏi nhất", "i": "gioi_nhat.png", "s": "gioi_nhat.mp3"},
    {"n": "Mún gọi Anh", "i": "goi_cho_anh.png", "s": "goi_cho_anh.mp3"},
    {"n": "Ngủ ngon ạ", "i": "anhngungon.png", "s": "ngu_non_a.mp3"},
    {"n": "Ngủ sớm ạ", "i": "gaubongngungon.png", "s": "ngu_som_a.mp3"},
    {"n": "Nhớ Gấu", "i": "nho_gau_bong.png", "s": "nho_gau_bong.mp3"},
    {"n": "Ôm cái nè", "i": "omcaine.png", "s": "notification.mp3"},
    {"n": "Hôn nè", "i": "hon.png", "s": "anh_oi.mp3"},
    {"n": "Nhõng nhẽo", "i": "Nhongnheo.png", "s": "anh_oi.mp3"},
    {"n": "Đi dạo", "i": "chodidao.png", "s": "goi_cho_anh.mp3"},
    {"n": "Đòi hôn", "i": "Doihon.png", "s": "hello.mp3"},
    {"n": "Massage", "i": "doimassage.png", "s": "anh_vat_va_roi.mp3"},
    {"n": "Mua đồ", "i": "doimuado.png", "s": "notification.mp3"},
    {"n": "Đòi uống", "i": "doiuong.png", "s": "anh_oi.mp3"},
  ];

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 1));
    _fallingEffectCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _initChallenges();
    Future.delayed(Duration.zero, () => _showNameDialog());
  }

  void _initChallenges() {
    List<String> raw = List.generate(1000, (i) => "Thử thách #${i+1}: Hãy làm điều gì đó lãng mạn cho đối phương ngay bây giờ!");
    raw[0] = "Hôn người ấy một cái thật kêu! 😘";
    raw[1] = "Chụp ảnh mặt xấu gửi cho nhau 📸";
    raw[2] = "Nói 'Yêu Em/Anh nhất' 5 lần liên tục";
    raw[3] = "Gửi 1 tin nhắn thoại kể về kỷ niệm đáng nhớ nhất";
    raw.shuffle();
    _challenges = raw;
  }

  void _setupPresence() {
    _presenceRef.child(_userName).set(true);
    _presenceRef.child(_userName).onDisconnect().set(false);

    // Sync Online & Mood
    _presenceRef.child("Gấu bông").onValue.listen((e) => setState(() => _isGauOnline = e.snapshot.value == true));
    _presenceRef.child("Bé Trắng").onValue.listen((e) => setState(() => _isBeOnline = e.snapshot.value == true));
    _moodRef.child("Gấu bông").onValue.listen((e) => setState(() => _gauMood = e.snapshot.value?.toString() ?? "😊"));
    _moodRef.child("Bé Trắng").onValue.listen((e) => setState(() => _beMood = e.snapshot.value?.toString() ?? "😊"));

    // --- LOGIC HAPTIC TOUCH (QUAN TRỌNG) ---
    _hapticRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        String toucher = data['user'] ?? "";
        bool active = data['active'] ?? false;
        if (toucher != _userName && active) {
          _triggerHeartbeatVibration(); // Rung máy khi người kia chạm
          if (mounted) setState(() => _isSomeoneTouching = true);
        } else {
          if (mounted) setState(() => _isSomeoneTouching = false);
        }
      }
    });

    // Voice Noti
    _dbRef.limitToLast(1).onChildAdded.listen((event) {
      if (event.snapshot.child('sender').value != _userName) {
        _notiPlayer.play(AssetSource('notification.mp3'));
      }
    });
  }

  // Giả lập nhịp tim bằng rung động (Lubb-Dupp)
  void _triggerHeartbeatVibration() async {
    while (_isSomeoneTouching) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 700));
    }
  }

  void _updateHapticStatus(bool active) {
    _hapticRef.set({
      "user": _userName,
      "active": active,
      "time": DateTime.now().millisecondsSinceEpoch
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.jpg', fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.5)),
          
          _buildFlowerRain(),

          SafeArea(
            child: Column(
              children: [
                _buildPresenceHeader(),
                _buildLoveInfo(),
                _buildMoodBar(),
                Expanded(flex: 3, child: _buildGridActions()),
                Expanded(flex: 2, child: _buildChatBox()),
                _buildInputArea(),
              ],
            ),
          ),
          
          // Hiệu ứng sóng âm khi có người chạm tim
          if (_isSomeoneTouching) _buildTouchRipple(),
          
          Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confettiCtrl, blastDirectionality: BlastDirectionality.explosive)),
        ],
      ),
    );
  }

  Widget _buildPresenceHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _avatarNode("Bé Trắng", "be_trang.png", _isBeOnline, _beMood),
          
          // --- VÙNG CHẠM ĐỂ THẤY NHAU ---
          GestureDetector(
            onLongPressStart: (_) {
              _updateHapticStatus(true);
              HapticFeedback.mediumImpact();
            },
            onLongPressEnd: (_) => _updateHapticStatus(false),
            child: Column(children: [
              ScaleTransition(
                scale: _pulseCtrl,
                child: Icon(
                  Icons.favorite, 
                  color: _isSomeoneTouching ? Colors.redAccent : Colors.pinkAccent, 
                  size: 45
                ),
              ),
              const Text("CHẠM GIỮ", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white54)),
            ]),
          ),

          _avatarNode("Gấu bông", "gau_bong.png", _isGauOnline, _gauMood),
        ],
      ),
    );
  }

  Widget _buildTouchRipple() {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 1),
        builder: (context, double value, child) {
          return Container(
            width: value * 300,
            height: value * 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.pinkAccent.withOpacity(1 - value), width: 2),
            ),
          );
        },
        onEnd: () => setState(() {}), // Loop hiệu ứng
      ),
    );
  }

  Widget _avatarNode(String name, String img, bool online, String mood) {
    return Column(children: [
      Stack(alignment: Alignment.bottomRight, children: [
        CircleAvatar(radius: 35, backgroundImage: AssetImage('assets/$img'), backgroundColor: Colors.white12),
        Container(width: 15, height: 15, decoration: BoxDecoration(color: online ? Colors.greenAccent : Colors.grey, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2))),
        Positioned(top: 0, left: 0, child: Text(mood, style: const TextStyle(fontSize: 18))),
      ]),
      Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildLoveInfo() {
    Duration diff = DateTime.now().difference(_startDate);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("${diff.inDays} Ngày", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(width: 10),
      IconButton(onPressed: _showChallenge, icon: const Icon(Icons.auto_awesome, color: Colors.yellow, size: 20)),
    ]);
  }

  Widget _buildFlowerRain() {
    return AnimatedBuilder(
      animation: _fallingEffectCtrl,
      builder: (ctx, child) => Stack(children: List.generate(20, (i) {
        double top = (_fallingEffectCtrl.value + (i * 0.1)) % 1.0 * MediaQuery.of(context).size.height;
        return Positioned(
          left: (i * 40.0 + (sin(_fallingEffectCtrl.value * 5 + i) * 30)) % MediaQuery.of(context).size.width,
          top: top,
          child: Opacity(
            opacity: 0.5,
            child: Icon(i % 3 == 0 ? Icons.local_florist : Icons.favorite, color: Colors.pinkAccent, size: 12 + (i % 8).toDouble()),
          ),
        );
      })),
    );
  }

  Widget _buildMoodBar() {
    final moods = ["😊", "😍", "😢", "😋", "😴", "😤"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: moods.map((m) => IconButton(onPressed: () {
        _moodRef.child(_userName).set(m);
        HapticFeedback.lightImpact();
      }, icon: Text(m, style: const TextStyle(fontSize: 20)))).toList()),
    );
  }

  Widget _buildGridActions() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.95),
      itemCount: actions.length,
      itemBuilder: (ctx, i) => InkWell(
        onTap: () {
          _actionPlayer.play(AssetSource(actions[i]['s']!));
          _dbRef.push().set({"sender": _userName, "text": "💖 ${actions[i]['n']}", "timestamp": DateTime.now().millisecondsSinceEpoch});
          _confettiCtrl.play();
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(15)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(child: Padding(padding: const EdgeInsets.all(6), child: Image.asset('assets/${actions[i]['i']}', errorBuilder: (c,e,s) => const Icon(Icons.favorite)))),
            Text(actions[i]['n']!, style: const TextStyle(fontSize: 8)),
            const SizedBox(height: 4),
          ]),
        ),
      ),
    );
  }

  Widget _buildChatBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
      child: StreamBuilder(
        stream: _dbRef.limitToLast(15).onValue,
        builder: (ctx, snap) {
          if (!snap.hasData) return const SizedBox();
          Map data = (snap.data!.snapshot.value as Map? ?? {});
          var list = data.values.toList()..sort((a,b) => a['timestamp'].compareTo(b['timestamp']));
          return ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              bool isMe = list[i]['sender'] == _userName;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.pinkAccent : Colors.white12,
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                      bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                    ),
                  ),
                  child: Text(list[i]['text'], style: const TextStyle(fontSize: 13)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
      child: Row(children: [
        Expanded(
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) {
              if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) _sendMessage();
            },
            child: TextField(
              controller: _chatCtrl,
              decoration: InputDecoration(hintText: "Nhắn tin...", filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(backgroundColor: Colors.pinkAccent, child: IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, size: 18))),
      ]),
    );
  }

  void _sendMessage() {
    if (_chatCtrl.text.trim().isNotEmpty) {
      _dbRef.push().set({"sender": _userName, "text": _chatCtrl.text.trim(), "timestamp": DateTime.now().millisecondsSinceEpoch});
      _chatCtrl.clear();
      Future.delayed(const Duration(milliseconds: 300), () => _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent));
    }
  }

  void _showChallenge() {
    setState(() => _challengeIdx = (_challengeIdx + 1) % _challenges.length);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Colors.pink[900],
      title: const Text("💘 THỬ THÁCH YÊU", textAlign: TextAlign.center),
      content: Text(_challenges[_challengeIdx], textAlign: TextAlign.center),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("XONG!"))],
    ));
  }

  void _showNameDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: const Text("Xác nhận"),
      actions: [
        TextButton(onPressed: () { setState(() => _userName = "Gấu bông"); _setupPresence(); Navigator.pop(ctx); }, child: const Text("Gấu bông")),
        TextButton(onPressed: () { setState(() => _userName = "Bé Trắng"); _setupPresence(); Navigator.pop(ctx); }, child: const Text("Bé Trắng")),
      ],
    ));
  }
}