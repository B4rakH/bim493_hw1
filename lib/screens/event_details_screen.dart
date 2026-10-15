import 'package:flutter/material.dart';
import '../models/event.dart';

/// Screen displaying complete details for a selected event.
/// Will be expanded in Step 6 with double-tap image enlargement and full interactions.
class EventDetailsScreen extends StatelessWidget {
  final Event event;
  final VoidCallback onToggleFavorite;
  final VoidCallback onJoin;
  final VoidCallback onCancelParticipation;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.onToggleFavorite,
    required this.onJoin,
    required this.onCancelParticipation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: Icon(
              event.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: event.isFavorite ? Colors.red : null,
            ),
            tooltip: event.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: onToggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                event.imagePath,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              event.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${event.category} • ${event.dateTime}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Venue: ${event.venue}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              event.description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
