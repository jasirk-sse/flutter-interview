import 'ticket.dart';

class LineItem {
  const LineItem({required this.description, required this.amount});

  factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
        description: json['description'] as String,
        amount: json['amount'] as double,
      );

  final String description;
  final double amount;
}

class TechnicianEta {
  const TechnicianEta({required this.etaMinutes});

  factory TechnicianEta.fromJson(Map<String, dynamic> json) =>
      TechnicianEta(etaMinutes: json['etaMinutes'] as int);

  final int etaMinutes;
}

class TicketDetail {
  const TicketDetail({
    required this.ticket,
    required this.technician,
    required this.scheduledAt,
    required this.slaDeadline,
    required this.lineItems,
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) => TicketDetail(
        ticket: Ticket.fromJson(json),
        technician: json['technician'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        slaDeadline: DateTime.parse(json['slaDeadline'] as String),
        lineItems: (json['lineItems'] as List)
            .map((e) => LineItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static const gstRate = 0.18;

  final Ticket ticket;
  final String technician;
  final DateTime scheduledAt;
  final DateTime slaDeadline;
  final List<LineItem> lineItems;

  double get subtotal => lineItems.fold(0, (sum, item) => sum + item.amount);

  double get gst => subtotal * gstRate;

  double get total => subtotal + gst;
}
