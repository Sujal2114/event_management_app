import 'package:event_management_app/saved_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Save the user data to database
Future<void> saveUserData(String name, String email, String userId) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'updatedAt': DateTime.now(),
    }, SetOptions(merge: true));
  } catch (e) {
    print('Error updating user data: $e');
    throw e;
  }
}

// get user data from the database
Future<Map<String, dynamic>?> getUserData() async {
  final userId = SavedData.getUserId();
  try {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return docSnapshot.data();
  } catch (e) {
    print('Error getting user data: $e');
    return null;
  }
}

// Create new events
Future<void> createEvent(
    String name,
    String desc,
    String image,
    String location,
    String datetime,
    String createdBy,
    bool isInPersonOrNot,
    String guest,
    String sponsers) async {
  try {
    // Upload image to Firebase Storage if provided
    String imageUrl = '';
    if (image.isNotEmpty) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('event_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putString(image, format: PutStringFormat.dataUrl);
      imageUrl = await storageRef.getDownloadURL();
    }

    // Create event document in Firestore
    await FirebaseFirestore.instance.collection('events').add({
      'name': name,
      'description': desc,
      'image': imageUrl,
      'location': location,
      'datetime': datetime,
      'createdBy': createdBy,
      'isInPerson': isInPersonOrNot,
      'guest': guest,
      'sponsers': sponsers,
      'participants': [],
      'createdAt': DateTime.now(),
    });
  } catch (e) {
    print('Error creating event: $e');
    throw e;
  }
}

// Read all Events
Future<QuerySnapshot<Map<String, dynamic>>> getAllEvents() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .orderBy('datetime', descending: true)
        .get();

    return querySnapshot;
  } catch (e) {
    print('Error getting events: $e');
    throw Exception('Error getting events: $e');
  }
}

// rsvp an event
Future<bool> rsvpEvent(List participants, String documentId) async {
  try {
    final userId = SavedData.getUserId();
    participants.add(userId);

    await FirebaseFirestore.instance
        .collection('events')
        .doc(documentId)
        .update({'participants': participants});
    return true;
  } catch (e) {
    print('Error updating RSVP: $e');
    return false;
  }
}

// list all event created by the user
Future<List<Map<String, dynamic>>> manageEvents() async {
  final userId = SavedData.getUserId();
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('createdBy', isEqualTo: userId)
        .orderBy('datetime', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  } catch (e) {
    print('Error getting managed events: $e');
    return [];
  }
}

// update the edited event
Future<void> updateEvent(
    String name,
    String desc,
    String image,
    String location,
    String datetime,
    String createdBy,
    bool isInPersonOrNot,
    String guest,
    String sponsers,
    String docID) async {
  try {
    String imageUrl = '';
    if (image.isNotEmpty && image.startsWith('data:')) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('event_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putString(image, format: PutStringFormat.dataUrl);
      imageUrl = await storageRef.getDownloadURL();
    } else {
      imageUrl = image; // Keep existing image URL if not changed
    }

    await FirebaseFirestore.instance.collection('events').doc(docID).update({
      'name': name,
      'description': desc,
      'image': imageUrl,
      'location': location,
      'datetime': datetime,
      'createdBy': createdBy,
      'isInPerson': isInPersonOrNot,
      'guest': guest,
      'sponsers': sponsers,
      'updatedAt': DateTime.now(),
    });
  } catch (e) {
    print('Error updating event: $e');
    throw e;
  }
}

// deleting an event
Future<void> deleteEvent(String docID) async {
  try {
    // Get the event document to check for image
    final eventDoc =
        await FirebaseFirestore.instance.collection('events').doc(docID).get();

    if (eventDoc.exists) {
      final data = eventDoc.data();
      final imageUrl = data?['image'] as String?;

      // Delete the image from storage if it exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('Error deleting image: $e');
        }
      }

      // Delete the event document
      await FirebaseFirestore.instance.collection('events').doc(docID).delete();
    }
  } catch (e) {
    print('Error deleting event: $e');
    throw e;
  }
}

// Get upcoming events
Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
  try {
    final now = DateTime.now();
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('datetime', isGreaterThan: now.toIso8601String())
        .orderBy('datetime', descending: false)
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  } catch (e) {
    print('Error getting upcoming events: $e');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getPastEvents() async {
  try {
    final now = DateTime.now();
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('datetime', isLessThan: now.toIso8601String())
        .orderBy('datetime', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  } catch (e) {
    print('Error getting past events: $e');
    return [];
  }
}
