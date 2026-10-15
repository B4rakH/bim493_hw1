class Event {
  final String id;
  final String title;
  final String category;
  final String dateTime;
  final String venue;
  final String description;
  final String imagePath;
  final int totalCapacity;
  final int availablePlaces;
  final bool isFavorite;
  final bool isJoined;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.venue,
    required this.description,
    required this.imagePath,
    required this.totalCapacity,
    required this.availablePlaces,
    this.isFavorite = false,
    this.isJoined = false,
  });

  bool get isFull => availablePlaces <= 0;

  Event copyWith({
    String? id,
    String? title,
    String? category,
    String? dateTime,
    String? venue,
    String? description,
    String? imagePath,
    int? totalCapacity,
    int? availablePlaces,
    bool? isFavorite,
    bool? isJoined,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      venue: venue ?? this.venue,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      availablePlaces: availablePlaces ?? this.availablePlaces,
      isFavorite: isFavorite ?? this.isFavorite,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}
