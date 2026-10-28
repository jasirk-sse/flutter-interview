import '../models/ticket.dart';
import '../models/ticket_detail.dart';
import 'fake_ticket_api.dart';

class TicketRepository {
  TicketRepository(this._api);

  static const pageSize = 20;

  final FakeTicketApi _api;

  Future<List<Ticket>> fetchPage(int page) async {
    final json = await _api.getTickets(page: page, pageSize: pageSize);
    return json.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Ticket>> search(String query) async {
    final json = await _api.searchTickets(query);
    return json.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TicketDetail> fetchDetail(int id) async {
    return TicketDetail.fromJson(await _api.getTicketDetail(id));
  }

  Future<void> resolve(int id) => _api.resolveTicket(id);

  Future<void> delete(int id) => _api.deleteTicket(id);

  Stream<TechnicianEta> watchTechnicianEta(int ticketId) =>
      _api.watchTechnician(ticketId).map(TechnicianEta.fromJson);

  Future<String> fetchTelemetry() => _api.getTelemetry();
}
