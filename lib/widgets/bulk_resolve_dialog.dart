import 'package:flutter/material.dart';

class BulkResolveDialog extends StatelessWidget {
  const BulkResolveDialog({
    super.key,
    required this.progress,
    required this.total,
  });

  final Stream<int> progress;
  final int total;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: progress,
      builder: (context, snapshot) {
        final done = snapshot.data ?? 0;
        final finished = snapshot.connectionState == ConnectionState.done;
        return AlertDialog(
          title: Text(finished ? 'All done' : 'Resolving tickets…'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: done / total),
              const SizedBox(height: 12),
              Text('$done of $total resolved'),
            ],
          ),
          actions: [
            if (finished)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
          ],
        );
      },
    );
  }
}
