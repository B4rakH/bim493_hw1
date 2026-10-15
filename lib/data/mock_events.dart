import '../models/event.dart';

const List<String> eventCategories = [
  'All',
  'Technology',
  'Arts',
  'Sports',
];

List<Event> getInitialEvents() {
  return const [
    Event(
      id: 'evt-1',
      title: 'AI & Robotics Hackathon 2026',
      category: 'Technology',
      dateTime: 'November 5, 2026 • 10:00 AM',
      venue: 'Engineering Faculty, Computer Lab 3',
      description:
          'Join student developers, roboticists, and designers for a collaborative 24-hour hackathon. Teams will build innovative artificial intelligence prototypes and autonomous robotics applications.',
      imagePath: 'assets/images/tech.jpg',
      totalCapacity: 50,
      availablePlaces: 12,
      isFavorite: false,
      isJoined: false,
    ),
    Event(
      id: 'evt-2',
      title: 'Contemporary Student Art Showcase',
      category: 'Arts',
      dateTime: 'November 10, 2026 • 02:00 PM',
      venue: 'Faculty of Fine Arts, Central Exhibition Hall',
      description:
          'Experience contemporary paintings, sculptures, and digital multimedia works created by university art students. Meet the student artists and participate in interactive studio discussions.',
      imagePath: 'assets/images/arts.jpg',
      totalCapacity: 40,
      availablePlaces: 1, // Exactly one available place initially
      isFavorite: false,
      isJoined: false,
    ),
    Event(
      id: 'evt-3',
      title: 'Campus Basketball Championship Finals',
      category: 'Sports',
      dateTime: 'November 15, 2026 • 05:30 PM',
      venue: 'University Indoor Sports Complex, Court A',
      description:
          'The crowning match of the autumn inter-faculty tournament! Come support your department basketball squad in this high-intensity final match. Live commentary and fan competitions included.',
      imagePath: 'assets/images/sports.jpg',
      totalCapacity: 100,
      availablePlaces: 0, // Initially full event
      isFavorite: false,
      isJoined: false,
    ),
    Event(
      id: 'evt-4',
      title: 'Mobile App Architecture with Flutter Workshop',
      category: 'Technology',
      dateTime: 'November 20, 2026 • 01:30 PM',
      venue: 'Information Technology Building, Seminar Room 102',
      description:
          'A hands-on technical workshop delving into Flutter UI composition, reactive state handling, and cross-platform mobile best practices for computer science and engineering students.',
      imagePath: 'assets/images/tech.jpg',
      totalCapacity: 60,
      availablePlaces: 25,
      isFavorite: false,
      isJoined: false,
    ),
    Event(
      id: 'evt-5',
      title: 'Autumn Philharmonic Orchestra Gala',
      category: 'Arts',
      dateTime: 'November 24, 2026 • 07:00 PM',
      venue: 'University Grand Auditorium',
      description:
          'An inspiring musical evening featuring the student philharmonic orchestra and guest soloists performing selected classical overtures, film soundtracks, and choral compositions.',
      imagePath: 'assets/images/arts.jpg',
      totalCapacity: 80,
      availablePlaces: 18,
      isFavorite: false,
      isJoined: false,
    ),
    Event(
      id: 'evt-6',
      title: 'Inter-Department Volleyball League',
      category: 'Sports',
      dateTime: 'November 28, 2026 • 03:00 PM',
      venue: 'Campus Gymnasium, Court 2',
      description:
          'Cheer on peer student athletes during the final round of the inter-department volleyball tournament. Fast-paced rallies, enthusiastic campus spirit, and healthy competition.',
      imagePath: 'assets/images/sports.jpg',
      totalCapacity: 45,
      availablePlaces: 8,
      isFavorite: false,
      isJoined: false,
    ),
  ];
}
