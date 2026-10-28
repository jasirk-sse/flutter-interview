# FieldFix — Flutter debugging exercise

FieldFix is a small app that field technicians use to manage solar service
tickets: browse and search tickets, open one to see the visit details and
invoice, mark it resolved, or assign several at once.

QA and the support team have reported a batch of bugs. Your job is to find
and fix as many as you can in **45 minutes**, and talk us through your
thinking as you go.

> **Prefer algorithms?** If you'd rather not do a repo-based exercise, tell
> your interviewer at the start and you can solve DSA problems instead. Either
> choice is completely fine.

## Setup (please do this before the interview)

```bash
flutter --version   # 3.41.x stable
flutter pub get
flutter run         # on an Android emulator or iOS simulator (phone size)
flutter test
```

Run the app on a **phone-sized emulator or simulator**, not web or desktop.

## Project layout

```
lib/
  data/fake_ticket_api.dart    # the "backend" (see note below)
  data/ticket_repository.dart  # API -> models
  models/                      # Ticket, TicketDetail, LineItem
  state/tickets_notifier.dart  # list state (Provider / ChangeNotifier)
  screens/                     # list, search, detail
  widgets/                     # ticket tile, status chip
```

`lib/data/fake_ticket_api.dart` stands in for the real server. **Treat it
as the backend contract and don't change it.** Its responses go through a
real JSON round-trip, so whatever it returns is what production returns.

## Bug reports

They're in no particular order. You're not expected to finish all of them,
so choose what to tackle first.

1. **Duplicate tickets.** "When I scroll down the list quickly, the same
   tickets show up two or three times. The header says more tickets are
   loaded than we actually have."
2. **Some tickets won't open.** "Ticket #1007 (and a few others) always shows
   *Couldn't load this ticket*. Retry doesn't help, and the network is fine."
3. **Wrong ticket ticked.** "I ticked #1003, then deleted #1002. Now #1004
   shows as ticked instead. When I tapped *Assign*, it assigned a ticket I
   couldn't see ticked."
4. **Resolved ticket still shows Open.** "I mark a ticket resolved and go back.
   The header count drops, but the ticket still says *Open* until I scroll
   away or pull to refresh."
5. **Visit time is wrong.** "The customer booked a visit for 10:00 AM, but the
   app shows 4:30 AM. Technicians are turning up at the wrong time."
6. **Search shows the wrong results.** "I typed *pune* and got tickets from
   other cities. It doesn't happen every time."
7. **Striped bars on some rows.** "A few rows in the ticket list show yellow
   and black stripes on my phone."
8. **Console errors and sluggishness.** "After opening and closing a few
   tickets, the debug console fills with errors, and the app gets slower
   the longer it runs."
9. **Odd collect amount.** "The *Collect* button shows amounts like
   ₹1295.6399999999999 or ₹1118.935."
10. **Live ETA is stuck.** "The *Live ETA* on a ticket always says
    *Locating technician…*, even though the technician is on the way."
11. **Bulk resolve only half works.** "I ticked 5 tickets and tapped
    *Resolve 5*. I tapped outside the progress popup to keep working, and only
    1 of the 5 actually got resolved."
12. **Insights never loads.** "Tapping the *Insights* icon always ends at
    *Couldn't build insights*. Retry doesn't help."

**Bonus:** write a test that would have caught one of the bugs you fixed.

## AI tools

You can use AI assistants the way you would day to day: autocomplete, API
and syntax lookups, "what does this error mean?".

Please **don't** paste bug reports, files or the repo into an AI agent and ask
it to find or fix the bugs. Before you change code for a bug, tell us the
root cause in your own words. We care more about your reasoning than about
the number of bugs fixed.

## What we look at

- How you reproduce and narrow down a bug (logs, debugger, DevTools, reading code).
- Whether you fix the root cause or just the symptom.
- How clearly you explain *why* it broke.
- How you prioritise within the time.
- Not introducing regressions. `flutter analyze` and `flutter test` should stay green.
