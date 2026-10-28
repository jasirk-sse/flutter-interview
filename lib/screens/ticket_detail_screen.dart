import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/ticket_repository.dart';
import '../models/ticket.dart';
import '../models/ticket_detail.dart';
import '../state/tickets_notifier.dart';
import '../widgets/status_chip.dart';

final _visitFormat = DateFormat('EEE, d MMM · h:mm a');

String _rupees(double value) => '₹${value.toStringAsFixed(2)}';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.ticket});

  final Ticket ticket;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late final TicketRepository _repository;
  TicketDetail? _detail;
  bool _failed = false;
  bool _resolving = false;
  Duration _slaRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _repository = context.read<TicketRepository>();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final detail = await _repository.fetchDetail(widget.ticket.id);
      setState(() => _detail = detail);
      _startSlaCountdown(detail.slaDeadline);
    } catch (_) {
      setState(() => _failed = true);
    }
  }

  void _startSlaCountdown(DateTime deadline) {
    void tick() => setState(
          () => _slaRemaining = deadline.difference(DateTime.now()),
        );
    tick();
    Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  Future<void> _resolve() async {
    setState(() => _resolving = true);
    await context.read<TicketsNotifier>().resolve(widget.ticket.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket #${widget.ticket.id} resolved')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ticket #${widget.ticket.id}')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_failed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Couldn't load this ticket."),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final detail = _detail;
    if (detail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final ticket = detail.ticket;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(ticket.customerName, style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(ticket.address),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: Text(ticket.issue, style: textTheme.titleSmall)),
            StatusChip(status: ticket.status),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Visit',
          children: [
            _Row(label: 'Technician', value: detail.technician),
            _Row(
              label: 'Scheduled',
              value: _visitFormat.format(detail.scheduledAt),
            ),
            StreamBuilder<TechnicianEta>(
              stream: _repository.watchTechnicianEta(ticket.id),
              builder: (context, snapshot) => _Row(
                label: 'Live ETA',
                value: switch (snapshot.data?.etaMinutes) {
                  null => 'Locating technician…',
                  0 => 'Arrived',
                  final minutes => '$minutes min away',
                },
              ),
            ),
          ],
        ),
        _Section(
          title: 'SLA',
          children: [
            _Row(label: 'Respond within', value: _formatSla(_slaRemaining)),
          ],
        ),
        _Section(
          title: 'Invoice',
          children: [
            for (final item in detail.lineItems)
              _Row(label: item.description, value: _rupees(item.amount)),
            const Divider(),
            _Row(label: 'Subtotal', value: _rupees(detail.subtotal)),
            _Row(label: 'GST (18%)', value: _rupees(detail.gst)),
            _Row(label: 'Total', value: _rupees(detail.total)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: ticket.status == TicketStatus.resolved || _resolving
                    ? null
                    : _resolve,
                child: const Text('Mark resolved'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: Text('Collect ₹${detail.total}'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatSla(Duration remaining) {
    if (remaining.isNegative) return 'Breached';
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${h}h ${m}m ${s}s';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}
