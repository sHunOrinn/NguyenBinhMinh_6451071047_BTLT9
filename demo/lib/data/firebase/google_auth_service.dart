import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Người dùng đã huỷ đăng nhập Google.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Không lấy được thông tin người dùng.',
        );
      }

      await _upsertUserProfile(user);
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Đăng nhập Google thất bại: $e',
      );
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  static Future<void> _upsertUserProfile(User user) async {
    final DocumentReference<Map<String, dynamic>> userRef =
    _firestore.collection('users').doc(user.uid);
    final DocumentSnapshot<Map<String, dynamic>> snap = await userRef.get();
    final Map<String, dynamic>? oldData = snap.data();

    final List<String> providerIds = user.providerData
        .map((UserInfo e) => e.providerId)
        .where((String id) => id.isNotEmpty)
        .toSet()
        .toList();

    final Map<String, dynamic> data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName':
      (oldData?['displayName'] as String?)?.trim().isNotEmpty == true
          ? oldData!['displayName']
          : (user.displayName ?? 'Người dùng'),
      'photoURL': (user.photoURL != null && user.photoURL!.trim().isNotEmpty)
          ? user.photoURL
          : (oldData?['photoURL'] ?? ''),
      'phoneNumber': user.phoneNumber ?? (oldData?['phoneNumber'] ?? ''),
      'provider': 'google',
      'providers': providerIds,
      'role': oldData?['role'] ?? 'user',
      'status': oldData?['status'] ?? 'active',
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snap.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
      await userRef.set(data);
    } else {
      await userRef.set(data, SetOptions(merge: true));
    }
  }
}