import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../theme/theme_provider.dart';
import '../localization/locale_provider.dart';
import '../repositories/repositories.dart';
import '../repositories/wallet_repository.dart';
import '../repositories/service_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // Providers
  sl.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
  sl.registerLazySingleton<LocaleProvider>(() => LocaleProvider());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerLazySingleton<UserRepository>(() => UserRepository());
  sl.registerLazySingleton<SkillRepository>(() => SkillRepository());
  sl.registerLazySingleton<PostRepository>(() => PostRepository());
  sl.registerLazySingleton<EventRepository>(() => EventRepository());
  sl.registerLazySingleton<MessageRepository>(() => MessageRepository());
  sl.registerLazySingleton<BookingRepository>(() => BookingRepository());
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepository());
  sl.registerLazySingleton<WalletRepository>(() => WalletRepository()); // ✅ جديد
  sl.registerLazySingleton<ServiceRepository>(() => ServiceRepository()); // ✅ جديد
}