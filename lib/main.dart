import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

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
  bool _isSending = false;
  bool _isNightMode = false;

  // URL App Script mới của bạn
  final String googleUrl = "https://script.google.com/macros/s/AKfycbwuDDrNzM82cQ3HwL5YcB8RV3-jGdKqvzXRdOeXbKGsgKIKxwGasXzd0IKLsa2c5iMp/exec";

  Future<void> _playSound(String fileName) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(fileName));
    } catch (e) { print(e); }
  }

  Future<void> _sendLove({String? directMsg}) async {
    String textToSend = directMsg ?? _controller.text;
    if (textToSend.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await http.post(Uri.parse(googleUrl), body: jsonEncode({"loinhan": textToSend}));
      if (directMsg == null) _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã gửi: $textToSend"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.black87,
        ),
      );
    } catch (e) { print(e); } 
    finally { setState(() => _isSending = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/background.jpg'), fit: BoxFit.cover),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            color: _isNightMode ? Colors.black.withOpacity(0.8) : Colors.black.withOpacity(0.2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text("Trạm Sạc Tình Yêu", 
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const Text("Dành riêng cho Bé Trắng ❤️", 
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 30),
                  
                  // Ô nhập tin nhắn
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Nhắn nhủ điều ngọt ngào...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                          onPressed: () => _sendLove(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Lưới các nút bấm với HÌNH ẢNH RIÊNG
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.8, // Chỉnh tỷ lệ để text không bị mất
                    children: [
                      _ioSButton("Ngủ ngon", Icons.bedtime, Colors.indigoAccent, () {
                        setState(() => _isNightMode = true);
                        _playSound('sleep.mp3');
                        Future.delayed(const Duration(seconds: 15), () => setState(() => _isNightMode = false));
                      }),
                      _ioSButton("Đòi ôm", Icons.favorite, Colors.pinkAccent, () => _sendLove(directMsg: "Bé Trắng muốn được ôm! 🫂")),
                      _ioSButton("Đòi ăn", Icons.restaurant, Colors.orangeAccent, () => _sendLove(directMsg: "Bé Trắng đói bụng rồi! 🍦")),
                      
                      // CÁC NÚT DÙNG HÌNH ẢNH CỦA BẠN
                      _ioSButton("Đòi hôn", "assets/Doihon.png", Colors.redAccent, () => _sendLove(directMsg: "Bé Trắng đòi hôn miếng nè! 😘")),
                      _ioSButton("Mua đồ", "assets/doimuado.png", Colors.purpleAccent, () => _sendLove(directMsg: "Bé Trắng muốn shopping! 🛍️")),
                      _ioSButton("Đi dạo", "assets/chodidao.png", Colors.teal, () => _sendLove(directMsg: "Chở Bé dạo Trường Sa đi Anh! 🛵")),
                      
                      _ioSButton("Massage", "assets/doimassage.png", Colors.greenAccent, () => _sendLove(directMsg: "Bé mỏi lưng, đòi massage! 💆‍♀️")),
                      _ioSButton("Nhõng nhẽo", "assets/Nhongnheo.png", Colors.lightBlueAccent, () => _sendLove(directMsg: "Bé đang nhõng nhẽo nè! 🥺")),
                      _ioSButton("Đòi uống", "assets/doiuong.png", Colors.brown, () => _sendLove(directMsg: "Bé thèm trà sữa quá! 🧋")),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () => _playSound('hello.mp3'),
                    child: Container(
                      height: 80, width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("Nghe giọng Anh", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm tạo nút bấm thông minh: Tự nhận diện Icon hoặc Hình ảnh
  Widget _ioSButton(String label, dynamic iconOrImage, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Center(
                  child: iconOrImage is IconData 
                    ? Icon(iconOrImage, color: color, size: 30) // Dùng icon hệ thống
                    : Padding(
                        padding: const EdgeInsets.all(8.0), // Căn lề cho ảnh đẹp hơn
                        child: Image.asset(iconOrImage, fit: BoxFit.contain), // Dùng ảnh của bạn
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, 
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }
}