import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../core/di/injection.dart';
import '../features/auth/bloc/auth_cubit.dart';

class MaharatApp extends StatelessWidget {
  const MaharatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<ThemeProvider>()),
        ChangeNotifierProvider.value(value: sl<LocaleProvider>()),
      ],
      child: BlocProvider(
        create: (context) => AuthCubit(),
        child: Consumer2<ThemeProvider, LocaleProvider>(
          builder: (context, themeProvider, localeProvider, child) {
            return MaterialApp.router(
              title: 'مهارات',
              debugShowCheckedModeBanner: false,

              // Theme
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              themeAnimationDuration: Duration.zero,
              themeAnimationCurve: Curves.linear,

              // Localization
              locale: localeProvider.locale,
              supportedLocales: const [
                Locale('ar'),
                Locale('en'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // Router
              routerConfig: AppRouter.router,

              // Direction based on locale
              builder: (context, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  themeProvider.updateSystemUI(context);
                });

                return Directionality(
                  textDirection: localeProvider.isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}