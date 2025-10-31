import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/user_model.dart';

class UserService {
  final CollectionReference _users = FirebaseFirestore.instance.collection(
    'users',
  );

  Future<void> createUser(UserModel user) {
    return _users.doc(user.id).set(user.toFirestore());
  }

  Future<UserModel?> getUser(String id) async {
    final doc = await _users.doc(id).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<bool> isUsernameTaken(String username) async {
    final query = await _users.where('username', isEqualTo: username).get();
    return query.docs.isNotEmpty;
  }

  Future<void> updateUser(UserModel user) {
    return _users.doc(user.id).update(user.toFirestore());
  }
}
