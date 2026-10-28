import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ticket.dart';
import '../state/tickets_notifier.dart';
import '../widgets/bulk_resolve_dialog.dart';
import '../widgets/ticket_tile.dart';
import 'insights_screen.dart';
import 'search_screen.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final _scrollController = ScrollController();
  final _selectedIds = <int>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<TicketsNotifier>().refresh(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<TicketsNotifier>().loadMore();
    }
  }

  void _onSelectionChanged(Ticket ticket, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(ticket.id);
      } else {
        _selectedIds.remove(ticket.id);
      }
    });
  }

  void _openTicket(Ticket ticket) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)),
    );
  }

  Future<void> _delete(Ticket ticket) async {
    setState(() => _selectedIds.remove(ticket.id));
    await context.read<TicketsNotifier>().delete(ticket.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket #${ticket.id} deleted')),
    );
  }

  Future<void> _resolveSelected() async {
    final ids = _selectedIds.toList()..sort();
    final progress = context.read<TicketsNotifier>().resolveMany(ids);
    await showDialog<void>(
      context: context,
      builder: (_) => BulkResolveDialog(progress: progress, total: ids.length),
    );
  }

  void _assignSelected() {
    final ids = _selectedIds.toList()..sort();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Assigned ${ids.map((id) => '#$id').join(', ')} '
          'to the next available technician',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Insights',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InsightsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const _SummaryHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _selectedIds.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resolveSelected,
                        child: Text('Resolve ${_selectedIds.length}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _assignSelected,
                        child: Text('Assign ${_selectedIds.length} selected'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    final isInitialLoad =
        context.select((TicketsNotifier n) => n.isLoading && n.tickets.isEmpty);
    final hasError = context.select((TicketsNotifier n) => n.error != null);

    if (isInitialLoad) {
      return const Center(child: CircularProgressIndicator());
    }
    if (hasError) {
      return Center(
        child: TextButton(
          onPressed: () => context.read<TicketsNotifier>().refresh(),
          child: const Text("Couldn't load tickets. Tap to retry."),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TicketsNotifier>().refresh(),
      child: Selector<TicketsNotifier, List<Ticket>>(
        selector: (_, notifier) => notifier.tickets,
        builder: (context, tickets, _) => ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: tickets.length + 1,
          itemBuilder: (context, index) {
            if (index == tickets.length) return const _LoadMoreFooter();
            final ticket = tickets[index];
            return TicketTile(
              ticket: ticket,
              onTap: () => _openTicket(ticket),
              onSelectedChanged: (selected) =>
                  _onSelectionChanged(ticket, selected),
              onDelete: () => _delete(ticket),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context) {
    final openCount = context.select((TicketsNotifier n) => n.openCount);
    final loaded = context.select((TicketsNotifier n) => n.tickets.length);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text('$openCount open · $loaded loaded'),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter();

  @override
  Widget build(BuildContext context) {
    final isLoadingMore = context.select((TicketsNotifier n) => n.isLoadingMore);
    final hasMore = context.select((TicketsNotifier n) => n.hasMore);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: isLoadingMore
            ? const CircularProgressIndicator()
            : Text(hasMore ? '' : "You're all caught up"),
      ),
    );
  }
}
