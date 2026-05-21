import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/nicknames.dart';

class DatingMapPage extends StatefulWidget {
  const DatingMapPage({super.key});

  @override
  State<DatingMapPage> createState() => _DatingMapPageState();
}

class _DatingMapPageState extends State<DatingMapPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  
  String _userName = "";
  String _currentFilter = "all";
  
  final List<Map<String, dynamic>> _locations = [];
  final List<StreamSubscription> _subscriptions = [];
  
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _latCtrl = TextEditingController();
  final TextEditingController _lngCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = "Ăn uống";
  
  final List<String> _categories = ["Ăn uống", "Vui chơi", "Du lịch", "Lần đầu tiên", "Khác"];
  
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _listenLocations();
  }
  
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? "";
      });
    }
  }
  
  void _listenLocations() {
    _subscriptions.add(
      _dbRef.child('dating_map').orderByChild('timestamp').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && mounted) {
          final map = data as Map;
          final list = <Map<String, dynamic>>[];
          map.forEach((key, value) {
            final item = Map<String, dynamic>.from(value as Map);
            item['key'] = key;
            list.add(item);
          });
          list.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
          setState(() {
            _locations.clear();
            _locations.addAll(list);
          });
        }
      }),
    );
  }
  
  List<Map<String, dynamic>> get _filteredLocations {
    if (_currentFilter == "all") return _locations;
    return _locations.where((loc) => loc['category'] == _currentFilter).toList();
  }
  
  Future<void> _addLocation() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnackbar("Vui lòng nhập tên địa điểm!");
      return;
    }
    
    await _dbRef.child('dating_map').push().set({
      'name': _nameCtrl.text.trim(),
      'lat': _latCtrl.text.trim().isNotEmpty ? double.tryParse(_latCtrl.text.trim()) ?? 0 : 10.8231,
      'lng': _lngCtrl.text.trim().isNotEmpty ? double.tryParse(_lngCtrl.text.trim()) ?? 0 : 106.6297,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'category': _selectedCategory,
      'note': _noteCtrl.text.trim(),
      'createdBy': _userName,
      'timestamp': ServerValue.timestamp,
    });
    
    _nameCtrl.clear();
    _latCtrl.clear();
    _lngCtrl.clear();
    _noteCtrl.clear();
    _selectedDate = DateTime.now();
    if (mounted) Navigator.pop(context);
    _showSnackbar("✅ Đã thêm địa điểm kỷ niệm!");
  }
  
  Future<void> _suggestRandomPlace() async {
    if (_locations.isEmpty) {
      _showSnackbar("Chưa có địa điểm nào! Hãy thêm vào trước nhé 💕");
      return;
    }
    
    final randomLoc = _locations[DateTime.now().millisecondsSinceEpoch % _locations.length];
    _showSnackbar(
      "💖 Lulu gợi ý: Hãy quay lại ${randomLoc['name']} nhé! "
      "${randomLoc['category'] == 'Ăn uống' ? 'Đồ ăn ở đó ngon lắm!' : 'Kỷ niệm ở đó thật đẹp!'}"
    );
  }
  
  String _getCategoryIcon(String category) {
    switch (category) {
      case "Ăn uống": return "🍜";
      case "Vui chơi": return "🎮";
      case "Du lịch": return "✈️";
      case "Lần đầu tiên": return "💝";
      default: return "📍";
    }
  }
  
  void _showAddLocationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("📍 Thêm địa điểm kỷ niệm"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Tên địa điểm", hintText: "VD: Tiệm cafe góc phố"),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latCtrl,
                      decoration: const InputDecoration(labelText: "Vĩ độ", hintText: "10.8231"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _lngCtrl,
                      decoration: const InputDecoration(labelText: "Kinh độ", hintText: "106.6297"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null && mounted) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: "Ngày hẹn hò"),
                  child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: "Danh mục"),
                items: _categories.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text("${_getCategoryIcon(c)} $c"),
                )).toList(),
                onChanged: (v) {
                  if (v != null && mounted) {
                    setState(() => _selectedCategory = v);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Cảm xúc/Nhật ký", hintText: "Hôm đó thật vui..."),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: _addLocation,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            child: const Text("Lưu kỷ niệm 💕"),
          ),
        ],
      ),
    );
  }
  
  void _showSnackbar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _nameCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _noteCtrl.dispose();
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final sweetName = CoupleNicknames.getRandomSweetName(
      CoupleNicknames.isGau(_userName),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("📍 Bản đồ hẹn hò", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.yellowAccent),
            onPressed: _suggestRandomPlace,
            tooltip: "Lulu gợi ý",
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE6F2), Color(0xFFFFB3D9)],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip("📌 Tất cả", "all"),
                    ..._categories.map((c) => _filterChip("${_getCategoryIcon(c)} $c", c)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _filteredLocations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_off, size: 64, color: Colors.pinkAccent),
                          const SizedBox(height: 16),
                          Text(
                            "Chưa có địa điểm nào!\nHãy thêm kỷ niệm đầu tiên nhé $sweetName 💕",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.pinkAccent, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_location),
                            label: const Text("Thêm địa điểm"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                            onPressed: _showAddLocationDialog,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredLocations.length,
                      itemBuilder: (ctx, i) {
                        final loc = _filteredLocations[i];
                        final date = loc['date'] ?? "";
                        final category = loc['category'] ?? "Khác";
                        final emoji = _getCategoryIcon(category);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.pinkAccent.withValues(alpha: 0.2),
                              child: Text(emoji, style: const TextStyle(fontSize: 24)),
                            ),
                            title: Text(
                              loc['name'] ?? "",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(category, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                if (date.isNotEmpty) Text(date, style: const TextStyle(fontSize: 10)),
                                if (loc['note']?.toString().isNotEmpty == true)
                                  Text(loc['note'], style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Text(
                              loc['createdBy']?.toString().contains("Gấu") == true ? "🧸" : "🐰",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLocationDialog,
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location),
        label: const Text("Thêm địa điểm"),
      ),
    );
  }
  
  Widget _filterChip(String label, String value) {
    final isSelected = _currentFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.pinkAccent)),
        selected: isSelected,
        selectedColor: Colors.pinkAccent,
        onSelected: (_) {
          if (mounted) {
            setState(() => _currentFilter = value);
          }
        },
      ),
    );
  }
}