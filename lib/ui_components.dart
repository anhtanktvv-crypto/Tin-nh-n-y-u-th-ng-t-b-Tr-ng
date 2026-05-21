import 'package:flutter/material.dart';

// 🎨 Cute & Cozy Design System
class CuteColors {
  static const Color primary = Color(0xFFFF7DAE);      // Hồng cute
  static const Color secondary = Color(0xFFFFB6D9);    // Hồng nhạt
  static const Color accent = Color(0xFFFFD6E7);       // Hồng rất nhạt
  static const Color background = Color(0xFFFFF6F9);   // Nền kem
  static const Color cardBg = Color(0xFFFFFFFF);       // Trắng card
  static const Color textDark = Color(0xFF2D2D2D);     // Chữ tối
  static const Color textLight = Color(0xFF7D7D7D);    // Chữ nhạt
  static const Color success = Color(0xFF4CAF50);      // Xanh lá
  static const Color warning = Color(0xFFFFC107);      // Vàng
  static const Color danger = Color(0xFFFF6B6B);       // Đỏ
}

class CuteTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    primaryColor: CuteColors.primary,
    scaffoldBackgroundColor: CuteColors.background,
    cardTheme: CardThemeData(
      color: CuteColors.cardBg,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: CuteColors.primary.withValues(alpha: 0.1),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: CuteColors.primary,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: CuteColors.cardBg,
      selectedItemColor: CuteColors.primary,
      unselectedItemColor: CuteColors.textLight,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: CuteColors.textDark, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: CuteColors.textDark),
      bodyMedium: TextStyle(color: CuteColors.textLight),
    ),
  );
}

// 🎀 Cute Button Widgets
class CuteButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isSmall;

  const CuteButton({
    required this.label,
    required this.onTap,
    this.color,
    this.isSmall = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: child,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 14 : 20,
            vertical: isSmall ? 8 : 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color ?? CuteColors.primary, (color ?? CuteColors.primary).withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isSmall ? 20 : 30),
            boxShadow: [
              BoxShadow(
                color: CuteColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isSmall ? 12 : 14,
            ),
          ),
        ),
      ),
    );
  }
}

// 🎀 Cute Card Widget
class CuteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? bgColor;
  final double borderRadius;

  const CuteCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.bgColor,
    this.borderRadius = 24,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor ?? CuteColors.cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: CuteColors.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// 🎀 Avatar with Status
class AvatarWithStatus extends StatelessWidget {
  final String imagePath;
  final String name;
  final bool isOnline;
  final VoidCallback? onTap;

  const AvatarWithStatus({
    required this.imagePath,
    required this.name,
    required this.isOnline,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage(imagePath),
                backgroundColor: CuteColors.accent,
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: CuteColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: CuteColors.success.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: CuteColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// 🎀 Mochi Character Widget
class MochiCharacter extends StatefulWidget {
  final String message;
  final bool isThinking;
  final VoidCallback? onTap;

  const MochiCharacter({
    required this.message,
    this.isThinking = false,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<MochiCharacter> createState() => _MochiCharacterState();
}

class _MochiCharacterState extends State<MochiCharacter> with TickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -10 * (_bounceController.value > 0.5 ? 1 - _bounceController.value : _bounceController.value)),
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CuteColors.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: CuteColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 48)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.isThinking)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${['⚫', '⚪', '⚫'][(_bounceController.value * 3).toInt()]} '),
                Text('${['⚫', '⚪', '⚫'][((_bounceController.value * 3 + 1) % 3).toInt()]} '),
                Text('${['⚫', '⚪', '⚫'][((_bounceController.value * 3 + 2) % 3).toInt()]}'),
              ],
            )
          else
            CuteCard(
              bgColor: CuteColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: 16,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CuteColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 🎀 Stat Widget
class StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color? valueColor;

  const StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CuteCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: CuteColors.textLight),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? CuteColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// 🎀 Enhanced Message Bubble
class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final String timestamp;
  final bool isMe;

  const MessageBubble({
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.isMe,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: BoxDecoration(
          gradient: isMe
              ? LinearGradient(
                  colors: [CuteColors.primary, CuteColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMe ? null : CuteColors.accent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isMe ? CuteColors.primary : CuteColors.secondary).withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : CuteColors.textDark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timestamp,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : CuteColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🎀 Interactive Game Button
class GameButton extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const GameButton({
    required this.emoji,
    required this.label,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.85).animate(_controller),
        child: CuteCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CuteColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
