import 'dart:math';

class LuLuAiService {
  static final LuLuAiService _instance = LuLuAiService._();
  factory LuLuAiService() => _instance;
  LuLuAiService._();

  final Random _rand = Random();
  final List<String> _context = [];

  void Function(String)? onMusicCommand;
  void Function(String)? onSettingsCommand; // Callback for settings

  final List<_Pattern> _patterns = [
    _Pattern(["yêu", "iu", "love", "thương", "tình cảm"],
        ["Lulu thấy tình yêu này ngọt ngào quá! 💖",
         "Ôi OTP quốc dân! Chúc hai bạn mãi hạnh phúc nha 🥺",
         "Tình yêu này Lulu chấm 1000/10 luôn! ⭐",
         "Mỗi ngày yêu thêm một chút nha 💕",
         "Hai bạn là hình mẫu tình yêu lý tưởng của Lulu đó! 💌",
         "Tình yêu là thứ đẹp nhất trên đời! 🌹"]),
    _Pattern(["nhớ", "miss", "xa", "cô đơn", "xa cách"],
        ["Nhớ thì gọi video call ngay đi! 📹",
         "Yêu xa cần nhiều yêu thương hơn 💕",
         "Lulu gửi ngàn cái ôm online nè 🫂",
         "Khoảng cách chỉ là con số thôi! 💖",
         "Người ta chắc cũng đang nhớ đó 🥺"]),
    _Pattern(["buồn", "khóc", "stress", "tủi thân", "mệt", "chán"],
        ["Lulu ở đây rồi, có chuyện gì kể Lulu nghe nè 🥺",
         "Ôm một cái nào! 🫂 Mọi chuyện rồi sẽ ổn thôi 🌤️",
         "Đừng tự ép bản thân quá nha 💕",
         "Ngày mai sẽ khá hơn hôm nay mà! 💖",
         "Hãy nhắn tin yêu thương cho người ấy đi, sẽ vui hơn đó! 💌"]),
    _Pattern(["giận", "dỗi", "cãi nhau", "khó chịu", "cãi"],
        ["Ôm nhau trước rồi nói chuyện nha 🫂",
         "Xin lỗi trước không có thua đâu 💕",
         "Yêu nhau thắng thua làm gì 🌷",
         "Nắm tay nhau đi nào, mọi chuyện sẽ ổn thôi 🤝"]),
    _Pattern(["ăn", "đói", "food", "món ăn", "gợi ý", "đồ ăn"],
        ["Lulu gợi ý bún bò Huế nè! 🍜 Món này bổ dưỡng lắm!",
         "Hôm nay ăn bánh mì thịt trứng đi! 🥖",
         "Bún thịt nướng là chân ái luôn! 🥗",
         "Gà rán lúc buồn là hợp lý! 🍗",
         "Hai bạn đi ăn lẩu đi, ngồi bên nhau ấm áp lắm! 🍲"]),
    _Pattern(["uống", "nước", "drink", "đồ uống", "trà", "cafe"],
        ["Lục trà chanh trân châu đen mát lạnh! 🧋",
         "Cà phê sữa đá tỉnh ngủ cực mạnh! ☕",
         "Phê la bòng bưởi giải nhiệt cực đã! 🍊",
         "Trà xanh chanh thạch đào healthy lắm! 🍵"]),
    _Pattern(["game", "chơi", "giải trí", "vui"],
        ["Lulu có game đoán ý người yêu nè! 🎮",
         "Chơi game 'Ai hiểu ai hơn' đi! 🎯",
         "Thử thách 'Nhắn tin không dùng chữ A' đi! 😂"]),
    _Pattern(["kỷ niệm", "ngày yêu nhau", "yêu nhau từ", "ngày kỷ niệm"],
        ["Hai bạn yêu nhau từ ngày 12/10/2025 ❤️",
         "Từ ngày yêu đến nay đã được {totalDays} ngày rồi! 💕"]),
    _Pattern(["quà", "tặng", "món quà", "gift"],
        ["Một món quà handmade sẽ rất ý nghĩa! 🎁",
         "Viết thư tay đi! Thời nay ai còn viết thư tay đâu! 💌",
         "Một chuyến du lịch bất ngờ! ✈️",
         "Tặng nhau bữa tối lãng mạn dưới ánh nến 🕯️"]),
    _Pattern(["hẹn hò", "date", "đi chơi", "hẹn"],
        ["Rủ nhau đi xem phim đi! 🎬",
         "Đi dạo công viên tình yêu 🌳",
         "Hẹn hò ở quán cà phê chill chill ☕"]),
    _Pattern(["cưới", "kết hôn", "tương lai", "gia đình"],
        ["Lulu tin hai bạn sẽ có một đám cưới trong mơ! 💒",
         "Tương lai phía trước còn nhiều điều đẹp đẽ lắm! 🌈"]),
    _Pattern(["khỏe", "ốm", "bệnh", "đau", "mệt"],
        ["Nhớ uống thuốc đúng giờ nha! 💊",
         "Nghỉ ngơi nhiều vào, sức khỏe là vàng! 🛌",
         "Lulu gửi năng lượng tích cực đến bạn! ✨"]),
    _Pattern(["cố gắng", "thi cử", "làm việc", "học tập"],
        ["Cố lên! Lulu tin bạn làm được! 💪",
         "Bạn giỏi lắm, đừng từ bỏ! 🌟"]),
    _Pattern(["ngủ", "ngủ ngon", "good night", "chúc ngủ"],
        ["Chúc bạn ngủ ngon và mơ đẹp nhé! 🌙",
         "Ngủ sớm đi, mai còn yêu thương tiếp! 💤"]),
    _Pattern(["anh tấn", "gấu bông mét tám", "golden húi", "chồng iu", "biệt danh gấu"],
        ["Anh Tấn - Gấu bông 3 tuổi rưỡi, còn gọi là Gấu bông mét tám, Golden húi, Chồng iu của chị Quyên! 🧸",
         "Gấu bông aka Anh Tấn có biệt danh: Gấu bông 3 tuổi rưỡi, Gấu bông mét tám, Golden húi, Chồng iu của chị Quyên! 💕",
         "Anh Tấn là Gấu bông đáng yêu của Bé Trắng! Biệt danh: Gấu bông 3 tuổi rưỡi, Gấu bông mét tám, Golden húi, Chồng iu của chị Quyên! 🧸"]),
    _Pattern(["chị quyên", "myq", "cục zang", "vợ iu", "bé trắng"],
        ["Chị Quyên - Bé Trắng 1 tuổi rưỡi, còn gọi là MyQ, Cục Zang, Vợ iu của anh Tấn! 🐰",
         "Bé Trắng aka Chị Quyên có biệt danh: Bé Trắng, MyQ, Cục Zang, Vợ iu của anh Tấn! 💕",
         "Chị Quyên là Bé Trắng đáng yêu của Gấu bông! Biệt danh: MyQ, Cục Zang, Vợ iu của anh Tấn! 🐰"]),
    _Pattern(["xin chào", "hello", "hi", "chào", "có ai không"],
        ["LuLu đây! Có gì cần giúp đỡ không nè? 💖",
         "Chào bạn! Lulu rất vui khi thấy bạn! 🥰"]),
  ];

  Future<String> ask(String question, {int totalDays = 0, int happyDays = 0, int sadDays = 0}) async {
    if (question.trim().isEmpty) {
      return _fallbackReplies[_rand.nextInt(_fallbackReplies.length)];
    }
    // Typing delay 1-2s như real người
    await Future.delayed(Duration(milliseconds: 800 + _rand.nextInt(1200)));
    
    final lower = question.toLowerCase().trim();
    _context.add(lower);
    if (_context.length > 5) _context.removeAt(0);

    // ===== SETTINGS COMMANDS =====
    if (lower.containsAny(["cài đặt", "setting", "chỉnh", "sửa"])) {
      if (lower.containsAny(["nhắc", "reminder", "lời nhắc"])) {
        onSettingsCommand?.call("open_reminder");
        return "Lulu mở cài đặt lời nhắc cho bạn nè! Vào mục 📌 Lời nhắc & Dặn dò để chỉnh sửa nha! ⚙️";
      }
      if (lower.containsAny(["nước", "uống", "water"])) {
        onSettingsCommand?.call("open_water");
        return "Lulu mở cài đặt nhắc uống nước! Bạn có thể bật/tắt và chọn giờ nhắc nha! 💧";
      }
      if (lower.containsAny(["nền", "background", "hình nền"])) {
        onSettingsCommand?.call("open_background");
        return "Lulu dẫn bạn đến chỗ đổi ảnh nền nè! 🌅";
      }
      if (lower.containsAny(["ngày", "kỷ niệm", "love date"])) {
        onSettingsCommand?.call("open_love_date");
        return "Bạn muốn đổi ngày kỷ niệm hả? Lulu mở cho bạn nè! 💕";
      }
      if (lower.containsAny(["quà", "wish", "gợi ý"])) {
        onSettingsCommand?.call("open_wish");
        return "Chỉnh gợi ý quà đúng không? Lulu mở luôn nè! 🎁";
      }
      if (lower.containsAny(["buồn", "sad", "sad days"])) {
        onSettingsCommand?.call("open_sad");
        return "Sửa ngày buồn hả? Vào mục 💕 Kỷ niệm trong Cài đặt nha! 😢";
      }
      onSettingsCommand?.call("open_settings");
      return "Lulu dẫn bạn vào trang Cài đặt! Ở đó bạn có thể chỉnh tất tần tật luôn! ⚙️";
    }

    // ===== MUSIC COMMANDS =====
    if (lower.containsAny(["bật nhạc", "mở nhạc", "nghe nhạc", "play nhạc"])) {
      if (lower.contains("tắt") || lower.contains("stop")) {
        onMusicCommand?.call("stop");
        return "Lulu tắt nhạc rồi nha! 🎵";
      }
      if (lower.containsAny(["hongkong", "dao bước", "dạo bước"])) {
        onMusicCommand?.call("play_hongkong");
        return "Bật 'Dạo Bước Hong Kong 1999' cho bạn nè! 🎵";
      }
      if (lower.containsAny(["thế giới", "the gioi", "dangrangto"])) {
        onMusicCommand?.call("play_thegioi");
        return "Bật 'Thế Giới Của Anh' cho bạn nè! 🎵";
      }
      if (lower.containsAny(["ai ngoài", "aingoaianh", "vstra"])) {
        onMusicCommand?.call("play_aingoaianh");
        return "Bật 'Ai Ngoài Anh' cho bạn nè! 🎵";
      }
      onMusicCommand?.call("play");
      return "Lulu bật nhạc tình yêu cho hai bạn nghe nè! 🎵💖";
    }
    if (lower.containsAny(["tắt nhạc", "stop", "dừng nhạc"])) {
      onMusicCommand?.call("stop");
      return "Lulu tắt nhạc rồi nghe! 🎵";
    }
    if (lower.containsAny(["chuyển bài", "next", "tiếp", "bài khác"])) {
      onMusicCommand?.call("next");
      return "Chuyển bài mới cho bạn nè! 🎶";
    }
    if (lower.containsAny(["lùi bài", "prev", "quay lại", "bài trước"])) {
      onMusicCommand?.call("prev");
      return "Lùi bài nha! 🎶";
    }
    if (lower.containsAny(["tạm dừng", "pause", "dừng"])) {
      onMusicCommand?.call("pause");
      return "Tạm dừng nhạc nha! ⏸️";
    }
    if (lower.containsAny(["tiếp tục", "resume", "chạy tiếp"])) {
      onMusicCommand?.call("resume");
      return "Tiếp tục phát nhạc nè! ▶️";
    }

    // ===== CONTEXT-BASED MATCHING (50% threshold) =====
    _Pattern? bestMatch;
    int maxMatch = 0;
    for (var pattern in _patterns) {
      int matchCount = pattern.keywords.where((kw) => lower.contains(kw)).length;
      // Tính % match
      final threshold = (pattern.keywords.length * 0.4).ceil();
      if (matchCount >= threshold && matchCount > maxMatch) {
        maxMatch = matchCount;
        bestMatch = pattern;
      }
    }

    if (bestMatch != null && maxMatch > 0) {
      String rawAnswer = bestMatch.answers[_rand.nextInt(bestMatch.answers.length)];
      rawAnswer = rawAnswer
          .replaceAll("{totalDays}", totalDays.toString())
          .replaceAll("{happyDays}", happyDays.toString())
          .replaceAll("{sadDays}", sadDays.toString());
      return rawAnswer;
    }

    // ===== SMART FALLBACK (50% related) =====
    // Check if any keyword partially matches
    double bestScore = 0;
    String? bestFallback;
    for (var pattern in _patterns) {
      double score = 0;
      for (var kw in pattern.keywords) {
        if (lower.contains(kw.substring(0, min(kw.length, 3)))) {
          score += 0.3;
        }
        if (lower.contains(kw)) {
          score += 0.7;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        if (pattern.answers.isNotEmpty) {
          bestFallback = pattern.answers[_rand.nextInt(pattern.answers.length)];
        }
      }
    }

    if (bestScore >= 0.5 && bestFallback != null) {
      return "🤔 Lulu nghĩ bạn đang nói về chủ đề này... $bestFallback";
    }

    return _fallbackReplies[_rand.nextInt(_fallbackReplies.length)];
  }

  final List<String> _fallbackReplies = [
    "Hmm, Lulu chưa hiểu lắm nhưng vẫn yêu hai bạn! 💖",
    "Nói thêm cho Lulu nghe đi! 🥺 Lulu tò mò lắm!",
    "Chủ đề này thú vị đó, nói thêm đi! 🎯",
    "Lulu đang suy nghĩ nè... 🤔 Có phải bạn muốn hỏi về tình yêu không? 💕",
    "Lulu vẫn luôn ở đây lắng nghe bạn! 🫂",
    "Bạn nói gì Lulu nghe với? Lulu muốn hiểu bạn hơn! 💬",
    "Câu này hơi khó với Lulu, nhưng Lulu sẽ cố gắng học hỏi! 📚",
    "Hãy thử hỏi Lulu về: nhạc, ăn uống, game, hay tình yêu nha! 💡",
  ];
}

class _Pattern {
  final List<String> keywords;
  final List<String> answers;
  const _Pattern(this.keywords, this.answers);
}

extension on String {
  bool containsAny(List<String> keywords) =>
      keywords.any((kw) => toLowerCase().contains(kw.toLowerCase()));
}

int min(int a, int b) => a < b ? a : b;