import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bim493_hw1/main.dart';

void main() {
  void setMobileViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('App loads successfully and displays explore screen', (WidgetTester tester) async {
    setMobileViewport(tester);
    await tester.pumpWidget(const CampusEventExplorerApp());
    await tester.pumpAndSettle();

    expect(find.text('Explore Events'), findsOneWidget);
    expect(find.text('AI & Robotics Hackathon 2026'), findsOneWidget);
  });

  testWidgets('Search ignores case and surrounding spaces', (WidgetTester tester) async {
    setMobileViewport(tester);
    await tester.pumpWidget(const CampusEventExplorerApp());
    await tester.pumpAndSettle();

    // Enter search with leading/trailing spaces and mixed case
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, '   roBotics   ');
    await tester.pumpAndSettle();

    // Verify AI & Robotics Hackathon 2026 matches and other events are filtered out
    expect(find.text('AI & Robotics Hackathon 2026'), findsOneWidget);
    expect(find.text('Campus Basketball Championship Finals'), findsNothing);
    expect(find.text('1 event found'), findsOneWidget);
  });

  testWidgets('Category filter and search work together with matching count', (WidgetTester tester) async {
    setMobileViewport(tester);
    await tester.pumpWidget(const CampusEventExplorerApp());
    await tester.pumpAndSettle();

    // Tap Arts category chip specifically
    await tester.tap(find.widgetWithText(FilterChip, 'Arts'));
    await tester.pumpAndSettle();

    // 2 Arts events should be found
    expect(find.text('2 events found'), findsOneWidget);
    expect(find.text('Contemporary Student Art Showcase'), findsOneWidget);
    expect(find.text('Autumn Philharmonic Orchestra Gala'), findsOneWidget);
    expect(find.text('AI & Robotics Hackathon 2026'), findsNothing);

    // Filter further by search
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Showcase');
    await tester.pumpAndSettle();

    expect(find.text('1 event found'), findsOneWidget);
    expect(find.text('Contemporary Student Art Showcase'), findsOneWidget);
    expect(find.text('Autumn Philharmonic Orchestra Gala'), findsNothing);
  });

  testWidgets('Empty state message is shown and clear search button restores events', (WidgetTester tester) async {
    setMobileViewport(tester);
    await tester.pumpWidget(const CampusEventExplorerApp());
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'NonExistentEventName999');
    await tester.pumpAndSettle();

    expect(find.text('No events found'), findsOneWidget);
    expect(find.text('0 events found'), findsOneWidget);
    expect(find.text('Clear search & filters'), findsOneWidget);

    // Tap clear button
    await tester.tap(find.text('Clear search & filters'));
    await tester.pumpAndSettle();

    // Verify events are restored
    expect(find.text('6 events found'), findsOneWidget);
    expect(find.text('AI & Robotics Hackathon 2026'), findsOneWidget);
  });

  testWidgets('Full event cannot be joined and shows Full indicator', (WidgetTester tester) async {
    setMobileViewport(tester);
    await tester.pumpWidget(const CampusEventExplorerApp());
    await tester.pumpAndSettle();

    // Scroll down to reveal Campus Basketball Championship Finals (initially 0 places)
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    final fullEventTitle = find.text('Campus Basketball Championship Finals');
    expect(fullEventTitle, findsOneWidget);
    expect(find.text('Full (0 available)'), findsOneWidget);

    // Open its details
    await tester.tap(fullEventTitle);
    await tester.pumpAndSettle();

    // Scroll down in details to verify participation button is disabled and indicates Full
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    final fullButtonText = find.text('Event Full');
    expect(fullButtonText, findsOneWidget);

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Event Full'),
    );
    expect(button.onPressed, isNull); // Disabled
  });

  testWidgets('Joining an event decreases places by 1 and updates My Events', (WidgetTester tester) async {
    setMobileViewport(tester);
    await tester.pumpWidget(const CampusEventExplorerApp());
    await tester.pumpAndSettle();

    // Open AI & Robotics Hackathon 2026 details (initially 12 places)
    await tester.tap(find.text('AI & Robotics Hackathon 2026'));
    await tester.pumpAndSettle();

    expect(find.text('12 places left'), findsOneWidget);

    // Scroll down and tap Join Event
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    final joinBtn = find.text('Join Event');
    await tester.tap(joinBtn);
    await tester.pumpAndSettle();

    // Confirm dialog is shown with title, date, venue
    expect(find.text('Confirm Participation'), findsOneWidget);
    expect(find.text('Event: AI & Robotics Hackathon 2026'), findsOneWidget);

    // Tap Yes
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    // Available places decreased to 11
    expect(find.text('11 places left'), findsOneWidget);
    expect(find.text('Cancel Participation'), findsOneWidget);
    expect(find.text('You are registered for this event.'), findsOneWidget);

    // Go back to main navigation
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Navigate to My Events tab
    await tester.tap(find.text('My Events'));
    await tester.pumpAndSettle();

    expect(find.text('Total registered events: 1'), findsOneWidget);
    expect(find.text('AI & Robotics Hackathon 2026'), findsOneWidget);
  });

  testWidgets('Student who joined the last available place can still cancel participation', (WidgetTester tester) async {
    setMobileViewport(tester);
    await tester.pumpWidget(const CampusEventExplorerApp());
    await tester.pumpAndSettle();

    // Contemporary Student Art Showcase has exactly 1 available place initially
    final showcaseTitle = find.text('Contemporary Student Art Showcase');
    expect(showcaseTitle, findsOneWidget);
    expect(find.text('Only 1 place left!'), findsOneWidget);

    // Open details
    await tester.tap(showcaseTitle);
    await tester.pumpAndSettle();

    // Scroll down and join the last place
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    final joinBtn = find.text('Join Event');
    await tester.tap(joinBtn);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    // Now places is 0 (Full), but the user is joined so they must see Cancel Participation
    expect(find.text('Full (0 available)'), findsOneWidget);
    final cancelBtn = find.text('Cancel Participation');
    expect(cancelBtn, findsOneWidget);

    // Cancel participation
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();

    // Confirm cancel dialog
    expect(find.text('Cancel Participation'), findsNWidgets(2)); // Title and button
    await tester.tap(find.widgetWithText(FilledButton, 'Yes'));
    await tester.pumpAndSettle();

    // Place is restored back to 1
    expect(find.text('Only 1 place left!'), findsOneWidget);
    expect(find.text('Join Event'), findsOneWidget);
  });

  testWidgets('Favorites update consistently across views without changing capacity', (WidgetTester tester) async {
    setMobileViewport(tester);
    await tester.pumpWidget(const CampusEventExplorerApp());
    await tester.pumpAndSettle();

    // Tap favorite on AI & Robotics Hackathon 2026 card
    final favoriteButtons = find.byTooltip('Add to favorites');
    await tester.tap(favoriteButtons.first);
    await tester.pumpAndSettle();

    // Switch to Favorites tab
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('AI & Robotics Hackathon 2026'), findsOneWidget);
    // Capacity remains unchanged (12 places)
    expect(find.text('12 places left'), findsOneWidget);
  });
}
