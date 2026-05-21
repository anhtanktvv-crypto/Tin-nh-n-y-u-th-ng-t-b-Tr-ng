import 'package:flutter/material.dart';
import 'ui_components.dart';

// 🏠 Dashboard Home Page - Responsive Layout
class DashboardHomePage extends StatelessWidget {
  final String userName;
  final bool isGauOnline;
  final bool isBeOnline;
  final int happyDays;
  final int totalDays;
  final String moodText;
  final String missingLevel;
  final String dailyMission;
  final String aiSuggestion;
  final int happinessPercent;
  final String mochiStatus;
  final VoidCallback? onPlayMusic;
  final bool isPlaying;
  final List<Widget> messageWidgets;
  final Widget? chatInputWidget;
  final VoidCallback? onMochiTap;
  final String beReminder;
  final String currentReminder;
  final String currentWish;
  final ScrollController scrollController;
  final List<Widget> bubbles;
  final bool showBubble;
  final String bubbleText;
  final String bubbleEmoji;

  const DashboardHomePage({
    required this.userName,
    required this.isGauOnline,
    required this.isBeOnline,
    required this.happyDays,
    required this.totalDays,
    required this.moodText,
    required this.missingLevel,
    required this.dailyMission,
    required this.aiSuggestion,
    required this.happinessPercent,
    required this.mochiStatus,
    this.onPlayMusic,
    required this.isPlaying,
    required this.messageWidgets,
    this.chatInputWidget,
    this.onMochiTap,
    required this.beReminder,
    required this.currentReminder,
    required this.currentWish,
    required this.scrollController,
    required this.bubbles,
    required this.showBubble,
    required this.bubbleText,
    required this.bubbleEmoji,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CuteColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Mobile/Tablet layout - single column
          if (constraints.maxWidth < 1024) {
            return _buildMobileLayout();
          }
          // Desktop layout - sidebar + content
          else {
            return Row(
              children: [
                // Left sidebar
                SizedBox(width: 320, child: _buildSidebar(context)),
                // Main content
                Expanded(child: _buildMainContent(context, constraints)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(),
          _buildStatCards(),
          _buildRemindersSection(),
          _buildMochiCard(),
          _buildChatSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CuteColors.primary.withValues(alpha: 0.1), CuteColors.secondary.withValues(alpha: 0.05)],
        ),
        border: Border(right: BorderSide(color: CuteColors.accent, width: 2)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          // Profile section
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CuteColors.cardBg,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: CuteColors.primary.withValues(alpha: 0.2), blurRadius: 12)],
                  ),
                  child: const Text('💖', style: TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 12),
                Text(
                  'Yêu thương',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${totalDays} ngày bên nhau',
                  style: const TextStyle(fontSize: 12, color: CuteColors.textLight),
                ),
              ],
            ),
          ),
          const Divider(height: 32),

          // Quick stats
          ..._buildQuickStats(),
          const Divider(height: 32),

          // Reminders
          Text(
            '📌 Lời nhắc',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 12),
          CuteCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(beReminder, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Text(currentReminder, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CuteCard(
            padding: const EdgeInsets.all(12),
            child: Text(currentWish, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuickStats() {
    return [
      StatCard(
        icon: '😊',
        label: 'Hạnh phúc',
        value: '$happinessPercent%',
        valueColor: happinessPercent > 70 ? CuteColors.success : CuteColors.warning,
      ),
      const SizedBox(height: 12),
      StatCard(
        icon: '🥺',
        label: 'Nhớ nhau',
        value: missingLevel,
      ),
      const SizedBox(height: 12),
      StatCard(
        icon: '❤️',
        label: 'Tâm trạng',
        value: moodText,
      ),
      const SizedBox(height: 12),
      StatCard(
        icon: '🤖',
        label: 'Mochi',
        value: mochiStatus,
      ),
    ];
  }

  Widget _buildMainContent(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildMochiCard(),
                const SizedBox(height: 24),
                _buildChatSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CuteColors.primary.withValues(alpha: 0.15), CuteColors.secondary.withValues(alpha: 0.1)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage("assets/gau_bong.png"),
                    backgroundColor: CuteColors.accent,
                  ),
                  const SizedBox(height: 12),
                  const Text("🧸 Gấu", style: TextStyle(fontWeight: FontWeight.bold)),
                  if (isGauOnline)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text("🟢 Online", style: TextStyle(fontSize: 10, color: CuteColors.success)),
                    ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '💖',
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${totalDays} ngày',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage("assets/be_trang.png"),
                    backgroundColor: CuteColors.accent,
                  ),
                  const SizedBox(height: 12),
                  const Text("🐰 Bé", style: TextStyle(fontWeight: FontWeight.bold)),
                  if (isBeOnline)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text("🟢 Online", style: TextStyle(fontSize: 10, color: CuteColors.success)),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(child: StatCard(icon: '😊', label: 'Hạnh phúc', value: '$happinessPercent%')),
          const SizedBox(width: 12),
          Expanded(child: StatCard(icon: '🥺', label: 'Nhớ nhau', value: missingLevel)),
          const SizedBox(width: 12),
          Expanded(child: StatCard(icon: '❤️', label: 'Tâm trạng', value: moodText)),
        ],
      ),
    );
  }

  Widget _buildRemindersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📌 Lời nhắc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          CuteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(beReminder, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Text(currentReminder, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Text(currentWish, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMochiCard() {
    return CuteCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('🤖 Mochi AI - Thú cưng dễ thương', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 Gợi ý', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(aiSuggestion, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📋 Nhiệm vụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(dailyMission, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatSection() {
    return CuteCard(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('💬 Tin nhắn gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              controller: scrollController,
              itemCount: messageWidgets.length,
              itemBuilder: (c, i) => messageWidgets[i],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: chatInputWidget ?? const SizedBox(),
          ),
        ],
      ),
    );
  }
}
