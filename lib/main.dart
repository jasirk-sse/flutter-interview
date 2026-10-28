import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/fake_ticket_api.dart';
import 'data/ticket_repository.dart';
import 'screens/ticket_list_screen.dart';
import 'state/tickets_notifier.dart';

void main() {
  runApp(FieldFixApp(repository: TicketRepository(FakeTicketApi())));
}

class FieldFixApp extends StatelessWidget {
  const FieldFixApp({super.key, required this.repository});

  final TicketRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TicketRepository>.value(value: repository),
        ChangeNotifierProvider(create: (_) => TicketsNotifier(repository)),
      ],
      child: MaterialApp(
        title: 'FieldFix',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF0B7A75),
          useMaterial3: true,
        ),
        home: const TicketListScreen(),
      ),
    );
  }
}
