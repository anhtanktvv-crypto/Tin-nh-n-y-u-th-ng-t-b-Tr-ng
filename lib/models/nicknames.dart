import 'dart:math';

class CoupleNicknames {
  static final Random _rand = Random();

  // Biệt danh của Anh Tấn - Gấu bông
  static const List<String> gauNicknames = [
    "Gấu bông 3 tuổi rưỡi",
    "Gấu bông mét tám",
    "Golden húi",
    "Chồng iu của chị Quyên",
    "Gấu bông",
    "Anh Tấn",
  ];

  // Biệt danh của Chị Quyên - Bé Trắng
  static const List<String> beNicknames = [
    "Bé Trắng 1 tuổi rưỡi",
    "Bé Trắng",
    "MyQ",
    "Cục Zang",
    "Vợ iu của anh Tấn",
    "Chị Quyên",
    "Bé Trắng của anh",
  ];

  /// Lấy biệt danh ngẫu nhiên cho Gấu bông
  static String getRandomGauName() {
    return gauNicknames[_rand.nextInt(gauNicknames.length)];
  }

  /// Lấy biệt danh ngẫu nhiên cho Bé Trắng
  static String getRandomBeName() {
    return beNicknames[_rand.nextInt(beNicknames.length)];
  }

  /// Lấy cặp biệt danh ngẫu nhiên
  static Map<String, String> getRandomPair() {
    return {
      "gau": getRandomGauName(),
      "be": getRandomBeName(),
    };
  }

  /// Kiểm tra xem tên có phải là Gấu bông không (dựa trên biệt danh)
  static bool isGau(String name) {
    final lower = name.toLowerCase();
    return lower.contains("gấu") || 
           lower.contains("golden") || 
           lower.contains("húi") ||
           lower.contains("tấn") ||
           lower.contains("chồng");
  }

  /// Kiểm tra xem tên có phải là Bé Trắng không
  static bool isBe(String name) {
    final lower = name.toLowerCase();
    return lower.contains("bé") || 
           lower.contains("trắng") ||
           lower.contains("myq") || 
           lower.contains("cục") || 
           lower.contains("quyên") ||
           lower.contains("vợ");
  }

  /// Lấy biệt danh thân mật ngẫu nhiên để AI LuLu gọi
  static String getRandomSweetName(bool isGau) {
    if (isGau) {
      final names = ["Gấu bông", "Golden húi", "Anh Tấn", "Chồng iu"];
      return names[_rand.nextInt(names.length)];
    } else {
      final names = ["Bé Trắng", "MyQ", "Cục Zang", "Vợ iu"];
      return names[_rand.nextInt(names.length)];
    }
  }

  /// Lấy lời chào ngẫu nhiên theo biệt danh
  static String getRandomGreeting(String userName) {
    final isGauUser = isGau(userName);
    final sweet = getRandomSweetName(isGauUser);
    final greetings = [
      "Chào $sweet! Hôm nay muốn làm gì với người yêu thương? 💕",
      "$sweet ơi! Lulu nhớ hai bạn quá! 🥺",
      "Ôi $sweet đã vào app rồi! Có cần Lulu giúp gì không? 💖",
      "Alo alo! $sweet vừa vào Love Station! 🎉",
      "Lulu chào $sweet! Chúc hai bạn luôn hạnh phúc! 🌹",
      "$sweet của Lulu ơi, hôm nay có chuyện gì vui kể Lulu nghe với! 💬",
    ];
    return greetings[_rand.nextInt(greetings.length)];
  }
}