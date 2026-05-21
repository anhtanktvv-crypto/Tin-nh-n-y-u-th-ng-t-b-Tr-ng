import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ================== GLASS CONTAINER ==================
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.borderColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.glassGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor?.withValues(alpha: 0.5) ??
              Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ================== AVATAR WITH ONLINE STATUS ==================
class AvatarWithStatus extends StatelessWidget {
  final String name;
  final bool online;
  final Color color;
  final String imageAsset;
  final double radius;
  final bool showRemindIcon;
  final VoidCallback? onRemind;
  final VoidCallback? onPin;

  const AvatarWithStatus({
    super.key,
    required this.name,
    required this.online,
    required this.color,
    this.imageAsset = 'assets/gau_bong.png',
    this.radius = 28,
    this.showRemindIcon = false,
    this.onRemind,
    this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: radius,
              backgroundImage: AssetImage(imageAsset),
              backgroundColor: Colors.white,
            ),
            if (online)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showRemindIcon)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onRemind != null)
                _iconButton(Icons.favorite, Colors.pinkAccent, 14, onRemind!),
              if (onPin != null)
                _iconButton(Icons.push_pin, Colors.blueAccent, 14, onPin!),
            ],
          ),
      ],
    );
  }

  Widget _iconButton(IconData icon, Color color, double size, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

// ================== INFO TILE ==================
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String content;
  final Color color;
  final VoidCallback? onEdit;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.content,
    required this.color,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(color: Colors.white, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70, size: 14),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ]),
    );
  }
}

// ================== STAT CHIP ==================
class StatChip extends StatelessWidget {
  final String text;
  final Color color;
  final bool edit;

  const StatChip(this.text, this.color, {super.key, this.edit = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 11)),
        if (edit) const Icon(Icons.edit, color: Colors.white70, size: 14),
      ]),
    );
  }
}

// ================== ISLAND ICON ==================
class IslandIcon extends StatelessWidget {
  final String image;
  final String actionName;
  final VoidCallback? onTap;

  const IslandIcon({
    super.key,
    required this.image,
    required this.actionName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.pink.withValues(alpha: 0.3), blurRadius: 8)],
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundImage: AssetImage(image),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

// ================== ACTION GRID ==================
class ActionGrid extends StatelessWidget {
  final List<Map<String, String>> actions;
  final void Function(Map<String, String> action) onActionTap;

  const ActionGrid({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: actions.length,
      itemBuilder: (ctx, i) {
        final act = actions[i];
        return GestureDetector(
          onTap: () => onActionTap(act),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/${act['i']}',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Center(
                      child: Text(act['e'] ?? '❤️', style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                act['n']!,
                style: const TextStyle(color: Colors.white, fontSize: 9),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ================== CATEGORY TABS ==================
class CategoryTabs extends StatelessWidget {
  final List<Map<String, String>> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final isSelected = selectedCategory == cat['key'];
          return GestureDetector(
            onTap: () => onCategoryChanged(cat['key']!),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.pinkAccent
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
              ),
              child: Text(cat['title']!, style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          );
        },
      ),
    );
  }
}

// ================== QUICK FLIRT ROW ==================
class QuickFlirtRow extends StatelessWidget {
  final List<Map<String, String>> quickFlirts;
  final ValueChanged<String> onFlirtTap;

  const QuickFlirtRow({
    super.key,
    required this.quickFlirts,
    required this.onFlirtTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: quickFlirts.length,
        itemBuilder: (ctx, i) {
          final item = quickFlirts[i];
          return GestureDetector(
            onTap: () => onFlirtTap("${item['emoji']} ${item['text']}"),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.5), width: 1),
              ),
              child: Row(children: [
                Text(item['emoji']!, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 3),
                Text(item['text']!, style: const TextStyle(color: Colors.white, fontSize: 9)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ================== CHAT BUBBLE ==================
class ChatBubble extends StatelessWidget {
  final String sender;
  final String text;
  final String timeStr;
  final bool isMe;
  final String avatarAsset;

  const ChatBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.timeStr,
    required this.isMe,
    this.avatarAsset = 'assets/gau_bong.png',
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage(avatarAsset),
                backgroundColor: Colors.transparent,
              ),
            if (!isMe) const SizedBox(width: 4),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.blue.withValues(alpha: 0.6)
                      : Colors.pink.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(isMe ? 14 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 14),
                  ),
                  border: Border.all(
                    color: isMe
                        ? Colors.blue.withValues(alpha: 0.3)
                        : Colors.pink.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    if (timeStr.isNotEmpty)
                      Text(
                        timeStr,
                        style: const TextStyle(color: Colors.white70, fontSize: 8),
                      ),
                  ],
                ),
              ),
            ),
            if (isMe) const SizedBox(width: 4),
            if (isMe)
              CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage(avatarAsset),
                backgroundColor: Colors.transparent,
              ),
          ],
        ),
      ),
    );
  }
}

// ================== FLOATING HEART ==================
class FloatingHeart extends StatefulWidget {
  final int index;

  const FloatingHeart({super.key, required this.index});

  @override
  State<FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<FloatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 3000 + widget.index * 500),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = Random(widget.index);
    final left = random.nextDouble() * size.width;

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Positioned(
          left: left,
          top: size.height * 0.1 + _floatAnimation.value * size.height * 0.8,
          child: Opacity(
            opacity: 0.3 * (1 - _floatAnimation.value),
            child: Transform.scale(
              scale: 0.5 + _floatAnimation.value * 0.5,
              child: Icon(
                Icons.favorite,
                color: widget.index % 2 == 0 ? Colors.pink : Colors.red,
                size: 15 + (widget.index % 3) * 5,
              ),
            ),
          ),
        );
      },
    );
  }
}