import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserServices {
  static Future<void> initBuyerProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = FirebaseFirestore.instance.collection('buyers').doc(user.uid);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'email'       : user.email ?? '',
        'displayName' : user.displayName ?? '',
        'photoURL'    : user.photoURL ?? '',
        'phoneNumber' : user.phoneNumber ?? '',
        'createdAt'   : FieldValue.serverTimestamp(),
      });
    }
  }
}

