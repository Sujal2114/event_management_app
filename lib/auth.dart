import 'package:event_management_app/saved_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Register User
Future<String> createUser(String name, String email, String password) async {
  try {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create user profile in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'name': name,
      'email': email,
      'createdAt': DateTime.now(),
    });

    // Save user data locally
    await SavedData.saveUserData(name, email, credential.user!.uid);
    return "success";
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      return 'The password provided is too weak';
    } else if (e.code == 'email-already-in-use') {
      return 'The account already exists for that email';
    }
    return e.message ?? 'Registration failed';
  } catch (e) {
    return 'An error occurred during registration';
  }
}

// Login User
Future<bool> loginUser(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get user profile from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    if (userDoc.exists) {
      await SavedData.saveUserData(
        userDoc.data()!['name'],
        email,
        credential.user!.uid,
      );
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}

// Logout the user
Future<void> logoutUser() async {
  await FirebaseAuth.instance.signOut();
  await SavedData.clearSavedData();
}

// check if user have an active session or not
Future<bool> checkSessions() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      await SavedData.saveUserData(
        userDoc.data()!['name'],
        currentUser.email!,
        currentUser.uid,
      );
      return true;
    }
  }
  return false;
}
