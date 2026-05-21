import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

// 🤖 Enhanced Mochi AI System
class MochiPet {
  // Pet state
  String mood = "😊 Vui vẻ";
  int happiness = 85;
  int energy = 80;
  DateTime lastFed = DateTime.now();
  DateTime lastPlayed = DateTime.now().subtract(const Duration(hours: 2));
  int petLevel = 1;
  int petExp = 0;

  // Personality
  final String name = "Mochi";
  final String personality = "Dễ thương, thông minh, yêu tình yêu";
  final List<String> nicknames = ["bé yêu", "em yêu", "người yêu", "anh/chị yêu"];

  // Memory
  final Map<String, dynamic> memory = {
    "partner1_name": "Gấu bông 3 tuổi rưỡi",
    "partner2_name": "Bé Trắng 1 tuổi rưỡi",
    "favorite_food": "bún bò Huế 🍜",
    "favorite_drink": "lục trà chanh 🧋",
    "favorite_songs": [
      "Ai Ngoài Anh - VSTRA",
      "Thế Giới Của Anh - Dangrangto",
      "Dạo Bước Hong Kong 1999",
    ],
    "favorite_dates": ["cafe đẹp", "picnic", "phim hay", "biển"],
    "special_memories": [],
  };

  // Knowledge base
  final List<MochiKnowledge> knowledge = [
    MochiKnowledge(
      topic: "love",
      keywords: ["yêu", "iu", "love", "thương", "tim"],
      responses: [
        "Mochi cũng yêu hai bạn nứt nẻ 💖",
        "Tình yêu này dễ thương quá! Mochi phát hiện romance 🥺",
        "Nắm tay nhau đi nào, Mochi thích cảnh này 🫂",
        "Hai bạn là OTP của Mochi, 10/10 ⭐",
        "Yêu nhau thì phải hôn lại nha 😘",
        "Mochi thấy tim hồng bay khắp nơi 💕",
      ],
    ),
    MochiKnowledge(
      topic: "miss",
      keywords: ["nhớ", "miss", "xa", "cô đơn", "thèm"],
      responses: [
        "Gọi điện video cho nhau đi 📱",
        "Yêu xa cần nhiều message yêu thương 💌",
        "Khoảng cách không ghét được tình cảm đâu 🌈",
        "Nhớ ai đó là cảm giác rất đặc biệt 💖",
        "Mochi gửi ôm online nè 🫂 Cầu bạn hai sớm gặp lại",
        "Người ta chắc cũng đang nhớ ông đó 🥺",
      ],
    ),
    MochiKnowledge(
      topic: "sad",
      keywords: ["buồn", "khóc", "stress", "tủi", "mệt", "chán"],
      responses: [
        "Có Mochi ở đây rồi, đừng buồn 🥺",
        "Ôm một cái, mọi chuyện rồi sẽ ổn 🫂",
        "Hãy kể cho Mochi nghe đi 💕",
        "Đừng ép bản thân quá nha, nghỉ ngơi đi ☁️",
        "Hôm nay khó nhưng ngày mai sẽ tươi 🌤️",
        "Mochi bật chế độ chữa lành ✨",
        "Khóc một tí cũng không sao, Mochi ở đây 🌷",
      ],
      actionType: "comfort",
    ),
    MochiKnowledge(
      topic: "food",
      keywords: ["ăn", "đói", "food", "bữa", "món ăn", "cơm", "bánh"],
      responses: [
        "Ăn bún bò Huế đi, Mochi mê lắm! 🍜",
        "Gà rán lúc buồn là cực đỉnh 🍗",
        "Pizza phô mai kéo sợi nè 🍕",
        "Bánh mì thịt nướng nóng giòn ghê 🥖",
        "Lẩu bò ăn trời mưa là tuyệt vời 🍲",
        "Sushi tươi ngon ghê 🍣",
        "Bánh tráng trộn cay cay là chân ái 🌶️",
      ],
      actionType: "suggestion",
    ),
    MochiKnowledge(
      topic: "drink",
      keywords: ["uống", "nước", "drink", "trà", "cà phê", "soda"],
      responses: [
        "Lục trà chanh trân châu đen ngon bá cháy 🧋",
        "Trà đào cam sả thơm phức 🍑",
        "Cafe sữa đá tỉnh ngủ cực mạnh ☕",
        "Sinh tố dâu dễ thương như Mochi 🍓",
        "Trà sữa trân châu gọi là chân lý 🧋",
      ],
    ),
    MochiKnowledge(
      topic: "date",
      keywords: ["đi chơi", "date", "hẹn hò", "đi", "quán"],
      responses: [
        "Đi xem phim lãng mạn đi 🎬",
        "Cafe chill tối nay nha ☕",
        "Dạo biển nghe sóng, Mochi thích lắm 🌊",
        "Đi food tour, khám phá đồ ngon nào 🍢",
        "Ngắm hoàng hôn là idea tuyệt đẹp 🌇",
        "Picnic lãng mạn cùng nhau 🧺",
      ],
      actionType: "date_suggestion",
    ),
    MochiKnowledge(
      topic: "music",
      keywords: ["nhạc", "music", "bài hát", "nghe", "playlist", "hát"],
      responses: [
        "Mochi đang nghe 'Ai Ngoài Anh' VSTRA nè 🎧",
        "'Thế Giới Của Anh' của Dangrangto chữa lành lắm 💖",
        "Dạo Bước Hong Kong 1999 - nghe vibe hoài niệm quá 🌃",
        "Nghe nhạc cùng người yêu là hạnh phúc nhất 🎵",
        "Mochi muốn nghe bài gì cho hai bạn? 🎶",
      ],
      actionType: "music",
    ),
    MochiKnowledge(
      topic: "gift",
      keywords: ["quà", "tặng", "sinh nhật", "ngày", "món quà"],
      responses: [
        "Một món quà handmade sẽ rất ý nghĩa 🎁",
        "Son môi, túi xách, gấu bông to đùng là lựa chọn hay 🧸",
        "Viết thư tay là quà tặng quý giá nhất 💌",
        "Ảnh couple cũ kỹ lưu niệm, Mochi yêu cái idea này 📸",
        "Voucher cafe hay resort? Mochi gợi ý nha 🎟️",
      ],
      actionType: "gift_suggestion",
    ),
  ];

  final Random _random = Random();

  // 🤖 Process query with Mochi AI
  MochiResponse askMochi(String question) {
    final lower = question.toLowerCase().trim();

    if (lower.isEmpty) {
      return MochiResponse(
        text: "Hỏi Mochi gì đi, Mochi đang sẵn sàng lắm 💖",
        emoji: "🤖",
        mood: "😊",
        action: null,
      );
    }

    // Find best matching knowledge
    MochiKnowledge? bestMatch;
    int maxMatches = 0;

    for (var kb in knowledge) {
      int matches = kb.keywords.where((kw) => lower.contains(kw)).length;
      if (matches > maxMatches) {
        maxMatches = matches;
        bestMatch = kb;
      }
    }

    String response;
    String action = "none";

    if (bestMatch != null && maxMatches > 0) {
      response = bestMatch.responses[_random.nextInt(bestMatch.responses.length)];
      action = bestMatch.actionType ?? "none";

      // Add context-aware suggestions
      if (bestMatch.topic == "sad") {
        mood = "😢 Lo lắng";
        happiness = (happiness - 15).clamp(0, 100);
      } else if (bestMatch.topic == "love") {
        happiness = (happiness + 10).clamp(0, 100);
      }
    } else {
      response = _getFallbackResponse(lower);
    }

    // Add Mochi's signature
    if (!response.contains(RegExp(r'[💖✨🥺🌷🫂💕☁️🎵]'))) {
      response += " ${["💖", "✨", "🥺", "🌷", "🫂"][_random.nextInt(5)]}";
    }

    return MochiResponse(
      text: response,
      emoji: "🤖",
      mood: mood,
      action: action,
    );
  }

  String _getFallbackResponse(String question) {
    final responses = [
      "Mochi chưa hiểu lắm nhưng vẫn yêu hai bạn 💖",
      "Nói thêm cho Mochi nghe đi 🥺",
      "Mochi đang suy nghĩ nè ✨",
      "Câu này hay quá, để Mochi nghĩ xem 😵",
      "Mochi vẫn luôn ở đây cho bạn 🫂",
    ];
    return responses[_random.nextInt(responses.length)];
  }

  // 🎮 Mini games
  String playGame(String gameType) {
    switch (gameType) {
      case "guess":
        return "Mochi nghĩ một số từ 1-10, bạn đoán được không 🎮";
      case "trivia":
        return "Bạn biết không? Trái tim hình trái tim ❤️ chỉ là huyền thoại, trái tim thực tế giống hành tây 😂";
      case "memory":
        return "Khoảnh khắc ngày ${_random.nextInt(17)}/10 là kỉ niệm tuyệt vời nhất của Mochi 🥺";
      case "quiz":
        return "Quiz tình yêu: Yêu nhau bao lâu rồi? Mochi quên mất 😭";
      default:
        return "Chơi gì nào? 🎮";
    }
  }

  // 📖 Tell story
  String tellStory(String storyType) {
    final stories = {
      "cute": "Một hôm, Gấu tìm Bé Trắng, Bé Trắng tìm Gấu, họ gặp nhau ở trạm sạc tình yêu... và rồi Mochi nhận ra, họ đã tìm nhau từ trước nên 💖",
      "funny":
          "Bạn biết gì? Mochi chứng kiến Gấu hôn Bé Trắng 420 cái trong một tuần. Ai tính thế này? 😂",
      "romantic": "Tình yêu không phải là lần nhìn đầu tiên, mà là lần nhìn cuối cùng bạn muốn. Gấu và Bé là vậy 💕",
    };
    return stories[storyType] ?? stories["cute"]!;
  }

  // Update pet state
  void feed() {
    lastFed = DateTime.now();
    energy = (energy + 30).clamp(0, 100);
    happiness = (happiness + 5).clamp(0, 100);
  }

  void play() {
    lastPlayed = DateTime.now();
    energy = (energy - 15).clamp(0, 100);
    happiness = (happiness + 20).clamp(0, 100);
    petExp += 10;
    _checkLevelUp();
  }

  void rest() {
    energy = (energy + 50).clamp(0, 100);
    happiness = (happiness + 10).clamp(0, 100);
  }

  void _checkLevelUp() {
    int newLevel = (petExp ~/ 100) + 1;
    if (newLevel > petLevel) {
      petLevel = newLevel;
    }
  }

  String getStatus() {
    if (energy < 30) {
      mood = "😴 Mệt";
    } else if (happiness < 40) {
      mood = "😢 Buồn";
    } else if (happiness > 80) {
      mood = "😊 Rất vui";
    } else {
      mood = "😌 Bình thường";
    }
    return "Mochi $mood | Level $petLevel | HP: $happiness% ⚡ $energy%";
  }
}

// 🎓 Knowledge base item
class MochiKnowledge {
  final String topic;
  final List<String> keywords;
  final List<String> responses;
  final String? actionType; // "comfort", "suggestion", "date_suggestion", etc.

  MochiKnowledge({
    required this.topic,
    required this.keywords,
    required this.responses,
    this.actionType,
  });
}

// 💬 Response object
class MochiResponse {
  final String text;
  final String emoji;
  final String mood;
  final String? action;

  MochiResponse({
    required this.text,
    required this.emoji,
    required this.mood,
    this.action,
  });
}

// 🎮 Mini game models
class MiniGame {
  final String id;
  final String title;
  final String emoji;
  final String description;

  MiniGame({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
  });
}

final List<MiniGame> availableGames = [
  MiniGame(id: "guess", title: "Đoán số", emoji: "🎯", description: "Mochi nghĩ một số, bạn đoán thử"),
  MiniGame(id: "trivia", title: "Sự thật hay hiểu lầm", emoji: "🧠", description: "Quiz tế nhị về tình yêu"),
  MiniGame(id: "memory", title: "Kỉ niệm yêu thương", emoji: "💕", description: "Nhớ lại khoảnh khắc đẹp"),
  MiniGame(id: "quiz", title: "Quiz cặp đôi", emoji: "🎭", description: "Quiz về mối quan hệ"),
  MiniGame(id: "story", title: "Kể chuyện", emoji: "📖", description: "Mochi kể chuyện yêu thương"),
];

// ------------------- LuLu AI (Local) -------------------
class LuluResponse {
  final String text;
  final LuluCommand? command;
  LuluResponse({required this.text, this.command});
}

class LuluCommand {
  final String action; // e.g., 'play'
  final String? file;
  LuluCommand({required this.action, this.file});
}

class LuluAI {
  final Map<String, String> memory = {};
  final Random _rand = Random();

  // Aliases for personalization
  final List<String> anhtanAliases = ["gấu bông mét tám", "gấu bông 3 tuổi rưỡi", "golden húi", "chồng iu của bé trắng", "gấu bông"];
  final List<String> quyennAliases = ["bé trắng 1 tuổi rưỡi", "bé trắng", "cục zàng iu của gấu bông", "chị quyên"];

  LuluResponse askLulu(String q) {
    final lower = q.toLowerCase().trim();

    if (lower.isEmpty) {
      return LuluResponse(text: 'LuLu chờ câu hỏi của anh nè, đừng ngại hỏi nhé 🥰');
    }

    // Learning: save simple facts with prefix "ghi nhớ:" or "nhớ rằng"
    if (lower.startsWith('ghi nhớ:') || lower.startsWith('nhớ rằng')) {
      final kv = q.split(':');
      if (kv.length >= 2) {
        final content = kv.sublist(1).join(':').trim();
        final key = 'note_${memory.length + 1}';
        memory[key] = content;
        _persistMemory();
        return LuluResponse(text: 'Đã ghi nhớ: "$content" 👍');
      }
    }

    // Love and relationship queries
    if (lower.contains('ngày yêu') || lower.contains('ngay yeu') || lower.contains('kỷ niệm') || lower.contains('ky niem') || lower.contains('bao lâu') || lower.contains('đếm ngày') || lower.contains('yêu nhau bao lâu')) {
      final startDate = _findLoveStartDate();
      if (startDate != null) {
        final days = DateTime.now().difference(startDate).inDays;
        final formatted = _formatDate(startDate);
        return LuluResponse(text: 'Ngày yêu của hai bạn là $formatted, đã yêu nhau $days ngày rồi 🥰. LuLu thấy tình yêu này rất ấm áp và dễ thương, cứ giữ nhau như vậy nhé.');
      }
      return LuluResponse(text: 'LuLu chưa biết chính xác ngày yêu, nhưng LuLu tin hai bạn đang có một câu chuyện thật đẹp và ngọt ngào ✨. Ghi nhớ ngày đó để LuLu kể chuyện nha.');
    }

    if (lower.contains('phong thủy') || lower.contains('phong thuy') || lower.contains('mệnh') || lower.contains('hợp nhau') || lower.contains('hợp mệnh') || lower.contains('sao') || lower.contains('cung')) {
      final fengs = [
        'LuLu thấy hai bạn như tách trà và bánh ngọt: mộc hợp hỏa, dễ làm tim nhau ấm áp. Năm nay nếu chọn ngày kỷ niệm vào các ngày 2, 9 hoặc 17 thì càng thêm may mắn 💫',
        'Phong thủy tình yêu: hãy giữ chữ tín và chân thành, nếu cùng nhau đi qua được giông bão thì hạnh phúc sẽ bền lâu như gốm sứ 🌹',
        'Cung mệnh hợp nhau nhất là khi hai bạn cùng cảm thông và biết chờ nhau. LuLu gợi ý mặc màu đỏ nhạt hoặc hồng nhạt khi đi chơi sẽ tăng cảm xúc yêu thương 🥰',
        'Năm nay chuyện tình cảm hợp với kiểu năng lượng “ấm áp”. Nếu muốn làm điều gì đó đặc biệt, chọn ngày 6 hoặc 14 sẽ rất hợp phong thủy ❤️',
      ];
      return LuluResponse(text: fengs[_rand.nextInt(fengs.length)]);
    }

    if (lower.contains('hạnh phúc') || lower.contains('hanh phuc') || lower.contains('vui vẻ') || lower.contains('ben lau') || lower.contains('chung thủy') || lower.contains('mãi mãi') || lower.contains('mai mai')) {
      final happy = [
        'Hạnh phúc là khi cả hai đều cảm thấy an toàn và được yêu thương, LuLu thấy hai bạn rất hợp rồi 💖',
        'LuLu tin rằng sự chân thành sẽ khiến tình yêu của hai bạn ngày càng sâu đậm hơn nữa ✨',
        'Hạnh phúc không phải là luôn đúng, mà là cùng nhau sửa sai và vẫn muốn nắm tay nhau 🫶',
      ];
      return LuluResponse(text: happy[_rand.nextInt(happy.length)]);
    }

    if (lower.contains('ngóng') || lower.contains('mong') || lower.contains('đợi') || lower.contains('doi') || lower.contains('háo hức') || lower.contains('hao huc')) {
      final longing = [
        'LuLu thấy anh đang ngóng em lắm rồi, tình cảm này đáng yêu quá 🥺',
        'Đợi nhau mà vẫn giữ được nụ cười là điều rất ngọt, LuLu gửi một cái ôm ảo cho hai bạn 🤗',
        'Ngóng là thương, thương là nhớ — LuLu hiểu cái cảm giác mong chờ này rất rõ 💕',
      ];
      return LuluResponse(text: longing[_rand.nextInt(longing.length)]);
    }

    // Simple music commands
    if (lower.contains('bật nhạc') || lower.contains('mở nhạc') || lower.contains('phát nhạc') || lower.contains('nghe nhạc') || lower.contains('tắt nhạc') || lower.contains('dừng nhạc') || lower.contains('tạm dừng')) {
      // detect song names
      if (lower.contains('a ngoai') || lower.contains('ai ngoài anh') || lower.contains('ai ngoai anh')) {
        return LuluResponse(text: 'Đã bật "Ai Ngoài Anh" 🎧', command: LuluCommand(action: 'play', file: 'AiNgoaiAnh.mp3'));
      }
      if (lower.contains('dao buoc') || lower.contains('dạo bước') || lower.contains('hong kong')) {
        return LuluResponse(text: 'Đã bật "Dạo Bước Hong Kong 1999" 🌃', command: LuluCommand(action: 'play', file: 'DaoBuocHongKong1999.mp3'));
      }
      if (lower.contains('thế giới') || lower.contains('the gioi')) {
        return LuluResponse(text: 'Đã bật "Thế Giới Của Anh" 💖', command: LuluCommand(action: 'play', file: 'the_gioi_cua_anh.mp3'));
      }
      // handle stop/pause
      if (lower.contains('tắt nhạc') || lower.contains('dừng nhạc')) return LuluResponse(text: 'Đã tắt nhạc 👋', command: LuluCommand(action: 'stop'));
      if (lower.contains('tạm dừng') || lower.contains('pause')) return LuluResponse(text: 'Tạm dừng âm nhạc ⏸️', command: LuluCommand(action: 'pause'));
      if (lower.contains('tiếp') || lower.contains('next') || lower.contains('tiếp theo') || lower.contains('bài sau')) return LuluResponse(text: 'Bài tiếp theo nè ▶️', command: LuluCommand(action: 'next'));
      if (lower.contains('lùi') || lower.contains('prev') || lower.contains('trước') || lower.contains('bài trước')) return LuluResponse(text: 'Quay lại bài trước ◀️', command: LuluCommand(action: 'prev'));
      // generic: play first preferred
      return LuluResponse(text: 'Đang bật một bài hát dễ thương 🎶', command: LuluCommand(action: 'play', file: 'AiNgoaiAnh.mp3'));
    }

    // Personalization queries
    if (anhtanAliases.any((a) => lower.contains(a))) {
      final answers = [
        'Anh Tấn à, gấu bông của chị Quyên đang nhớ anh lắm 🥺',
        'Gấu bông mét tám huhu, có nhớ Bé Trắng không? 💖',
        'Golden húi đang ở đây nè, ôm một cái! 🧸',
      ];
      return LuluResponse(text: answers[_rand.nextInt(answers.length)]);
    }
    if (quyennAliases.any((a) => lower.contains(a))) {
      final answers = [
        'Chị Quyên (Bé Trắng) đang cười xinh lắm 🥰',
        'Bé Trắng muốn ăn bún bò hoặc bánh mì nè 🍜🥖',
        'Cục Zàng iu của Gấu đang đợi tin nhắn của anh đó 💌',
      ];
      return LuluResponse(text: answers[_rand.nextInt(answers.length)]);
    }

    // Food suggestions
    if (lower.contains('ăn gì') || lower.contains('gợi ý') || lower.contains('món ăn') || lower.contains('đề xuất')) {
      final foods = ['Bún bò', 'Bún thịt nướng', 'Bánh mì', 'Pizza', 'Sushi'];
      return LuluResponse(text: 'Gợi ý món ăn: ${foods[_rand.nextInt(foods.length)]}');
    }

    // Quậy quậy
    if (lower.contains('quậy') || lower.contains('quậy quậy')) {
      final acts = ['Nói xấu nhẹ nhàng thôi nha 😜', 'Mochi... ủa LuLu quậy nè 😂', 'Đùa thôi mà, ôm nhau đi! 🫂'];
      return LuluResponse(text: acts[_rand.nextInt(acts.length)]);
    }

    // Fallback: try to mirror and store in memory for learning
    // Save Q->A pair: here we generate a friendly reply and remember the Q
    memory['q_${memory.length + 1}'] = q;
    _persistMemory();
    final fallback = [
      'LuLu nghe nè: $q... nhưng LuLu muốn biết thêm 😄',
      'Ồ, anh hỏi hay đó! LuLu sẽ trả lời: $q (LuLu đang học thêm)',
      'Câu hỏi thú vị — LuLu sẽ ghi lại để học dần nhé 💾',
    ];
    return LuluResponse(text: fallback[_rand.nextInt(fallback.length)]);
  }

  DateTime? _findLoveStartDate() {
    final dateRegex = RegExp(r'(\d{1,2})[\/\-.](\d{1,2})(?:[\/\-.](\d{2,4}))?');
    for (final value in memory.values) {
      final match = dateRegex.firstMatch(value);
      if (match != null) {
        final day = int.tryParse(match.group(1)!) ?? 0;
        final month = int.tryParse(match.group(2)!) ?? 0;
        var year = DateTime.now().year;
        if (match.group(3) != null) {
          final rawYear = match.group(3)!;
          year = rawYear.length == 2 ? int.parse('20$rawYear') : int.tryParse(rawYear) ?? year;
        }
        try {
          return DateTime(year, month, day);
        } catch (_) {
          continue;
        }
      }
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  Future<void> loadMemory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('lulu_memory') ?? [];
    memory.clear();
    for (var i = 0; i < saved.length; i++) {
      memory['note_${i + 1}'] = saved[i];
    }
  }

  Future<void> saveMemory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('lulu_memory', memory.values.toList());
  }

  void _persistMemory() {
    saveMemory();
  }
}
