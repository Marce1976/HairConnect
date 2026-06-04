import 'failure.dart';

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super('Credenciales inválidas', code: 'invalid-credential');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure()
      : super('El email ya está registrado', code: 'email-already-in-use');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure()
      : super('La contraseña es demasiado débil', code: 'weak-password');
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure()
      : super('Usuario no encontrado', code: 'user-not-found');
}

class GenericAuthFailure extends AuthFailure {
  const GenericAuthFailure(super.message, {super.code});
}
