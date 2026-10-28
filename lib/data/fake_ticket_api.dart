import 'dart:convert';
import 'dart:math';

/// In-memory stand-in for the FieldFix backend.
///
/// Treat this file as the server: responses are round-tripped through JSON so
/// they have exactly the shape and types the real API returns.
class FakeTicketApi {
  FakeTicketApi({this.latencyScale = 1.0}) : _tickets = _seed();

  final double latencyScale;
  final List<Map<String, dynamic>> _tickets;
  String? _telemetry;

  Future<List<dynamic>> getTickets({
    required int page,
    required int pageSize,
  }) async {
    await _delay(800);
    final start = (page - 1) * pageSize;
    return _json(_tickets.skip(start).take(pageSize).map(_summary).toList());
  }

  Future<List<dynamic>> searchTickets(String query) async {
    await _delay(300 + 900 ~/ max(query.length, 1));
    final q = query.toLowerCase();
    final matches = _tickets.where((t) {
      final haystack = '${t['customerName']} ${t['city']} ${t['issue']}';
      return haystack.toLowerCase().contains(q);
    });
    return _json(matches.map(_summary).toList());
  }

  Future<Map<String, dynamic>> getTicketDetail(int id) async {
    await _delay(600);
    return _json(_find(id));
  }

  Future<void> resolveTicket(int id) async {
    await _delay(500);
    _find(id)['status'] = 'resolved';
  }

  Future<void> deleteTicket(int id) async {
    await _delay(400);
    _tickets.removeWhere((t) => t['id'] == id);
  }

  /// Live location feed for the technician assigned to [ticketId].
  Stream<Map<String, dynamic>> watchTechnician(int ticketId) async* {
    await _delay(1500);
    for (var eta = 12 + ticketId % 10; eta >= 0; eta--) {
      yield _json({'ticketId': ticketId, 'etaMinutes': eta});
      await _delay(4000);
    }
  }

  /// Raw JSON body: one reading per panel every 15 minutes of daylight for
  /// the last year.
  Future<String> getTelemetry() async {
    await _delay(700);
    return _telemetry ??= await _buildTelemetry();
  }

  Map<String, dynamic> _find(int id) {
    return _tickets.firstWhere(
      (t) => t['id'] == id,
      orElse: () => throw StateError('Ticket $id not found'),
    );
  }

  Map<String, dynamic> _summary(Map<String, dynamic> t) => {
        for (final key in const [
          'id',
          'customerName',
          'city',
          'address',
          'issue',
          'priority',
          'status',
        ])
          key: t[key],
      };

  Future<void> _delay(int ms) =>
      Future.delayed(Duration(milliseconds: (ms * latencyScale).round()));

  static T _json<T>(Object value) => jsonDecode(jsonEncode(value)) as T;

  static const _names = [
    'Aarav Sharma',
    'Priya Nair',
    'Venkataraman Subramaniam Iyer',
    'Rohit Kulkarni',
    'Sneha Deshpande',
    'Imran Qureshi',
    'Kavya Reddy',
    'Arjun Mehta',
    'Fatima Sheikh',
    'Siddharth Rao',
    'Neha Joshi',
  ];

  static const _cities = [
    'Pune',
    'Mumbai',
    'Thane',
    'Bengaluru',
    'Hyderabad',
    'Jaipur',
    'Ahmedabad',
  ];

  static const _addresses = [
    '14 Baner Road',
    '7 Linking Road, Bandra',
    'Flat 1204, Tower B, Lodha Amara, Kolshet Road, Thane West, Maharashtra 400607',
    '22 Indiranagar 2nd Stage',
    '5 Jubilee Hills',
    '9 C-Scheme',
    '31 SG Highway',
    'Plot 88, Survey No. 112/3, Near Hinjewadi Phase 2 Metro Station, Maan, Pune 411057',
    '3 Koregaon Park Lane 5',
  ];

  static const _issues = [
    'Inverter error E-21',
    'Low generation',
    'Panel cleaning request',
    'Net meter not syncing',
    'Loose DC connector',
    'Monitoring app offline',
    'Bird nest under panels',
    'Earthing check',
  ];

  static const _technicians = [
    'Ganesh Patil',
    'Ravi Kumar',
    'Suresh Yadav',
    'Anil Pawar',
  ];

  static const _priorities = ['low', 'medium', 'high'];

  static const _cleaningRates = [299.5, 449.25, 599.0, 749.75];

  static Future<String> _buildTelemetry() async {
    final random = Random(42);
    final start = DateTime.utc(2025, 11, 1);
    final buffer = StringBuffer('[');
    var first = true;
    for (var day = 0; day < 365; day++) {
      final date = start.add(Duration(days: day));
      final season = 0.85 + 0.15 * sin(2 * pi * (day - 60) / 365);
      for (var panel = 1; panel <= 12; panel++) {
        final health = panel == 7 || panel == 11 ? 0.72 : 1.0;
        for (var slot = 0; slot < 52; slot++) {
          final sun = sin(pi * slot / 52);
          final kwh = 0.11 * sun * season * health * (0.9 + 0.2 * random.nextDouble());
          final ts = date
                  .add(Duration(hours: 6, minutes: 15 * slot))
                  .millisecondsSinceEpoch ~/
              1000;
          if (!first) buffer.write(',');
          first = false;
          buffer.write('{"panel":$panel,"ts":$ts,"kwh":${kwh.toStringAsFixed(4)}}');
        }
      }
      if (day % 10 == 0) await Future<void>.delayed(Duration.zero);
    }
    buffer.write(']');
    return buffer.toString();
  }

  static List<Map<String, dynamic>> _seed() {
    final now = DateTime.now().toUtc();
    return List.generate(57, (i) {
      final id = 1001 + i;
      return {
        'id': id,
        'customerName': _names[i % _names.length],
        'city': _cities[i % _cities.length],
        'address': _addresses[i % _addresses.length],
        'issue': _issues[i % _issues.length],
        'priority': _priorities[i % _priorities.length],
        'status': i % 5 == 4 ? 'in_progress' : 'open',
        'technician': _technicians[i % _technicians.length],
        'scheduledAt': DateTime.utc(
          now.year,
          now.month,
          now.day + 1 + i % 4,
          4 + i % 6,
          30,
        ).toIso8601String(),
        'slaDeadline': now
            .add(Duration(hours: 2 + i % 7, minutes: (17 * i) % 60))
            .toIso8601String(),
        'lineItems': [
          {'description': 'Site visit', 'amount': id % 10 == 7 ? 450 : 499.0},
          {
            'description': 'Panel cleaning',
            'amount': _cleaningRates[id % _cleaningRates.length],
          },
          if (id % 3 == 0)
            {'description': 'DC connector replacement', 'amount': 89.7},
        ],
      };
    });
  }
}
