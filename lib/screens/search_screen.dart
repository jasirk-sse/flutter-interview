import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/ticket_repository.dart';
import '../models/ticket.dart';
import '../widgets/status_chip.dart';
import 'ticket_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Ticket> _results = const [];
  bool _searching = false;

  Future<void> _onQueryChanged(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _searching = true);
    final results = await context.read<TicketRepository>().search(trimmed);
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search name, city or issue',
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
        ),
        bottom: _searching
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: ListView.separated(
        itemCount: _results.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final ticket = _results[index];
          return ListTile(
            title: Text('#${ticket.id} · ${ticket.customerName}'),
            subtitle: Text('${ticket.city} · ${ticket.issue}'),
            trailing: StatusChip(status: ticket.status),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TicketDetailScreen(ticket: ticket),
              ),
            ),
          );
        },
      ),
    );
  }
}
