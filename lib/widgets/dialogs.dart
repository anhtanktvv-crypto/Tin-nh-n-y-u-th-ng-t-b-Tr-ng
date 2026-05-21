import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class DialogHelper {
  static void showInputDialog({required BuildContext context, required String title, required String hintText, required ValueChanged<String> onSubmitted, TextEditingController? controller}) {
    final ctrl = controller ?? TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text(title),
      content: TextField(controller: ctrl, decoration: InputDecoration(hintText: hintText), autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
        TextButton(onPressed: () { if (ctrl.text.isNotEmpty) onSubmitted(ctrl.text); if (ctx.mounted) Navigator.pop(ctx); }, child: const Text("Gửi")),
      ],
    ));
  }
  static void showConfirmDialog({required BuildContext context, required String title, required String content, required VoidCallback onConfirm, String cancelText = "Hủy", String confirmText = "Đồng ý"}) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text(title), content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(cancelText)),
        TextButton(onPressed: () { Navigator.pop(ctx); onConfirm(); }, child: Text(confirmText)),
      ],
    ));
  }
  static void showNumberInputDialog({required BuildContext context, required String title, required String hintText, required ValueChanged<int> onSubmitted, int initialValue = 0}) {
    final controller = TextEditingController(text: initialValue.toString());
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text(title),
      content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: hintText)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
        TextButton(onPressed: () { int? value = int.tryParse(controller.text); if (value != null) onSubmitted(value); if (ctx.mounted) Navigator.pop(ctx); }, child: const Text("Lưu")),
      ],
    ));
  }
}

class LuLuDialog extends StatefulWidget {
  final Future<String> Function(String question) onAsk;
  final String initialMessage;
  final String userName;
  const LuLuDialog({super.key, required this.onAsk, this.initialMessage = "", this.userName = ""});
  @override
  State<LuLuDialog> createState() => _LuLuDialogState();
}

class _LuLuDialogState extends State<LuLuDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isThinking = false;
  final List<Map<String, dynamic>> _chatHistory = [];
  late AnimationController _typingAnimCtrl;
  late Animation<double> _typingAnim;

  @override
  void initState() {
    super.initState();
    _typingAnimCtrl = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _typingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _typingAnimCtrl, curve: Curves.elasticIn));
    if (widget.initialMessage.isNotEmpty) Future.microtask(() => _ask(widget.initialMessage, isInitial: true));
  }

  Future<void> _ask(String question, {bool isInitial = false}) async {
    if (question.trim().isEmpty) return;
    final q = question.trim();
    if (!isInitial) _ctrl.clear();
    _chatHistory.add({"role": "user", "text": q});
    setState(() => _isThinking = true);
    _typingAnimCtrl.forward(from: 0);
    _typingAnimCtrl.repeat(reverse: true);
    final answer = await widget.onAsk(q);
    if (mounted) {
      _typingAnimCtrl.stop();
      _chatHistory.add({"role": "bot", "text": answer});
      setState(() => _isThinking = false);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    }
  }

  @override
  void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); _typingAnimCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;
    return AlertDialog(
      insetPadding: const EdgeInsets.all(4),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: SizedBox(
        width: sw * 0.96,
        height: sh * 0.88,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFE6F2), Color(0xFFFFB3D9)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)),
          child: Column(children: [
            Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.purpleGradient, border: Border.all(color: Colors.white, width: 2)),
                child: ClipOval(child: Image.asset('assets/lulu_icon.png', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.smart_toy, color: Colors.white, size: 26)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text("🤖 AI LuLu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("Trợ lý thông minh", style: TextStyle(fontSize: 10, color: Colors.white70)),
              ])),
              GestureDetector(onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white70, size: 20))),
            ]),
            const SizedBox(height: 8),
            Expanded(child: Container(
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
              child: ListView.builder(controller: _scrollCtrl, padding: const EdgeInsets.all(8), itemCount: _chatHistory.length + (_isThinking ? 1 : 0), itemBuilder: (ctx, i) {
                if (i == _chatHistory.length) return Padding(padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), child: Row(children: [
                  AnimatedBuilder(animation: _typingAnim, builder: (context, child) => Transform.scale(scale: 0.8 + _typingAnim.value * 0.4,
                    child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        const SizedBox(width: 6),
                        Text("Lulu đang suy nghĩ...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white.withValues(alpha: 0.9), fontSize: 10)),
                      ]),
                    ),
                  )),
                ]));
                final msg = _chatHistory[i];
                final isUser = msg["role"] == "user";
                return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: sw * 0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue.withValues(alpha: 0.7) : Colors.pink.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14).copyWith(bottomRight: isUser ? const Radius.circular(4) : Radius.zero, bottomLeft: isUser ? Radius.zero : const Radius.circular(4)),
                    ),
                    child: Text(msg["text"], style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.3)),
                  ),
                ));
              }),
            )),
            const SizedBox(height: 8),
            Container(decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3))),
              child: Row(children: [
                Expanded(child: TextField(controller: _ctrl, style: const TextStyle(fontSize: 12), decoration: const InputDecoration(hintText: "Hỏi Lulu...", border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)), onSubmitted: (v) => _ask(v))),
                Container(margin: const EdgeInsets.all(3), decoration: BoxDecoration(gradient: AppTheme.purpleGradient, borderRadius: BorderRadius.circular(8)),
                  child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18), onPressed: () => _ask(_ctrl.text), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32))),
              ]),
            ),
            const SizedBox(height: 6),
            Wrap(spacing: 4, children: ["🎵 Nghe nhạc", "🍜 Ăn gì?", "💕 Yêu nhau", "⚙️ Cài đặt", "🧸 Anh Tấn", "🐰 Chị Quyên"]
              .map((t) => ActionChip(label: Text(t, style: const TextStyle(color: Colors.white, fontSize: 9)), backgroundColor: Colors.pink.withValues(alpha: 0.7), padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact, onPressed: () => _ask(t))).toList()),
          ]),
        ),
      ),
    );
  }
}

class CoupleGameDialog extends StatefulWidget {
  final String userName;
  final Function(int) onCorrect;
  const CoupleGameDialog({super.key, required this.userName, required this.onCorrect});
  @override State<CoupleGameDialog> createState() => _CoupleGameDialogState();
}
class _CoupleGameDialogState extends State<CoupleGameDialog> with SingleTickerProviderStateMixin {
  final Random _rand = Random();
  final TextEditingController _answerCtrl = TextEditingController();
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  int _cur = 0; bool _revealed = false; bool _correct = true; int _score = 0; int _streak = 0;
  final List<Map<String, dynamic>> _games = [
    {"q": "Ai yêu ai nhiều hơn?", "a": "Cả hai yêu nhau nhiều như nhau ❤️"},
    {"q": "Ngày yêu nhau là ngày nào?", "a": "12/10/2025 ❤️"},
    {"q": "Biệt danh của 2 người?", "a": "Gấu bông & Bé Trắng 🧸🐰"},
    {"q": "Bài hát 'của hai đứa'?", "a": "Ai Ngoài Anh - VSTRA 🎵"},
    {"q": "Ai nói yêu trước?", "a": "Gấu bông nói trước! 💖"},
    {"q": "Món ăn yêu thích nhất của Bé Trắng?", "a": "Bún bò Huế 🍜"},
    {"q": "Đồ uống yêu thích của Bé Trắng?", "a": "Lục trà chanh trân châu đen 🧋"},
    {"q": "Màu yêu thích của Bé Trắng?", "a": "Màu hồng 💖"},
    {"q": "Bí mật hạnh phúc?", "a": "Yêu thương và thấu hiểu 💖"},
    {"q": "Điều hạnh phúc nhất?", "a": "Có nhau trong cuộc đời! 💖"},
  ];
  late Map<String, dynamic> _game;

  @override void initState() {
    super.initState();
    _game = _games[_rand.nextInt(_games.length)];
    _loadScore();
    _pulseCtrl = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.03).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pulseCtrl.repeat(reverse: true);
  }
  Future<void> _loadScore() async { final p = await SharedPreferences.getInstance(); if (mounted) setState(() => _score = p.getInt('couple_game_score') ?? 0); }
  Future<void> _saveScore() async { final p = await SharedPreferences.getInstance(); await p.setInt('couple_game_score', _score); }
  void _check() {
    if (_answerCtrl.text.trim().isEmpty) return;
    final wrong = _rand.nextInt(100) == 0;
    setState(() { _revealed = true; _correct = !wrong; if (!wrong) { _score += 1 + _rand.nextInt(3); _streak++; if (_streak >= 3) _score += 2; if (_answerCtrl.text.containsAny(["thương", "yêu", "giỏi", "nhớ"])) _score += 1; } else _streak = 0; });
    _saveScore(); widget.onCorrect(_score);
  }
  void _next() { setState(() { _game = _games[_rand.nextInt(_games.length)]; _revealed = false; _correct = true; _answerCtrl.clear(); }); }
  @override void dispose() { _answerCtrl.dispose(); _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFE6F2), Color(0xFFFFB3D9)]), borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(14), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFD500F9)]), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: Row(children: [
              const Icon(Icons.favorite, color: Colors.yellowAccent, size: 20),
              const SizedBox(width: 8),
              const Expanded(child: Text("💕 Game", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
              Text("❤️ $_score", style: const TextStyle(color: Colors.white, fontSize: 14)),
            ])),
          Padding(padding: const EdgeInsets.all(14), child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (_streak >= 2) Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrangeAccent]), borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.local_fire_department, color: Colors.white, size: 14), const SizedBox(width: 3), Text("Streak ×$_streak", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))])),
            AnimatedBuilder(animation: _pulseAnim, builder: (context, child) => Transform.scale(scale: _pulseAnim.value,
              child: Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3))),
                child: Text(_game["q"], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD81B60)), textAlign: TextAlign.center)))),
            const SizedBox(height: 10),
            if (!_revealed)
              TextField(controller: _answerCtrl, decoration: InputDecoration(hintText: "Trả lời...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), suffixIcon: IconButton(icon: const Icon(Icons.check, color: Colors.pinkAccent), onPressed: _check)), onSubmitted: (_) => _check())
            else ...[
              Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _correct ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: _correct ? Colors.green : Colors.red)),
                child: Column(children: [
                  Text(_correct ? "✅ Đúng!" : "😅 Sai!", style: TextStyle(fontWeight: FontWeight.bold, color: _correct ? Colors.green : Colors.red)),
                  const SizedBox(height: 4),
                  Text("💡 ${_game["a"]}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ])),
              const SizedBox(height: 8),
            ],
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (!_revealed) TextButton(onPressed: () => setState(() { _revealed = true; _correct = true; }), child: const Text("Bỏ qua", style: TextStyle(fontSize: 12))),
              if (_revealed) ElevatedButton(onPressed: _next, style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)), child: const Text("Câu tiếp →", style: TextStyle(fontSize: 12))),
              const SizedBox(width: 6),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Thoát", style: TextStyle(fontSize: 11))),
            ]),
          ])),
        ])),
    );
  }
}

extension on String {
  bool containsAny(List<String> keywords) => keywords.any((kw) => toLowerCase().contains(kw.toLowerCase()));
}

class TodoDialog extends StatefulWidget {
  final Function(String) onAddTodo; final Function(int) onToggleTodo; final Function(int) onDeleteTodo;
  final TextEditingController todoCtrl; final List<Map<String, dynamic>> todoList;
  const TodoDialog({super.key, required this.onAddTodo, required this.onToggleTodo, required this.onDeleteTodo, required this.todoCtrl, required this.todoList});
  @override State<TodoDialog> createState() => _TodoDialogState();
}
class _TodoDialogState extends State<TodoDialog> {
  late TextEditingController _ctrl;
  @override void initState() { super.initState(); _ctrl = widget.todoCtrl; }
  @override
  Widget build(BuildContext context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: const Text("📝 Todo"),
    content: SizedBox(width: double.maxFinite, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: "Thêm...", border: OutlineInputBorder()), onSubmitted: (_) { widget.onAddTodo(_ctrl.text); _ctrl.clear(); })), const SizedBox(width: 6), IconButton(icon: const Icon(Icons.add_circle, color: Colors.pinkAccent), onPressed: () { widget.onAddTodo(_ctrl.text); _ctrl.clear(); })]),
      const SizedBox(height: 12),
      widget.todoList.isEmpty ? const Text("Chưa có task!", style: TextStyle(fontStyle: FontStyle.italic)) : SizedBox(height: 180, child: ListView.builder(itemCount: widget.todoList.length, itemBuilder: (ctx, i) {
        final t = widget.todoList[i];
        return ListTile(dense: true, leading: Icon(t['done'] ? Icons.check_circle : Icons.circle_outlined, color: t['done'] ? Colors.green : Colors.grey), title: Text(t['text'], style: TextStyle(fontSize: 13, decoration: t['done'] ? TextDecoration.lineThrough : null)), trailing: IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => widget.onDeleteTodo(i)), onTap: () => widget.onToggleTodo(i));
      })),
    ])),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng"))],
  );
}