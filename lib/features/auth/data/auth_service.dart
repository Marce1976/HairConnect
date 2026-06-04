import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hair_connect/core/errors/auth_failure.dart';
import 'package:hair_connect/features/auth/data/user_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final UserService _userService;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? firebaseAuth,
    UserService? userService,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _userService = userService ?? UserService(),
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Crea un usuario en Firebase Auth y opcionalmente guarda sus datos en
  /// Firestore si se proporcionan [name] y [isClient].
  ///
  /// Lanza un [AuthFailure] específico según el código de error de Firebase.
  Future<User?> register(
    String email,
    String password, {
    String? name,
    bool? isClient,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null && name != null && isClient != null) {
        await _userService.saveUser(user, name, isClient);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw GenericAuthFailure('Error inesperado durante el registro: $e');
    }
  }

  /// Inicia sesión con email y contraseña.
  ///
  /// Lanza un [AuthFailure] específico según el código de error de Firebase.
  Future<User?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw GenericAuthFailure('Error inesperado durante el inicio de sesión: $e');
    }
  }

  /// Inicia sesión con Google Sign-In.
  ///
  /// Retorna el [User] de Firebase si la autenticación es exitosa.
  /// Retorna `null` si el usuario cancela el diálogo de Google.
  /// Lanza un [AuthFailure] específico según el error de Firebase.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Usuario canceló

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      // Si es la primera vez, guardar en Firestore
      if (result.additionalUserInfo?.isNewUser ?? false) {
        await _userService.saveUser(
          result.user!,
          googleUser.displayName ?? 'Usuario',
          true, // por defecto cliente, pueden cambiarlo después
        );
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw GenericAuthFailure(
        'Error al iniciar sesión con Google: $e',
      );
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Mapea los códigos de error de Firebase Auth a [AuthFailure] concretos.
  AuthFailure _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return EmailAlreadyInUseFailure();
      case 'weak-password':
        return WeakPasswordFailure();
      case 'user-not-found':
        return UserNotFoundFailure();
      case 'invalid-credential':
        return InvalidCredentialsFailure();
      default:
        return GenericAuthFailure(
          e.message ?? 'Error de autenticación',
          code: e.code,
        );
    }
  }
}
