import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/nicknames.dart';

class PiggyBankPage extends StatefulWidget {
  const PiggyBankPage({super.key});

  @override
  State<PiggyBankPage> createState() => _PiggyBankPageState();
}

class _PiggyBankPageState extends State<PiggyBankPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String _userName = "";
  
  final List<Map<String, dynamic>> _goals = [];
  final List<StreamSubscription> _subscriptions = [];
  
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _targetCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 365));
  String _depositPerson = "Gấu bông";
  
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _listenGoals();
  }
  
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _userName = prefs.getString('user_name') ?? "");
  }
  
  void _listenGoals() {
    _subscriptions.add(
      _dbRef.child('piggy_bank').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && mounted) {
          final map = data as Map;
          final list = <Map<String, dynamic>>[];
          map.forEach((key, value) {
            final item = Map<String, dynamic>.from(value as Map);
            item['key'] = key;
            list.add(item);
          });
          setState(() {
            _goals.clear();
            _goals.addAll(list);
          });
        }
      }),
    );
  }
  
  Future<void> _createGoal() async {
    if (_nameCtrl.text.trim().isEmpty || _targetCtrl.text.trim().isEmpty) {
      _showSnackbar("Vui lòng nhập tên và số tiền mục tiêu!");
      return;
    }
    final target = int.tryParse(_targetCtrl.text.replaceAll(',', '')) ?? 0;
    if (target <= 0) {
      _showSnackbar("Số tiền mục tiêu phải lớn hơn 0!");
      return;
    }
    
    await _dbRef.child('piggy_bank').push().set({
      'name': _nameCtrl.text.trim(),
      'target': target,
      'current': 0,
      'deadline': _deadline.toIso8601String(),
      'createdBy': _userName,
      'history': {},
      'created_at': ServerValue.timestamp,
    });
    
    _nameCtrl.clear();
    _targetCtrl.clear();
    if (mounted) Navigator.pop(context);
    _showSnackbar("🐷 Đã tạo heo đất mới!");
  }
  
  Future<void> _depositMoney(Map<String, dynamic> goal) async {
    final key = goal['key'];
    final amountText = _amountCtrl.text.trim();
    if (amountText.isEmpty) {
      _showSnackbar("Nhập số tiền muốn bỏ vào!");
      return;
    }
    final amount = int.tryParse(amountText.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      _showSnackbar("Số tiền phải lớn hơn 0!");
      return;
    }
    
    final current = (goal['current'] ?? 0) as int;
    final newCurrent = current + amount;
    
    final historyRef = _dbRef.child('piggy_bank/$key/history').push();
    await historyRef.set({
      'amount': amount,
      'person': _depositPerson,
      'note': _noteCtrl.text.trim(),
      'timestamp': ServerValue.timestamp,
    });
    
    await _dbRef.child('piggy_bank/$key/current').set(newCurrent);
    
    _amountCtrl.clear();
    _noteCtrl.clear();
    if (mounted) Navigator.pop(context);
    
    // Check if goal reached
    final target = (goal['target'] ?? 0) as int;
    if (newCurrent >= target) {
      _showSnackbar("🎉🎉🎉 Hoàn thành mục tiêu! ${goal['name']} đã đạt! Pháo hoa ăn mừng!");
    } else {
      _showSnackbar("🐷 Đã bỏ $amount₫ vào heo! Còn ${target - newCurrent}₫ nữa!");
    }
  }
  
  void _showCreateGoalDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🐷 Tạo heo đất mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "🎯 Tên mục tiêu", hintText: "Quỹ đi Đà Lạt cuối năm"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _targetCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "💰 Số tiền mục tiêu (₫)", hintText: "5,000,000"),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: ctx,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2050),
                );
                if (date != null && mounted) setState(() => _deadline = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "📅 Hạn chót (không bắt buộc)"),
                child: Text(DateFormat('dd/MM/yyyy').format(_deadline)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: _createGoal,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            child: const Text("🐷 Tạo heo"),
          ),
        ],
      ),
    );
  }
  
  void _showDepositDialog(Map<String, dynamic> goal) {
    final current = (goal['current'] ?? 0) as int;
    final target = (goal['target'] ?? 0) as int;
    final progress = target > 0 ? (current / target * 100).clamp(0, 100) : 0.0;
    
    _depositPerson = CoupleNicknames.isGau(_userName) ? _userName : (_userName.contains("Bé") ? _userName : "Gấu bông");
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("🐷 ${goal['name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 20,
                backgroundColor: Colors.grey.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
              ),
            ),
            const SizedBox(height: 8),
            Text("💰 Đã đạt: ${_formatMoney(current)}₫ / ${_formatMoney(target)}₫ (${progress.toStringAsFixed(1)}%)", 
                 style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "💵 Số tiền bỏ vào (₫)", hintText: "50,000"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _depositPerson,
              decoration: const InputDecoration(labelText: "👤 Người bỏ"),
              items: ["Gấu bông", "Bé Trắng"].map((p) => DropdownMenuItem(
                value: p,
                child: Text(p == "Gấu bông" ? "🧸 Gấu bông" : "🐰 Bé Trắng"),
              )).toList(),
              onChanged: (v) {
                if (v != null && mounted) setState(() => _depositPerson = v);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: "📝 Ghi chú (không bắt buộc)", hintText: "Tiền phạt đi làm muộn..."),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () => _depositMoney(goal),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            child: const Text("🐷 Cho heo ăn"),
          ),
        ],
      ),
    );
  }
  
  void _showHistory(Map<String, dynamic> goal) {
    final history = goal['history'] as Map? ?? {};
    final list = history.values.toList()..sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("📋 Lịch sử: ${goal['name']}"),
        content: SizedBox(
          width: double.maxFinite,
          child: list.isEmpty
              ? const Text("Chưa có lịch sử bỏ heo!")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final item = list[i] as Map;
                    final person = item['person'] ?? '???';
                    final amount = item['amount'] ?? 0;
                    final note = item['note'] ?? '';
                    final isGau = person.toString().contains("Gấu");
                    return ListTile(
                      leading: Text(isGau ? "🧸" : "🐰", style: const TextStyle(fontSize: 24)),
                      title: Text("${isGau ? "Gấu bông" : "Bé Trắng"} bỏ ${_formatMoney(amount)}₫", style: const TextStyle(fontSize: 13)),
                      subtitle: note.isNotEmpty ? Text(note, style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)) : null,
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng"))],
      ),
    );
  }
  
  String _formatMoney(int amount) {
    return NumberFormat('#,###').format(amount);
  }
  
  void _showSnackbar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 4), behavior: SnackBarBehavior.floating),
      );
    }
  }
  
  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    for (var sub in _subscriptions) sub.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🐷 Heo đất tình yêu", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFE6F2), Color(0xFFFFB3D9)]),
        ),
        child: _goals.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.savings, size: 80, color: Colors.pinkAccent),
                    const SizedBox(height: 16),
                    Text("Chưa có heo đất nào!\nHãy tạo mục tiêu tiết kiệm đầu tiên 💕", 
                         textAlign: TextAlign.center, style: const TextStyle(color: Colors.pinkAccent, fontSize: 14)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Tạo heo đất mới"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                      onPressed: _showCreateGoalDialog,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _goals.length,
                itemBuilder: (ctx, i) {
                  final goal = _goals[i];
                  final current = (goal['current'] ?? 0) as int;
                  final target = (goal['target'] ?? 1) as int;
                  final progress = target > 0 ? (current / target * 100).clamp(0, 100) : 0.0;
                  final isComplete = current >= target;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(isComplete ? Icons.celebration : Icons.savings, color: isComplete ? Colors.amber : Colors.pinkAccent, size: 28),
                              const SizedBox(width: 8),
                              Expanded(child: Text(goal['name'] ?? "", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)))),
                              if (isComplete) const Icon(Icons.check_circle, color: Colors.green),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              minHeight: 24,
                              backgroundColor: Colors.grey.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(isComplete ? Colors.green : Colors.pinkAccent),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("💵 ${_formatMoney(current)}₫", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
                              Text("🎯 ${_formatMoney(target)}₫", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              Text("${progress.toStringAsFixed(0)}%", style: TextStyle(fontSize: 12, color: isComplete ? Colors.green : Colors.pinkAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.history, size: 18),
                                label: const Text("Lịch sử", style: TextStyle(fontSize: 11)),
                                onPressed: () => _showHistory(goal),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add_circle, size: 18),
                                label: const Text("Cho heo ăn", style: TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: () => _showDepositDialog(goal),
                              ),
                            ],
                          ),
                          if (goal['deadline'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text("📅 Hạn: ${goal['deadline'].toString().substring(0, 10)}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGoalDialog,
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Tạo heo mới"),
      ),
    );
  }
}