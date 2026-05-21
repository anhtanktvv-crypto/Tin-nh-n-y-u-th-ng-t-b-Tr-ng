import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../models/nicknames.dart';

class TimeCapsulePage extends StatefulWidget {
  const TimeCapsulePage({super.key});

  @override
  State<TimeCapsulePage> createState() => _TimeCapsulePageState();
}

class _TimeCapsulePageState extends State<TimeCapsulePage> with TickerProviderStateMixin {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final AudioService _audio = AudioService();
  
  String _userName = "";
  bool _showLocked = true;
  
  final List<Map<String, dynamic>> _letters = [];
  final List<StreamSubscription> _subscriptions = [];
  
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();
  final TextEditingController _imageCtrl = TextEditingController();
  DateTime _unlockDate = DateTime.now().add(const Duration(days: 30));
  String _recipient = "Cả hai";
  
  Timer? _countdownTimer;
  
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _listenLetters();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }
  
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _userName = prefs.getString('user_name') ?? "");
  }
  
  void _listenLetters() {
    _subscriptions.add(
      _dbRef.child('time_capsule').orderByChild('unlock_date').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && mounted) {
          final map = data as Map;
          final list = <Map<String, dynamic>>[];
          map.forEach((key, value) {
            final item = Map<String, dynamic>.from(value as Map);
            item['key'] = key;
            list.add(item);
          });
          list.sort((a, b) => (b['created_at'] ?? 0).compareTo(a['created_at'] ?? 0));
          setState(() {
            _letters.clear();
            _letters.addAll(list);
          });
          // Check for newly unlocked letters
          for (var letter in list) {
            final unlockDate = DateTime.tryParse(letter['unlock_date'] ?? '');
            final opened = letter['opened'] ?? false;
            if (unlockDate != null && !opened && unlockDate.isBefore(DateTime.now())) {
              _autoOpenLetter(letter);
            }
          }
        }
      }),
    );
  }
  
  void _autoOpenLetter(Map<String, dynamic> letter) async {
    final sweetName = CoupleNicknames.isGau(_userName) 
        ? CoupleNicknames.getRandomBeName() 
        : CoupleNicknames.getRandomGauName();
    
    _showSnackbar("🔔 $sweetName ơi, có một bức thư tình từ quá khứ vừa được mở khóa nè! 💌");
    await _dbRef.child('time_capsule/${letter['key']}/opened').set(true);
  }
  
  List<Map<String, dynamic>> get _lockedLetters => 
      _letters.where((l) => DateTime.tryParse(l['unlock_date'] ?? '')?.isAfter(DateTime.now()) ?? true).toList();
  
  List<Map<String, dynamic>> get _openedLetters => 
      _letters.where((l) {
        final unlockDate = DateTime.tryParse(l['unlock_date'] ?? '');
        return unlockDate != null && unlockDate.isBefore(DateTime.now());
      }).toList();
  
  String _getCountdown(DateTime unlockDate) {
    final diff = unlockDate.difference(DateTime.now());
    if (diff.isNegative) return "Đã mở khóa! 🎉";
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    return "$days ngày $hours giờ $minutes phút";
  }
  
  Future<void> _sendLetter() async {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      _showSnackbar("Vui lòng nhập tiêu đề và nội dung thư!");
      return;
    }
    
    await _dbRef.child('time_capsule').push().set({
      'title': _titleCtrl.text.trim(),
      'content': _contentCtrl.text.trim(),
      'image_url': _imageCtrl.text.trim(),
      'unlock_date': _unlockDate.toIso8601String(),
      'recipient': _recipient,
      'sender': _userName,
      'opened': false,
      'created_at': ServerValue.timestamp,
    });
    
    _titleCtrl.clear();
    _contentCtrl.clear();
    _imageCtrl.clear();
    _unlockDate = DateTime.now().add(const Duration(days: 30));
    if (mounted) Navigator.pop(context);
    _showSnackbar("💌 Đã gửi thư! Hẹn ngày mở khóa nhé! 🔒");
  }
  
  void _showSendLetterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("💌 Gửi thư cho tương lai"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "📝 Tiêu đề thư", hintText: "Gửi Bé Trắng vào sinh nhật tuổi 25..."),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "💬 Nội dung thư", hintText: "Viết tâm thư của bạn vào đây..."),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _imageCtrl,
                decoration: const InputDecoration(labelText: "🖼️ Link ảnh (không bắt buộc)", hintText: "https://..."),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: _unlockDate,
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime(2050),
                  );
                  if (date != null && mounted) setState(() => _unlockDate = date);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: "🔓 Ngày mở khóa"),
                  child: Text(DateFormat('dd/MM/yyyy').format(_unlockDate)),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _recipient,
                decoration: const InputDecoration(labelText: "👤 Người nhận"),
                items: ["Cả hai", "Bé Trắng", "Gấu bông"].map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r == "Cả hai" ? "💑 Cả hai" : r == "Bé Trắng" ? "🐰 Bé Trắng" : "🧸 Gấu bông"),
                )).toList(),
                onChanged: (v) {
                  if (v != null && mounted) setState(() => _recipient = v);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: _sendLetter,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            child: const Text("🔒 Gửi và khóa"),
          ),
        ],
      ),
    );
  }
  
  void _openLetterDetail(Map<String, dynamic> letter) {
    final unlockDate = DateTime.tryParse(letter['unlock_date'] ?? '');
    final isUnlocked = unlockDate != null && unlockDate.isBefore(DateTime.now());
    
    if (!isUnlocked) {
      _showSnackbar("🔒 Thư chưa đến ngày mở khóa! Còn ${_getCountdown(unlockDate!)}");
      return;
    }
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE6F2), Color(0xFFFFB3D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.pinkAccent),
                  const SizedBox(width: 8),
                  Expanded(child: Text(letter['title'] ?? "", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)))),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(letter['content'] ?? "", style: const TextStyle(fontSize: 14, color: Color(0xFF4A0024), height: 1.5)),
                    if (letter['image_url']?.toString().isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text("Từ: ${letter['sender'] ?? '???'}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text("Ngày mở: ${letter['unlock_date']?.toString().substring(0, 10) ?? '???'}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
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
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _imageCtrl.dispose();
    _countdownTimer?.cancel();
    for (var sub in _subscriptions) sub.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final sweetName = CoupleNicknames.getRandomSweetName(CoupleNicknames.isGau(_userName));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("💌 Hộp thư tương lai", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFE6F2), Color(0xFFFFB3D9)]),
        ),
        child: Column(
          children: [
            // Tabs
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(child: _tabChip("🔒 Đang khóa (${_lockedLetters.length})", true)),
                  const SizedBox(width: 8),
                  Expanded(child: _tabChip("📬 Đã mở (${_openedLetters.length})", false)),
                ],
              ),
            ),
            Expanded(child: _showLocked ? _buildLockedList(sweetName) : _buildOpenedList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSendLetterDialog,
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note),
        label: const Text("Viết thư mới"),
      ),
    );
  }
  
  Widget _tabChip(String label, bool isLocked) {
    final isSelected = _showLocked == isLocked;
    return GestureDetector(
      onTap: () => setState(() => _showLocked = isLocked),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pinkAccent : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
  
  Widget _buildLockedList(String sweetName) {
    if (_lockedLetters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.pinkAccent),
            const SizedBox(height: 16),
            Text("Chưa có thư nào!\nHãy gửi lời nhắn cho tương lai $sweetName 💌", textAlign: TextAlign.center, style: const TextStyle(color: Colors.pinkAccent, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit_note),
              label: const Text("Viết thư mới"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              onPressed: _showSendLetterDialog,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _lockedLetters.length,
      itemBuilder: (ctx, i) {
        final letter = _lockedLetters[i];
        final unlockDate = DateTime.tryParse(letter['unlock_date'] ?? '') ?? DateTime.now();
        final countdown = _getCountdown(unlockDate);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.lock, color: Colors.orange, size: 32),
            title: Text(letter['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("⏰ $countdown", style: const TextStyle(fontSize: 11, color: Colors.orange)),
                Text("👤 Gửi: ${letter['recipient'] ?? 'Cả hai'}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            trailing: const Icon(Icons.lock_outline, color: Colors.orange),
            onTap: () => _openLetterDetail(letter),
          ),
        );
      },
    );
  }
  
  Widget _buildOpenedList() {
    if (_openedLetters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mail_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("Chưa có thư nào được mở khóa!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _openedLetters.length,
      itemBuilder: (ctx, i) {
        final letter = _openedLetters[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.email, color: Colors.pinkAccent, size: 32),
            title: Text(letter['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text("📅 ${letter['unlock_date']?.toString().substring(0, 10) ?? '???'}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () => _openLetterDetail(letter),
          ),
        );
      },
    );
  }
}