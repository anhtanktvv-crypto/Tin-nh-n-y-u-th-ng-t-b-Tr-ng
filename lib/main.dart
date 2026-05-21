import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'html_stub.dart' if (dart.library.html) 'dart:html' as html;
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'ui_components.dart';
import 'mochi_ai.dart';

// New: Better web responsive utilities
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile, tablet, desktop;
  const ResponsiveLayout({required this.mobile, required this.tablet, required this.desktop, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) return mobile;
      else if (constraints.maxWidth < 1200) return tablet;
      else return desktop;
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LoveStationApp());
}

class LoveStationApp extends StatelessWidget {
  const LoveStationApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Love Station - Bé Ngoan 💖',
        theme: CuteTheme.light,
        home: const LovePage(),
        debugShowCheckedModeBanner: false,
      );
}

// ================== BUBBLE ANIMATION CLASS ==================
class Bubble {
  final int id;
  final Offset position;
  final String emoji;
  Bubble({required this.id, required this.position, required this.emoji});
}

// ================== TRANG CHÍNH VỚI BOTTOM NAVIGATION ==================
class LovePage extends StatefulWidget {
  const LovePage({super.key});
  @override
  State<LovePage> createState() => _LovePageState();
}

class _LovePageState extends State<LovePage> with TickerProviderStateMixin {
  // -------------------- CONTROLLERS & FIREBASE --------------------
  final ScrollController _scrollController = ScrollController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _msgCtrl = TextEditingController();
  final TextEditingController _featureCtrl = TextEditingController();
  final TextEditingController _eventTitleCtrl = TextEditingController();
  final TextEditingController _eventDescCtrl = TextEditingController();
  final TextEditingController _mochiInputCtrl = TextEditingController();
  final TextEditingController _luluInputCtrl = TextEditingController();
  DateTime _selectedEventDate = DateTime.now();
  TimeOfDay _selectedEventTime = TimeOfDay.now();

  // -------------------- AUDIO --------------------
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _notiPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _clickPlayer = AudioPlayer();
  late ConfettiController _confettiCtrl;

  // 🤖 -------------------- MOCHI PET AI SYSTEM --------------------
  late MochiPet mochiPet;
  late LuluAI luluAI;

  // -------------------- USER DATA --------------------
  String _userName = "";
  String _beReminder = "💖 Đang chờ Gấu dặn dò...";
  String _currentReminder = "📌 Chưa có lời nhắc chung";
  String _currentWish = "🎁 Gợi ý quà yêu";
  String _mochiStatus = "Đang kết nối";
  bool _isGauOnline = false, _isBeOnline = false;
  String _giftContent = "";
  bool _isGiftAvailable = false;
  final DateTime _loveStart = DateTime(2023, 10, 17);
  int _sadDays = 0;

  // -------------------- UI STATE --------------------
  bool _showBubble = false;
  String _bubbleText = "", _bubbleImage = "", _bubbleEmoji = "";
  Timer? _bubbleTimer;
  bool _userInteracted = false;
  final List<StreamSubscription> _subscriptions = [];
  bool _isPartnerTyping = false;
  Timer? _typingTimer;
  List<Bubble> bubbles = [];
  final Random _rand = Random();
  Timer? _bubbleTimerGen;
  Timer? _waterReminderTimer;
  bool _waterReminderEnabled = false;
  int _waterHour = 9, _waterMinute = 0;
  final String _waterEnabledKey = "waterEnabled", _waterHourKey = "waterHour", _waterMinuteKey = "waterMinute";
  bool _emergencySent = false;

  // -------------------- MOCHI AI RESPONSE --------------------
  String _mochiAnswer = "💬 Hãy hỏi Mochi bất cứ điều gì! (VD: yêu, nhớ, ăn gì, nhạc...)";
  bool _isMochiThinking = false;

  // -------------------- LULU AI CHAT --------------------
  String _luluAnswer = "Chào LuLu! Hỏi LuLu gì đi nhé...";
  final List<Map<String, String>> _luluHistory = [];

  // -------------------- MOCHI POPUP --------------------
  OverlayEntry? _mochiPopupOverlay;
  Timer? _popupTimer;
  final List<String> _randomCuteMessages = [
    "Ôm nhau cái nà 😤",
    "Hôm nay yêu nhiều hơn hôm qua 2% 😳",
    "Mochi phát hiện nhớ nhau 😏",
    "Anh nhớ uống nước nha 😳",
    "Hôn bé một cái đi mà 🥺",
    "Có người đang thương ai đó quá 😏",
    "Hai bạn im lặng lâu quá, Mochi rảnh nè 🌷",
    "Nhớ gọi video cho nhau nha 📹",
    "Mochi thấy tim hồng đang bay đầy trời 💘",
    "Hôm nay trời đẹp, thích hợp nắm tay nhau ☀️",
  ];
  String _currentMochiPopupMessage = "Mochi: Ôm nhau cái nà 😤";
  bool _isPopupShowing = false;

  // -------------------- MOOD DETECTION --------------------
  int _happinessPercent = 98;
  String _missingLevel = "Cao";
  String _moodText = "Yêu nhiều";
  String _dailyMission = "Hôn bé 3 cái";
  String _aiSuggestion = "Đi ăn pizza tối nay nha 🍕";
  String _memoryRecap = "💞 1 năm trước: Hai người đã thức tới 2h sáng chat 😭";
  DateTime? _lastMessageTime;
  Timer? _moodCheckTimer;

  // -------------------- CÁC DANH SÁCH TÍNH NĂNG (gom vào settings) --------------------
  final List<Map<String, String>> quickFlirts = [
    {"emoji": "❤️", "text": "Nhớ em"},
    {"emoji": "😘", "text": "Hôn cái nào"},
    {"emoji": "💖", "text": "Yêu nhiều"},
    {"emoji": "🫂", "text": "Ôm cái nào"},
  ];
  final List<Map<String, String>> songs = [
    {"name": "Ai Ngoài Anh - VSTRA", "file": "AiNgoaiAnh.mp3"},
    {"name": "Dạo Bước Hong Kong 1999", "file": "DaoBuocHongKong1999.mp3"},
    {"name": "Thế Giới Của Anh", "file": "the_gioi_cua_anh.mp3"},
    {"name": "Bún bò", "file": "bunbo.mp3"},
    {"name": "Lục trà chanh", "file": "luc_tra.mp3"},
  ];

  int _currentSongIndex = -1;
  bool _isPlaying = false;
  bool _musicExpanded = false;
  final GlobalKey _beAvatarKey = GlobalKey();
  final GlobalKey _gauAvatarKey = GlobalKey();

  // -------------------- HELPERS --------------------
  int get totalDays => DateTime.now().difference(_loveStart).inDays;
  int get happyDays => (totalDays - _sadDays).clamp(0, totalDays);
  String get loveDuration {
    final diff = DateTime.now().difference(_loveStart);
    return "${diff.inDays} ngày, ${diff.inHours % 24} giờ ${diff.inMinutes % 60} phút";
  }

  // -------------------- AI MOCHI LOGIC --------------------
  Future<void> _askMochi(String question) async {
    if (_isMochiThinking) return;
    setState(() {
      _isMochiThinking = true;
      _mochiAnswer = "Mochi đang suy nghĩ... ⏳";
    });
    await Future.delayed(Duration(milliseconds: 500 + _rand.nextInt(1000)));

    // Route to LuLu if user asks for LuLu or mentions anh Tấn / chị Quyên
    final lower = question.toLowerCase();
    if (lower.contains('lulu') || lower.contains('lu lu') || lower.contains('anh tấn') || lower.contains('chị quyên') || lower.contains('chị quyen')) {
      final lresp = luluAI.askLulu(question);
      // handle play command
      if (lresp.command?.action == 'play' && lresp.command?.file != null) {
        _playSongByFile(lresp.command!.file!);
      }
      if (mounted) {
        setState(() {
          _mochiAnswer = lresp.text;
          _isMochiThinking = false;
        });
      }
      return;
    }

    MochiResponse response = mochiPet.askMochi(question);
    if (mounted) {
      setState(() {
        _mochiAnswer = response.text;
        _isMochiThinking = false;
      });
    }
  }

  // 🎮 Play mini game with Mochi
  void _playMochiGame(String gameId) {
    String result = mochiPet.playGame(gameId);
    if (mounted) {
      setState(() {
        _mochiAnswer = result;
        mochiPet.play(); // Mochi gains exp
      });
      _showSnackbar("Mochi gained 10 exp! Level: ${mochiPet.petLevel} 🎮");
    }
  }

  // 📖 Mochi tells a story
  void _mochiTellStory(String storyType) {
    String story = mochiPet.tellStory(storyType);
    if (mounted) {
      setState(() {
        _mochiAnswer = story;
      });
      _showMochiPopup("Mochi: $story");
    }
  }

  // 🎀 Feed Mochi
  void _feedMochi() {
    mochiPet.feed();
    if (mounted) {
      setState(() {
        _mochiAnswer = "Mochi: Nom nom nom! Cảm ơn đã cho Mochi ăn 🍜 HP: ${mochiPet.happiness}% ⚡${mochiPet.energy}%";
      });
      _showSnackbar("Mochi vui vẻ!");
    }
  }

  void _showMochiDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Container(
              decoration: BoxDecoration(
                color: CuteColors.background,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8, maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Text("🤖 Mochi - Thú cưng AI dễ thương", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18)),
                  Text(mochiPet.getStatus(), style: const TextStyle(fontSize: 12, color: CuteColors.textLight)),
                  const SizedBox(height: 12),

                  // Pet care buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CuteButton(label: "🍜 Cho ăn", onTap: () { _feedMochi(); setDialogState(() {}); }, isSmall: true),
                      CuteButton(label: "🎮 Chơi", onTap: () { mochiPet.play(); setDialogState(() {}); }, isSmall: true),
                      CuteButton(label: "😴 Nghỉ ngơi", onTap: () { mochiPet.rest(); setDialogState(() {}); }, isSmall: true),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Input field
                  TextField(
                    controller: _mochiInputCtrl,
                    decoration: InputDecoration(
                      hintText: "Hỏi Mochi (yêu, nhớ, ăn, nhạc...)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: CuteColors.accent,
                      prefixIcon: const Icon(Icons.chat_bubble, color: CuteColors.primary),
                    ),
                    onSubmitted: (value) async {
                      if (value.trim().isEmpty) return;
                      _mochiInputCtrl.clear();
                      await _askMochi(value);
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 12),

                  // Response display
                  Flexible(
                    child: SingleChildScrollView(
                      child: _isMochiThinking
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                  SizedBox(height: 12),
                                  Text("Mochi đang suy nghĩ...", style: TextStyle(fontStyle: FontStyle.italic)),
                                ],
                              ),
                            )
                          : CuteCard(
                              bgColor: CuteColors.accent,
                              child: Text(_mochiAnswer, style: const TextStyle(fontSize: 14, color: CuteColors.primary)),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mini games
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: CuteColors.accent, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("🎮 Trò chơi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            CuteButton(
                              label: "Đoán số",
                              onTap: () { _playMochiGame("guess"); setDialogState(() {}); },
                              isSmall: true,
                            ),
                            CuteButton(
                              label: "Trivia",
                              onTap: () { _playMochiGame("trivia"); setDialogState(() {}); },
                              isSmall: true,
                            ),
                            CuteButton(
                              label: "Kỉ niệm",
                              onTap: () { _playMochiGame("memory"); setDialogState(() {}); },
                              isSmall: true,
                            ),
                            CuteButton(
                              label: "Quiz",
                              onTap: () { _playMochiGame("quiz"); setDialogState(() {}); },
                              isSmall: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Story buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CuteButton(
                        label: "😄 Chuyện hài hước",
                        onTap: () { _mochiTellStory("funny"); setDialogState(() {}); },
                        isSmall: true,
                      ),
                      CuteButton(
                        label: "💕 Chuyện lãng mạn",
                        onTap: () { _mochiTellStory("romantic"); setDialogState(() {}); },
                        isSmall: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Close button
                  CuteButton(label: "👋 Tạm biệt Mochi", onTap: () { _mochiInputCtrl.clear(); Navigator.pop(ctx); }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------- AI MOCHI POPUP (TỰ HIỆN) --------------------
  void _showMochiPopup(String message) {
    if (_isPopupShowing) return;
    _isPopupShowing = true;
    _currentMochiPopupMessage = message;
    _mochiPopupOverlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 24,
        left: 16,
        right: 16,
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(begin: const Offset(-1.0, 0), end: const Offset(0, 0)),
          duration: const Duration(milliseconds: 400),
          builder: (context, offset, child) => FractionalTranslation(
            translation: offset,
            child: Opacity(
              opacity: 1.0,
              child: child,
            ),
          ),
          child: GestureDetector(
            onTap: () => _hideMochiPopup(),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🤖", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _currentMochiPopupMessage,
                      style: const TextStyle(color: Color(0xFFFF7DAE), fontWeight: FontWeight.w500, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.close, color: Colors.grey, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_mochiPopupOverlay!);
    Future.delayed(const Duration(seconds: 4), () {
      if (_isPopupShowing) _hideMochiPopup();
    });
  }

  void _hideMochiPopup() {
    if (_mochiPopupOverlay != null && _isPopupShowing) {
      _mochiPopupOverlay!.remove();
      _mochiPopupOverlay = null;
      _isPopupShowing = false;
    }
  }

  void _schedulePopup() {
    _popupTimer?.cancel();
    _popupTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (_isPopupShowing) return;
      String randomMessage = _randomCuteMessages[_rand.nextInt(_randomCuteMessages.length)];
      _showMochiPopup("Mochi: $randomMessage");
    });
  }

  // -------------------- MOOD DETECTION & DAILY MISSION --------------------
  void _updateMoodAndMission() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour >= 23 || hour <= 4) {
      _missingLevel = "Rất cao";
      _moodText = "Nhớ nhau nhiều";
    } else if (hour >= 5 && hour <= 10) {
      _moodText = "Buổi sáng yêu thương";
    } else {
      _moodText = "Yêu nhiều";
    }
    // Random happiness percent between 85 and 100
    _happinessPercent = 85 + _rand.nextInt(16);
    List<String> missions = [
      "Hôn bé 3 cái",
      "Gửi ảnh selfie cho nhau",
      "Nói 'Anh yêu em' 5 lần",
      "Gọi video 10 phút",
      "Viết thư tay (chụp ảnh gửi)",
    ];
    _dailyMission = missions[_rand.nextInt(missions.length)];
    List<String> suggestions = [
      "Đi ăn pizza tối nay nha 🍕",
      "Xem phim 'Cô gái năm ấy' cùng nhau 🎬",
      "Gửi voice message đi nào 🎤",
      "Tối nay đi dạo phố không? 🌃",
    ];
    _aiSuggestion = suggestions[_rand.nextInt(suggestions.length)];
    // Lấy sự kiện cũ nhất từ Firebase để recap
    _dbRef.child('events').limitToLast(1).once().then((event) {
      if (event.snapshot.value != null) {
        final eventsMap = event.snapshot.value as Map?;
        if (eventsMap != null && eventsMap.isNotEmpty) {
          final firstEvent = eventsMap.values.first;
          setState(() {
            _memoryRecap = "💞 ${firstEvent['title'] ?? 'Kỷ niệm'} - ${firstEvent['datetime']?.toString().substring(0,10) ?? 'hôm đó'}";
          });
        }
      }
    });
    setState(() {});
  }

  // -------------------- CÁC HÀM GỬI NHẮN, ACTION --------------------
  void _sendMsg({String? actionText, String? sound, Map? actionData}) async {
    if (!_userInteracted) setState(() => _userInteracted = true);
    String text = actionText ?? _msgCtrl.text.trim();
    if (text.isEmpty) return;
    await _dbRef.child('messages').push().set({
      "sender": _userName,
      "text": text,
      "timestamp": ServerValue.timestamp,
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
      } catch (e) {}
    }
    _scrollToBottom();
    await _clickPlayer.play(AssetSource('music/notification.mp3'));
    _lastMessageTime = DateTime.now();
  }

  void _sendQuickFlirt(String text) => _sendMsg(actionText: text);
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  // -------------------- LỜI NHẮC, QUÀ, CALENDAR, WATER, EMERGENCY, FEATURE --------------------
  void _showBeReminderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("💌 Dặn dò Bé Trắng"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Nhập lời nhắn...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) await _dbRef.child('be_reminder').set(controller.text);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Gửi"),
          ),
        ],
      ),
    );
  }

  void _showGauReminderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("📌 Lời nhắc chung"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Nhập lời nhắc...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) await _dbRef.child('reminder').set(controller.text);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Gửi"),
          ),
        ],
      ),
    );
  }

  void _showWishDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🎁 Gợi ý quà yêu"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Bé thích quà gì?")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) await _dbRef.child('currentWish').set(controller.text);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Gửi"),
          ),
        ],
      ),
    );
  }

  void _showGauGiftDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🎁 Gửi quà cho Bé"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Quà gì? Nhập nội dung...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _dbRef.child('gift').set({'available': true, 'content': controller.text, 'opened': false});
                if (mounted) _showSnackbar("Đã gửi quà! Bé sẽ nhận được.");
              }
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Gửi"),
          ),
        ],
      ),
    );
  }

  void _showBeGiftOpen() {
    if (_isGiftAvailable && _giftContent.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("🎁 Bé có quà!"),
          content: Text(_giftContent),
          actions: [
            TextButton(
              onPressed: () async {
                await _dbRef.child('gift').set({'available': false, 'content': '', 'opened': true});
                _showSnackbar("Cảm ơn Gấu nhé! 💖");
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text("Mở quà"),
            ),
          ],
        ),
      );
    } else {
      _showSnackbar("Chưa có quà mới nào!");
    }
  }

  void _editSadDays() {
    final controller = TextEditingController(text: _sadDays.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("😢 Ngày buồn"),
        content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Số ngày buồn")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              int? days = int.tryParse(controller.text);
              if (days != null) await _dbRef.child('sadDays').set(days);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _sendFeatureRequest() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("💡 Góp ý tính năng mới"),
        content: TextField(controller: _featureCtrl, maxLines: 3, decoration: const InputDecoration(hintText: "Nhập ý tưởng...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              final text = _featureCtrl.text.trim();
              if (text.isNotEmpty) {
                await _dbRef.child('featureRequests').push().set({
                  'content': text,
                  'sender': _userName,
                  'timestamp': ServerValue.timestamp,
                });
                _showNotification("💡 Góp ý mới", "$_userName vừa gửi: $text");
                _featureCtrl.clear();
                if (mounted) Navigator.pop(ctx);
                _showSnackbar("Cảm ơn! Góp ý đã được gửi.");
              }
            },
            child: const Text("Gửi"),
          ),
        ],
      ),
    );
  }

  void _sendEmergency() async {
    if (_emergencySent) return;
    setState(() => _emergencySent = true);
    await _dbRef.child('emergency').push().set({
      'sender': _userName,
      'timestamp': ServerValue.timestamp,
      'resolved': false,
    });
    _showNotification("🚨 KHẨN CẤP!", "$_userName cần sự giúp đỡ ngay lập tức! 🚨");
    _showSnackbar("Đã gửi tín hiệu khẩn cấp!");
    await _clickPlayer.play(AssetSource('music/emergency.mp3'));
    Future.delayed(const Duration(minutes: 2), () {
      if (mounted) setState(() => _emergencySent = false);
    });
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("📅 Thêm sự kiện"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _eventTitleCtrl, decoration: const InputDecoration(labelText: "Tên sự kiện")),
            TextField(controller: _eventDescCtrl, decoration: const InputDecoration(labelText: "Mô tả")),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text("Ngày: ${_selectedEventDate.day}/${_selectedEventDate.month}/${_selectedEventDate.year}")),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(context: ctx, firstDate: DateTime.now(), lastDate: DateTime(2030));
                  if (date != null) setState(() => _selectedEventDate = date);
                },
                child: const Text("Chọn ngày"),
              ),
            ]),
            Row(children: [
              Expanded(child: Text("Giờ: ${_selectedEventTime.hour}:${_selectedEventTime.minute}")),
              TextButton(
                onPressed: () async {
                  final time = await showTimePicker(context: ctx, initialTime: _selectedEventTime);
                  if (time != null) setState(() => _selectedEventTime = time);
                },
                child: const Text("Chọn giờ"),
              ),
            ]),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(onPressed: _addEventWithTime, child: const Text("Thêm")),
        ],
      ),
    );
  }

  Future<void> _addEventWithTime() async {
    if (_eventTitleCtrl.text.isEmpty) return;
    final dateTime = DateTime(
      _selectedEventDate.year, _selectedEventDate.month, _selectedEventDate.day,
      _selectedEventTime.hour, _selectedEventTime.minute,
    );
    await _dbRef.child('events').push().set({
      'title': _eventTitleCtrl.text,
      'desc': _eventDescCtrl.text,
      'datetime': dateTime.toIso8601String(),
      'date': _selectedEventDate.toIso8601String().split('T').first,
      'time': "${_selectedEventTime.hour.toString().padLeft(2,'0')}:${_selectedEventTime.minute.toString().padLeft(2,'0')}",
      'createdBy': _userName,
      'timestamp': ServerValue.timestamp,
    });
    _eventTitleCtrl.clear();
    _eventDescCtrl.clear();
    _showSnackbar("Đã thêm sự kiện");
    final partner = _userName.contains("Gấu") ? "Bé Trắng 1 tuổi rưỡi" : "Gấu bông 3 tuổi rưỡi";
    _showNotification("📅 Sự kiện mới", "$_userName vừa thêm sự kiện: ${_eventTitleCtrl.text}");
  }

  // -------------------- WATER REMINDER --------------------
  void _loadWaterPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterReminderEnabled = prefs.getBool(_waterEnabledKey) ?? false;
      _waterHour = prefs.getInt(_waterHourKey) ?? 9;
      _waterMinute = prefs.getInt(_waterMinuteKey) ?? 0;
    });
    if (_waterReminderEnabled) _scheduleWater();
  }

  void _scheduleWater() {
    _waterReminderTimer?.cancel();
    final now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, now.day, _waterHour, _waterMinute);
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));
    _waterReminderTimer = Timer(next.difference(now), () {
      _showNotification("💧 Nhắc uống nước", "Yêu ơi, đến giờ uống nước rồi! 🚰💖");
      _scheduleWater();
    });
  }

  void _showWaterTimePicker() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _waterHour, minute: _waterMinute));
    if (t != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _waterHour = t.hour;
        _waterMinute = t.minute;
      });
      await prefs.setInt(_waterHourKey, _waterHour);
      await prefs.setInt(_waterMinuteKey, _waterMinute);
      if (_waterReminderEnabled) _scheduleWater();
    }
  }

  // -------------------- NOTIFICATION (WEB) --------------------
  void _requestNotificationPermission() {
    if (html.Notification.supported) html.Notification.requestPermission();
  }

  void _showNotification(String title, String body) {
    if (html.Notification.supported && html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    }
    _showSnackbar("$title: $body");
  }

  void _showSnackbar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
    }
  }

  // -------------------- PRESENCE, TYPING, BUBBLES --------------------
  void _updatePresence(bool online) async {
    final now = DateTime.now().toIso8601String();
    await _dbRef.child('presence').child(_userName).set({'online': online, 'lastSeen': now});
    if (online) {
      await _dbRef.child('loginHistory').child(_userName).push().set({'loginTime': now, 'type': 'login'});
    } else {
      await _dbRef.child('loginHistory').child(_userName).push().set({'logoutTime': now, 'type': 'logout'});
    }
  }

  void _setTyping(bool typing) {
    _dbRef.child('typing').child(_userName).set(typing);
    if (typing) {
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 1), () => _setTyping(false));
    }
  }

  void _listenTyping() {
    String partner = _userName.contains("Gấu") ? "Bé Trắng 1 tuổi rưỡi" : "Gấu bông 3 tuổi rưỡi";
    _subscriptions.add(_dbRef.child('typing').child(partner).onValue.listen((event) {
      if (mounted) setState(() => _isPartnerTyping = event.snapshot.value == true);
    }));
  }

  void _startBubbleGenerator() {
    _bubbleTimerGen = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      final bubbleId = DateTime.now().millisecondsSinceEpoch + _rand.nextInt(1000);
      final bubble = Bubble(
        id: bubbleId,
        position: Offset(_rand.nextDouble() * (size.width - 50), size.height + 20),
        emoji: ["❤️", "😘", "🥺", "💖", "😊", "🧸", "🐰", "💕", "🎵", "💋"][_rand.nextInt(10)],
      );
      setState(() => bubbles.add(bubble));
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted) setState(() => bubbles.removeWhere((b) => b.id == bubbleId));
      });
    });
  }


  // -------------------- MUSIC PLAYER --------------------
  void _playRandomSong() {
    if (songs.isEmpty) return;
    final randomIndex = _rand.nextInt(songs.length);
    _playSong(randomIndex);
  }

  void _playSong(int index) async {
    if (index < 0 || index >= songs.length) return;
    try {
      final song = songs[index];
      await _musicPlayer.stop();
      await _musicPlayer.setSource(AssetSource('music/${song["file"]}'));
      await _musicPlayer.setVolume(1.0);
      await _musicPlayer.resume();
      setState(() {
        _currentSongIndex = index;
        _isPlaying = true;
      });
      _showSnackbar("🎵 Đang phát: ${song["name"]}");
    } catch (e) {
      _showSnackbar("❌ Không thể phát bài hát: $e");
    }
  }

  // Play song by filename (asset) or by matching name
  void _playSongByFile(String fileName) async {
    try {
      final f = fileName.split('/').last;
      final idx = songs.indexWhere((s) => (s['file']?.toString().toLowerCase() ?? '').contains(f.toLowerCase()) || (s['name']?.toString().toLowerCase() ?? '').contains(f.toLowerCase()));
      if (idx != -1) {
        _playSong(idx);
        return;
      }
      await _musicPlayer.stop();
      await _musicPlayer.setSource(AssetSource('music/$f'));
      await _musicPlayer.setVolume(1.0);
      await _musicPlayer.resume();
      setState(() {
        _currentSongIndex = -1;
        _isPlaying = true;
      });
    } catch (e) {
      _showSnackbar('❌ Không thể phát bài hát: $e');
    }
  }

  void _pauseMusic() async {
    if (!_isPlaying) return;
    await _musicPlayer.pause();
    setState(() => _isPlaying = false);
  }

  void _playNext() {
    if (songs.isEmpty) return;
    final next = (_currentSongIndex + 1) % songs.length;
    _playSong(next);
  }

  void _playPrev() {
    if (songs.isEmpty) return;
    final prev = (_currentSongIndex - 1) < 0 ? songs.length - 1 : (_currentSongIndex - 1);
    _playSong(prev);
  }

  void _stopMusic() async {
    await _musicPlayer.stop();
    setState(() {
      _isPlaying = false;
      _currentSongIndex = -1;
    });
  }

  void _sendLuluMessage(String text) {
    if (text.trim().isEmpty) return;
    final resp = luluAI.askLulu(text);
    setState(() {
      _luluHistory.add({'sender': 'Bạn', 'text': text});
      _luluHistory.add({'sender': 'LuLu', 'text': resp.text});
      _luluAnswer = resp.text;
    });
    if (resp.command != null) {
      switch (resp.command!.action) {
        case 'play':
          if (resp.command!.file != null) _playSongByFile(resp.command!.file!);
          break;
        case 'stop':
          _stopMusic();
          break;
        case 'pause':
          _pauseMusic();
          break;
        case 'next':
          _playNext();
          break;
        case 'prev':
          _playPrev();
          break;
      }
    }
  }

  void _showLuluChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (context, scrollCtrl) {
            return Container(
              decoration: BoxDecoration(
                color: CuteColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Row(children: [
                    ClipOval(child: Image.asset('assets/lulu.png', width: 40, height: 40)),
                    const SizedBox(width: 8),
                    const Text('LuLu — Trợ lý dễ thương', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ]),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Chào! Hỏi LuLu gì đi — có thể bật nhạc, gợi ý món ăn, hoặc quậy quậy 😄', style: TextStyle(color: CuteColors.textLight, fontSize: 13)),
                        ),
                        // Simple quick controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(onPressed: () => _playPrev(), icon: const Icon(Icons.skip_previous), label: const Text('Prev')),
                            ElevatedButton.icon(onPressed: () => _pauseMusic(), icon: const Icon(Icons.pause), label: const Text('Pause')),
                            ElevatedButton.icon(onPressed: () => _stopMusic(), icon: const Icon(Icons.stop), label: const Text('Stop')),
                            ElevatedButton.icon(onPressed: () => _playNext(), icon: const Icon(Icons.skip_next), label: const Text('Next')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // LuLu chat history
                        if (_luluHistory.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: const Text('LuLu sẵn sàng trò chuyện nha! Hỏi LuLu gì đi nào...', style: TextStyle(fontSize: 14)),
                          )
                        else
                          Column(
                            children: _luluHistory.map((msg) {
                              final isUser = msg['sender'] == 'Bạn';
                              return Align(
                                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isUser ? const Color(0xFFFFD6E7) : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(msg['text'] ?? '', style: TextStyle(color: isUser ? const Color(0xFFFF7DAE) : Colors.black87)),
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 12),
                        if (luluAI.memory.isNotEmpty)
                          Text('Ghi nhớ: ${luluAI.memory.values.take(6).join(" • ")}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                  // Input
                  SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _luluInputCtrl,
                            decoration: InputDecoration(hintText: 'Hỏi LuLu...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                            onSubmitted: (v) async {
                              if (v.trim().isEmpty) return;
                              _luluInputCtrl.clear();
                              _sendLuluMessage(v);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final v = _luluInputCtrl.text.trim();
                            if (v.isEmpty) return;
                            _luluInputCtrl.clear();
                            _sendLuluMessage(v);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7DAE)),
                          child: const Text('Gửi'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _pauseResume() async {
    if (_currentSongIndex == -1) {
      _playRandomSong();
      return;
    }
    if (_isPlaying) {
      await _musicPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _musicPlayer.resume();
      setState(() => _isPlaying = true);
    }
  }

  // -------------------- FIREBASE LISTENERS --------------------
  void _listenData() {
    _subscriptions.add(_dbRef.child('messages').onChildAdded.listen((event) async {
      if (!mounted) return;
      _scrollToBottom();
      final data = event.snapshot.value as Map?;
      if (data != null && _userName.isNotEmpty && data['sender'] != _userName && _userInteracted) {
        await _notiPlayer.play(AssetSource('music/notification.mp3'));
      }
    }));
    _subscriptions.add(_dbRef.child('be_reminder').onValue.listen((event) {
      if (event.snapshot.value != null && mounted) setState(() => _beReminder = event.snapshot.value.toString());
    }));
    _subscriptions.add(_dbRef.child('reminder').onValue.listen((event) {
      if (event.snapshot.value != null && mounted) setState(() => _currentReminder = event.snapshot.value.toString());
    }));
    _subscriptions.add(_dbRef.child('gift').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null && mounted) {
        setState(() {
          _isGiftAvailable = data['available'] ?? false;
          _giftContent = data['content'] ?? "";
        });
        if (data['available'] == true && data['opened'] == false && !_userName.contains("Gấu")) {
          _showSnackbar("🎁 Bé có quà mới từ Gấu!");
        }
      }
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
      if (event.snapshot.value != null && mounted) setState(() => _mochiStatus = event.snapshot.value.toString());
    }));
    _subscriptions.add(_dbRef.child('currentWish').onValue.listen((event) {
      if (event.snapshot.value != null && mounted) setState(() => _currentWish = event.snapshot.value.toString());
    }));
    _subscriptions.add(_dbRef.child('sadDays').onValue.listen((event) {
      if (event.snapshot.value != null && mounted) setState(() => _sadDays = (event.snapshot.value as int?) ?? 0);
    }));

    bool previousGauOnline = false;
    bool previousBeOnline = false;
    _subscriptions.add(_dbRef.child('presence').child('Gấu bông 3 tuổi rưỡi').child('online').onValue.listen((event) {
      final newValue = event.snapshot.value == true;
      if (previousGauOnline != newValue && newValue == true && _userName.contains("Bé")) {
        _showNotification("🔔 Gấu bông vừa vào app", "Hãy cùng trò chuyện nào 💖");
      }
      previousGauOnline = newValue;
      setState(() => _isGauOnline = newValue);
    }));
    _subscriptions.add(_dbRef.child('presence').child('Bé Trắng 1 tuổi rưỡi').child('online').onValue.listen((event) {
      final newValue = event.snapshot.value == true;
      if (previousBeOnline != newValue && newValue == true && _userName.contains("Gấu")) {
        _showNotification("🔔 Bé Trắng vừa vào app", "Chúc hai bạn có phút giây ngọt ngào 💖");
      }
      previousBeOnline = newValue;
      setState(() => _isBeOnline = newValue);
    }));
  }

  // -------------------- USER IDENTITY --------------------
  void _checkSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString('user_name');
    if (saved != null) {
      if (mounted) setState(() => _userName = saved);
      _setupPresence();
      _listenData();
      _listenTyping();
    } else {
      if (mounted) _showNameDialog();
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
          TextButton(onPressed: () => _setIdentity("Gấu bông 3 tuổi rưỡi"), child: const Text("🧸 Gấu bông")),
          TextButton(onPressed: () => _setIdentity("Bé Trắng 1 tuổi rưỡi"), child: const Text("🐰 Bé Trắng")),
        ],
      ),
    );
  }

  void _setIdentity(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    if (mounted) setState(() => _userName = name);
    if (mounted) Navigator.pop(context);
    _setupPresence();
    _listenData();
    _listenTyping();
  }

  void _setupPresence() {
    _subscriptions.add(_dbRef.child('.info/connected').onValue.listen((event) {
      if (event.snapshot.value == true) {
        _dbRef.child('presence').child(_userName).child('online').set(true);
        _dbRef.child('presence').child(_userName).child('online').onDisconnect().set(false);
        _updatePresence(true);
      }
    }));
  }

  // -------------------- WIDGETS UI --------------------
  Widget _buildHeroCouple() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 24,
        runSpacing: 16,
        children: [
          Column(
            children: [
              CircleAvatar(radius: 40, backgroundImage: AssetImage("assets/gau_bong.png")),
              const SizedBox(height: 4),
              Text("Gấu", style: TextStyle(color: Color(0xFFFF7DAE), fontWeight: FontWeight.bold)),
              if (_isGauOnline)
                Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
            ],
          ),
          Column(
            children: [
              CircleAvatar(radius: 40, backgroundImage: AssetImage("assets/be_trang.png")),
              const SizedBox(height: 4),
              Text("Bé Trắng", style: TextStyle(color: Color(0xFFFF7DAE), fontWeight: FontWeight.bold)),
              if (_isBeOnline)
                Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: isNarrow
              ? Column(
                  children: [
                    _buildStatCard("😊 Hạnh phúc", "$happyDays%", "🥺 Nhớ nhau: $_missingLevel", "❤️ Mood hôm nay: $_moodText"),
                    const SizedBox(height: 12),
                    _buildStatCard("🤖 Mochi", _aiSuggestion, "📌 Nhiệm vụ: $_dailyMission", ""),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildStatCard("😊 Hạnh phúc", "$happyDays%", "🥺 Nhớ nhau: $_missingLevel", "❤️ Mood hôm nay: $_moodText")),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard("🤖 Mochi", _aiSuggestion, "📌 Nhiệm vụ: $_dailyMission", "")),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, String line1, String line2) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD6E7)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF7DAE))),
          const SizedBox(height: 8),
          if (line1.isNotEmpty) Text(line1, style: const TextStyle(fontSize: 13)),
          if (line2.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(line2, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          _quickActionButton("❤️ Nhớ em", () => _sendQuickFlirt("Nhớ em")),
          _quickActionButton("😘 Hôn", () => _sendQuickFlirt("Hôn em")),
          _quickActionButton("🎤 Voice", () => _showSnackbar("Tính năng voice đang phát triển 📢")),
          _quickActionButton("🎁 Surprise", () => _sendRandomSuggestion()),
        ],
      ),
    );
  }

  Widget _quickActionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD6E7),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Text(text, style: TextStyle(color: Color(0xFFFF7DAE), fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ),
    );
  }

  void _sendRandomSuggestion() {
    final List<String> suggestions = [
      "🍜 Ăn phở bò tái", "🍕 Pizza hải sản", "🥗 Salad trộn", "🍣 Sushi", "🥘 Lẩu thái",
      "🎡 Công viên giải trí", "🎬 Rạp chiếu phim", "🛍️ Siêu thị mua sắm", "🏞️ Đi dạo hồ",
      "🎁 Mua túi xách", "🧸 Gấu bông lớn", "💍 Vòng tay đôi", "🎨 Tranh tô màu", "💐 Hoa hồng đỏ",
    ];
    final randomIndex = _rand.nextInt(suggestions.length);
    final suggestion = suggestions[randomIndex];
    _sendMsg(actionText: "💡 Gợi ý: $suggestion", sound: "notification.mp3");
  }

  Widget _buildChatSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFD6E7)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("💬 Tin nhắn gần đây", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7DAE))),
          ),
          Container(
            height: 320,
            child: StreamBuilder(
              stream: _dbRef.child('messages').limitToLast(20).onValue,
              builder: (ctx, snap) {
                if (!snap.hasData || snap.data!.snapshot.value == null) return const Center(child: Text("Chưa có tin nhắn nào"));
                final list = (snap.data!.snapshot.value as Map).values.toList()..sort((a,b)=>a['timestamp'].compareTo(b['timestamp']));
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: list.length,
                  itemBuilder: (c,i) {
                    final msg = list[i];
                    final me = msg['sender'] == _userName;
                    final timeStr = _formatTimestamp(msg['timestamp'] as int?);
                    return Align(
                      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: me ? const Color(0xFFFFD6E7) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: Offset(0,1))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(msg['text'], style: TextStyle(color: me ? Color(0xFFFF7DAE) : Colors.black87, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(timeStr, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Nhắn gì đó...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMsg(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF7DAE)),
                  onPressed: () => _sendMsg(),
                ),
                IconButton(
                  icon: const Icon(Icons.smart_toy, color: Color(0xFFFF7DAE)),
                  onPressed: _showMochiDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int? ts) {
    if (ts == null) return "";
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    return "${d.hour}:${d.minute.toString().padLeft(2,'0')}";
  }

  // -------------------- CÁC TAB --------------------
  int _selectedIndex = 0;
  final List<Widget> _pages = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildMemoriesTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("📸 Khoảnh khắc đẹp", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF7DAE))),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.memory, size: 48, color: Color(0xFFFF7DAE)),
                  const SizedBox(height: 8),
                  Text(_memoryRecap, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showCalendarDialog(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7DAE), foregroundColor: Colors.white),
            child: const Text("Xem lịch sự kiện"),
          ),
          const SizedBox(height: 16),
          StreamBuilder(
            stream: _dbRef.child('events').limitToLast(10).onValue,
            builder: (ctx, snap) {
              if (!snap.hasData || snap.data!.snapshot.value == null) {
                return const Text("Chưa có sự kiện nào");
              }
              final events = (snap.data!.snapshot.value as Map).values.toList();
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (ctx,i) => ListTile(
                  leading: const Icon(Icons.event, color: Color(0xFFFF7DAE)),
                  title: Text(events[i]['title'] ?? ""),
                  subtitle: Text(events[i]['datetime']?.toString().substring(0,16) ?? ""),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMochiTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🤖 Trò chuyện với Mochi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF7DAE))),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showMochiDialog,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7DAE), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: const Text("Mở hộp thoại Mochi"),
          ),
          const SizedBox(height: 30),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("📌 Nhiệm vụ hôm nay", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_dailyMission, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuluTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                ClipOval(child: Image.asset('assets/lulu.png', width: 46, height: 46)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('LuLu AI Chat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF7DAE))),
                      SizedBox(height: 4),
                      Text('Nói chuyện với LuLu, bật nhạc, gợi ý món ăn, hoặc quậy quậy!', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(onPressed: _playPrev, icon: const Icon(Icons.skip_previous), label: const Text('Prev'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7DAE))),
                ElevatedButton.icon(onPressed: _pauseMusic, icon: const Icon(Icons.pause), label: const Text('Pause'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7DAE))),
                ElevatedButton.icon(onPressed: _stopMusic, icon: const Icon(Icons.stop), label: const Text('Stop'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7DAE))),
                ElevatedButton.icon(onPressed: _playNext, icon: const Icon(Icons.skip_next), label: const Text('Next'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7DAE))),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(24)),
                child: _luluHistory.isEmpty
                    ? const Center(child: Text('LuLu sẵn sàng trò chuyện nè!', style: TextStyle(color: Colors.black54)))
                    : ListView.builder(
                        itemCount: _luluHistory.length,
                        itemBuilder: (ctx, index) {
                          final item = _luluHistory[index];
                          final isUser = item['sender'] == 'Bạn';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isUser ? const Color(0xFFFFD6E7) : const Color(0xFFF6F6F6),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(item['text'] ?? '', style: TextStyle(color: isUser ? const Color(0xFFFF7DAE) : Colors.black87)),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),
            if (luluAI.memory.isNotEmpty)
              Text('Ghi nhớ: ${luluAI.memory.values.take(6).join(" • ")}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _luluInputCtrl,
                    decoration: InputDecoration(
                      hintText: 'Hỏi LuLu...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isEmpty) return;
                      _luluInputCtrl.clear();
                      _sendLuluMessage(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final value = _luluInputCtrl.text.trim();
                    if (value.isEmpty) return;
                    _luluInputCtrl.clear();
                    _sendLuluMessage(value);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7DAE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                  child: const Text('Gửi'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      children: [
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.water_drop, color: Color(0xFFFF7DAE)),
          title: const Text("Nhắc uống nước"),
          trailing: Switch(
            value: _waterReminderEnabled,
            onChanged: (v) async {
              setState(() => _waterReminderEnabled = v);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(_waterEnabledKey, v);
              if (v) _scheduleWater();
              else _waterReminderTimer?.cancel();
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.alarm, color: Color(0xFFFF7DAE)),
          title: const Text("Chọn giờ nhắc nước"),
          onTap: _showWaterTimePicker,
        ),
        ListTile(
          leading: const Icon(Icons.card_giftcard, color: Color(0xFFFF7DAE)),
          title: const Text("Gợi ý quà yêu"),
          onTap: _showWishDialog,
        ),
        ListTile(
          leading: const Icon(Icons.warning_amber, color: Color(0xFFFF7DAE)),
          title: const Text("Gửi tín hiệu khẩn cấp"),
          onTap: _sendEmergency,
        ),
        ListTile(
          leading: const Icon(Icons.lightbulb, color: Color(0xFFFF7DAE)),
          title: const Text("Góp ý tính năng"),
          onTap: _sendFeatureRequest,
        ),
        ListTile(
          leading: const Icon(Icons.edit_calendar, color: Color(0xFFFF7DAE)),
          title: const Text("Thêm sự kiện"),
          onTap: _showCalendarDialog,
        ),
        ListTile(
          leading: const Icon(Icons.favorite, color: Color(0xFFFF7DAE)),
          title: const Text("Lời nhắc chung"),
          onTap: _showGauReminderDialog,
        ),
        ListTile(
          leading: const Icon(Icons.message, color: Color(0xFFFF7DAE)),
          title: const Text("Dặn dò Bé Trắng"),
          onTap: _showBeReminderDialog,
        ),
        ListTile(
          leading: const Icon(Icons.sentiment_dissatisfied, color: Color(0xFFFF7DAE)),
          title: const Text("Chỉnh ngày buồn"),
          onTap: _editSadDays,
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text("Đăng xuất"),
          onTap: () async {
            await _dbRef.child('presence').child(_userName).child('online').set(false);
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('user_name');
            if (mounted) _showNameDialog();
          },
        ),
        const SizedBox(height: 30),
        const Center(child: Text("Love Station - Bé Ngoan", style: TextStyle(color: Colors.grey))),
      ],
    );
  }

  // -------------------- BUILD CHÍNH --------------------
  @override
  Widget build(BuildContext context) {
    _pages.clear();
    _pages.add(
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Nền blur glass
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/background.png"), fit: BoxFit.cover),
              ),
            ),
            Container(color: Colors.white.withValues(alpha: 0.2)),
            // Nội dung chính
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeroCouple(),
                    _buildSmartCards(),
                    _buildQuickActions(),
                    _buildChatSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // Music player mini
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  if (_currentSongIndex == -1) _playRandomSong();
                  else _pauseResume();
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Color(0xFFFF7DAE)),
                ),
              ),
            ),
                    // LuLu quick-open button (tràn viền icon)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: _showLuluChat,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          child: ClipOval(
                            child: Image.asset('assets/lulu.png', fit: BoxFit.cover, width: 56, height: 56),
                          ),
                        ),
                      ),
                    ),
            // Bubbles
            ...bubbles.map((b) => Positioned(
              left: b.position.dx,
              top: b.position.dy,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: -MediaQuery.of(context).size.height - 100),
                duration: const Duration(seconds: 8),
                builder: (ctx, val, _) => Transform.translate(
                  offset: Offset(0, val),
                  child: Opacity(opacity: (1 - (-val / MediaQuery.of(context).size.height)).clamp(0.0, 1.0), child: Text(b.emoji, style: const TextStyle(fontSize: 28))),
                ),
              ),
            )),
            // Action bubble
            if (_showBubble)
              Positioned(
                top: 120,
                left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Color(0xFFFF7DAE), borderRadius: BorderRadius.circular(30)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Image.asset('assets/$_bubbleImage', width: 30, height: 30, errorBuilder: (c,e,s) => Text(_bubbleEmoji, style: const TextStyle(fontSize: 24))),
                      const SizedBox(width: 8),
                      Text("$_bubbleText $_bubbleEmoji", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    _pages.add(_buildMemoriesTab());
    _pages.add(_buildMochiTab());
    _pages.add(_buildLuluTab());
    _pages.add(_buildSettingsTab());

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFFF7DAE),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.memory), label: "Memories"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "Mochi"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "LuLu"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 🤖 Initialize Mochi Pet
    mochiPet = MochiPet();
    luluAI = LuluAI();
    luluAI.loadMemory().then((_) {
      if (mounted) setState(() {});
    });
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 5));
    _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    _checkSavedUser();
    _startBubbleGenerator();
    _loadWaterPrefs();
    _requestNotificationPermission();
    _subscriptions.add(_musicPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    }));
    _updateMoodAndMission();
    _schedulePopup();
    // Hiện popup chào mừng sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _showMochiPopup("Mochi: Hôm nay hai bạn thế nào? 💖");
    });
    // Mỗi 5 phút cập nhật mood
    _moodCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _updateMoodAndMission();
    });
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _msgCtrl.dispose();
    _featureCtrl.dispose();
    _eventTitleCtrl.dispose();
    _eventDescCtrl.dispose();
    _mochiInputCtrl.dispose();
    _luluInputCtrl.dispose();
    _audioPlayer.dispose();
    _notiPlayer.dispose();
    _musicPlayer.dispose();
    _clickPlayer.dispose();
    _scrollController.dispose();
    _bubbleTimer?.cancel();
    _bubbleTimerGen?.cancel();
    _typingTimer?.cancel();
    _waterReminderTimer?.cancel();
    _popupTimer?.cancel();
    _moodCheckTimer?.cancel();
    _hideMochiPopup();
    for (var sub in _subscriptions) sub.cancel();
    super.dispose();
  }
}
