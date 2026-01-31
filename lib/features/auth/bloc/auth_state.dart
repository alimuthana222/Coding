import 'package:equatable/equatable.dart';
import '../../../core/models/user_model.dart';

enum AppAuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AppAuthState extends Equatable {
  final AppAuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AppAuthState({
    this.status = AppAuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  const AppAuthState.initial() : this(status: AppAuthStatus.initial);

  const AppAuthState.loading() : this(status: AppAuthStatus.loading);

  const AppAuthState.authenticated(UserModel user)
      : this(status: AppAuthStatus.authenticated, user: user);

  const AppAuthState.unauthenticated()
      : this(status: AppAuthStatus.unauthenticated);

  const AppAuthState.error(String message)
      : this(status: AppAuthStatus.error, errorMessage: message);

  bool get isLoading => status == AppAuthStatus.loading;
  bool get isAuthenticated => status == AppAuthStatus.authenticated;
  bool get isUnauthenticated => status == AppAuthStatus.unauthenticated;

  AppAuthState copyWith({
    AppAuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}