class Insights {
  const Insights({
    required this.readings,
    required this.totalKwh,
    required this.bestMonth,
    required this.bestMonthKwh,
    required this.underperformingPanels,
  });

  factory Insights.fromReadings(
    List<dynamic> readings, {
    required double underperformingBelow,
  }) {
    var total = 0.0;
    final byMonth = <DateTime, double>{};
    final byPanel = <int, double>{};
    for (final reading in readings.cast<Map<String, dynamic>>()) {
      final kwh = (reading['kwh'] as num).toDouble();
      final panel = reading['panel'] as int;
      final at = DateTime.fromMillisecondsSinceEpoch(
        (reading['ts'] as int) * 1000,
        isUtc: true,
      );
      final month = DateTime.utc(at.year, at.month);
      total += kwh;
      byMonth[month] = (byMonth[month] ?? 0) + kwh;
      byPanel[panel] = (byPanel[panel] ?? 0) + kwh;
    }

    final best = byMonth.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final panelAverage = total / byPanel.length;
    final weakPanels = [
      for (final entry in byPanel.entries)
        if (entry.value < panelAverage * underperformingBelow) entry.key,
    ]..sort();

    return Insights(
      readings: readings.length,
      totalKwh: total,
      bestMonth: best.key,
      bestMonthKwh: best.value,
      underperformingPanels: weakPanels,
    );
  }

  final int readings;
  final double totalKwh;
  final DateTime bestMonth;
  final double bestMonthKwh;
  final List<int> underperformingPanels;
}
