import 'package:flutter/foundation.dart';

import '../data/ticket_repository.dart';
import '../models/ticket.dart';

class TicketsNotifier extends ChangeNotifier {
  TicketsNotifier(this._repository);

  final TicketRepository _repository;

  List<Ticket> _tickets = const [];
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  Object? _error;

  List<Ticket> get tickets => _tickets;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  Object? get error => _error;

  int get openCount =>
      _tickets.where((t) => t.status != TicketStatus.resolved).length;

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final firstPage = await _repository.fetchPage(1);
      _tickets = firstPage;
      _page = 1;
      _hasMore = firstPage.length == TicketRepository.pageSize;
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final nextPage = _page + 1;
      final items = await _repository.fetchPage(nextPage);
      _tickets = [..._tickets, ...items];
      _page = nextPage;
      _hasMore = items.length == TicketRepository.pageSize;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> resolve(int id) async {
    await _repository.resolve(id);
    _markResolved(id);
    notifyListeners();
  }

  /// Resolves [ids] one by one, emitting how many are done so far.
  Stream<int> resolveMany(List<int> ids) async* {
    var done = 0;
    for (final id in ids) {
      await _repository.resolve(id);
      _markResolved(id);
      yield ++done;
    }
    notifyListeners();
  }

  void _markResolved(int id) {
    final index = _tickets.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tickets[index].status = TicketStatus.resolved;
    }
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    _tickets = _tickets.where((t) => t.id != id).toList();
    notifyListeners();
  }
}
