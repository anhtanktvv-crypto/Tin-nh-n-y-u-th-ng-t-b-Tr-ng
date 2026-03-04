import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Thư viện để gửi tin nhắn qua mạng
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
      home: LovePage(),
    );
  }
}

class LovePage extends StatefulWidget {
  @override
  _LovePageState createState() => _LovePageState();
}

class _LovePageState extends State<LovePage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  // THAY LINK CỦA BẠN VÀO ĐÂY
  final String googleUrl = "https://script.google.com/macros/s/AKfycbz4L5lRgs2GfaVkNFisZxG7pCIhLsc4YC3JA4YEMO8V4LaoECLLEqVmN3FrIBRcPVgT/exec";

  Future<void> _sendLove() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      await http.post(
        Uri.parse(googleUrl),
        body: jsonEncode({"loinhan": _controller.text}),
      );
      
      _controller.clear();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(title: Text("❤️ Gửi thành công"), content: Text("Anh đã nhận được lời yêu thương của Em!")),
      );
    } catch (e) {
      print("Lỗi rồi: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(title: Text("App Tình Yêu ❤️"), centerTitle: true),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: 100, color: Colors.pink),
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Nhập lời yêu thương...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(height: 20),
              _isSending 
                ? CircularProgressIndicator() 
                : ElevatedButton(
                    onPressed: _sendLove,
                    child: Text("Gửi cho Anh ❤️"),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}