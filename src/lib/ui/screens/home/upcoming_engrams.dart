import 'package:flutter/material.dart';
import 'package:cerebrum_app/api/learning_center_api.dart';
import 'package:cerebrum_app/models/engram_models.dart';

class EngramItem {
  final String title;
  final String? time;
  final String engramId;

  const EngramItem({required this.title, required this.engramId, this.time});
}

class DaySchedule {
  final DateTime date;
  final List<EngramItem> items;

  const DaySchedule({required this.date, required this.items});
}

class UpcomingEngramsSection extends StatefulWidget {
  const UpcomingEngramsSection({super.key});

  @override
  State<UpcomingEngramsSection> createState() => _UpcomingEngramsSectionState();
}

class _UpcomingEngramsSectionState extends State<UpcomingEngramsSection> {
  bool _loading = true;
  List<DaySchedule> _days = const [];

  @override
  void initState() {
    super.initState();
    _loadEngrams();
  }

  Future<void> _loadEngrams() async {
    try {
      final response = await LearningCenterApi.listEngrams(
        bubbleId: "1edae102638a8cd7882e6de1c1e9639e",
        noteId: "01KTC4MWWA4YNSYNTYDYBEKB52",
        userId: "d6f3f2f2aff44185b7d97d160ffdec38",
      );

      if (!mounted) return;

      final items = response.engrams.map(_mapEngram).toList();

      // TODO: once due-date data is available, group by actual due date
      // instead of dumping everything under "today".
      setState(() {
        _days = [DaySchedule(date: DateTime.now(), items: items)];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  EngramItem _mapEngram(Engram e) {
    final title = switch (e.type) {
      EngramType.mcq => "MCQ",
      EngramType.flashcard => "Flashcard",
      EngramType.shortQuestion => "Short Q",
      EngramType.longQuestion => "Long Q",
      EngramType.unknown => "Engram",
    };

    return EngramItem(title: title, time: "", engramId: e.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 130,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_days.isEmpty) {
      return const SizedBox.shrink();
    }

    return UpcomingEngramsList(
      days: _days,
      onTapEngram: (item) {
        // Navigate to attempt screen
      },
    );
  }
}

/// Stacks one DayEngramsCard per day, cycling through the accent palette.
class UpcomingEngramsList extends StatelessWidget {
  final List<DaySchedule> days;
  final ValueChanged<EngramItem>? onTapEngram;

  const UpcomingEngramsList({super.key, required this.days, this.onTapEngram});

  static const _palette = [
    Color(0xffB8AFD1), // lavender
    Color(0xffCFA6A6), // dusty rose
    Color(0xff8FBFB3), // teal
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(days.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == days.length - 1 ? 0 : 12),
          child: DayEngramsCard(
            date: days[i].date,
            items: days[i].items,
            color: _palette[i % _palette.length],
            onTapEngram: onTapEngram,
          ),
        );
      }),
    );
  }
}

class DayEngramsCard extends StatelessWidget {
  final DateTime date;
  final List<EngramItem> items;
  final Color color;
  final ValueChanged<EngramItem>? onTapEngram;

  const DayEngramsCard({
    super.key,
    required this.date,
    required this.items,
    required this.color,
    this.onTapEngram,
  });

  static const _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  static const _months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          double
              .infinity, // fills available width — no horizontal scroll needed
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _days[date.weekday - 1],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff2F2940),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${date.day}",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    height: .9,
                    color: Color(0xff2F2940),
                  ),
                ),
                Text(
                  _months[date.month - 1],
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xff2F2940),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Slots stretch to fill remaining width — no fixed width, no scroll.
          Expanded(
            child:
                items.isEmpty
                    ? const SizedBox(height: 86)
                    : Row(
                      children: List.generate(items.length, (i) {
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.black.withOpacity(
                                    0.28,
                                  ), // bolder divider
                                  width: 1.5,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: EngramColumn(
                              item: items[i],
                              highlighted: i == 0,
                              onTap: () => onTapEngram?.call(items[i]),
                            ),
                          ),
                        );
                      }),
                    ),
          ),
        ],
      ),
    );
  }
}

class EngramColumn extends StatelessWidget {
  final EngramItem item;
  final bool highlighted;
  final VoidCallback? onTap;

  const EngramColumn({
    super.key,
    required this.item,
    required this.highlighted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.time ?? '',
            style: const TextStyle(fontSize: 10, color: Color(0xff2F2940)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 22,
            child:
                highlighted
                    ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xff4B4068),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                    : const SizedBox(),
          ),
          const Spacer(),
          InkWell(
            onTap: onTap,
            child: const Icon(
              Icons.add_circle_outline,
              size: 18,
              color: Color(0xff2F2940),
            ),
          ),
        ],
      ),
    );
  }
}
