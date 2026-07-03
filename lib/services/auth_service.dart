import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Currently logged in user ID
  String? currentUserId;

  // Stream controller to broadcast auth state changes (true = logged in, false = logged out)
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  Stream<bool> get authStateChanges => _authStateController.stream;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Listen to Firestore document changes
  void _listenToUserDoc(String uid) {
    _userDocSubscription?.cancel();
    _userDocSubscription = _firestore.collection('users').doc(uid).snapshots().listen((snapshot) {
      if (!snapshot.exists) {
        // The user document was deleted from Firestore
        logout();
      } else {
        _authStateController.add(true);
      }
    });
  }

  // Initialize and check current login status
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUid = prefs.getString('currentUserId');
    if (storedUid != null && storedUid.isNotEmpty) {
      currentUserId = storedUid;
      _listenToUserDoc(currentUserId!);
      return true;
    }
    return false;
  }

  // Check if current user has accepted Terms of Service
  Future<bool> checkTosStatus() async {
    if (currentUserId == null) return false;
    
    // First check local SharedPreferences for speed
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? localAccepted = prefs.getBool('tos_accepted');
    if (localAccepted == true) {
      return true;
    }
    
    // If not found locally, check Firestore
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUserId!).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        bool firestoreAccepted = data?['tosAccepted'] == true;
        if (firestoreAccepted) {
          // Save to local cache
          await prefs.setBool('tos_accepted', true);
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error checking TOS status: $e');
    }
    return false;
  }

  // Accept Terms of Service for current user
  Future<void> acceptTermsOfService() async {
    if (currentUserId == null) return;
    
    // Save to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tos_accepted', true);
    
    // Save to Firestore
    try {
      await _firestore.collection('users').doc(currentUserId!).update({
        'tosAccepted': true,
        'tosAcceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving TOS acceptance to Firestore: $e');
    }
  }

  // Login
  Future<void> login(String username, String password) async {
    try {
      // Check Firestore for user
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('user-not-found');
      }

      // Get user document
      var userDoc = userQuery.docs.first;
      String storedPassword = userDoc['password'];
      
      if (storedPassword != password.trim()) {
        throw Exception('wrong-password');
      }

      // Store current user ID for the session
      currentUserId = userDoc['uid'] ?? userDoc.id;

      // Persist user session locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', currentUserId!);

      _listenToUserDoc(currentUserId!);

    } catch (e) {
      rethrow;
    }
  }

  // Sign Up
  Future<void> signUp(String username, String password) async {
    try {
      // Check if username already exists
      QuerySnapshot existingUser = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception('Username already exists');
      }

      // Create user document in Firestore
      String userId = _firestore.collection('users').doc().id;
      
      await _firestore
          .collection('users')
          .doc(userId)
          .set({
        'uid': userId,
        'username': username.trim(),
        'password': password.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'tosAccepted': false, // Unaccepted by default
        'riceFieldLatitude': null,
        'riceFieldLongitude': null,
      });

      // Store current user ID for the session
      currentUserId = userId;
      
      // Persist user session locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', currentUserId!);

      _listenToUserDoc(currentUserId!);
      
    } catch (e) {
       rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    currentUserId = null;
    _userDocSubscription?.cancel();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    await prefs.remove('tos_accepted'); // Clear TOS accepted state on logout
    await _auth.signOut();
    
    _authStateController.add(false);
  }
}
