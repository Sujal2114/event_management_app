class EventRating {
  final String userId;
  final String userEmail;
  final double rating;
  final String review;
  final DateTime timestamp;

  EventRating({
    required this.userId,
    required this.userEmail,
    required this.rating,
    required this.review,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'rating': rating,
      'review': review,
      'timestamp': timestamp,
    };
  }

  factory EventRating.fromMap(Map<String, dynamic> map) {
    return EventRating(
      userId: map['userId'] as String,
      userEmail: map['userEmail'] as String,
      rating: (map['rating'] as num).toDouble(),
      review: map['review'] as String,
      timestamp: DateTime.parse(map['timestamp'].toString()),
    );
  }
}
