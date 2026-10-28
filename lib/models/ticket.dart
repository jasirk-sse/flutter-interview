enum TicketStatus {
  open('Open'),
  inProgress('In progress'),
  resolved('Resolved');

  const TicketStatus(this.label);

  final String label;

  static TicketStatus fromJson(String value) => switch (value) {
        'in_progress' => TicketStatus.inProgress,
        'resolved' => TicketStatus.resolved,
        _ => TicketStatus.open,
      };
}

enum TicketPriority { low, medium, high }

class Ticket {
  Ticket({
    required this.id,
    required this.customerName,
    required this.city,
    required this.address,
    required this.issue,
    required this.priority,
    required this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json['id'] as int,
        customerName: json['customerName'] as String,
        city: json['city'] as String,
        address: json['address'] as String,
        issue: json['issue'] as String,
        priority: TicketPriority.values.byName(json['priority'] as String),
        status: TicketStatus.fromJson(json['status'] as String),
      );

  final int id;
  final String customerName;
  final String city;
  final String address;
  final String issue;
  final TicketPriority priority;
  TicketStatus status;
}
