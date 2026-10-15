import 'package:flutter/material.dart';
import '../data/mock_events.dart';
import '../models/event.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/event_card.dart';
import '../widgets/search_filter_header.dart';
import 'event_details_screen.dart';

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

  void resetSearchAndFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'All';
    });
  }

  void setCategoryFilter(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  // Helper to fetch latest event from master list
  Event getEventById(String id) {
    return _events.firstWhere((e) => e.id == id);
  }

  void _openEventDetails(Event event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          // Re-fetch event state from master list dynamically
          final currentEvent = getEventById(event.id);
          return EventDetailsScreen(
            event: currentEvent,
            onToggleFavorite: () {
              toggleFavorite(currentEvent.id);
            },
            onJoin: () {
              joinEvent(currentEvent.id);
            },
            onCancelParticipation: () {
              cancelParticipation(currentEvent.id);
            },
          );
        },
      ),
    ).then((_) {
      // Trigger rebuild upon returning to reflect any state changes made in Details
      setState(() {});
    });
  }

  // --- Filtering Logic (Applied identically across all three views) ---

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

  List<Event> get allFavoriteEvents =>
      _events.where((event) => event.isFavorite).toList();

  List<Event> get filteredFavoriteEvents => _filterEvents(allFavoriteEvents);

  List<Event> get allJoinedEvents =>
      _events.where((event) => event.isJoined).toList();

  List<Event> get filteredJoinedEvents => _filterEvents(allJoinedEvents);

  int get totalJoinedCount => allJoinedEvents.length;

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

  bool get isFilterOrSearchActive =>
      _searchQuery.trim().isNotEmpty || _selectedCategory != 'All';

  // --- View Builders ---

  Widget _buildExploreView() {
    final list = filteredExploreEvents;
    if (list.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off,
        title: 'No events found',
        message: isFilterOrSearchActive
            ? 'No campus events match your current search and filter criteria.'
            : 'There are currently no events listed.',
        actionLabel: isFilterOrSearchActive ? 'Clear search & filters' : null,
        onAction: isFilterOrSearchActive ? resetSearchAndFilters : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final event = list[index];
        return EventCard(
          event: event,
          onTap: () => _openEventDetails(event),
          onToggleFavorite: () => toggleFavorite(event.id),
        );
      },
    );
  }

  Widget _buildFavoritesView() {
    if (allFavoriteEvents.isEmpty) {
      return const EmptyStateView(
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        message:
            'You haven\'t saved any favorite events. Tap the heart icon on any event card or details page to add it here.',
      );
    }

    final list = filteredFavoriteEvents;
    if (list.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off,
        title: 'No matching favorites',
        message: 'None of your favorited events match the current search or category filter.',
        actionLabel: 'Clear search & filters',
        onAction: resetSearchAndFilters,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final event = list[index];
        return EventCard(
          event: event,
          onTap: () => _openEventDetails(event),
          onToggleFavorite: () => toggleFavorite(event.id),
        );
      },
    );
  }

  Widget _buildMyEventsView() {
    if (allJoinedEvents.isEmpty) {
      return const EmptyStateView(
        icon: Icons.event_available_outlined,
        title: 'No joined events',
        message:
            'You haven\'t joined any events yet. Explore upcoming campus events and join to track your participation here.',
      );
    }

    final list = filteredJoinedEvents;

    return Column(
      children: [
        // Summary banner showing total joined events
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), // Soft blue tint
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF1E3A8A), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Total registered events: $totalJoinedCount',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: list.isEmpty
              ? EmptyStateView(
                  icon: Icons.search_off,
                  title: 'No matching joined events',
                  message:
                      'None of your joined events match the current search or category filter.',
                  actionLabel: 'Clear search & filters',
                  onAction: resetSearchAndFilters,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final event = list[index];
                    return EventCard(
                      event: event,
                      onTap: () => _openEventDetails(event),
                      onToggleFavorite: () => toggleFavorite(event.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Explore Events',
      'My Favorites',
      'My Events',
    ];

    Widget currentBody;
    switch (_currentIndex) {
      case 1:
        currentBody = _buildFavoritesView();
        break;
      case 2:
        currentBody = _buildMyEventsView();
        break;
      case 0:
      default:
        currentBody = _buildExploreView();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Common search and category filter header applied to all 3 views
          SearchFilterHeader(
            searchController: _searchController,
            onSearchChanged: setSearchQuery,
            onClearSearch: clearSearch,
            selectedCategory: _selectedCategory,
            onCategorySelected: setCategoryFilter,
            matchingCount: currentMatchingCount,
          ),

          // Active view content
          Expanded(child: currentBody),
        ],
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
