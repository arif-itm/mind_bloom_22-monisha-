import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';

/// Use this page as a single entry in your app:
/// Navigator.push(context, MaterialPageRoute(builder: (_) => WellnessSinglePage()));
class WellnessSinglePage extends StatefulWidget {
  const WellnessSinglePage({super.key});

  @override
  State<WellnessSinglePage> createState() => _WellnessSinglePageState();
}

class _WellnessSinglePageState extends State<WellnessSinglePage> {
  final ScrollController _scroll = ScrollController();

  // section anchors
  final _homeKey = GlobalKey();
  final _sleepKey = GlobalKey();
  final _dietKey = GlobalKey();
  final _exerciseKey = GlobalKey();
  final _mindfulnessKey = GlobalKey();
  final _chatKey = GlobalKey();
  final _meditationKey = GlobalKey();

  // search (filters meditation items)
  String _search = '';

  // meditation chart state
  int? _touchedIndex;

  // Demo meditation data (minutes)
  final List<_MeditationSlice> _meditationData = [
    _MeditationSlice('Breathing', 22),
    _MeditationSlice('Guided', 31),
    _MeditationSlice('Mindfulness', 17),
    _MeditationSlice('Yoga Nidra', 14),
  ];

  // demo content to filter under Meditation “Explore” list
  final List<_MeditationItem> _catalog = [
    _MeditationItem(
      title: 'Box Breathing (3-min)',
      type: 'Breathing',
      image:
      'https://images.unsplash.com/photo-1516822003754-cca485356ecb?q=80&w=1200&auto=format&fit=crop',
      videoUrl: 'https://youtu.be/tEmt1Znux58',
    ),
    _MeditationItem(
      title: 'Guided Body Scan (7-min)',
      type: 'Guided',
      image:
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=1200&auto=format&fit=crop',
      videoUrl: 'https://youtu.be/sG7DBA-mgFY',
    ),
    _MeditationItem(
      title: 'Mindfulness Bell (5-min)',
      type: 'Mindfulness',
      image:
      'https://images.unsplash.com/photo-1518131678677-a9b669e3eac9?q=80&w=1200&auto=format&fit=crop',
      videoUrl: 'https://youtu.be/64QzBuhsyuk',
    ),
    _MeditationItem(
      title: 'Yoga Nidra (10-min)',
      type: 'Yoga Nidra',
      image:
      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=1200&auto=format&fit=crop',
      videoUrl: 'https://youtu.be/M0u9GST_j3s',
    ),
  ];

  // Diet chart demo data (weekly minutes of “healthy routine” or you can treat as score)
  final List<int> _dietScores = [60, 45, 70, 55, 80, 66, 72];

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  void _jumpTo(GlobalKey key) {
    // find the position of the section and animate scroll
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      alignment: 0.05,
    );
  }

  int get _totalMeditation =>
      _meditationData.fold(0, (sum, e) => sum + e.minutes);

  @override
  Widget build(BuildContext context) {
    final filtered = _catalog
        .where((e) =>
    e.title.toLowerCase().contains(_search.toLowerCase()) ||
        e.type.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Wellness'),
        centerTitle: false,
        backgroundColor: const Color(0xFF4CAF50),
        actions: [
          IconButton(
            onPressed: () async {
              final res = await showSearch<String?>(
                context: context,
                delegate: _MeditationSearchDelegate(
                  initial: _search,
                  onSubmit: (q) => setState(() => _search = q ?? ''),
                ),
              );
              if (res != null) {
                setState(() => _search = res);
              }
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search meditation',
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          // Top nav chips
          SliverToBoxAdapter(
            child: Padding(
              key: _homeKey,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _navChip('Home', () => _jumpTo(_homeKey)),
                  _navChip('Sleep', () => _jumpTo(_sleepKey)),
                  _navChip('Diet', () => _jumpTo(_dietKey)),
                  _navChip('Exercise', () => _jumpTo(_exerciseKey)),
                  _navChip('Mindfulness', () => _jumpTo(_mindfulnessKey)),
                  _navChip('Meditation', () => _jumpTo(_meditationKey)),
                  _navChip('Chat AI', () => _jumpTo(_chatKey)),
                ],
              ),
            ),
          ),

          // Hero card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _heroCard(),
            ),
          ),

          // Sleep Section
          _sectionHeader('Sleep', _sleepKey, onSeeAll: () {
            _jumpTo(_sleepKey);
          }),
          SliverToBoxAdapter(child: _sleepContent()),

          // Diet Section (with interactive bar chart)
          _sectionHeader('Diet', _dietKey),
          SliverToBoxAdapter(child: _dietContent()),

          // Exercise Section
          _sectionHeader('Exercise', _exerciseKey),
          SliverToBoxAdapter(child: _exerciseContent()),

          // Mindfulness Section
          _sectionHeader('Mindfulness', _mindfulnessKey),
          SliverToBoxAdapter(child: _mindfulnessContent()),

          // Meditation Section (with interactive DONUT chart)
          _sectionHeader('Meditation', _meditationKey),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _meditationDonut(),
                  const SizedBox(height: 18),
                  const Text(
                    'Explore',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _meditationGrid(filtered),
                ],
              ),
            ),
          ),

          // EmoCare AI Chat Section
          _sectionHeader('EmoCare AI Chat', _chatKey),
          SliverToBoxAdapter(child: _chatIntro(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ---------- UI pieces ----------

  Widget _navChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF4CAF50), width: 1),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=1400&auto=format&fit=crop'),
          fit: BoxFit.cover,
          opacity: .18,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Message of the day',
              style: TextStyle(color: Colors.white70)),
          SizedBox(height: 8),
          Text(
            '“A calm breath steadies the mind. One small pause can change your day.”',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _sectionHeader(String title, GlobalKey key,
      {VoidCallback? onSeeAll}) {
    return SliverToBoxAdapter(
      child: Padding(
        key: key,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: const Text('See all'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sleepContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          _wideTile(
            title: 'Wind-down Routine',
            subtitle: '10-minute stretch + dim light',
            image:
            'https://images.unsplash.com/photo-1517232115160-ff93364542dd?q=80&w=1200&auto=format&fit=crop',
            trailing: ElevatedButton(
              onPressed: () => _openUrl('https://youtu.be/ZToicYcHIOU'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text('Video'),
            ),
          ),
          const SizedBox(height: 10),
          _wideTile(
            title: 'Sleep Stories',
            subtitle: 'Soothing voice & low music',
            image:
            'https://images.unsplash.com/photo-1527631746610-bca00a040d60?q=80&w=1200&auto=format&fit=crop',
            trailing: IconButton(
              onPressed: () => _openUrl('https://youtu.be/axJm0C8fT1A'),
              icon: const Icon(Icons.play_circle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dietContent() {
    // Interactive bar chart (weekly routine score)
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                    rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          final idx = v.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(idx >= 0 && idx < 7 ? days[idx] : ''),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'Score: ${rod.toY.toInt()}',
                          const TextStyle(fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: _dietScores[i].toDouble(),
                        width: 16,
                        borderRadius: BorderRadius.circular(6),
                      )
                    ]);
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _wideTile(
            title: 'Relaxation Foods',
            subtitle: 'Magnesium-rich recipes & hydration',
            image:
            'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?q=80&w=1200&auto=format&fit=crop',
            trailing: TextButton(
              onPressed: () => _openUrl('https://youtu.be/jE3ZJ2y9g2k'),
              child: const Text('Watch tips'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exerciseContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          _wideTile(
            title: 'Gentle Morning Flow',
            subtitle: '5 poses • 6-8 minutes',
            image:
            'https://images.unsplash.com/photo-1552196563-55cd4e45efb3?q=80&w=1200&auto=format&fit=crop',
            trailing: ElevatedButton(
              onPressed: () => _openUrl('https://youtu.be/v7AYKMP6rOE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text('Start'),
            ),
          ),
          const SizedBox(height: 10),
          _wideTile(
            title: 'Desk Reset',
            subtitle: '3-min stretch you can do anywhere',
            image:
            'https://images.unsplash.com/photo-1517346665566-17ad29585b14?q=80&w=1200&auto=format&fit=crop',
            trailing: IconButton(
              onPressed: () => _openUrl('https://youtu.be/fqQGZ7jC5nI'),
              icon: const Icon(Icons.play_circle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mindfulnessContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          _wideTile(
            title: '5-4-3-2-1 Grounding',
            subtitle: 'Quick anxiety reset using senses',
            image:
            'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=1200&auto=format&fit=crop',
            trailing: IconButton(
              onPressed: () => _openUrl('https://youtu.be/FJmZ6b2j-8E'),
              icon: const Icon(Icons.play_circle_fill),
            ),
          ),
        ],
      ),
    );
  }

  Widget _meditationDonut() {
    final total = _totalMeditation;
    final touched = _touchedIndex == null
        ? null
        : _meditationData[_touchedIndex!.clamp(0, _meditationData.length - 1)];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'This week’s practice',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 58,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      enabled: true,
                      touchCallback: (event, response) {
                        if (!event.isInterestedForInteractions ||
                            response?.touchedSection == null) {
                          setState(() => _touchedIndex = null);
                          return;
                        }
                        setState(() => _touchedIndex =
                            response!.touchedSection!.touchedSectionIndex);
                      },
                    ),
                    sections: List.generate(_meditationData.length, (i) {
                      final s = _meditationData[i];
                      final isTouched = i == _touchedIndex;
                      final percent =
                          s.minutes / (total == 0 ? 1 : total) * 100.0;
                      return PieChartSectionData(
                        value: s.minutes.toDouble(),
                        title:
                        '${s.label}\n${percent.toStringAsFixed(0)}%',
                        radius: isTouched ? 66 : 56,
                        titleStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isTouched ? 12 : 11,
                          color: Colors.black87,
                        ),
                      );
                    }),
                  ),
                ),
                // Center total / selected minutes
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        touched == null
                            ? '$total min'
                            : '${touched.minutes} min',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        touched?.label ?? 'total',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _meditationData.map((s) {
              return Chip(
                label: Text('${s.label} • ${s.minutes}m'),
                backgroundColor: const Color(0xFFE8F5E9),
                side: const BorderSide(color: Color(0xFF4CAF50)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _meditationGrid(List<_MeditationItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: .86,
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final it = items[i];
        return GestureDetector(
          onTap: () => _openUrl(it.videoUrl),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      it.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.type,
                          style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        it.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(Icons.play_circle_fill, size: 18),
                          SizedBox(width: 6),
                          Text('Watch'),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chatIntro(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EmoCare — Safe, authentic & secure',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'Share anything. Your space is private. The AI listens without judgement and guides with gentle prompts.',
              style: TextStyle(color: Colors.black87, height: 1.35),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.lock, size: 18),
                SizedBox(width: 6),
                Text('End-to-end security'),
                SizedBox(width: 12),
                Icon(Icons.verified_user, size: 18),
                SizedBox(width: 6),
                Text('No data selling'),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmoCareChatPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Open EmoCare'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wideTile({
    required String title,
    required String subtitle,
    required String image,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.horizontal(left: Radius.circular(14)),
            child: Image.network(
              image,
              width: 110,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (trailing != null) Padding(
            padding: const EdgeInsets.only(right: 10),
            child: trailing,
          ),
        ],
      ),
    );
  }
}

// ---------- Search Delegate ----------
class _MeditationSearchDelegate extends SearchDelegate<String?> {
  final String initial;
  final ValueChanged<String?> onSubmit;

  _MeditationSearchDelegate({required this.initial, required this.onSubmit})
      : super(searchFieldLabel: 'Search meditation…') {
    query = initial;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Clear',
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSubmit(query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ---------- EmoCare Chat Page (same file) ----------
class EmoCareChatPage extends StatefulWidget {
  const EmoCareChatPage({super.key});

  @override
  State<EmoCareChatPage> createState() => _EmoCareChatPageState();
}

class _EmoCareChatPageState extends State<EmoCareChatPage> {
  final List<_ChatMsg> _messages = [
    _ChatMsg(
      fromAI: true,
      text:
      'Hey, I’m here with you. What’s on your mind right now?',
      ts: DateTime.now(),
    ),
  ];
  final TextEditingController _ctrl = TextEditingController();

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(fromAI: false, text: text, ts: DateTime.now()));
      // lightweight, offline supportive echo
      _messages.add(
        _ChatMsg(
          fromAI: true,
          text:
          "Thanks for sharing. Try a slow breath in (4), hold (4), out (6). What would feel 1% better right now?",
          ts: DateTime.now(),
        ),
      );
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EmoCare AI Chat'),
        backgroundColor: const Color(0xFF4CAF50),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.lock),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final m = _messages[i];
                final align =
                m.fromAI ? CrossAxisAlignment.start : CrossAxisAlignment.end;
                final bubbleColor =
                m.fromAI ? const Color(0xFFF0FDF4) : const Color(0xFFE8F5E9);
                return Column(
                  crossAxisAlignment: align,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(12),
                        border:
                        Border.all(color: const Color(0xFF4CAF50), width: .6),
                      ),
                      child: Text(m.text),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        filled: true,
                        fillColor: const Color(0xFFF6F7F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    color: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Models ----------
class _MeditationSlice {
  final String label;
  final int minutes;
  _MeditationSlice(this.label, this.minutes);
}

class _MeditationItem {
  final String title;
  final String type;
  final String image;
  final String videoUrl;
  _MeditationItem({
    required this.title,
    required this.type,
    required this.image,
    required this.videoUrl,
  });
}

class _ChatMsg {
  final bool fromAI;
  final String text;
  final DateTime ts;
  _ChatMsg({required this.fromAI, required this.text, required this.ts});
}