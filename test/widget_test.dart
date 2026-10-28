import 'package:fieldfix/data/fake_ticket_api.dart';
import 'package:fieldfix/data/ticket_repository.dart';
import 'package:fieldfix/state/tickets_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TicketsNotifier notifier;

  setUp(() {
    notifier = TicketsNotifier(
      TicketRepository(FakeTicketApi(latencyScale: 0)),
    );
  });

  test('refresh loads the first page', () async {
    await notifier.refresh();

    expect(notifier.tickets, hasLength(TicketRepository.pageSize));
    expect(notifier.tickets.first.id, 1001);
    expect(notifier.hasMore, isTrue);
  });

  test('loadMore appends the next page', () async {
    await notifier.refresh();
    await notifier.loadMore();

    expect(notifier.tickets, hasLength(TicketRepository.pageSize * 2));
    expect(notifier.tickets.last.id, 1040);
  });
}
