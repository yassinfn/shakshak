import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  User? _firebaseUser;
  UserModel? _user;

  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;

  UserViewModel() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    if (_firebaseUser != null) {
      _user = await _userService.getUser(_firebaseUser!.uid);
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    final authService = AuthService();
    final userCredential = await authService.signInWithGoogle();
    if (userCredential != null) {
      _firebaseUser = userCredential.user;
      if (_firebaseUser != null) {
        _user = await _userService.getUser(_firebaseUser!.uid);
        if (_user == null) {
          final newUser = UserModel(
            id: _firebaseUser!.uid,
            username: '', // To be set in ProfileConfigScreen
            discoveryPoints: 0,
            lastMessageTimestamp: null,
          );
          await _userService.createUser(newUser);
          _user = newUser;
        }
      }
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    final authService = AuthService();
    await authService.signOut();
    _firebaseUser = null;
    _user = null;
    notifyListeners();
  }

  Future<bool> setUsername(String username) async {
    if (_user != null) {
      final isTaken = await _userService.isUsernameTaken(username);
      if (isTaken) {
        return false;
      }
      _user!.username = username;
      await _userService.updateUser(_user!);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> updateUser(UserModel user) async {
    await _userService.updateUser(user);
    _user = user;
    notifyListeners();
  }
}
