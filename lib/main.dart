import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart'; // Thư viện dùng để Rung (Haptic)

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const LovePage(),
    );
  }
}

class LovePage extends StatefulWidget {
  const LovePage({super.key});
  @override
  _LovePageState createState() => _LovePageState();
}

class _LovePageState extends State<LovePage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  bool _isSending = false;
  
  // LINK SCRIPT MỚI NHẤT CỦA BẠN (ĐÃ CẬP NHẬT)
  final String googleUrl = "https://script.google.com/macros/s/AKfycbz66AkNZSqP2pQZhc7QOx1hL-xV3eDFlmKZNjI5fUrlzynteEWzwEMOk4bdv1YNfucG/exec";

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // 1. TỰ ĐỘNG KIỂM TRA CHẾ ĐỘ NGÀY/ĐÊM (6h-18h là ngày)
  bool _isNightNow() {
    int hour = DateTime.now().hour;
    return hour < 6 || hour >= 18;
  }

  // 2. TÍNH NGÀY KỶ NIỆM (TỪ 12/10/2025)
  int _calculateDays() {
    final startDate = DateTime(2025, 10, 12);
    final now = DateTime.now();
    return now.difference(startDate).inDays;
  }

  // 3. HIỆU ỨNG RUNG TIM ĐẬP (Haptic Feedback)
  void _heartBeatVibration() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.mediumImpact());
  }

  Future<void> _playSound(String fileName) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(fileName));
    } catch (e) { print(e); }
  }

  Future<void> _sendLove({String? directMsg, bool launchConfetti = false, String? mood}) async {
    String textToSend = directMsg ?? _controller.text;
    if (mood != null) textToSend = "Tâm trạng hiện tại: $mood";
    if (textToSend.isEmpty) return;

    if (launchConfetti) {
      _confettiController.play();
      _heartBeatVibration(); 
    }

    setState(() => _isSending = true);
    try {
      await http.post(Uri.parse(googleUrl), body: jsonEncode({"loinhan": textToSend}));
      if (directMsg == null && mood == null) _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mood != null ? "Đã báo cho Anh Tân là Bé đang $mood! ❤️" : "Đã gửi: $textToSend"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _isNightNow() ? Colors.indigo[900] : Colors.pink[400],
        ),
      );
    } catch (e) { print(e); } 
    finally { setState(() => _isSending = false); }
  }

  @override
  Widget build(BuildContext context) {
    bool isNight = _isNightNow();
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. HÌNH NỀN CHÍNH CỦA BẠN
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), 
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. LỚP PHỦ MÀU ADAPTIVE (Tự đổi tông Sáng/Tối theo giờ)
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            color: isNight 
                ? Colors.indigo[900]!.withOpacity(0.65) // Tông đêm mờ ảo
                : Colors.white.withOpacity(0.15),       // Tông ngày trong trẻo
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), 
              child: Container(color: Colors.transparent),
            ),
          ),

          // 3. PHÁO HOA TIM
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.red, Colors.pink, Colors.white],
              createParticlePath: _drawHeart,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // CARD KỶ NIỆM
                  _buildHeaderCard(isNight),

                  const SizedBox(height: 15),
                  Text(
                    "Dù cách nhau bao xa, tim mình vẫn gần ❤️",
                    style: TextStyle(color: isNight ? Colors.white70 : Colors.black54, fontSize: 11, fontStyle: FontStyle.italic),
                  ),

                  const SizedBox(height: 20),

                  // THANH TÂM TRẠNG (MOOD)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _moodIcon("🌈", "Vui vẻ"),
                      _moodIcon("☁️", "Bình thường"),
                      _moodIcon("🌧️", "Hơi buồn"),
                      _moodIcon("⚡", "Đang dỗi"),
                    ],
                  ),

                  const SizedBox(height: 25),
                  
                  // Ô NHẬP TIN NHẮN
                  _buildMessageInput(isNight),

                  const SizedBox(height: 25),

                  // LƯỚI 12 ICON (Đã sửa ngungon chuẩn chính tả)
                  _buildIconGrid(),

                  const SizedBox(height: 20),
                  
                  // NHẬT KÝ & THỬ THÁCH
                  Row(
                    children: [
                      Expanded(child: _actionButton("Nhật Ký ❤️", Icons.book_rounded, Colors.pinkAccent, () {})),
                      const SizedBox(width: 15),
                      Expanded(child: _actionButton("Thử Thách 🏆", Icons.star_rounded, Colors.orangeAccent, () => _showChallenge())),
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  // NÚT TRÁI TIM RUNG ĐẬP
                  GestureDetector(
                    onTap: () {
                      _heartBeatVibration();
                      _playSound('hello.mp3');
                    },
                    child: Container(
                      height: 65, width: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        color: Colors.white.withOpacity(0.2), 
                        border: Border.all(color: Colors.white30)
                      ),
                      child: const Icon(Icons.favorite, color: Colors.red, size: 30),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS THÀNH PHẦN ---

  Widget _buildHeaderCard(bool isNight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isNight ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text("TRẠM SẠC TÌNH YÊU", style: TextStyle(color: isNight ? Colors.white : Colors.pink[900], fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13)),
          const SizedBox(height: 8),
          Text("${_calculateDays()}", style: TextStyle(color: isNight ? Colors.pinkAccent : Colors.pink[700], fontSize: 42, fontWeight: FontWeight.bold)),
          const Text("NGÀY HẠNH PHÚC", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isNight) {
    return Container(
      decoration: BoxDecoration(
        color: isNight ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: _controller,
        style: TextStyle(color: isNight ? Colors.white : Colors.black87, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Gửi lời yêu thương cho Anh...",
          hintStyle: TextStyle(color: isNight ? Colors.white54 : Colors.black38, fontSize: 13),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.send_rounded, color: isNight ? Colors.pinkAccent : Colors.pink, size: 20),
            onPressed: () => _sendLove(),
          ),
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.82,
      children: [
        _ioSButton("Chào sáng", "assets/chaobuoisangem.png", () => _sendLove(directMsg: "Dậy thôi bé ơi! ☀️", launchConfetti: true)),
        _ioSButton("Gấu ngủ ngon", "assets/gaubongngungon.png", () => _sendLove(directMsg: "Gấu đi ngủ đây! 😴")),
        _ioSButton("G9 Anh Iuu", "assets/anhngungon.png", () => _sendLove(directMsg: "Chúc Anh ngủ ngon! 🌙")),
        _ioSButton("Thương bé", "assets/thuongembe.png", () => _sendLove(directMsg: "Thương em nhất! ❤️", launchConfetti: true)),
        _ioSButton("Thương gấu", "assets/thuonggaubong.png", () => _sendLove(directMsg: "Thương Gấu lắm! 🧸", launchConfetti: true)),
        _ioSButton("Ôm cái nè", "assets/omcaine.png", () => _sendLove(directMsg: "Ôm một cái thật chặt! 🫂", launchConfetti: true)),
        _ioSButton("Hôn miếng", "assets/hon.png", () => _sendLove(directMsg: "Hôn miếng nà! 😘", launchConfetti: true)),
        _ioSButton("Nhoaaa", "assets/nhoa.png", () => _sendLove(directMsg: "Nhoaaa! 🥺")),
        _ioSButton("Phê la đi", "assets/doiuong.png", () => _sendLove(directMsg: "Thèm trà sữa quá! 🧋")),
        _ioSButton("Đi dạo thôi", "assets/chodidao.png", () => _sendLove(directMsg: "Đi dạo phố đi Anh! 🛵")),
        _ioSButton("Massage nè", "assets/doimassage.png", () => _sendLove(directMsg: "Mỏi lưng quá à! 💆‍♀️")),
        _ioSButton("Mua đồ nà", "assets/doimuado.png", () => _sendLove(directMsg: "Dẫn bé đi shopping! 🛍️")),
      ],
    );
  }

  Widget _moodIcon(String emoji, String label) {
    return GestureDetector(
      onTap: () {
        _heartBeatVibration();
        _sendLove(mood: label);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  Widget _actionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 16),
      label: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
      style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  void _showChallenge() {
    final challenges = ["Khen Anh Tân 1 câu ngọt ngào!", "Gửi 1 tấm hình đẹp nhất của Bé!", "Hát 1 câu tặng Anh nhé!", "Tối nay mình đi ăn món gì Bé thích nà!"];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Thử Thách Hôm Nay 🏆"),
        content: Text((challenges..shuffle()).first),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Okie luôn!"))],
      ),
    );
  }

  Path _drawHeart(Size size) {
    double width = size.width, height = size.height;
    Path path = Path();
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.2 * width, height * 0.1, -0.35 * width, height * 0.6, 0.5 * width, height);
    path.cubicTo(1.35 * width, height * 0.6, 0.8 * width, height * 0.1, 0.5 * width, height * 0.35);
    path.close();
    return path;
  }

  Widget _ioSButton(String label, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
              child: ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.asset(imagePath, fit: BoxFit.contain)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}