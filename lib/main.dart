import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marquee/marquee.dart';
import 'dart:async';

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
  runApp(const MaterialApp(home: LovePage(), debugShowCheckedModeBanner: false));
}

class LovePage extends StatefulWidget {
  const LovePage({super.key});
  @override
  State<LovePage> createState() => _LovePageState();
}

class _LovePageState extends State<LovePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _msgCtrl = TextEditingController();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _notiPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  late ConfettiController _confettiCtrl;

  String _userName = "";
  String _myMood = "😊";
  String _partnerMood = "😊";
  String _currentReminder = "";
  bool _isGauOnline = false;
  bool _isBeOnline = false;
  
  String _giftContent = "";
  bool _isGiftAvailable = false;
  bool _isGiftOpened = false;
  
  bool _showBubble = false;
  String _bubbleText = "";
  String _bubbleImage = "";
  String _bubbleEmoji = "";
  
  bool _isMuted = false;
  Timer? _bubbleTimer;

  final DateTime _startDate = DateTime(2025, 10, 12);
  final List<String> reminders = [
    "💖 Kỷ niệm 5 tháng yêu nhau!",
    "🍵 Nhớ mua trà sữa cho Bé Trắng.",
    "🎬 Tối nay 18h đón bé đó Gấu 💋.",
  ];

  String get localReminder => reminders[DateTime.now().minute % reminders.length];

  final List<Map<String, String>> actions = [
    {"n": "Anh đừng bùn", "i": "anh_dung_bun.png", "s": "anh_dung_bun.mp3", "e": "🥺"},
    {"n": "Anh là số 1", "i": "anh_la_so_1.png", "s": "anh_la_so_1.mp3", "e": "🏆"},
    {"n": "Anh ơi", "i": "anh_oi.png", "s": "anh_oi.mp3", "e": "📢"},
    {"n": "Vất vả òi", "i": "anh_vat_va_roi.png", "s": "anh_vat_va_roi.mp3", "e": "💪"},
    {"n": "Sáng vui vẻ", "i": "buoi_sang_vui_ve.png", "s": "buoi_sang_vui_ve.mp3", "e": "☀️"},
    {"n": "Trưa vui vẻ", "i": "mammam.png", "s": "buoi_trua_vui_ve.mp3", "e": "🍱"},
    {"n": "Giỏi nhất", "i": "gioi_nhat.png", "s": "gioi_nhat.mp3", "e": "🥇"},
    {"n": "Mún gọi Anh", "i": "goi_cho_anh.png", "s": "goi_cho_anh.mp3", "e": "📞"},
    {"n": "Ngủ ngon ạ", "i": "anhngungon.png", "s": "ngu_gon_a.mp3", "e": "🌙"},
    {"n": "Ngủ sớm ạ", "i": "gaubongngungon.png", "s": "ngu_som_a.mp3", "e": "😴"},
    {"n": "Nhớ Gấu", "i": "nho_gau_bong.png", "s": "nho_gau_bong.mp3", "e": "🧸"},
    {"n": "Ôm cái nè", "i": "omcaine.png", "s": "notification.mp3", "e": "🫂"},
    {"n": "Hôn nè", "i": "hon.png", "s": "anh_oi.mp3", "e": "😘"},
    {"n": "Nhõng nhẽo", "i": "Nhongnheo.png", "s": "anh_oi.mp3", "e": "💅"},
    {"n": "Chúc 5 Tháng", "i": "chuc_ky_niem_5Th.png", "s": "chuc_ky_niem_5Th.mp3", "e": "💖"},
    {"n": "Uống thuốc nè", "i": "nhac_uong_thuoc.png", "s": "nhac_uong_thuoc.mp3", "e": "💊"},
    {"n": "Lục trà", "i": "luc_tra.png", "s": "luc_tra.mp3", "e": "🍵"},
    {"n": "Phê La", "i": "phela.png", "s": "phela.mp3", "e": "🥤"},
    {"n": "Bún bò", "i": "bunbo.png", "s": "bunbo.mp3", "e": "🍜"},
    {"n": "Nhớ Bé Trắng", "i": "nho_be_trang.png", "s": "nho_be_trang.mp3", "e": "🐰"},
  ];

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 5));
    _checkSavedUser(); 
  }

  void _toggleMute() async {
  setState(() {
    _isMuted = !_isMuted;
  });

  try {
    if (_isMuted) {
      // Ép dừng hẳn luồng nhạc, Safari sẽ không thể "cãi" được
      await _bgmPlayer.pause(); 
      await _bgmPlayer.setVolume(0); 
    } else {
      // Chỉnh âm lượng trước rồi mới cho chạy lại
      await _bgmPlayer.setVolume(0.5);
      await _bgmPlayer.resume(); 
    }
  } catch (e) {
    debugPrint("Lỗi âm thanh: $e");
  }
}

  void _showGauReminderDialog() {
    TextEditingController c = TextEditingController(text: _currentReminder);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("📌 Ghim lời nhắc hôm nay"),
        content: TextField(controller: c, decoration: const InputDecoration(hintText: "Nhắc nhở mới...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(onPressed: () {
            _dbRef.child('reminders').set({"task": c.text, "ts": ServerValue.timestamp});
            Navigator.pop(ctx);
          }, child: const Text("Ghim")),
        ],
      ),
    );
  }

  void _showGauGiftDialog() {
    TextEditingController giftCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🎁 Gửi quà bí ẩn"),
        content: TextField(controller: giftCtrl, decoration: const InputDecoration(hintText: "Lời nhắn quà...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(onPressed: () {
            _dbRef.child('gift').set({"content": giftCtrl.text, "available": true, "opened": false, "ts": ServerValue.timestamp});
            Navigator.pop(ctx);
          }, child: const Text("Gửi")),
        ],
      ),
    );
  }

void _showBeGiftOpen() {
  if (!_isGiftAvailable) return;
  
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("🎁 Quà bí ẩn từ Gấu"),
      content: Text(_giftContent.isEmpty ? "Đang chờ Gấu gửi quà..." : _giftContent),
      actions: [
        TextButton(
          onPressed: () {
            _dbRef.child('gift/opened').set(true); // Cập nhật trạng thái đã mở
            _confettiCtrl.play(); // Nổ pháo hoa cho vui
            Navigator.pop(ctx);
          }, 
          child: const Text("Yêu Gấu ❤️")
        ),
      ],
    ),
  );
}
 
  void _playBGM() async {
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('love_song.mp3'), volume: 0.5);
    } catch (e) { debugPrint("Lỗi nhạc: $e"); }
  }

  void _showAnniversaryDialog() {
    _confettiCtrl.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎉 HAPPY 5 MONTHS 🎉", style: TextStyle(color: Colors.pinkAccent, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Icon(Icons.favorite, color: Colors.redAccent, size: 60),
              const SizedBox(height: 20),
              const Text("🧸🧸🧸Cám ơn Bé Trắng đã Thương anh 150 ngày bên nhau cực hạnh phúc! Chồng thương bé lắm 🐰🐰🐰 ❤️", textAlign: TextAlign.center),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () { _playBGM(); _confettiCtrl.stop(); Navigator.pop(ctx); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                child: const Text("Vào Trạm Sạc 🚀", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _listenData() {
    _dbRef.child('messages').onChildAdded.listen((event) {
      if (!mounted) return;
      _scrollToBottom();
      final data = event.snapshot.value as Map?;
      if (data != null && _userName.isNotEmpty && data['sender'] != _userName) {
        _notiPlayer.play(AssetSource('notification.mp3'));
      }
    });

    _dbRef.child('reminders').onValue.listen((event) {
      if (event.snapshot.value != null && mounted) {
        final data = event.snapshot.value as Map;
        setState(() => _currentReminder = data['task'] ?? "");
      }
    });

    _dbRef.child('gift').onValue.listen((event) {
      if (event.snapshot.value != null && mounted) {
        final data = event.snapshot.value as Map;
        setState(() {
          _giftContent = data['content'] ?? "";
          _isGiftAvailable = data['available'] ?? false;
          _isGiftOpened = data['opened'] ?? false;
        });
      }
    });
    
    _dbRef.child('actions_log').onValue.listen((event) {
       if (event.snapshot.value != null && mounted) {
          final data = event.snapshot.value as Map;
          int ts = data['ts'] ?? 0;
          int now = DateTime.now().millisecondsSinceEpoch;
          if (now - ts < 10000) {
            setState(() {
              _bubbleText = data['name'];
              _bubbleImage = data['image'];
              _bubbleEmoji = data['emoji'];
              _showBubble = true;
            });
            _bubbleTimer?.cancel();
            _bubbleTimer = Timer(const Duration(seconds: 5), () => setState(() => _showBubble = false));
          }
       }
    });
  }

  void _checkSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString('user_name');
    if (saved != null) {
      setState(() => _userName = saved);
      _setupPresence(); _listenData();
      Future.delayed(const Duration(seconds: 1), () => _showAnniversaryDialog());
    } else {
      Future.delayed(Duration.zero, () => _showNameDialog());
    }
  }

  void _showNameDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: const Text("🧸 Chào mừng Cục Zang 🐰"),
      actions: [
        TextButton(onPressed: () => _setIdentity("Gấu bông 3 tuổi rưỡi"), child: const Text("Gấu bông")),
        TextButton(onPressed: () => _setIdentity("Bé Trắng 1 tuổi rưỡi"), child: const Text("Bé Trắng")),
      ],
    ));
  }

  void _setIdentity(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    setState(() => _userName = name);
    Navigator.pop(context);
    _setupPresence(); _listenData();
    Future.delayed(const Duration(seconds: 1), () => _showAnniversaryDialog());
  }

  void _setupPresence() {
    if (_userName.isEmpty) return;
    _dbRef.child('.info/connected').onValue.listen((event) {
      if (event.snapshot.value == true) {
        var onlineRef = _dbRef.child('presence/$_userName/online');
        onlineRef.set(true); onlineRef.onDisconnect().set(false);
      }
    });
    _dbRef.child('presence/Gấu bông 3 tuổi rưỡi/online').onValue.listen((e) => setState(() => _isGauOnline = (e.snapshot.value == true)));
    _dbRef.child('presence/Bé Trắng 1 tuổi rưỡi/online').onValue.listen((e) => setState(() => _isBeOnline = (e.snapshot.value == true)));
    String partner = _userName.contains("Gấu") ? "Bé Trắng 1 tuổi rưỡi" : "Gấu bông 3 tuổi rưỡi";
    _dbRef.child('presence/$partner/mood').onValue.listen((e) { if (mounted && e.snapshot.value != null) setState(() => _partnerMood = e.snapshot.value.toString()); });
  }

  void _updateMood(String icon) { _dbRef.child('presence/$_userName/mood').set(icon); setState(() => _myMood = icon); }

  void _sendMsg({String? actionText, String? sound, Map? actionData}) {
    String text = actionText ?? _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _dbRef.child('messages').push().set({"sender": _userName, "text": text, "timestamp": ServerValue.timestamp});
    if (actionData != null) _dbRef.child('actions_log').set({...actionData, "ts": ServerValue.timestamp});
    _msgCtrl.clear();
    if (sound != null) _audioPlayer.play(AssetSource(sound));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Widget _avatarIsland(String name, bool online, Color color, String mood) {
    bool isGauCard = name.contains("Gấu");
    String img = isGauCard ? "assets/gau_bong.png" : "assets/be_trang.png";
    return GestureDetector(
      onLongPress: () {
        if (_userName.contains("Gấu")) {
          isGauCard ? _showGauReminderDialog() : _showGauGiftDialog();
        }
      },
      child: Column(
        children: [
          Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
            Container(width: 65, height: 65, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: online ? color : Colors.grey, width: 3)), child: CircleAvatar(backgroundColor: Colors.transparent, backgroundImage: AssetImage(img))),
            Positioned(right: -2, bottom: -2, child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: Text(mood, style: const TextStyle(fontSize: 16)))),
          ]),
          const SizedBox(height: 6),
          Text(name, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int days = DateTime.now().difference(_startDate).inDays;
    bool isGau = _userName.contains("Gấu Bông");
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/background.png"), fit: BoxFit.cover))),
          Container(color: Colors.black.withOpacity(0.75)),
          SafeArea(
            child: Column(
              children: [
                Padding(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15), // Giảm bớt padding ngang
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Bên trái: Avatar Bé Trắng
      _avatarIsland("Bé Trắng 1 tuổi rưỡi", _isBeOnline, Colors.pinkAccent, isGau ? _partnerMood : _myMood),

      // GIỮA: Cột thông tin (Bọc Expanded để chống tràn)
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dòng chữ này dài nên phải bọc FittedBox
            FittedBox(
              fit: BoxFit.scaleDown,
              child: const Text(
                "Ở bên nhau Mãi Mãi nhé Bé Trắng", 
                style: TextStyle(color: Colors.white38, fontSize: 8),
              ),
            ),
            Text("$days", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("DAYS", style: TextStyle(color: Colors.pinkAccent, fontSize: 10)),
            
            // Nút Hộp Quà
            IconButton(
              padding: EdgeInsets.zero, // Ép sát cho đỡ tốn diện tích
              constraints: const BoxConstraints(),
              icon: Icon(
                (_isGiftAvailable && !_isGiftOpened) ? Icons.card_giftcard : Icons.redeem,
                color: (_isGiftAvailable && !_isGiftOpened) ? Colors.redAccent : Colors.white24,
                size: 26,
              ),
              onPressed: isGau ? _showGauGiftDialog : _showBeGiftOpen,
            ),
          ],
        ),
      ),

      // Bên phải: Avatar Gấu + Bong bóng
      Stack(
        clipBehavior: Clip.none, 
        alignment: Alignment.topCenter, 
        children: [
          _avatarIsland("Gấu bông 3 tuổi rưỡi", _isGauOnline, Colors.blueAccent, isGau ? _myMood : _partnerMood),
          
          // Lời nhắc ghim
          if (_currentReminder.isNotEmpty) 
            Positioned(
              top: -35, 
              child: Material(
                elevation: 5, 
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.all(4), 
                  color: Colors.white, 
                  child: Text("📌 $_currentReminder", style: const TextStyle(fontSize: 9, color: Colors.black))
                )
              )
            ),
          
          // Bong bóng hành động
          if (_showBubble) 
            Positioned(
              top: -105, 
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 500), 
                tween: Tween<double>(begin: 0, end: 1), 
                builder: (ctx, double val, child) => Transform.scale(
                  scale: val, 
                  child: Column(
                    children: [
                      Container(
                        width: 70, height: 70, 
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          border: Border.all(color: Colors.white, width: 2),
                          image: DecorationImage(image: AssetImage("assets/$_bubbleImage"), fit: BoxFit.cover)
                        )
                      ),
                      Container(
                        padding: const EdgeInsets.all(4), 
                        decoration: BoxDecoration(color: Colors.pinkAccent, borderRadius: BorderRadius.circular(10)), 
                        child: Text("$_bubbleText $_bubbleEmoji", style: const TextStyle(color: Colors.white, fontSize: 9))
                      )
                    ]
                  )
                )
              )
            ),
        ],
      ),
    ],
  ),
),
                Container(height: 30, child: Marquee(text: _currentReminder.isNotEmpty ? "📌: $_currentReminder" : "💖 $localReminder", style: const TextStyle(color: Colors.white, fontSize: 11), velocity: 30, blankSpace: 80)),
                Expanded(
                  child: StreamBuilder(
                    stream: _dbRef.child('messages').limitToLast(15).onValue,
                    builder: (ctx, snap) {
                      if (!snap.hasData || snap.data!.snapshot.value == null) return const SizedBox();
                      final list = (snap.data!.snapshot.value as Map).values.toList()..sort((a,b) => a['timestamp'].compareTo(b['timestamp']));
                      return ListView.builder(controller: _scrollController, itemCount: list.length, itemBuilder: (c, i) {
                        bool me = list[i]['sender'] == _userName;
                        return Align(alignment: me ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: me ? Colors.blue.withOpacity(0.3) : Colors.pink.withOpacity(0.3), borderRadius: BorderRadius.circular(15)), child: Text("${list[i]['sender']}: ${list[i]['text']}", style: const TextStyle(color: Colors.white, fontSize: 11))));
                      });
                    }
                  ),
                ),
                SizedBox(height: 120, child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5), itemCount: actions.length, itemBuilder: (ctx, i) => InkWell(onTap: () { _updateMood(actions[i]['e']!); _sendMsg(actionText: actions[i]['n'], sound: actions[i]['s'], actionData: {"name": actions[i]['n'], "image": actions[i]['i'], "emoji": actions[i]['e']}); }, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset('assets/${actions[i]['i']}', width: 30, height: 30, errorBuilder: (c,e,s) => const Icon(Icons.favorite, color: Colors.white24)), Text(actions[i]['n']!, style: const TextStyle(color: Colors.white70, fontSize: 7))])))),
                Padding(padding: const EdgeInsets.all(10), child: Row(children: [Expanded(child: TextField(controller: _msgCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), hintText: "Nhắn gì đó..."))), IconButton(icon: const Icon(Icons.send, color: Colors.pinkAccent), onPressed: () => _sendMsg())])),
              ],
            ),
          ),
          Positioned(top: 100, right: 20, child: GestureDetector(onTap: _toggleMute, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: _isMuted ? Colors.grey : Colors.pinkAccent, size: 20)))),
          Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confettiCtrl, blastDirection: 1.57, colors: const [Colors.red, Colors.pink])),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiCtrl.dispose(); _msgCtrl.dispose(); _audioPlayer.dispose(); _notiPlayer.dispose(); _bgmPlayer.dispose();
    _scrollController.dispose(); _bubbleTimer?.cancel(); super.dispose();
  }
}