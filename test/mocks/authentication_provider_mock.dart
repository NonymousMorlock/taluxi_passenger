import 'package:mockito/mockito.dart';
import 'package:user_manager/user_manager.dart';

class MockAuthenticationProvider extends Mock
    implements AuthenticationProvider {
  // ! These exceptions were chosen by chance .
  static const exceptionToBeThrownWhenSigningUp =
      AuthenticationException.emailAlreadyUsed();
  static const exceptionToBeThrownWhenSigningIn =
      AuthenticationException.invalidEmail();
  static const exceptionToBeThrownWhenSigningOut =
      AuthenticationException.unknown();
  static const exceptionToBeThrownWhenResetingPassword =
      AuthenticationException.unknown();

// TODOtest password reset exception handling in [SignInBusinessLogic] .

  @override
  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    throw exceptionToBeThrownWhenSigningUp;
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw exceptionToBeThrownWhenSigningIn;
  }

  @override
  Future<void> signInWithFacebook() {
    throw exceptionToBeThrownWhenSigningIn;
  }

  @override
  Future<void> signOut() {
    throw exceptionToBeThrownWhenSigningOut;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    throw exceptionToBeThrownWhenResetingPassword;
  }
}
