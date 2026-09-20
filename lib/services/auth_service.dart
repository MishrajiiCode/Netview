import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLocalAdmin = false;

  static const String masterAdminEmail = 'rajmishr150@gmail.com';
  static const String masterAdminPassword = 'rajmishra2026';

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isAdmin => _isLocalAdmin || _auth.currentUser != null;

  Future<UserCredential?> signIn(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    // Check master admin credentials
    if (cleanEmail == masterAdminEmail && password == masterAdminPassword) {
      try {
        // Try Firebase Auth first
        final credential = await _auth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        _isLocalAdmin = true;
        return credential;
      } catch (_) {
        // Master admin accepted locally if Firebase Auth user isn't created yet
        _isLocalAdmin = true;
        return null;
      }
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isLocalAdmin = false;
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    } catch (e) {
      throw 'Authentication failed: $e';
    }
  }

  Future<void> signOut() async {
    _isLocalAdmin = false;
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No admin account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please check your credentials.';
    }
  }
}
