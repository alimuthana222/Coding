// إعادة تسمية AuthState إلى AppAuthState لتجنب التعارض
abstract class AppAuthState {
  const AppAuthState();
}

class AuthInitial extends AppAuthState {
  const AuthInitial();
}

class AuthLoading extends AppAuthState {
  const AuthLoading();
}

class AuthSuccess extends AppAuthState {
  final String message;
  const AuthSuccess(this.message);
}

class AuthError extends AppAuthState {
  final String message;
  const AuthError(this.message);
}