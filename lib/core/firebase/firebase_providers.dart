import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Firebase core providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

// User Authentication state provider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Admin Custom Claim validator provider (checks if user token has admin: true)
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return false;
  
  // Force refresh token to fetch latest custom claims
  final idTokenResult = await user.getIdTokenResult(true);
  final claims = idTokenResult.claims;
  
  if (claims != null && claims['admin'] == true) {
    return true;
  }
  return false;
});
