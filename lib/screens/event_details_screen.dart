import 'package:flutter/material.dart';
import '../models/event.dart';
import 'enlarged_image_screen.dart';

/// Screen displaying complete details for a selected event.
/// Features double-tap image enlargement, live favorite toggle,
/// and join/cancel participation with confirmation dialogs and feedback.
class EventDetailsScreen extends StatefulWidget {
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
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Event _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  void _handleToggleFavorite() {
    setState(() {
      _event = _event.copyWith(isFavorite: !_event.isFavorite);
    });
    widget.onToggleFavorite();
  }

  Future<void> _showJoinConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Participation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to join this event?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 14),
              Text(
                'Event: ${_event.title}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Date/Time: ${_event.dateTime}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 6),
              Text(
                'Venue: ${_event.venue}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _event = _event.copyWith(
          isJoined: true,
          availablePlaces: _event.availablePlaces - 1,
        );
      });
      widget.onJoin();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully joined "${_event.title}"!'),
          backgroundColor: const Color(0xFF1E3A8A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showCancelConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Participation'),
          content: Text(
            'Are you sure you want to cancel your participation for "${_event.title}"? This will free up 1 available place.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _event = _event.copyWith(
          isJoined: false,
          availablePlaces: (_event.availablePlaces + 1).clamp(0, _event.totalCapacity),
        );
      });
      widget.onCancelParticipation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Participation cancelled for "${_event.title}".'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openEnlargedImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EnlargedImageViewerScreen(
          imagePath: _event.imagePath,
          title: _event.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Availability styling
    Color availabilityBg;
    Color availabilityFg;
    String availabilityText;

    if (_event.isFull) {
      availabilityBg = Colors.red.shade100;
      availabilityFg = Colors.red.shade800;
      availabilityText = 'Full (0 available)';
    } else if (_event.availablePlaces == 1) {
      availabilityBg = Colors.orange.shade100;
      availabilityFg = Colors.orange.shade900;
      availabilityText = 'Only 1 place left!';
    } else {
      availabilityBg = Colors.green.shade100;
      availabilityFg = Colors.green.shade800;
      availabilityText = '${_event.availablePlaces} places left';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: Icon(
              _event.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _event.isFavorite ? Colors.red : null,
            ),
            tooltip: _event.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: _handleToggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with Double-Tap enlargement gesture detector
            GestureDetector(
              onDoubleTap: _openEnlargedImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Image.asset(
                      _event.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  // Double tap hint badge
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xB3000000), // 70% black
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Double-tap to enlarge',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unique Event ID and Category badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _event.category,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        'ID: ${_event.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    _event.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Joined Status Banner (if joined)
                  if (_event.isJoined) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.blue.shade700, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You are registered for this event.',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Date and Time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date & Time',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              _event.dateTime,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Venue
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Venue',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              _event.venue,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Capacity & Availability Info Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Total Capacity',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_event.totalCapacity}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 36, color: Colors.grey.shade300),
                        Column(
                          children: [
                            const Text(
                              'Available Places',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: availabilityBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                availabilityText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: availabilityFg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'About this Event',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _event.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Participation Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _buildParticipationButton(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipationButton() {
    // If user is already joined: must offer Cancel participation with confirmation
    // Note: Even if availablePlaces == 0, a joined student can still cancel!
    if (_event.isJoined) {
      return OutlinedButton.icon(
        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
        label: const Text(
          'Cancel Participation',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _showCancelConfirmationDialog,
      );
    }

    // If user has not joined and event is Full: marked Full and cannot be joined
    if (_event.isFull) {
      return FilledButton.tonalIcon(
        onPressed: null, // Disabled
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.block, size: 18),
        label: const Text(
          'Event Full',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    // If user has not joined and places are available: offer Join with confirmation
    return FilledButton.icon(
      icon: const Icon(Icons.how_to_reg),
      label: const Text(
        'Join Event',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A8A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _showJoinConfirmationDialog,
    );
  }
}
