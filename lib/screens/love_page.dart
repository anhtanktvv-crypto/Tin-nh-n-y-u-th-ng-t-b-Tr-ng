import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/love_models.dart';
import '../services/firebase_service.dart';
import '../services/audio_service.dart';
import '../services/lulu_ai_service.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/notification_service.dart';
import '../widgets/love_widgets.dart';
import '../widgets/dialogs.dart';
import '../models/nicknames.dart';
import 'dating_map_page.dart';
import 'time_capsule_page.dart';
import 'piggy_bank_page.dart';
import 'app_settings_page.dart';
import 'events_page.dart';

class LovePage extends StatefulWidget {
  const LovePage({super.key});

  @override
  State<LovePage> createState() => _LovePageState();
}

class _LovePageState extends State<LovePage> with TickerProviderStateMixin {
  // ================== SINGLETONS ==================
  final FirebaseService _fb = FirebaseService();
  final AudioService _audio = AudioService();
  final LuLuAiService _lulu = LuLuAiService();

  // ================== CONTROLLERS ==================
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _msgCtrl = TextEditingController();
  final TextEditingController _featureCtrl = TextEditingController();
  final TextEditingController _eventTitleCtrl = TextEditingController();
  final TextEditingController _eventDescCtrl = TextEditingController();
  final TextEditingController _todoCtrl = TextEditingController();

  // ================== STATE ==================
  String _userName = "";
  String _beReminder = "💖 Đang chờ Gấu dặn dò...";
  String _currentReminder = "📌 Chưa có lời nhắc chung";
  String _currentWish = "🎁 Gợi ý quà yêu";
  bool _isGauOnline = false, _isBeOnline = false;
  String _giftContent = "";
  bool _isGiftAvailable = false;
  DateTime _loveStart = DateTime(2025, 10, 12);
  int _sadDays = 0;

  bool _showActions = false;
  bool _isPartnerTyping = false;
  Timer? _typingTimer;

  DateTime _selectedEventDate = DateTime.now();
  TimeOfDay _selectedEventTime = TimeOfDay.now();

  final List<StreamSubscription> _subscriptions = [];

  // ================== BACKGROUND ==================
  String _currentBackground = 'assets/background.png';
  bool _autoBg = true;

  final List<Map<String, String>> bgOptions = [
    {"name": "🌅 Mặc định", "file": "assets/background.png"},
    {"name": "☀️ Nắng", "file": "assets/nang.png"},
    {"name": "🌧️ Mưa", "file": "assets/mua.png"},
    {"name": "🍓 Dâu", "file": "assets/dau.png"},
  ];

  String get autoBgFile {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return 'assets/nang.png';       // Sáng
    if (hour >= 12 && hour < 18) return 'assets/mua.png';       // Chiều (mưa)
    if (hour >= 18 && hour < 22) return 'assets/dau.png';       // Tối (dâu)
    return 'assets/background.png';                              // Đêm
  }

  // Data
  final List<Map<String, String>> actions = [
    {"n": "Nhớ quá", "i": "nho_gau_bong.png", "e": "❤️", "s": "notification.mp3", "c": "love"},
    {"n": "Hôn gió", "i": "hon.png", "e": "💋", "s": "kiss.mp3", "c": "love"},
    {"n": "Ôm ấp", "i": "omcaine.png", "e": "🫂", "s": "hug.mp3", "c": "love"},
    {"n": "Yêu thương", "i": "keylove.png", "e": "💖", "s": "love.mp3", "c": "love"},
    {"n": "Cơm chưa?", "i": "bunbo.png", "e": "🍜", "s": "notification.mp3", "c": "care"},
    {"n": "Ngủ chưa?", "i": "ngu_som_a.png", "e": "😴", "s": "notification.mp3", "c": "care"},
    {"n": "Đi chơi", "i": "Dulich.png", "e": "🎮", "s": "notification.mp3", "c": "activity"},
    {"n": "Xem phim", "i": "chupanh.png", "e": "🎬", "s": "notification.mp3", "c": "activity"},
    {"n": "Tặng quà", "i": "quatang.png", "e": "🎁", "s": "notification.mp3", "c": "gift"},
    {"n": "Sinh nhật", "i": "BetrangVuiqua.png", "e": "🎂", "s": "happy.mp3", "c": "gift"},
  ];

  final List<Map<String, String>> categories = [
    {"key": "love", "title": "💖 Yêu thương"},
    {"key": "care", "title": "🍵 Quan tâm"},
    {"key": "activity", "title": "🎬 Hoạt động"},
    {"key": "gift", "title": "🎁 Quà tặng"},
  ];

  final List<Map<String, String>> quickFlirts = [
    {"emoji": "❤️", "text": "Yêu em"},
    {"emoji": "😘", "text": "Hôn em"},
    {"emoji": "🥺", "text": "Nhớ em"},
    {"emoji": "💖", "text": "Thương em"},
    {"emoji": "😊", "text": "Vui lắm"},
    {"emoji": "🧸", "text": "Gấu của em"},
    {"emoji": "🐰", "text": "Bé của anh"},
    {"emoji": "🧸", "text": "Cục cưng"},
  ];

  final List<Song> songs = [
    const Song(name: "Ai Ngoài Anh - VSTRA", file: "AiNgoaiAnh.mp3"),
    const Song(name: "Dạo Bước Hong Kong 1999", file: "DaoBuocHongKong1999.mp3"),
    const Song(name: "Thế Giới Của Anh - Dangrangto", file: "the_gioi_cua_anh.mp3"),
  ];

  final List<FoodItem> favoriteFoods = [
    const FoodItem(name: "Bún bò Huế", emoji: "🍜", category: "food"),
    const FoodItem(name: "Bún thịt nướng", emoji: "🥗", category: "food"),
    const FoodItem(name: "Bánh mì thịt trứng", emoji: "🥖", category: "food"),
    const FoodItem(name: "Cà phê", emoji: "☕", category: "drink"),
    const FoodItem(name: "Lục trà chanh trân châu đen", emoji: "🧋", category: "drink"),
    const FoodItem(name: "Trà xanh chanh thạch đào", emoji: "🍑", category: "drink"),
    const FoodItem(name: "Phê la bòng bưởi", emoji: "🍊", category: "drink"),
  ];

  final List<Map<String, dynamic>> _todoList = [];

  String _selectedCategory = "love";
  int _currentSongIndex = -1;
  bool _isPlaying = false;
  int _gameScore = 0;

  late ConfettiController _confettiCtrl;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  // ================== COMPUTED ==================
  int get totalDays => DateTime.now().difference(_loveStart).inDays;
  int get happyDays => (totalDays - _sadDays).clamp(0, totalDays);
  bool get isMeGau => _userName.contains("Gấu");

  // ================== NOTIFICATION SERVICE ==================
  final NotificationService _notiService = NotificationService();

  // ================== FIREBASE LISTENERS ==================
  void _listenData() {
    // Khởi tạo notification
    if (_userName.isNotEmpty) {
      _notiService.init(_userName);
      _notiService.listenToMessages(FirebaseDatabase.instance.ref());
    }

    _subscriptions.add(
      _fb.listenMessages().listen((event) {
        if (!mounted) return;
        _scrollToBottom();
        final data = event.snapshot.value as Map?;
        if (data != null && _userName.isNotEmpty && data['sender'] != _userName) {
          _audio.playNotificationSound();
        }
      }),
    );

    _subscriptions.add(
      _fb.listenBeReminder().listen((event) {
        if (event.snapshot.value != null && mounted) {
          setState(() => _beReminder = event.snapshot.value.toString());
        }
      }),
    );

    _subscriptions.add(
      _fb.listenReminder().listen((event) {
        if (event.snapshot.value != null && mounted) {
          setState(() => _currentReminder = event.snapshot.value.toString());
        }
      }),
    );

    _subscriptions.add(
      _fb.listenGift().listen((event) {
        final data = event.snapshot.value as Map?;
        if (data != null && mounted) {
          setState(() {
            _isGiftAvailable = data['available'] ?? false;
            _giftContent = data['content'] ?? "";
          });
          if (data['available'] == true && data['opened'] == false && !isMeGau) {
            _showSnackbar("🎁 Bé có quà mới từ Gấu!");
          }
        }
      }),
    );

    _subscriptions.add(
      _fb.listenActions().listen((event) {
        // Bubble action handling would go here
      }),
    );

    _subscriptions.add(
      _fb.listenWish().listen((event) {
        if (event.snapshot.value != null && mounted) {
          setState(() => _currentWish = event.snapshot.value.toString());
        }
      }),
    );

    _subscriptions.add(
      _fb.listenSadDays().listen((event) {
        if (event.snapshot.value != null && mounted) {
          _sadDays = (event.snapshot.value as int?) ?? 0;
          setState(() {});
        }
      }),
    );

    // Presence
    _subscriptions.add(
      _fb.listenOnline("Gấu bông 3 tuổi rưỡi").listen((event) {
        final newValue = event.snapshot.value == true;
        if (mounted) {
          setState(() => _isGauOnline = newValue);
        }
      }),
    );

    _subscriptions.add(
      _fb.listenOnline("Bé Trắng 1 tuổi rưỡi").listen((event) {
        final newValue = event.snapshot.value == true;
        if (mounted) {
          setState(() => _isBeOnline = newValue);
        }
      }),
    );

    // Typing
    String partner = isMeGau ? "Bé Trắng 1 tuổi rưỡi" : "Gấu bông 3 tuổi rưỡi";
    _subscriptions.add(
      _fb.listenTyping(partner).listen((event) {
        if (mounted) {
          setState(() => _isPartnerTyping = event.snapshot.value == true);
        }
      }),
    );
  }

  // ================== ACTIONS ==================
  void _sendMsg({String? actionText, String? sound, Map? actionData}) async {
    if (_userName.isEmpty) return;
    String text = actionText ?? _msgCtrl.text.trim();
    if (text.isEmpty) return;
    if (!mounted) return;

    await _fb.sendMessage(_userName, text);

    if (actionData != null) {
      await _fb.sendAction({
        'n': actionData['n'] as String,
        'i': actionData['i'] as String,
        'e': actionData['e'] as String,
      });
    }
    _msgCtrl.clear();
    if (sound != null) {
      await _audio.playNotification(sound);
    }
    _scrollToBottom();
  }

  void _sendQuickFlirt(String text) => _sendMsg(actionText: text);

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // ================== USER IDENTITY ==================
  void _checkSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString('user_name');
    if (saved != null) {
      if (mounted) {
        _userName = saved;
        setState(() {});
      }
      _listenData();
      _setupPresence();
    } else {
      if (mounted) _showNameDialog();
    }
  }

  void _showNameDialog() {
    // Random biệt danh cho lần này
    final randomGau = CoupleNicknames.getRandomGauName();
    final randomBe = CoupleNicknames.getRandomBeName();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🧸 Chào cặp đôi yêu quý 🐰"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ai đang dùng app? Chọn vai trò nhé:"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text("🎲 Hôm nay bạn là:", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🧸 ", style: TextStyle(fontSize: 11, color: Colors.brown.shade300)),
                      Text(randomGau, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🐰 ", style: TextStyle(fontSize: 11, color: Colors.pink.shade300)),
                      Text(randomBe, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.pink)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _setIdentity(randomGau),
            icon: const Text("🧸", style: TextStyle(fontSize: 24)),
            label: Text(randomGau, style: const TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 4),
          ElevatedButton.icon(
            onPressed: () => _setIdentity(randomBe),
            icon: const Text("🐰", style: TextStyle(fontSize: 24)),
            label: Text(randomBe, style: const TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _setIdentity(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    if (mounted) {
      _userName = name;
      setState(() {});
    }
    if (mounted) Navigator.pop(context);
    _listenData();
    _setupPresence();
  }

  void _setupPresence() {
    _subscriptions.add(
      _fb.listenConnected().listen((event) {
        if (event.snapshot.value == true) {
          _fb.setOnline(_userName);
        }
      }),
    );
  }

  // ================== DIALOG SHOWERS ==================
  void _showBeReminderDialog() {
    DialogHelper.showInputDialog(
      context: context,
      title: "💌 Dặn dò Bé Trắng",
      hintText: "Nhập lời nhắn...",
      onSubmitted: (text) => _fb.setBeReminder(text),
    );
  }

  void _showGauReminderDialog() {
    DialogHelper.showInputDialog(
      context: context,
      title: "📌 Lời nhắc chung",
      hintText: "Nhập lời nhắc...",
      onSubmitted: (text) => _fb.setReminder(text),
    );
  }

  void _showWishDialog() {
    DialogHelper.showInputDialog(
      context: context,
      title: "🎁 Gợi ý quà yêu",
      hintText: "Bé thích quà gì?",
      onSubmitted: (text) => _fb.setWish(text),
    );
  }

  void _showGauGiftDialog() {
    DialogHelper.showInputDialog(
      context: context,
      title: "🎁 Gửi quà cho Bé",
      hintText: "Quà gì? Nhập nội dung...",
      onSubmitted: (text) async {
        await _fb.sendGift(text);
        _showSnackbar("Đã gửi quà! Bé sẽ nhận được.");
      },
    );
  }

  void _showBeGiftOpen() {
    if (_isGiftAvailable && _giftContent.isNotEmpty) {
      DialogHelper.showConfirmDialog(
        context: context,
        title: "🎁 Bé có quà!",
        content: _giftContent,
        confirmText: "Mở quà 🎉",
        onConfirm: () async {
          await _fb.openGift();
          _showSnackbar("Cảm ơn Gấu nhé! 💖");
          _confettiCtrl.play();
        },
      );
    } else {
      _showSnackbar("Chưa có quà mới nào!");
    }
  }

  void _editSadDays() {
    DialogHelper.showNumberInputDialog(
      context: context,
      title: "😢 Ngày buồn",
      hintText: "Số ngày buồn",
      initialValue: _sadDays,
      onSubmitted: (days) => _fb.setSadDays(days),
    );
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("📅 Thêm sự kiện"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _eventTitleCtrl,
              decoration: const InputDecoration(labelText: "Tên sự kiện"),
            ),
            TextField(
              controller: _eventDescCtrl,
              decoration: const InputDecoration(labelText: "Mô tả"),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: Text(
                  "Ngày: ${_selectedEventDate.day}/${_selectedEventDate.month}/${_selectedEventDate.year}",
                ),
              ),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    _selectedEventDate = date;
                    setState(() {});
                  }
                },
                child: const Text("Chọn ngày"),
              ),
            ]),
            Row(children: [
              Expanded(
                child: Text(
                  "Giờ: ${_selectedEventTime.hour}:${_selectedEventTime.minute.toString().padLeft(2, '0')}",
                ),
              ),
              TextButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: ctx,
                    initialTime: _selectedEventTime,
                  );
                  if (time != null) {
                    _selectedEventTime = time;
                    setState(() {});
                  }
                },
                child: const Text("Chọn giờ"),
              ),
            ]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: _addEventWithTime,
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  Future<void> _addEventWithTime() async {
    if (_eventTitleCtrl.text.isEmpty) return;
    await _fb.addEvent(
      title: _eventTitleCtrl.text,
      desc: _eventDescCtrl.text,
      dateTime: DateTime(
        _selectedEventDate.year,
        _selectedEventDate.month,
        _selectedEventDate.day,
        _selectedEventTime.hour,
        _selectedEventTime.minute,
      ).toIso8601String(),
      date: _selectedEventDate.toIso8601String().split('T').first,
      time:
          "${_selectedEventTime.hour.toString().padLeft(2, '0')}:${_selectedEventTime.minute.toString().padLeft(2, '0')}",
      createdBy: _userName,
    );
    _eventTitleCtrl.clear();
    _eventDescCtrl.clear();
    _showSnackbar("Đã thêm sự kiện");
  }

  void _showTodoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => TodoDialog(
        onAddTodo: _addTodo,
        onToggleTodo: _toggleTodo,
        onDeleteTodo: _deleteTodo,
        todoCtrl: _todoCtrl,
        todoList: _todoList,
      ),
    );
  }

  void _addTodo(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _todoList.add({
        'text': text.trim(),
        'done': false,
        'createdBy': _userName,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
    _showSnackbar("✅ Đã thêm task mới");
  }

  void _toggleTodo(int index) {
    setState(() => _todoList[index]['done'] = !_todoList[index]['done']);
  }

  void _deleteTodo(int index) {
    setState(() => _todoList.removeAt(index));
  }

  void _sendFeatureRequest() {
    DialogHelper.showInputDialog(
      context: context,
      title: "💡 Góp ý tính năng mới",
      hintText: "Nhập ý tưởng...",
      onSubmitted: (text) async {
        await _fb.sendFeatureRequest(text, _userName);
        _showSnackbar("Cảm ơn! Góp ý đã được gửi.");
      },
    );
  }

  void _showLuluDialog() {
    final sweetName = CoupleNicknames.getRandomSweetName(isMeGau);
    showDialog(
      context: context,
      builder: (ctx) => LuLuDialog(
        userName: _userName,
        initialMessage: "$sweetName ơi! Nghe nhạc hông nè? 🎵",
        onAsk: (question) async {
          final answer = await _lulu.ask(
            question,
            totalDays: totalDays,
            happyDays: happyDays,
            sadDays: _sadDays,
          );
          // Thay thế biệt danh trong câu trả lời
          final processed = answer
              .replaceAll("Bé Trắng", CoupleNicknames.getRandomBeName())
              .replaceAll("Gấu bông", CoupleNicknames.getRandomGauName());
          return processed;
        },
      ),
    );
  }

  void _startCoupleGame() {
    showDialog(
      context: context,
      builder: (ctx) => CoupleGameDialog(
        userName: _userName,
        onCorrect: (score) {
          _gameScore = score;
          _showSnackbar("❤️ Điểm hiện tại: $score");
          _confettiCtrl.play();
        },
      ),
    );
  }

  // ================== MUSIC ==================
  void _playSong(int index) {
    if (index < 0 || index >= songs.length) return;
    final song = songs[index];
    _audio.setCurrentSong(index);
    _audio.playSong(song.file);
    setState(() {
      _currentSongIndex = index;
      _isPlaying = true;
    });
    _showSnackbar("🎵 Đang phát: ${song.name}");
  }

  void _pauseResume() {
    if (_currentSongIndex == -1) {
      _playSong(Random().nextInt(songs.length));
      return;
    }
    _audio.pauseResume().then((_) {
      setState(() => _isPlaying = !_isPlaying);
    });
  }

  void _nextSong() {
    if (songs.isEmpty) return;
    int next = (_currentSongIndex + 1) % songs.length;
    _playSong(next);
  }

  void _prevSong() {
    if (songs.isEmpty) return;
    int prev = _currentSongIndex - 1;
    if (prev < 0) prev = songs.length - 1;
    _playSong(prev);
  }

  // ================== WATER REMINDER ==================
  Timer? _waterReminderTimer;
  bool _waterReminderEnabled = false;
  int _waterHour = 9, _waterMinute = 0;
  final String _waterEnabledKey = "waterEnabled",
      _waterHourKey = "waterHour",
      _waterMinuteKey = "waterMinute";

  void _loadWaterPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _waterReminderEnabled = prefs.getBool(_waterEnabledKey) ?? false;
    _waterHour = prefs.getInt(_waterHourKey) ?? 9;
    _waterMinute = prefs.getInt(_waterMinuteKey) ?? 0;
    setState(() {});
    if (_waterReminderEnabled) _scheduleWater();
  }

  void _scheduleWater() {
    _waterReminderTimer?.cancel();
    final now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, now.day, _waterHour, _waterMinute);
    if (next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }
    _waterReminderTimer = Timer(next.difference(now), () {
      _showNotification("💧 Nhắc uống nước", "Yêu ơi, đến giờ uống nước rồi! 🚰💖");
      _scheduleWater();
    });
  }

  void _showWaterTimePicker() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _waterHour, minute: _waterMinute),
    );
    if (t == null) return;
    final prefs = await SharedPreferences.getInstance();
    _waterHour = t.hour;
    _waterMinute = t.minute;
    await prefs.setInt(_waterHourKey, _waterHour);
    await prefs.setInt(_waterMinuteKey, _waterMinute);
    setState(() {});
    if (_waterReminderEnabled) _scheduleWater();
  }

  // ================== UTILITIES ==================
  void _showNotification(String title, String body) {
    _showSnackbar("$title: $body");
  }

  void _showSnackbar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String _getLoveDuration() {
    final diff = DateTime.now().difference(_loveStart);
    return "${diff.inDays} ngày, ${diff.inHours % 24} giờ, ${diff.inMinutes % 60} phút";
  }

  String _formatTimestamp(int? ts) {
    if (ts == null) return "";
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    final n = DateTime.now();
    final weekDays = ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "CN"];
    final dayOfWeek = weekDays[d.weekday - 1];
    final time = "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
    final dateStr = "$dayOfWeek ngày ${d.day}/${d.month}/${d.year}";
    
    // Nếu là hôm nay thì chỉ hiện giờ
    if (d.year == n.year && d.month == n.month && d.day == n.day) {
      return time;
    }
    // Nếu là hôm qua
    final yesterday = n.subtract(const Duration(days: 1));
    if (d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day) {
      return "Hôm qua $time";
    }
    return "$dateStr $time";
  }

  void _confirmLogout() {
    DialogHelper.showConfirmDialog(
      context: context,
      title: "Đổi tài khoản",
      content: "Bạn có chắc muốn đổi tài khoản không?",
      onConfirm: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_name');
        if (mounted) _showNameDialog();
      },
    );
  }

  void _showFavoriteFoodsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("🍜 Món ăn & Đồ uống yêu thích"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: favoriteFoods.length,
            itemBuilder: (ctx, i) {
              final food = favoriteFoods[i];
              return ListTile(
                leading: Text(food.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(food.name),
                subtitle: Text(
                  food.category == 'food' ? 'Món ăn' : 'Đồ uống',
                  style: TextStyle(
                    fontSize: 10,
                    color: food.category == 'food' ? Colors.orange : Colors.blue,
                  ),
                ),
              );
            },
          ),
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

  // ================== BACKGROUND ==================
  void _initBackground() {
    if (_autoBg) {
      _currentBackground = autoBgFile;
    }
    // Periodic check every 30 phút
    Timer.periodic(const Duration(minutes: 30), (_) {
      if (_autoBg && mounted) {
        final newBg = autoBgFile;
        if (newBg != _currentBackground) {
          setState(() => _currentBackground = newBg);
        }
      }
    });
  }

  void _showBackgroundChooser() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.image, color: Colors.pinkAccent),
            const SizedBox(width: 8),
            const Text("🖼️ Chọn ảnh nền"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Auto toggle
            SwitchListTile(
              title: const Text("🌤️ Tự động theo giờ"),
              value: _autoBg,
              onChanged: (val) {
                setState(() {
                  _autoBg = val;
                  if (val) _currentBackground = autoBgFile;
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            const Divider(),
            // Manual options
            ...bgOptions.map((bg) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(bg['file']!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(bg['name']!),
              trailing: _currentBackground == bg['file'] && !_autoBg
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _autoBg = false;
                  _currentBackground = bg['file']!;
                });
                if (ctx.mounted) Navigator.pop(ctx);
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

  // ================== MUSIC COMMAND CALLBACK ==================
  void _setupLuluMusicCommands() {
    _lulu.onMusicCommand = (cmd) {
      switch (cmd) {
        case "play":
          if (_currentSongIndex == -1) _playSong(Random().nextInt(songs.length));
          else _pauseResume();
          break;
        case "pause":
          if (_isPlaying) _pauseResume();
          break;
        case "resume":
          if (!_isPlaying) _pauseResume();
          break;
        case "stop":
          _audio.stopMusic();
          setState(() {
            _isPlaying = false;
            _currentSongIndex = -1;
          });
          break;
        case "next":
          _nextSong();
          break;
        case "prev":
          _prevSong();
          break;
        case "play_hongkong":
          _playSong(1); // DaoBuocHongKong1999
          break;
        case "play_thegioi":
          _playSong(2); // the_gioi_cua_anh
          break;
        case "play_aingoaianh":
          _playSong(0); // AiNgoaiAnh
          break;
      }
    };
  }

  // ================== LOVE DATE ==================
  void _showLoveDateEditor() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("💕 Ngày kỷ niệm"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Chọn ngày bắt đầu yêu nhau:"),
            const SizedBox(height: 12),
            Text(
              "📅 ${_loveStart.day}/${_loveStart.month}/${_loveStart.year}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng"),
          ),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: ctx,
                initialDate: _loveStart,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null && mounted) {
                // Lưu xuống SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('love_start_date', date.toIso8601String());
                setState(() {});
                if (ctx.mounted) Navigator.pop(ctx);
                _showSnackbar("✅ Đã cập nhật ngày kỷ niệm!");
              }
            },
            child: const Text("Chọn ngày mới"),
          ),
        ],
      ),
    );
  }

  // ================== INIT & DISPOSE ==================
  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 5));
    _checkSavedUser();
    _loadWaterPrefs();
    _initBackground();
    _setupLuluMusicCommands();
    _loadLoveDate();
    _subscriptions.add(
      _audio.onMusicComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      }),
    );
  }

  Future<void> _loadLoveDate() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('love_start_date');
    if (saved != null) {
      final parsed = DateTime.tryParse(saved);
      if (parsed != null && mounted) {
        setState(() => _loveStart = parsed);
      }
    }
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _msgCtrl.dispose();
    _featureCtrl.dispose();
    _eventTitleCtrl.dispose();
    _eventDescCtrl.dispose();
    _todoCtrl.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _waterReminderTimer?.cancel();
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  // ================== BUILD ==================
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDesktop = AppTheme.isDesktop(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        drawer: _buildDrawer(),
        body: Stack(
          children: [
            // Background
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Container(
                key: ValueKey(_currentBackground),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_currentBackground),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Container(color: Colors.black.withValues(alpha: 0.35)),

            // Dynamic Island
            Positioned(
              top: topPadding + 4,
              left: 16,
              child: IslandIcon(
                image: 'assets/gau_bong.png',
                actionName: 'Nhớ Gấu',
                onTap: () => _sendMsg(actionText: 'Nhớ Gấu', sound: 'notification.mp3'),
              ),
            ),
            Positioned(
              top: topPadding + 4,
              right: 16,
              child: IslandIcon(
                image: 'assets/be_trang.png',
                actionName: 'Nhớ Bé Trắng',
                onTap: () => _sendMsg(actionText: 'Nhớ Bé Trắng', sound: 'notification.mp3'),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: isDesktop ? 40 : 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Header with Avatars
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AvatarWithStatus(
                            name: "Bé Trắng",
                            online: _isBeOnline,
                            color: Colors.pinkAccent,
                            imageAsset: 'assets/be_trang.png',
                          ),
                          const Spacer(),
                          Flexible(
                            flex: 3,
                            child: GlassContainer(
                              child: Column(
                                children: [
                                  const Text(
                                    "💖 KỶ NIỆM 💖",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getLoveDuration(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Text(
                                    "12/10/2025",
                                    style: TextStyle(color: Colors.pinkAccent, fontSize: 11),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "💬 Nhấn vào đây để nhắn ❤️",
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          AvatarWithStatus(
                            name: "Gấu bông",
                            online: _isGauOnline,
                            color: Colors.blueAccent,
                            imageAsset: 'assets/gau_bong.png',
                            showRemindIcon: isMeGau,
                            onRemind: _showBeReminderDialog,
                            onPin: _showGauReminderDialog,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Info tiles
                    InfoTile(
                      icon: Icons.favorite,
                      label: "Nhắn từ Gấu",
                      content: _beReminder,
                      color: Colors.pink,
                      onEdit: isMeGau ? _showBeReminderDialog : null,
                    ),
                    InfoTile(
                      icon: Icons.push_pin,
                      label: "Lời nhắc chung",
                      content: _currentReminder,
                      color: Colors.blue,
                      onEdit: isMeGau ? _showGauReminderDialog : null,
                    ),
                    InfoTile(
                      icon: Icons.card_giftcard,
                      label: "Gợi ý quà",
                      content: _currentWish,
                      color: Colors.orange,
                      onEdit: isMeGau ? _showWishDialog : null,
                    ),

                    // Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(children: [
                        Expanded(child: StatChip("😊 Hạnh phúc: $happyDays ngày", Colors.green)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: isMeGau ? _editSadDays : null,
                            child: StatChip("😢 Buồn: $_sadDays ngày", Colors.blueGrey, edit: isMeGau),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 12),

                    // Chat box
                    GlassContainer(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      padding: EdgeInsets.zero,
                      child: Column(children: [
                        if (_isPartnerTyping)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12, top: 4),
                              child: Text(
                                "${isMeGau ? "Bé Trắng" : "Gấu bông"} đang viết...",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 150,
                          child: StreamBuilder(
                            stream: _fb.listenRecentMessages(),
                            builder: (ctx, snap) {
                              if (!snap.hasData || snap.data!.snapshot.value == null) {
                                return const Center(
                                  child: Text(
                                    "Hãy nhắn gì đó...",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                );
                              }
                              final list = (snap.data!.snapshot.value as Map).values.toList()
                                ..sort((a, b) =>
                                    (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));
                              return ListView.builder(
                                controller: _scrollController,
                                itemCount: list.length,
                                itemBuilder: (c, i) {
                                  final msg = list[i];
                                  final isMe = msg['sender'] == _userName;
                                  return ChatBubble(
                                    sender: msg['sender'],
                                    text: msg['text'],
                                    timeStr: _formatTimestamp(msg['timestamp'] as int?),
                                    isMe: isMe,
                                    avatarAsset: msg['sender'].contains("Gấu")
                                        ? 'assets/gau_bong.png'
                                        : 'assets/be_trang.png',
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ]),
                    ),

                    // Actions collapsible
                    GestureDetector(
                      onTap: () => setState(() => _showActions = !_showActions),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _showActions
                              ? Colors.pinkAccent.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.pinkAccent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _showActions ? "💕 Thu gọn cảm xúc" : "💕 Mở bảng cảm xúc",
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            Icon(
                              _showActions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_showActions) ...[
                      CategoryTabs(
                        categories: categories,
                        selectedCategory: _selectedCategory,
                        onCategoryChanged: (key) => setState(() => _selectedCategory = key),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ActionGrid(
                          actions: actions.where((a) => a['c'] == _selectedCategory).toList(),
                          onActionTap: (act) => _sendMsg(
                            actionText: act['n'],
                            sound: act['s'],
                            actionData: act,
                          ),
                        ),
                      ),
                      QuickFlirtRow(
                        quickFlirts: quickFlirts,
                        onFlirtTap: _sendQuickFlirt,
                      ),
                    ],

                    // Input row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: AppTheme.inputDecoration,
                      child: Row(children: [
                        IconButton(
                          icon: const Icon(Icons.card_giftcard, color: Colors.white, size: 20),
                          onPressed: isMeGau ? _showGauGiftDialog : _showBeGiftOpen,
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month, color: Colors.white, size: 22),
                          onPressed: _showCalendarDialog,
                        ),
                        IconButton(
                          icon: const Icon(Icons.list_alt, color: Colors.greenAccent, size: 22),
                          onPressed: _showTodoDialog,
                        ),
                        IconButton(
                          icon: const Icon(Icons.water_drop, color: Colors.cyan, size: 22),
                          onPressed: _showWaterTimePicker,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _msgCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            textInputAction: TextInputAction.send,
                            onChanged: (v) {
                              _typingTimer?.cancel();
                              _fb.setTyping(_userName, v.isNotEmpty);
                              if (v.isNotEmpty) {
                                _typingTimer = Timer(const Duration(seconds: 2), () {
                                  _fb.setTyping(_userName, false);
                                });
                              }
                            },
                            onSubmitted: (_) => _sendMsg(),
                            decoration: const InputDecoration(
                              hintText: "Nhắn...",
                              hintStyle: TextStyle(color: Colors.white70, fontSize: 12),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 6),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.pinkAccent, size: 22),
                          onPressed: () => _sendMsg(),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Floating buttons
            Positioned(
              bottom: isDesktop ? 20 : 80,
              left: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: "lulu",
                    mini: true,
                    onPressed: _showLuluDialog,
                    backgroundColor: Colors.purpleAccent,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/lulu_icon.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.smart_toy, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: "menu",
                    mini: true,
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    backgroundColor: Colors.blueAccent,
                    child: const Icon(Icons.menu, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiCtrl,
                blastDirection: 1.57,
                colors: const [Colors.red, Colors.pink, Colors.purple, Colors.orange],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== DRAWER ==================
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE6F2), Color(0xFFFFB3D9)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.pinkAccent, Colors.redAccent]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    '💖 Love Station',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trạm Sạc Tình Yêu',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text('👤 $_userName', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
            _drawerItem(Icons.water_drop, "💧 Nhắc uống nước", () {
              Navigator.pop(context);
              _showWaterTimePicker();
            }),
            _drawerItem(Icons.calendar_today, "📅 Lịch sự kiện", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventsPage()),
              );
            }),
            _drawerItem(Icons.list_alt, "📝 Todo List", () {
              Navigator.pop(context);
              _showTodoDialog();
            }),
            _drawerItem(Icons.restaurant, "🍜 Món ăn yêu thích", () {
              Navigator.pop(context);
              _showFavoriteFoodsDialog();
            }),
            _drawerItem(Icons.location_on, "📍 Bản đồ hẹn hò", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DatingMapPage()),
              );
            }),
            _drawerItem(Icons.games, "🎮 Game cặp đôi", () {
              Navigator.pop(context);
              _startCoupleGame();
            }),
            _drawerItem(Icons.email, "💌 Hộp thư tương lai", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeCapsulePage()));
            }),
            _drawerItem(Icons.savings, "🐷 Heo đất tình yêu", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PiggyBankPage()));
            }),
            _drawerItem(Icons.lightbulb, "💡 Góp ý tính năng", () {
              Navigator.pop(context);
              _sendFeatureRequest();
            }),
            const Divider(),
            _drawerItem(Icons.settings, "⚙️ Cài đặt", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSettingsPage()));
            }),
            _drawerItem(Icons.info, "Về ứng dụng", () {
              Navigator.pop(context);
              _showAboutDialog();
            }),
            _drawerItem(Icons.image, "🖼️ Đổi ảnh nền", () {
              Navigator.pop(context);
              _showBackgroundChooser();
            }),
            const Divider(),
            _drawerItem(Icons.logout, "Đổi tài khoản", () {
              Navigator.pop(context);
              _confirmLogout();
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.pinkAccent),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFE6F2), Color(0xFFFFB3D9), Color(0xFFFF80BF)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.pinkAccent, Colors.redAccent],
                          ),
                          boxShadow: [BoxShadow(color: Colors.pink.withValues(alpha: 0.4), blurRadius: 12)],
                        ),
                        child: const Icon(Icons.favorite, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "💖 Love Station v2.0 💖",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF880E4F),
                          shadows: [Shadow(color: Colors.white, blurRadius: 8)],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Trạm Sạc Tình Yêu",
                        style: TextStyle(color: Color(0xFFAD1457), fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // App Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.pink.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow("🚀", "Phiên bản", "Love Station v2.0"),
                      _infoRow("📱", "Tên ứng dụng", "Love Station – Trạm Sạc Tình Yêu"),
                      _infoRow("👨‍💻", "Đơn vị phát triển", "Design by WMQ"),
                      _infoRow("✅", "Tình trạng", "Hoạt động ổn định (Đầy ắp yêu thương 100%)"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.pink.withValues(alpha: 0.2)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🌸 Trạm Sạc Tình Yêu – Nơi Hạnh Phúc Bắt Đầu",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF880E4F),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Chào mừng Bé Trắng của anh đến với không gian nâng cấp hoàn toàn mới của Love Station v2.0! Đây không chỉ là một ứng dụng di động, mà là cuốn nhật ký sống động, là chiếc hộp lưu giữ từng khoảnh khắc ngọt ngào, từng kỷ niệm vô giá mà chúng mình cùng nhau trải qua.\n\n"
                        "Mỗi tính năng trong phiên bản 2.0 này đều được thiết kế và gửi gắm bằng cả trái tim, với mong muốn mang lại sự gắn kết tuyệt vời nhất cho hai đứa:",
                        style: TextStyle(color: Color(0xFF4A0024), fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Features
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _featureRow("💧", "Nhắc uống nước: Để anh luôn được chăm sóc sức khỏe cho Bé Trắng mỗi ngày."),
                      const SizedBox(height: 4),
                      _featureRow("📅", "Lịch sự kiện & Todo List: Nơi ghi dấu những ngày kỷ niệm đặc biệt và cùng nhau lên kế hoạch cho tương lai của chúng mình."),
                      const SizedBox(height: 4),
                      _featureRow("🍲", "Món ăn yêu thích & 🎵 Thư viện nhạc: Giai điệu chúng ta cùng say đắm, những món ngon chúng ta cùng muốn thử."),
                      const SizedBox(height: 4),
                      _featureRow("🎮", "Game cặp đôi: Những phút giây giải trí, gắn kết thêm tiếng cười và niềm vui."),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Love letter
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "✨ Lời Chúc Đặc Biệt Gửi Đến Bé Trắng",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\"Gửi Bé Trắng thân yêu của anh,\n\n"
                        "Phiên bản Love Station 2.0 này là món quà đặc biệt được tạo ra để dành riêng cho em. Chúc em yêu luôn tìm thấy thật nhiều niềm vui, sự bất ngờ và ngập tràn hạnh phúc mỗi khi truy cập vào app.\n\n"
                        "Hãy cùng anh Gấu bông tiếp tục hành trình nuôi dưỡng tình yêu này thật bền chặt. Và đừng quên, bên cạnh chúng mình còn có sự đồng hành của LULU AI – người trợ lý thông minh luôn sẵn sàng lắng nghe, thấu hiểu và cùng chúng mình dệt nên những câu chuyện tình yêu thật đẹp nhé!\n\n"
                        "Anh yêu em nhiều hơn ngày hôm qua! 🐻❤️👧\"",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Footer
                Center(
                  child: Text(
                    "Love Station v2.0 - Cùng Bé Trắng và Gấu bông viết tiếp chương nhạc hạnh phúc! 💕",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("💕 Đóng"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$emoji ", style: const TextStyle(fontSize: 14)),
          Text("$label: ", style: const TextStyle(color: Color(0xFF6A0030), fontSize: 11, fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF4A0024), fontSize: 11))),
        ],
      ),
    );
  }

  Widget _featureRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF4A0024), fontSize: 10, height: 1.3))),
      ],
    );
  }
}