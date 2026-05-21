import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/nicknames.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String _userName = "";
  
  String _beReminder = "💖 Đang chờ Gấu dặn dò...";
  String _currentReminder = "📌 Chưa có lời nhắc chung";
  String _currentWish = "🎁 Gợi ý quà yêu";
  int _sadDays = 0;
  DateTime _loveStart = DateTime(2025, 10, 12);
  
  bool _waterEnabled = false;
  int _waterHour = 9, _waterMinute = 0;
  int _gameScore = 0;
  
  final List<StreamSubscription> _subscriptions = [];
  final TextEditingController _reminderCtrl = TextEditingController();
  final TextEditingController _wishCtrl = TextEditingController();
  final TextEditingController _beReminderCtrl = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _listenFirebase();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? "";
        _waterEnabled = prefs.getBool('waterEnabled') ?? false;
        _waterHour = prefs.getInt('waterHour') ?? 9;
        _waterMinute = prefs.getInt('waterMinute') ?? 0;
        _gameScore = prefs.getInt('couple_game_score') ?? 0;
        final savedDate = prefs.getString('love_start_date');
        if (savedDate != null) {
          final parsed = DateTime.tryParse(savedDate);
          if (parsed != null) _loveStart = parsed;
        }
      });
    }
  }
  
  void _listenFirebase() {
    _subscriptions.add(
      _dbRef.child('be_reminder').onValue.listen((event) {
        if (event.snapshot.value != null && mounted) {
          setState(() => _beReminder = event.snapshot.value.toString());
        }
      }),
    );
    _subscriptions.add(
      _dbRef.child('reminder').onValue.listen((event) {
        if (event.snapshot.value != null && mounted) {
          setState(() => _currentReminder = event.snapshot.value.toString());
        }
      }),
    );
    _subscriptions.add(
      _dbRef.child('currentWish').onValue.listen((event) {
        if (event.snapshot.value != null && mounted) {
          setState(() => _currentWish = event.snapshot.value.toString());
        }
      }),
    );
    _subscriptions.add(
      _dbRef.child('sadDays').onValue.listen((event) {
        if (event.snapshot.value != null && mounted) {
          _sadDays = (event.snapshot.value as int?) ?? 0;
          setState(() {});
        }
      }),
    );
  }
  
  Future<void> _updateReminder(String text) async {
    await _dbRef.child('reminder').set(text);
    _showSnackbar("✅ Đã cập nhật lời nhắc chung!");
  }
  
  Future<void> _updateBeReminder(String text) async {
    await _dbRef.child('be_reminder').set(text);
    _showSnackbar("✅ Đã cập nhật dặn dò!");
  }
  
  Future<void> _updateWish(String text) async {
    await _dbRef.child('currentWish').set(text);
    _showSnackbar("✅ Đã cập nhật gợi ý quà!");
  }
  
  Future<void> _updateSadDays(int days) async {
    await _dbRef.child('sadDays').set(days);
    _showSnackbar("✅ Đã cập nhật ngày buồn!");
  }
  
  Future<void> _updateLoveDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('love_start_date', date.toIso8601String());
    setState(() => _loveStart = date);
    _showSnackbar("✅ Đã cập nhật ngày kỷ niệm!");
  }
  
  Future<void> _toggleWater(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('waterEnabled', enabled);
    setState(() => _waterEnabled = enabled);
  }
  
  Future<void> _setWaterTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('waterHour', hour);
    await prefs.setInt('waterMinute', minute);
    setState(() {
      _waterHour = hour;
      _waterMinute = minute;
    });
  }
  
  void _showSnackbar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 3), behavior: SnackBarBehavior.floating),
      );
    }
  }
  
  @override
  void dispose() {
    _reminderCtrl.dispose();
    _wishCtrl.dispose();
    _beReminderCtrl.dispose();
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final sweetName = CoupleNicknames.getRandomSweetName(CoupleNicknames.isGau(_userName));
    final isGau = CoupleNicknames.isGau(_userName);
    final totalDays = DateTime.now().difference(_loveStart).inDays;
    final happyDays = (totalDays - _sadDays).clamp(0, totalDays);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("⚙️ Cài đặt", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFE6F2), Color(0xFFFFB3D9)]),
        ),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.loveGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Chào $sweetName! 💕", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Tùy chỉnh mọi thứ ở đây", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(isGau ? 'assets/gau_bong.png' : 'assets/be_trang.png'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _sectionHeader("💕 Kỷ niệm"),
            _settingTile(
              Icons.calendar_month,
              "Ngày bắt đầu yêu nhau",
              "📅 ${_loveStart.day}/${_loveStart.month}/${_loveStart.year} ($totalDays ngày)",
              () async {
                final date = await showDatePicker(
                  context: context, initialDate: _loveStart, firstDate: DateTime(2020), lastDate: DateTime.now(),
                );
                if (date != null) _updateLoveDate(date);
              },
            ),
            _settingTile(Icons.favorite, "Ngày hạnh phúc", "😊 $happyDays ngày", null),
            _settingTile(Icons.mood_bad, "Ngày buồn", "😢 $_sadDays ngày", isGau ? () => _editSadDays() : null),
            
            const SizedBox(height: 12),
            _sectionHeader("📌 Lời nhắc & Dặn dò"),
            _settingTile(Icons.favorite, "Dặn dò Bé Trắng", _beReminder, isGau ? () => _editBeReminder() : null),
            _settingTile(Icons.push_pin, "Lời nhắc chung", _currentReminder, isGau ? () => _editReminder() : null),
            _settingTile(Icons.card_giftcard, "Gợi ý quà", _currentWish, isGau ? () => _editWish() : null),
            
            const SizedBox(height: 12),
            _sectionHeader("💧 Nhắc uống nước"),
            SwitchListTile(
              title: const Text("Bật nhắc uống nước"),
              subtitle: Text("${_waterHour.toString().padLeft(2, '0')}:${_waterMinute.toString().padLeft(2, '0')}"),
              value: _waterEnabled,
              onChanged: _toggleWater,
              activeTrackColor: Colors.pinkAccent.withValues(alpha: 0.5),
              activeThumbColor: Colors.pinkAccent,
            ),
            if (_waterEnabled)
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.pinkAccent),
                title: const Text("Giờ nhắc"),
                subtitle: Text("${_waterHour.toString().padLeft(2, '0')}:${_waterMinute.toString().padLeft(2, '0')}"),
                trailing: const Icon(Icons.edit, color: Colors.pinkAccent, size: 18),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context, initialTime: TimeOfDay(hour: _waterHour, minute: _waterMinute),
                  );
                  if (time != null) _setWaterTime(time.hour, time.minute);
                },
              ),
            
            const SizedBox(height: 12),
            _sectionHeader("🎮 Game cặp đôi"),
            _settingTile(Icons.emoji_events, "Điểm số", "❤️ $_gameScore điểm", null),
            
            const SizedBox(height: 12),
            _sectionHeader("ℹ️ Thông tin ứng dụng"),
            _settingTile(Icons.info, "Phiên bản", "Love Station v2.0", null),
            _settingTile(Icons.developer_mode, "Đơn vị phát triển", "Design by WMQ", null),
            
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text("💖 Love Station v2.0", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
                  const SizedBox(height: 8),
                  Text(
                    "Cảm ơn $sweetName đã sử dụng Love Station!\n"
                    "Mỗi tính năng đều được thiết kế bằng tình yêu thương ❤️\n\n"
                    "Hãy góp ý thêm cho tụi mình ngày càng hoàn thiện hơn nha!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF4A0024), height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
    );
  }
  
  Widget _settingTile(IconData icon, String title, String subtitle, VoidCallback? onEdit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.pinkAccent, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: onEdit != null ? const Icon(Icons.edit, color: Colors.pinkAccent, size: 18) : null,
        onTap: onEdit,
        dense: true,
      ),
    );
  }
  
  void _editReminder() {
    _reminderCtrl.text = _currentReminder;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("📌 Sửa lời nhắc chung"),
        content: TextField(controller: _reminderCtrl, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () { _updateReminder(_reminderCtrl.text); Navigator.pop(ctx); },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }
  
  void _editBeReminder() {
    _beReminderCtrl.text = _beReminder;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("💌 Sửa dặn dò Bé Trắng"),
        content: TextField(controller: _beReminderCtrl, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () { _updateBeReminder(_beReminderCtrl.text); Navigator.pop(ctx); },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }
  
  void _editWish() {
    _wishCtrl.text = _currentWish;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🎁 Sửa gợi ý quà"),
        content: TextField(controller: _wishCtrl, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () { _updateWish(_wishCtrl.text); Navigator.pop(ctx); },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }
  
  void _editSadDays() {
    final ctrl = TextEditingController(text: _sadDays.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("😢 Sửa ngày buồn"),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              final days = int.tryParse(ctrl.text);
              if (days != null) _updateSadDays(days);
              Navigator.pop(ctx);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }
}