import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/ticket_repository.dart';
import '../models/insights.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final double _underperformingBelow = 0.9;
  late Future<Insights> _insights;

  @override
  void initState() {
    super.initState();
    _insights = _load();
  }

  Future<Insights> _load() async {
    final raw = await context.read<TicketRepository>().fetchTelemetry();
    return Isolate.run(() => _summarise(raw));
  }

  Insights _summarise(String raw) => Insights.fromReadings(
        jsonDecode(raw) as List,
        underperformingBelow: _underperformingBelow,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: FutureBuilder<Insights>(
        future: _insights,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Couldn't build insights."),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => setState(() => _insights = _load()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final insights = snapshot.data;
          if (insights == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _InsightsView(
            insights: insights,
            underperformingBelow: _underperformingBelow,
          );
        },
      ),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView({
    required this.insights,
    required this.underperformingBelow,
  });

  final Insights insights;
  final double underperformingBelow;

  @override
  Widget build(BuildContext context) {
    final kwh = NumberFormat.decimalPattern('en_IN');
    final weak = insights.underperformingPanels;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatCard(
          label: 'Generation, last 12 months',
          value: '${kwh.format(insights.totalKwh.round())} kWh',
        ),
        _StatCard(
          label: 'Best month',
          value: '${DateFormat('MMMM yyyy').format(insights.bestMonth)} · '
              '${kwh.format(insights.bestMonthKwh.round())} kWh',
        ),
        _StatCard(
          label:
              'Panels below ${(underperformingBelow * 100).round()}% of average',
          value: weak.isEmpty ? 'None' : weak.map((p) => 'Panel $p').join(', '),
        ),
        const SizedBox(height: 8),
        Text(
          'Based on ${kwh.format(insights.readings)} readings',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(value, style: textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
