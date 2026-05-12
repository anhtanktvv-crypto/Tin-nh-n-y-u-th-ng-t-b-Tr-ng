import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB3a5Yjs2knhSsk1sK4oB8sfUPqzi66b1g",
      authDomain: "meove-53c46.firebaseapp.com",
      databaseURL:
          "https://meove-53c46-default-rtdb.asia-southeast1.firebasedatabase.app",
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
      title: 'Love Station',
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'Quicksand'),
      home: const LovePage(),
      debugShowCheckedModeBanner: false,
    );
  }
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
  final AudioPlayer _musicPlayer = AudioPlayer(); // dành riêng cho bài hát
  late ConfettiController _confettiCtrl;

  String _userName = "";
  String _beReminder = "💖 Đang chờ Gấu dặn dò...";
  String _currentReminder = "📌 Chưa có lời nhắc chung";
  String _currentWish = "🎁 Gợi ý quà yêu";
  String _mochiStatus = "Đang kết nối";
  bool _isGauOnline = false;
  bool _isBeOnline = false;
  String _giftContent = "";
  bool _isGiftAvailable = false;
  bool _isGiftOpened = false;

  final DateTime _loveStart = DateTime(2025, 10, 12);
  int _sadDays = 0;

  bool _showBubble = false;
  String _bubbleText = "", _bubbleImage = "", _bubbleEmoji = "";
  Timer? _bubbleTimer;
  bool _userInteracted = false;
  List<StreamSubscription> _subscriptions = [];
  String _selectedCategory = "love";

  // ========== DANH SÁCH ACTION ==========
  final List<Map<String, String>> actions = [
    {
      "n": "Yêu quá đi",
      "i": "Yeuquadi.png",
      "s": "notification.mp3",
      "e": "😍",
      "c": "love"
    },
    {
      "n": "Nhớ Gấu",
      "i": "nho_gau_bong.png",
      "s": "nho_gau_bong.mp3",
      "e": "🧸",
      "c": "love"
    },
    {
      "n": "Nhớ Bé Trắng",
      "i": "nho_be_trang.png",
      "s": "nho_be_trang.mp3",
      "e": "🐰",
      "c": "love"
    },
    {
      "n": "Hôn nè",
      "i": "hon.png",
      "s": "notification.mp3",
      "e": "😘",
      "c": "love"
    },
    {
      "n": "Ôm cái nè",
      "i": "omcaine.png",
      "s": "notification.mp3",
      "e": "🤗",
      "c": "love"
    },
    {
      "n": "Rung động",
      "i": "Rungdong.png",
      "s": "notification.mp3",
      "e": "💓",
      "c": "love"
    },
    {
      "n": "Hạnh phúc",
      "i": "Hanhphuc.png",
      "s": "notification.mp3",
      "e": "😁",
      "c": "emotion"
    },
    {
      "n": "Tự hào",
      "i": "tuhao.png",
      "s": "notification.mp3",
      "e": "🥹",
      "c": "emotion"
    },
    {
      "n": "Cố lên nhé",
      "i": "betrangcolen.png",
      "s": "notification.mp3",
      "e": "💪",
      "c": "emotion"
    },
    {
      "n": "Giận dỗi",
      "i": "Giandoi.png",
      "s": "notification.mp3",
      "e": "😤",
      "c": "emotion"
    },
    {
      "n": "Đi chơi nha",
      "i": "dichoinha.png",
      "s": "notification.mp3",
      "e": "🎡",
      "c": "activity"
    },
    {
      "n": "Đi ăn",
      "i": "doimuado.png",
      "s": "notification.mp3",
      "e": "🍜",
      "c": "activity"
    },
    {
      "n": "Du lịch",
      "i": "Dulich.png",
      "s": "notification.mp3",
      "e": "✈️",
      "c": "activity"
    },
    {
      "n": "Uống thuốc",
      "i": "nhac_uong_thuoc.png",
      "s": "nhac_uong_thuoc.mp3",
      "e": "💊",
      "c": "activity"
    },
    {
      "n": "Lục trà",
      "i": "luc_tra.png",
      "s": "luc_tra.mp3",
      "e": "🍵",
      "c": "activity"
    },
    {
      "n": "Bún bò",
      "i": "bunbo.png",
      "s": "bunbo.mp3",
      "e": "🍜",
      "c": "activity"
    },
    {
      "n": "Chúc 5 tháng",
      "i": "chuc_ky_niem_5Th.png",
      "s": "chuc_ky_niem_5Th.mp3",
      "e": "🎉",
      "c": "memory"
    },
    {
      "n": "Ngủ ngoan",
      "i": "gaubongngungon.png",
      "s": "ngu_ngon_a.mp3",
      "e": "🌙",
      "c": "care"
    },
    {
      "n": "Anh đừng buồn",
      "i": "anh_dung_bun.png",
      "s": "anh_dung_bun.mp3",
      "e": "🥺",
      "c": "care"
    },
    {
      "n": "Anh ơi",
      "i": "anh_oi.png",
      "s": "anh_oi.mp3",
      "e": "📢",
      "c": "care"
    },
    {
      "n": "Vất vả òi",
      "i": "anh_vat_va_roi.png",
      "s": "anh_vat_va_roi.mp3",
      "e": "💪",
      "c": "care"
    },
  ];

  final List<Map<String, String>> categories = [
    {"key": "love", "title": "💗 Yêu thương"},
    {"key": "emotion", "title": "😊 Cảm xúc"},
    {"key": "activity", "title": "🎉 Hoạt động"},
    {"key": "memory", "title": "💌 Kỷ niệm"},
    {"key": "care", "title": "🌙 Chăm sóc"},
  ];

  final List<Map<String, String>> quickFlirts = [
    {"text": "Thương quá", "emoji": "❤️"},
    {"text": "Hôn cái nà", "emoji": "😘"},
    {"text": "Nhớ Gấu", "emoji": "🥺"},
    {"text": "Yêu nhiều", "emoji": "💖"},
    {"text": "Cười lên", "emoji": "😊"},
    {"text": "Cố lên", "emoji": "💪"},
    {"text": "Ngủ ngon", "emoji": "🌙"},
    {"text": "Sáng vui", "emoji": "☀️"},
    {"text": "Gấu ơi", "emoji": "🧸"},
    {"text": "Bé à", "emoji": "🐰"},
    {"text": "Yêu quá", "emoji": "😍"},
  ];

  final List<Map<String, String>> randomActivities = [
    {"text": "🍕 Đi ăn pizza?", "emoji": "🍕"},
    {"text": "☕ Uống cf nhé?", "emoji": "☕"},
    {"text": "🎡 Chơi công viên?", "emoji": "🎡"},
    {"text": "🎬 Xem phim mới?", "emoji": "🎬"},
    {"text": "💆 Massage thư giãn", "emoji": "💆"},
  ];

  final List<String> sweetCompliments = [
    "Anh yêu em nhiều lắm",
    "Em đẹp tuyệt vời",
    "Anh tự hào về em",
    "Có em là hạnh phúc",
  ];

  final GlobalKey _beAvatarKey = GlobalKey();
  final GlobalKey _gauAvatarKey = GlobalKey();

  // ========== HÀM RUNG ==========
  void _vibrate(
      {int duration = 50,
      bool isNotification = false,
      bool isMusic = false}) async {
    if (await Vibration.hasVibrator() ?? false) {
      if (isNotification) {
        Vibration.vibrate(pattern: [0, 80, 100, 80]);
      } else if (isMusic) {
        Vibration.vibrate(pattern: [0, 50, 30, 50]);
      } else {
        Vibration.vibrate(duration: duration);
      }
    }
  }

  // ========== DIALOG NHẠC (phát từ assets) ==========
  void _playMusic(String songName, String fileName) async {
    try {
      // Dừng bài đang phát trước khi chạy bài mới
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource('music/$fileName'));
      _vibrate(isMusic: true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("🎵 Đang phát: $songName")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Không thể phát $songName")));
    }
  }

  void _showMusicDialog() {
    final List<Map<String, String>> songs = [
      {"name": "Dạo Bước HongKong 1999", "file": "DaoBuocHongKong1999.mp3"},
      {"name": "Thế giới của anh", "file": "the_gioi_cua_anh.mp3"},
      {"name": "Ai ngoài anh", "file": "AiNgoaiAnh.mp3"},
    ];
    // ... hiển thị danh sách, khi chọn sẽ gọi _playMusic(file)

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🎵 Bài hát em thích",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Chọn bài hát để cùng thưởng thức 💖",
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            ...songs.map((song) => ListTile(
                  leading:
                      const Icon(Icons.music_note, color: Colors.pinkAccent),
                  title: Text(song["name"]!),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () {
                    Navigator.pop(ctx);
                    _playMusic(song["name"]!, song["file"]!);
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  // ========== CÁC HÀM XỬ LÝ KHÁC (dặn dò, ghim, quà, ...) ==========
  void _showThoughtBubble(GlobalKey avatarKey, String text) {
    final RenderBox? renderBox =
        avatarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + size.width / 2 - 60,
        top: position.dy - 30,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4)
                ]),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.edit_note, color: Colors.pinkAccent, size: 12),
              const SizedBox(width: 4),
              Text(text,
                  style: const TextStyle(color: Colors.black87, fontSize: 10)),
            ]),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry?.remove());
  }

  void _showBeReminderDialog() {
    TextEditingController c = TextEditingController(text: _beReminder);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("📝 Dặn dò Bé Trắng"),
        content: TextField(
          controller: c,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) async {
            String newText = c.text.trim();
            if (newText.isNotEmpty) {
              await _dbRef.child('be_reminder').set(newText);
              setState(() => _beReminder = newText);
              _showThoughtBubble(_beAvatarKey, "Đã dặn: $newText");
            }
            Navigator.pop(ctx);
          },
          decoration: const InputDecoration(hintText: "Nhập lời dặn..."),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
              onPressed: () async {
                String newText = c.text.trim();
                if (newText.isNotEmpty) {
                  await _dbRef.child('be_reminder').set(newText);
                  setState(() => _beReminder = newText);
                  _showThoughtBubble(_beAvatarKey, "Đã dặn: $newText");
                }
                Navigator.pop(ctx);
              },
              child: const Text("Gửi")),
        ],
      ),
    );
  }

  void _showGauReminderDialog() {
    TextEditingController c = TextEditingController(text: _currentReminder);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("📌 Ghim lời nhắc chung"),
        content: TextField(
          controller: c,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) async {
            String newText = c.text.trim();
            if (newText.isNotEmpty) {
              await _dbRef.child('reminder').set(newText);
              setState(() => _currentReminder = newText);
              _showThoughtBubble(_gauAvatarKey, "Đã ghim: $newText");
            }
            Navigator.pop(ctx);
          },
          decoration: const InputDecoration(hintText: "Nhập lời nhắc..."),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
              onPressed: () async {
                String newText = c.text.trim();
                if (newText.isNotEmpty) {
                  await _dbRef.child('reminder').set(newText);
                  setState(() => _currentReminder = newText);
                  _showThoughtBubble(_gauAvatarKey, "Đã ghim: $newText");
                }
                Navigator.pop(ctx);
              },
              child: const Text("Ghim")),
        ],
      ),
    );
  }

  void _showWishDialog() {
    TextEditingController c = TextEditingController(text: _currentWish);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🎁 Gợi ý quà yêu"),
        content: TextField(
          controller: c,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) async {
            String newWish = c.text.trim();
            if (newWish.isNotEmpty) {
              await _dbRef.child('currentWish').set(newWish);
              setState(() => _currentWish = newWish);
            }
            Navigator.pop(ctx);
          },
          decoration: const InputDecoration(hintText: "Nhập gợi ý quà..."),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
              onPressed: () async {
                String newWish = c.text.trim();
                if (newWish.isNotEmpty) {
                  await _dbRef.child('currentWish').set(newWish);
                  setState(() => _currentWish = newWish);
                }
                Navigator.pop(ctx);
              },
              child: const Text("Lưu")),
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
              content: TextField(
                  controller: giftCtrl,
                  decoration:
                      const InputDecoration(hintText: "Nhập nội dung quà")),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Hủy")),
                TextButton(
                    onPressed: () {
                      if (giftCtrl.text.trim().isNotEmpty) {
                        _dbRef.child('gift').set({
                          "content": giftCtrl.text.trim(),
                          "available": true,
                          "opened": false,
                          "ts": ServerValue.timestamp
                        });
                      }
                      Navigator.pop(ctx);
                    },
                    child: const Text("Gửi")),
              ],
            ));
  }

  void _showBeGiftOpen() {
    if (!_isGiftAvailable) return;
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("🎁 Quà bí ẩn"),
              content: Text(_giftContent),
              actions: [
                TextButton(
                    onPressed: () {
                      _dbRef.child('gift/opened').set(true);
                      _confettiCtrl.play();
                      Navigator.pop(ctx);
                    },
                    child: const Text("Yêu Gấu ❤️"))
              ],
            ));
  }

  void _listenData() {
    _subscriptions
        .add(_dbRef.child('messages').onChildAdded.listen((event) async {
      if (!mounted) return;
      _scrollToBottom();
      final data = event.snapshot.value as Map?;
      if (data != null &&
          _userName.isNotEmpty &&
          data['sender'] != _userName &&
          _userInteracted) {
        await _notiPlayer.play(AssetSource('music/notification.mp3'));
        _vibrate(isNotification: true);
      }
    }));
    _subscriptions.add(_dbRef.child('be_reminder').onValue.listen((event) {
      if (event.snapshot.value != null && mounted)
        setState(() => _beReminder = event.snapshot.value.toString());
    }));
    _subscriptions.add(_dbRef.child('reminder').onValue.listen((event) {
      if (event.snapshot.value != null && mounted)
        setState(() => _currentReminder = event.snapshot.value.toString());
    }));
    _subscriptions.add(_dbRef.child('gift').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null && mounted)
        setState(() {
          _isGiftAvailable = data['available'] ?? false;
          _isGiftOpened = data['opened'] ?? false;
          _giftContent = data['content'] ?? "";
        });
    }));
    _subscriptions.add(_dbRef.child('actions_log').onValue.listen((event) {
      if (event.snapshot.value != null && mounted) {
        final data = event.snapshot.value as Map;
        setState(() {
          _bubbleText = data['name'] ?? "";
          _bubbleImage = data['i'] ?? data['image'] ?? "";
          _bubbleEmoji = data['e'] ?? data['emoji'] ?? "";
          _showBubble = true;
        });
        _bubbleTimer?.cancel();
        _bubbleTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) setState(() => _showBubble = false);
        });
      }
    }));
    _subscriptions.add(_dbRef.child('mochi/status').onValue.listen((event) {
      if (event.snapshot.value != null && mounted)
        setState(() => _mochiStatus = event.snapshot.value.toString());
    }));
    _subscriptions.add(_dbRef.child('currentWish').onValue.listen((event) {
      if (event.snapshot.value != null && mounted)
        setState(() => _currentWish = event.snapshot.value.toString());
    }));
    _subscriptions.add(_dbRef.child('sadDays').onValue.listen((event) {
      if (event.snapshot.value != null && mounted)
        setState(() => _sadDays = (event.snapshot.value as int?) ?? 0);
    }));
  }

  void _checkSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString('user_name');
    if (saved != null) {
      setState(() => _userName = saved);
      _setupPresence();
      _listenData();
    } else {
      _showNameDialog();
    }
  }

  void _showNameDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              title: const Text("🧸 Chào cặp đôi yêu quý 🐰"),
              content: const Text("Ai đang dùng app? Chọn vai trò nhé:"),
              actions: [
                TextButton(
                    onPressed: () => _setIdentity("Gấu bông 3 tuổi rưỡi"),
                    child: const Text("🧸 Gấu bông")),
                TextButton(
                    onPressed: () => _setIdentity("Bé Trắng 1 tuổi rưỡi"),
                    child: const Text("🐰 Bé Trắng")),
              ],
            ));
  }

  void _setIdentity(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    setState(() => _userName = name);
    Navigator.pop(context);
    _setupPresence();
    _listenData();
  }

  void _setupPresence() {
    _subscriptions.add(_dbRef.child('.info/connected').onValue.listen((event) {
      if (event.snapshot.value == true) {
        var onlineRef = _dbRef.child('presence/$_userName/online');
        onlineRef.set(true);
        onlineRef.onDisconnect().set(false);
      }
    }));
    _subscriptions.add(_dbRef
        .child('presence/Gấu bông 3 tuổi rưỡi/online')
        .onValue
        .listen(
            (e) => setState(() => _isGauOnline = (e.snapshot.value == true))));
    _subscriptions.add(_dbRef
        .child('presence/Bé Trắng 1 tuổi rưỡi/online')
        .onValue
        .listen(
            (e) => setState(() => _isBeOnline = (e.snapshot.value == true))));
  }

  void _sendMsg({String? actionText, String? sound, Map? actionData}) async {
    if (!_userInteracted) setState(() => _userInteracted = true);
    String text = actionText ?? _msgCtrl.text.trim();
    if (text.isEmpty) return;
    await _dbRef.child('messages').push().set({
      "sender": _userName,
      "text": text,
      "timestamp": ServerValue.timestamp
    });
    if (actionData != null) {
      await _dbRef.child('actions_log').set({
        "name": actionData['n'],
        "i": actionData['i'],
        "e": actionData['e'],
        "ts": ServerValue.timestamp,
      });
    }
    _msgCtrl.clear();
    if (sound != null && _userInteracted) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('music/$sound'));
      } catch (e) {
        print("Lỗi phát nhạc: $e");
      }
    }
    _scrollToBottom();
    _vibrate();
  }

  void _sendQuickFlirt(String text) => _sendMsg(actionText: text);
  void _sendRandomSuggestion() {
    final randomActivity = randomActivities[
        DateTime.now().millisecondsSinceEpoch % randomActivities.length];
    final randomCompliment = sweetCompliments[
        DateTime.now().millisecondsSinceEpoch % sweetCompliments.length];
    _sendMsg(
        actionText:
            "${randomActivity['emoji']} ${randomActivity['text']} - $randomCompliment",
        sound: "notification.mp3");
  }

  void _controlMochi() async {
    _vibrate();
    if (_mochiStatus.contains("online")) {
      await _dbRef.child('mochi/command/action').set("play_sound");
      await _dbRef.child('mochi/command/sound_id').set(1);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã gửi lệnh cho Mochi!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mochi đang ngoại tuyến!")));
    }
  }

  void _editSadDays() {
    TextEditingController c = TextEditingController(text: _sadDays.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("😢 Số ngày buồn vì anh"),
        content: TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Nhập số ngày")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
              onPressed: () async {
                int? val = int.tryParse(c.text.trim());
                if (val != null) {
                  await _dbRef.child('sadDays').set(val);
                  setState(() => _sadDays = val);
                }
                Navigator.pop(ctx);
              },
              child: const Text("Lưu")),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients)
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 5));
    _checkSavedUser();
  }

  int get totalDays => DateTime.now().difference(_loveStart).inDays;
  int get happyDays => (totalDays - _sadDays).clamp(0, totalDays);
  String get loveDuration =>
      "$totalDays ngày, ${DateTime.now().difference(_loveStart).inHours % 24} giờ, ${DateTime.now().difference(_loveStart).inMinutes % 60} phút";

  // ========== UI ==========
  Widget _avatarWithIcons(
      String name, bool online, Color color, GlobalKey avatarKey,
      {required bool showRemindIcon,
      VoidCallback? onRemind,
      VoidCallback? onPin}) {
    bool isGau = name.contains("Gấu");
    return GestureDetector(
      key: avatarKey,
      child: Column(
        children: [
          CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(
                  isGau ? "assets/gau_bong.png" : "assets/be_trang.png"),
              backgroundColor: Colors.white),
          const SizedBox(height: 2),
          Text(name,
              style: TextStyle(
                  color: color, fontSize: 9, fontWeight: FontWeight.bold)),
          if (showRemindIcon)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRemind != null)
                  IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.pinkAccent, size: 14),
                      onPressed: onRemind,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints()),
                if (onPin != null)
                  IconButton(
                      icon: const Icon(Icons.push_pin,
                          color: Colors.blueAccent, size: 14),
                      onPressed: onPin,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String content, Color color,
      {VoidCallback? onEdit}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text("$label:",
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(width: 4),
          Expanded(
              child: Text(content,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
          if (onEdit != null)
            IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70, size: 12),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints()),
        ],
      ),
    );
  }

  Widget _quickEmojiButton(String emoji, String text) {
    return GestureDetector(
      onTap: () => _sendMsg(actionText: text, sound: "notification.mp3"),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.all(2),
          child: Text(emoji, style: const TextStyle(fontSize: 18))),
    );
  }

  Widget _islandIcon(String image, String actionName) {
    return GestureDetector(
      onTap: () {
        _vibrate();
        _sendMsg(actionText: actionName, sound: "notification.mp3");
      },
      child: CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage(image),
          backgroundColor: Colors.white),
    );
  }

  Widget _actionGrid(String category) {
    final items = actions.where((a) => a['c'] == category).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.9,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final act = items[i];
        return GestureDetector(
          onTap: () =>
              _sendMsg(actionText: act['n'], sound: act['s'], actionData: act),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset('assets/${act['i']}',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Center(
                          child: Text(act['e'] ?? '❤️',
                              style: const TextStyle(fontSize: 20)))),
                ),
              ),
              const SizedBox(height: 2),
              Text(act['n']!,
                  style: const TextStyle(color: Colors.white, fontSize: 8),
                  textAlign: TextAlign.center,
                  maxLines: 2),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMeGau = _userName.contains("Gấu");

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/background.png"),
                        fit: BoxFit.cover))),
            Container(color: Colors.black.withOpacity(0.35)),
            Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: _islandIcon('assets/gau_bong.png', 'Nhớ Gấu')),
            Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 12,
                child: _islandIcon('assets/be_trang.png', 'Nhớ Bé Trắng')),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _avatarWithIcons("Bé Trắng", _isBeOnline,
                              Colors.pinkAccent, _beAvatarKey,
                              showRemindIcon: false),
                          const Spacer(),
                          Flexible(
                            flex: 3,
                            child: Column(
                              children: [
                                const Text("💖 KỶ NIỆM 💖",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11)),
                                Text(loveDuration,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11),
                                    textAlign: TextAlign.center),
                                const Text("12/10/2025",
                                    style: TextStyle(
                                        color: Colors.pinkAccent,
                                        fontSize: 10)),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 4,
                                  children: [
                                    _quickEmojiButton("❤️", "Yêu quá"),
                                    _quickEmojiButton("😘", "Hôn nè"),
                                    _quickEmojiButton("🥺", "Nhớ quá"),
                                    _quickEmojiButton("💖", "Thương"),
                                    _quickEmojiButton("😊", "Vui"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _avatarWithIcons(
                            "Gấu bông",
                            _isGauOnline,
                            Colors.blueAccent,
                            _gauAvatarKey,
                            showRemindIcon: isMeGau,
                            onRemind: _showBeReminderDialog,
                            onPin: _showGauReminderDialog,
                          ),
                        ],
                      ),
                    ),
                    _infoTile(Icons.card_giftcard, "Gợi ý quà", _currentWish,
                        Colors.orange,
                        onEdit: isMeGau ? _showWishDialog : null),
                    _infoTile(
                        Icons.smart_toy, "Mochi", _mochiStatus, Colors.grey),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Center(
                                  child: Text("😊 Hạnh phúc: $happyDays ngày",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10))),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: isMeGau ? _editSadDays : null,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(16)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("😢 Buồn: $_sadDays ngày",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10)),
                                    if (isMeGau)
                                      const Icon(Icons.edit,
                                          color: Colors.white70, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16)),
                      constraints:
                          const BoxConstraints(minHeight: 100, maxHeight: 140),
                      child: StreamBuilder(
                        stream:
                            _dbRef.child('messages').limitToLast(15).onValue,
                        builder: (ctx, snap) {
                          if (!snap.hasData ||
                              snap.data!.snapshot.value == null)
                            return const Center(
                                child: Text("Hãy nhắn gì đó...",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 10)));
                          final list = (snap.data!.snapshot.value as Map)
                              .values
                              .toList()
                            ..sort((a, b) =>
                                a['timestamp'].compareTo(b['timestamp']));
                          return ListView.builder(
                              controller: _scrollController,
                              itemCount: list.length,
                              itemBuilder: (c, i) {
                                bool me = list[i]['sender'] == _userName;
                                return Align(
                                  alignment: me
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: me
                                            ? Colors.blue.withOpacity(0.6)
                                            : Colors.pink.withOpacity(0.6),
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    child: Text(
                                        "${list[i]['sender'].split(' ')[0]}: ${list[i]['text']}",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 9)),
                                  ),
                                );
                              });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (ctx, i) {
                          final cat = categories[i];
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat['key']!),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _selectedCategory == cat['key']
                                    ? Colors.pinkAccent
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(cat['title']!,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11)),
                            ),
                          );
                        },
                      ),
                    ),
                    _actionGrid(_selectedCategory),
                    Container(
                      height: 34,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: quickFlirts.length,
                        itemBuilder: (ctx, i) {
                          final item = quickFlirts[i];
                          return GestureDetector(
                            onTap: () => _sendQuickFlirt(
                                "${item['emoji']} ${item['text']}"),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.pinkAccent, width: 0.5)),
                              child: Row(
                                children: [
                                  Text(item['emoji']!,
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 2),
                                  Text(item['text']!,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 9)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        IconButton(
                            icon: const Icon(Icons.smart_toy,
                                color: Colors.white, size: 20),
                            onPressed: _controlMochi),
                        IconButton(
                            icon: const Icon(Icons.card_giftcard,
                                color: Colors.white, size: 20),
                            onPressed:
                                isMeGau ? _showGauGiftDialog : _showBeGiftOpen),
                        IconButton(
                            icon: const Icon(Icons.music_note,
                                color: Colors.pinkAccent, size: 22),
                            onPressed: _showMusicDialog),
                        Expanded(
                          child: TextField(
                            controller: _msgCtrl,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMsg(),
                            decoration: const InputDecoration(
                                hintText: "Nhắn...",
                                hintStyle: TextStyle(
                                    color: Colors.white70, fontSize: 11),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 6)),
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.shuffle,
                                color: Colors.pinkAccent, size: 20),
                            onPressed: _sendRandomSuggestion),
                        IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.pinkAccent, size: 20),
                            onPressed: () => _sendMsg()),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            if (_showBubble)
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/${_bubbleImage}',
                            width: 30,
                            height: 30,
                            errorBuilder: (c, e, s) => Text(_bubbleEmoji,
                                style: const TextStyle(fontSize: 20))),
                        const SizedBox(width: 4),
                        Text("$_bubbleText $_bubbleEmoji",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                    confettiController: _confettiCtrl,
                    blastDirection: 1.57,
                    colors: const [Colors.red, Colors.pink])),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _msgCtrl.dispose();
    _audioPlayer.dispose();
    _notiPlayer.dispose();
    _musicPlayer.dispose();
    _scrollController.dispose();
    _bubbleTimer?.cancel();
    for (var sub in _subscriptions) sub.cancel();
    super.dispose();
  }
}
