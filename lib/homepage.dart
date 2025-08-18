import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Top Bar =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B3B3B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 28),
                    onPressed: () {},
                  )
                ],
              ),

              const SizedBox(height: 4),
              const Text(
                "Message of the day",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 12),
              // ===== Quote Card =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"Don\'t waste time knocking on the wall, hoping to turn it into a door."',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "—Coco Chanel",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // ===== Mood Section =====
              const Text(
                "How are you feeling today?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _MoodItem("😡", "V. Bad"),
                  _MoodItem("😞", "Bad"),
                  _MoodItem("😐", "Neutral"),
                  _MoodItem("😊", "Good"),
                  _MoodItem("😁", "V. Good"),
                ],
              ),

              const SizedBox(height: 24),
              // ===== Daily Stats =====
              const Text(
                "Daily Stats",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Water Tracker
              _StatCard(
                title: "Water",
                value: "1.5L / 2L",
                progress: 0.75,
                cups: 5,
              ),

              const SizedBox(height: 16),

              // Steps Tracker
              const _StepsCard(
                steps: 2245,
                goal: 10000,
              ),

              const SizedBox(height: 24),

              // ===== Mood Progress (interactive) =====
              const MoodTracker(),
            ],
          ),
        ),
      ),
    );
  }
}

// Mood icon row (top of screen)
class _MoodItem extends StatelessWidget {
  final String emoji;
  final String label;
  const _MoodItem(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}

// Water Stat Card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final int cups;
  const _StatCard({
    required this.title,
    required this.value,
    required this.progress,
    required this.cups,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(
                    cups,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(Icons.local_drink,
                          size: 28, color: Colors.green[400]),
                    ),
                  ),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle, color: Colors.green),
          )
        ],
      ),
    );
  }
}

// Steps Card
class _StepsCard extends StatelessWidget {
  final int steps;
  final int goal;
  const _StepsCard({required this.steps, required this.goal});

  @override
  Widget build(BuildContext context) {
    final double progress = steps / goal;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Steps",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            "$steps / $goal",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: Colors.green,
            minHeight: 6,
          ),
          const SizedBox(height: 4),
          Text("${(progress * 100).toStringAsFixed(0)}%",
              style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

// =============== Mood Tracker ===============
enum Mood { veryBad, bad, neutral, good, veryGood }
enum Period { weekly, monthly, annual }

class MoodTracker extends StatefulWidget {
  const MoodTracker({super.key});

  @override
  State<MoodTracker> createState() => _MoodTrackerState();
}

class _MoodTrackerState extends State<MoodTracker> {
  // In-memory mood log
  final Map<DateTime, Mood> _moodByDate = {};

  Period _period = Period.weekly;
  DateTime _anchorDate = DateTime.now();

  // UI helpers
  final _emoji = const {
    Mood.veryBad: "😡",
    Mood.bad: "😟",
    Mood.neutral: "😐",
    Mood.good: "🙂",
    Mood.veryGood: "😁",
  };

  final _barColor = const {
    Mood.veryBad: Colors.red,
    Mood.bad: Colors.orange,
    Mood.neutral: Colors.grey,
    Mood.good: Colors.lightGreen,
    Mood.veryGood: Colors.green,
  };

  // ---------- Date helpers ----------
  DateTime get _startOfWeek {
    final d = _anchorDate;
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
    // Monday as start of week
  }

  List<DateTime> get _daysOfWeek {
    final start = _startOfWeek;
    return List.generate(7, (i) => DateTime(start.year, start.month, start.day + i));
  }

  DateTime get _startOfMonth => DateTime(_anchorDate.year, _anchorDate.month, 1);
  int get _daysInMonth => DateTime(_anchorDate.year, _anchorDate.month + 1, 0).day;

  List<DateTime> get _weekStartsInMonth {
    final first = _startOfMonth;
    final last = DateTime(_anchorDate.year, _anchorDate.month, _daysInMonth);
    final List<DateTime> weeks = [];
    DateTime cursor = first.subtract(Duration(days: first.weekday - 1));
    while (cursor.isBefore(last) || _isSameDay(cursor, last)) {
      weeks.add(cursor);
      cursor = cursor.add(const Duration(days: 7));
    }
    // keep only weeks intersecting the month
    return weeks.where((w) {
      final end = w.add(const Duration(days: 6));
      return !(end.isBefore(first) || w.isAfter(last));
    }).toList();
  }

  // ---------- Mood pick ----------
  Future<void> _pickMoodFor(DateTime date) async {
    final selected = await showModalBottomSheet<Mood>(
      context: context,
      builder: (_) => SizedBox(
        height: 140,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: Mood.values.map((m) {
            return GestureDetector(
              onTap: () => Navigator.pop(context, m),
              child: Text(_emoji[m]!, style: const TextStyle(fontSize: 40)),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _moodByDate[_normalize(date)] = selected;
      });
    }
  }

  // ---------- Navigation ----------
  void _prevPeriod() {
    setState(() {
      switch (_period) {
        case Period.weekly:
          _anchorDate = _anchorDate.subtract(const Duration(days: 7));
          break;
        case Period.monthly:
          _anchorDate = DateTime(_anchorDate.year, _anchorDate.month - 1, 1);
          break;
        case Period.annual:
          _anchorDate = DateTime(_anchorDate.year - 1, 1, 1);
          break;
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      switch (_period) {
        case Period.weekly:
          _anchorDate = _anchorDate.add(const Duration(days: 7));
          break;
        case Period.monthly:
          _anchorDate = DateTime(_anchorDate.year, _anchorDate.month + 1, 1);
          break;
        case Period.annual:
          _anchorDate = DateTime(_anchorDate.year + 1, 1, 1);
          break;
      }
    });
  }

  Future<void> _pickAnchorDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchorDate,
      firstDate: DateTime(2018),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _anchorDate = picked);
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mood Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Tabs
          _Tabs(
            period: _period,
            onChanged: (p) => setState(() => _period = p),
          ),
          const SizedBox(height: 6),

          // Header (prev / title / next + calendar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundIcon(onTap: _prevPeriod, icon: Icons.chevron_left),
              Text(_periodTitle,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  _RoundIcon(onTap: _nextPeriod, icon: Icons.chevron_right),
                  const SizedBox(width: 6),
                  _RoundIcon(onTap: _pickAnchorDate, icon: Icons.calendar_today),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),

          // Chart
          _buildChart(),

          const SizedBox(height: 16),

          // Supportive message
          _SupportCard(message: _supportMessage),

          const SizedBox(height: 10),

          // Recommendation link
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecommendationsPage(
                      mood: _dominantMood ?? Mood.neutral),
                ),
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("See Recommendations"),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Chart builders ---
  Widget _buildChart() {
    switch (_period) {
      case Period.weekly:
        final days = _daysOfWeek;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((d) {
            final mood = _moodByDate[_normalize(d)];
            final double h =
            mood == null ? 0.0 : ((mood.index + 1) * 18.0);
            return GestureDetector(
              onTap: () => _pickMoodFor(d),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(mood == null ? "➕" : _emoji[mood]!,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 6),
                  Container(
                    width: 20,
                    height: h,
                    decoration: BoxDecoration(
                      color:
                      mood == null ? Colors.grey[300] : _barColor[mood],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(DateFormat.E().format(d),
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        );

      case Period.monthly:
      // average per week in this month
        final weeks = _weekStartsInMonth;
        final List<double> vals = weeks.map((ws) {
          final days = List.generate(7, (i) => ws.add(Duration(days: i)));
          final moods = days
              .where((d) => d.month == _anchorDate.month)
              .map((d) => _moodByDate[_normalize(d)])
              .whereType<Mood>()
              .toList();
          if (moods.isEmpty) return 0.0;
          final avg =
              moods.map((m) => m.index).reduce((a, b) => a + b) / moods.length;
          return avg.toDouble();
        }).toList();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(weeks.length, (i) {
            final double v = vals[i];
            final double h = v == 0.0 ? 0.0 : (v + 1) * 18.0;
            final Color? moodColor =
            v == 0.0 ? Colors.grey[300] : _barColor[Mood.values[v.round()]];
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 20), // no emoji on monthly bars
                Container(
                  width: 24,
                  height: h,
                  decoration: BoxDecoration(
                    color: moodColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text("W${i + 1}", style: const TextStyle(fontSize: 12)),
              ],
            );
          }),
        );

      case Period.annual:
      // average per month in this year
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(12, (m) {
            final monthStart = DateTime(_anchorDate.year, m + 1, 1);
            final days = List.generate(
                DateTime(_anchorDate.year, m + 2, 0).day,
                    (i) => DateTime(_anchorDate.year, m + 1, i + 1));
            final moods = days
                .map((d) => _moodByDate[_normalize(d)])
                .whereType<Mood>()
                .toList();
            final double v = moods.isEmpty
                ? 0.0
                : moods.map((e) => e.index).reduce((a, b) => a + b) /
                moods.length;
            final double h = v == 0.0 ? 0.0 : (v + 1) * 16.0;
            final Color? moodColor =
            v == 0.0 ? Colors.grey[300] : _barColor[Mood.values[v.round()]];
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 18,
                  height: h,
                  decoration: BoxDecoration(
                    color: moodColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(DateFormat.MMM().format(monthStart),
                    style: const TextStyle(fontSize: 10)),
              ],
            );
          }),
        );
    }
  }

  // --- Support message based on current period's average mood ---
  Mood? get _dominantMood {
    List<Mood> moods;
    switch (_period) {
      case Period.weekly:
        moods = _daysOfWeek
            .map((d) => _moodByDate[_normalize(d)])
            .whereType<Mood>()
            .toList();
        break;
      case Period.monthly:
        moods = List.generate(_daysInMonth, (i) => i + 1)
            .map((d) => _moodByDate[_normalize(
            DateTime(_anchorDate.year, _anchorDate.month, d))])
            .whereType<Mood>()
            .toList();
        break;
      case Period.annual:
        final List<Mood> all = [];
        for (int m = 1; m <= 12; m++) {
          final days = DateTime(_anchorDate.year, m + 1, 0).day;
          for (int d = 1; d <= days; d++) {
            final mood =
            _moodByDate[_normalize(DateTime(_anchorDate.year, m, d))];
            if (mood != null) all.add(mood);
          }
        }
        moods = all;
        break;
    }
    if (moods.isEmpty) return null;
    final double avg =
        moods.map((e) => e.index).reduce((a, b) => a + b) / moods.length;
    return Mood.values[avg.round()];
  }

  String get _periodTitle {
    switch (_period) {
      case Period.weekly:
        final first = _daysOfWeek.first;
        final last = _daysOfWeek.last;
        return "${DateFormat.MMMd().format(first)} - ${DateFormat.MMMd().format(last)}";
      case Period.monthly:
        return DateFormat.yMMMM().format(_anchorDate);
      case Period.annual:
        return DateFormat.y().format(_anchorDate);
    }
  }

  String get _supportMessage {
    final m = _dominantMood;
    if (m == null) {
      return "Log your mood this ${_period == Period.weekly ? "week" : _period == Period.monthly ? "month" : "year"} to see insights and tips.";
    }
    switch (m) {
      case Mood.veryBad:
        return "That sounds really tough. Try a 3-minute deep-breathing exercise. You’re not alone—small steps count.";
      case Mood.bad:
        return "Rough patch? A short walk or a cup of water can help reset your nervous system.";
      case Mood.neutral:
        return "Steady is good. Maybe try a gratitude note to lift the day a little.";
      case Mood.good:
        return "Nice! Keep the momentum—celebrate one win from today.";
      case Mood.veryGood:
        return "Love that energy! Share a kind word with someone and keep it going.";
    }
  }

  // utils
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// Segmented tabs
class _Tabs extends StatelessWidget {
  final Period period;
  final ValueChanged<Period> onChanged;
  const _Tabs({required this.period, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String text, Period p) => Expanded(
      child: GestureDetector(
        onTap: () => onChanged(p),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: period == p
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: period == p
                  ? const Color(0xFF4CAF50)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: period == p
                    ? const Color(0xFF2E7D32)
                    : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );

    return Row(
      children: [
        chip("Weekly", Period.weekly),
        const SizedBox(width: 8),
        chip("Monthly", Period.monthly),
        const SizedBox(width: 8),
        chip("Annual", Period.annual),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  const _RoundIcon({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}

// Support message card
class _SupportCard extends StatelessWidget {
  final String message;
  const _SupportCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("It seems like you had a harder time.",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

// ================= Recommendations Page =================
class RecommendationsPage extends StatelessWidget {
  final Mood mood;
  const RecommendationsPage({super.key, required this.mood});

  List<RecommendationItem> get _items {
    switch (mood) {
      case Mood.veryBad:
      case Mood.bad:
        return const [
          RecommendationItem("3-minute Box Breathing",
              "Quick exercise to calm the nervous system."),
          RecommendationItem("Grounding: 5-4-3-2-1",
              "Use senses to get present and reduce spirals."),
          RecommendationItem(
              "Reach Out", "Send a short message to a friend or hotline."),
        ];
      case Mood.neutral:
        return const [
          RecommendationItem(
              "Gratitude Note", "Write one thing you appreciate today."),
          RecommendationItem(
              "10-minute Walk", "Gentle movement to lift energy."),
          RecommendationItem(
              "Plan a Tiny Win", "Pick a task < 2 minutes."),
        ];
      case Mood.good:
      case Mood.veryGood:
        return const [
          RecommendationItem(
              "Share Kindness", "Send a thank-you text to someone."),
          RecommendationItem("Mindful Minute",
              "One minute of breathing to sustain momentum."),
          RecommendationItem("Stretch & Hydrate",
              "Keep the body happy too."),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recommendations"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final r = _items[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(r.subtitle,
                          style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RecommendationItem {
  final String title;
  final String subtitle;
  const RecommendationItem(this.title, this.subtitle);
}