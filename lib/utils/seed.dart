import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseSeeder {
  static final List<Map<String, dynamic>> _sampleEvents = [
    {
      'name': 'Tech Conference 2024',
      'description':
          'Annual technology conference featuring the latest innovations in AI, blockchain, and cloud computing.',
      'location': 'Silicon Valley Convention Center',
      'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      'imageUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87',
      'createdAt': Timestamp.fromDate(DateTime.now()), // Fixing createdAt
    },
    {
      'name': 'Music Festival',
      'description':
          'A three-day music extravaganza featuring top artists from around the world.',
      'location': 'Central Park',
      'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 45))),
      'imageUrl': 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Food & Wine Expo',
      'description':
          'Experience culinary delights and wine tasting from renowned chefs and sommeliers.',
      'location': 'Grand Hotel Ballroom',
      'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
      'imageUrl': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Startup Pitch Night',
      'description':
          'Watch innovative startups pitch their ideas to potential investors.',
      'location': 'Innovation Hub',
      'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      'imageUrl': 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Art Gallery Opening',
      'description':
          'Exhibition featuring contemporary artworks from emerging artists.',
      'location': 'Metropolitan Art Gallery',
      'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 21))),
      'imageUrl': 'https://images.unsplash.com/photo-1531243269054-5ebf6f34081e',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Fitness Workshop',
      'description':
          'Learn about nutrition, exercise techniques, and wellness from fitness experts.',
      'location': 'City Gym Complex',
      'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 10))),
      'imageUrl': 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Book Launch Event',
      'description': 'Meet the author and get your copy signed at this exclusive book launch.',
      'location': 'City Library Auditorium',
      'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 25))),
      'imageUrl': 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Career Fair 2024',
      'description': 'Connect with top employers and explore career opportunities across industries.',
      'location': 'University Campus',
      'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 60))),
      'imageUrl': 'https://images.unsplash.com/photo-1560523159-4a9692d222ef',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Photography Workshop',
      'description': 'Master the art of photography with hands-on training from professional photographers.',
      'location': 'Creative Studio',
      'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 40))),
      'imageUrl': 'https://images.unsplash.com/photo-1452587925148-ce544e77e70d',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    },
    {
      'name': 'Charity Gala Dinner',
      'description': 'An elegant evening of dining and fundraising for local community projects.',
      'location': 'Ritz Carlton Ballroom',
      'dateTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 90))),
      'imageUrl': 'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    },
  ];

  static Future<void> seedEvents() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final WriteBatch batch = firestore.batch();

      for (final eventData in _sampleEvents) {
        final docRef = firestore.collection('events').doc();
        batch.set(docRef, eventData);
      }

      await batch.commit(); // Ensure proper async commit
      print('Successfully seeded ${_sampleEvents.length} events');
    } catch (e) {
      print('Error seeding events: $e');
    }
  }
}
