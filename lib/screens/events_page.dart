import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../models/nicknames.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final NotificationService _noti = NotificationService();
  String _userName = "";
  
  final List<Map<String, dynamic>> _events = [];
  final List<StreamSubscription> _subscriptions = [];
  Timer? _checkTimer;
  
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _filter = "all";

  @override
  void initState() {
    super.initState();
    _loadUser();
    _listenEvents();
    // Check every 30 seconds for upcoming events
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkUpcomingEvents());
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _userName = prefs.getString('user_name') ?? "");
  }

  void _listenEvents() {
    _subscriptions.add(
      _dbRef.child('events').orderByChild('datetime').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && mounted) {
          final map = data as Map;
          final list = <Map<String, dynamic>>[];
          map.forEach((key, value) {
            final item = Map<String, dynamic>.from(value as Map);
            item['key'] = key;
            list.add(item);
          });
          // Sort by date ascending
          list.sort((a, b) {
            final dateA = DateTime.tryParse(a['datetime']?.toString() ?? a['date']?.toString() ?? '') ?? DateTime(2000);
            final dateB = DateTime.tryParse(b['datetime']?.toString() ?? b['date']?.toString() ?? '') ?? DateTime(2000);
            return dateA.compareTo(dateB);
          });
          setState(() {
            _events.clear();
            _events.addAll(list);
          });
        }
      }),
    );
  }

  void _checkUpcomingEvents() {
    _noti.init(_userName);
    final now = DateTime.now();
    for (var event in _events) {
      final dateTimeStr = event['datetime']?.toString() ?? '';
      final eventTime = DateTime.tryParse(dateTimeStr);
      if (eventTime != null) {
        final diff = eventTime.difference(now);
        // Notify if within 5 minutes of event
        if (diff.inMinutes >= 0 && diff.inMinutes <= 5 && diff.inMinutes > 0) {
          _noti.showNotification(
            "📅 Sự kiện sắp diễn ra!",
            "${event['title']} - ${event['desc'] ?? ''}",
            tag: 'event_${event['key']}',
          );
        }
      }
    }
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_filter == "all") return _events;
    if (_filter == "upcoming") {
      return _events.where((e) {
        final dateStr = e['datetime']?.toString() ?? e['date']?.toString() ?? '';
        final eventDate = DateTime.tryParse(dateStr);
        return eventDate != null && eventDate.isAfter(DateTime.now());
      }).toList();
    }
    if (_filter == "past") {
      return _events.where((e) {
        final dateStr = e['datetime']?.toString() ?? e['date']?.toString() ?? '';
        final eventDate = DateTime.tryParse(dateStr);
        return eventDate != null && eventDate.isBefore(DateTime.now());
      }).toList();
    }
    return _events;
  }

  String _getDayName(DateTime date) {
    final days = ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "CN"];
    return days[date.weekday - 1];
  }

  String _getEventStatus(Map<String, dynamic> event) {
    final dateStr = event['datetime']?.toString() ?? event['date']?.toString() ?? '';
    final eventDate = DateTime.tryParse(dateStr);
    if (eventDate == null) return "📌";
    if (eventDate.isBefore(DateTime.now())) return "✅ Đã qua";
    final diff = eventDate.difference(DateTime.now());
    if (diff.inDays == 0) return "🔔 Hôm nay!";
    if (diff.inDays == 1) return "⏰ Ngày mai!";
    if (diff.inDays <= 7) return "📅 ${diff.inDays} ngày nữa";
    return "📅 ${diff.inDays} ngày nữa";
  }

  Color _getEventColor(Map<String, dynamic> event) {
    final dateStr = event['datetime']?.toString() ?? event['date']?.toString() ?? '';
    final eventDate = DateTime.tryParse(dateStr);
    if (eventDate == null) return Colors.grey;
    if (eventDate.isBefore(DateTime.now())) return Colors.grey;
    final diff = eventDate.difference(DateTime.now());
    if (diff.inDays <= 1) return Colors.redAccent;
    if (diff.inDays <= 7) return Colors.orange;
    return Colors.pinkAccent;
  }

  Future<void> _addEvent() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnackbar("Vui lòng nhập tên sự kiện!");
      return;
    }
    
    final dateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );

    await _dbRef.child('events').push().set({
      'title': _titleCtrl.text.trim(),
      'desc': _descCtrl.text.trim(),
      'datetime': dateTime.toIso8601String(),
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'time': "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
      'createdBy': _userName,
      'timestamp': ServerValue.timestamp,
      'notified': false,
    });

    _titleCtrl.clear();
    _descCtrl.clear();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    if (mounted) Navigator.pop(context);
    _showSnackbar("✅ Đã thêm sự kiện! Sẽ nhắc bạn khi đến giờ! 🔔");
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("📅 Thêm sự kiện"),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: "🎯 Tên sự kiện", hintText: "Sinh nhật Bé Trắng...")),
            const SizedBox(height: 8),
            TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: "📝 Mô tả", hintText: "Mua quà, chuẩn bị bất ngờ...")),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(context: ctx, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                if (date != null && mounted) setState(() => _selectedDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "📅 Ngày"),
                child: Text("${_getDayName(_selectedDate)}, ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(context: ctx, initialTime: _selectedTime);
                if (time != null && mounted) setState(() => _selectedTime = time);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "⏰ Giờ"),
                child: Text("${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}"),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.pinkAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.notifications_active, color: Colors.pinkAccent, size: 18),
                const SizedBox(width: 8),
                const Expanded(child: Text("Sẽ nhắc bạn trước 5 phút! 🔔", style: TextStyle(fontSize: 12, color: Colors.pinkAccent))),
              ]),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(onPressed: _addEvent, style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent), child: const Text("✅ Thêm sự kiện")),
        ],
      ),
    );
  }

  void _showSnackbar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 3), behavior: SnackBarBehavior.floating));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _checkTimer?.cancel();
    for (var sub in _subscriptions) sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📅 Lịch sự kiện", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFE6F2), Color(0xFFFFB3D9)]),
        ),
        child: Column(children: [
          // Filter chips
          Container(padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(scrollDirection: Axis.horizontal,
              child: Row(children: [
                _filterChip("📌 Tất cả", "all"),
                _filterChip("🔜 Sắp tới", "upcoming"),
                _filterChip("✅ Đã qua", "past"),
              ]),
            ),
          ),
          Expanded(child: _filteredEvents.isEmpty
            ? Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.event_busy, size: 64, color: Colors.pinkAccent),
                  const SizedBox(height: 16),
                  const Text("Chưa có sự kiện nào!", style: TextStyle(color: Colors.pinkAccent, fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Thêm sự kiện mới"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                    onPressed: _showAddEventDialog,
                  ),
                ]),
              )
            : ListView.builder(padding: const EdgeInsets.all(8), itemCount: _filteredEvents.length, itemBuilder: (ctx, i) {
                final event = _filteredEvents[i];
                final status = _getEventStatus(event);
                final color = _getEventColor(event);
                final timeStr = event['time'] ?? '';
                final title = event['title'] ?? '';
                final desc = event['desc'] ?? '';
                final isCreator = event['createdBy'] == _userName;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(status.contains("Hôm nay") ? "🔔" : status.contains("Đã qua") ? "✅" : "📅", style: const TextStyle(fontSize: 24))),
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("${event['date'] ?? ''} $timeStr", style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
                      if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1),
                      Text(status, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                    ]),
                    trailing: isCreator ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () async {
                        await _dbRef.child('events/${event['key']}').remove();
                        _showSnackbar("✅ Đã xóa sự kiện");
                      },
                    ) : Text(event['createdBy']?.contains("Gấu") == true ? "🧸" : "🐰", style: const TextStyle(fontSize: 20)),
                  ),
                );
              }),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventDialog,
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Thêm sự kiện"),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.pinkAccent)),
        selected: isSelected,
        selectedColor: Colors.pinkAccent,
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }
}