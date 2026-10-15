import 'package:flutter/material.dart';
import '../data/mock_events.dart';
import '../models/event.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Master list of events kept in memory during the app session
  late List<Event> _events;

  // Active navigation index: 0 = Explore, 1 = Favorites, 2 = My Events
  int _currentIndex = 0;

  // Shared search and category filter state (applied across all three views)
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _events = getInitialEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- State Manipulation Methods ---

  void toggleFavorite(String eventId) {
    setState(() {
      _events = _events.map((event) {
        if (event.id == eventId) {
          return event.copyWith(isFavorite: !event.isFavorite);
        }
        return event;
      }).toList();
    });
  }

  void joinEvent(String eventId) {
    setState(() {
      _events = _events.map((event) {
        if (event.id == eventId) {
          if (event.isJoined || event.availablePlaces <= 0) {
            return event;
          }
          return event.copyWith(
            isJoined: true,
            availablePlaces: event.availablePlaces - 1,
          );
        }
        return event;
      }).toList();
    });
  }

  void cancelParticipation(String eventId) {
    setState(() {
      _events = _events.map((event) {
        if (event.id == eventId) {
          if (!event.isJoined) {
            return event;
          }
          return event.copyWith(
            isJoined: false,
            availablePlaces: (event.availablePlaces + 1).clamp(0, event.totalCapacity),
          );
        }
        return event;
      }).toList();
    });
  }

  void setSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void setCategoryFilter(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  // --- Filter and Derived Getters ---

  List<Event> _filterEvents(List<Event> sourceEvents) {
    final trimmedQuery = _searchQuery.trim().toLowerCase();
    return sourceEvents.where((event) {
      final matchesCategory = _selectedCategory == 'All' ||
          event.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = trimmedQuery.isEmpty ||
          event.title.toLowerCase().contains(trimmedQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Event> get filteredExploreEvents => _filterEvents(_events);

  List<Event> get filteredFavoriteEvents =>
      _filterEvents(_events.where((event) => event.isFavorite).toList());

  List<Event> get filteredJoinedEvents =>
      _filterEvents(_events.where((event) => event.isJoined).toList());

  int get totalJoinedCount => _events.where((event) => event.isJoined).length;

  int get currentMatchingCount {
    switch (_currentIndex) {
      case 1:
        return filteredFavoriteEvents.length;
      case 2:
        return filteredJoinedEvents.length;
      case 0:
      default:
        return filteredExploreEvents.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Explore Events',
      'My Favorites',
      'My Events ($totalJoinedCount joined)',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Active tab: ${titles[_currentIndex]}\nMatching events: $currentMatchingCount',
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: totalJoinedCount > 0,
              label: Text('$totalJoinedCount'),
              child: const Icon(Icons.event_available_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: totalJoinedCount > 0,
              label: Text('$totalJoinedCount'),
              child: const Icon(Icons.event_available),
            ),
            label: 'My Events',
          ),
        ],
      ),
    );
  }
}
