import 'package:flutter/material.dart';

import '../models/ticket.dart';
import 'status_chip.dart';

class TicketTile extends StatefulWidget {
  const TicketTile({
    super.key,
    required this.ticket,
    required this.onTap,
    required this.onSelectedChanged,
    required this.onDelete,
  });

  final Ticket ticket;
  final VoidCallback onTap;
  final ValueChanged<bool> onSelectedChanged;
  final VoidCallback onDelete;

  @override
  State<TicketTile> createState() => _TicketTileState();
}

class _TicketTileState extends State<TicketTile> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _selected,
              onChanged: (value) {
                setState(() => _selected = value ?? false);
                widget.onSelectedChanged(_selected);
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${ticket.id} · ${ticket.customerName}',
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(ticket.address, style: textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(ticket.issue, style: textTheme.bodyMedium),
                const SizedBox(height: 6),
                StatusChip(status: ticket.status),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
