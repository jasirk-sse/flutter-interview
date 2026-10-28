import 'package:flutter/material.dart';

import '../models/ticket.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      TicketStatus.open => (colors.errorContainer, colors.onErrorContainer),
      TicketStatus.inProgress => (
          colors.tertiaryContainer,
          colors.onTertiaryContainer
        ),
      TicketStatus.resolved => (
          colors.primaryContainer,
          colors.onPrimaryContainer
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: foreground),
      ),
    );
  }
}
