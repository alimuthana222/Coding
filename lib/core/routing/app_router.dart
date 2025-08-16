import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/auth/views/profile_view.dart';
import '../../features/auth/views/edit_profile_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/services/views/services_view.dart';
import '../../features/services/views/create_service_view.dart';
import '../../features/wallet/views/wallet_view.dart';
import '../../features/timebank/views/timebank_view.dart';
import '../../features/community/views/community_view.dart';
import '../../features/community/views/create_post_view.dart';
import '../../features/events/views/events_view.dart';
import '../../features/messaging/views/conversations_view.dart';
import '../../features/messaging/views/chat_view.dart';
import '../../features/bookings/views/bookings_view.dart';
import '../../features/admin/views/admin_dashboard_view.dart';
import '../../shared/widgets/main_navigation.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth/login',
    redirect: (context, state) {
      final currentUserAsync = ref.read(currentUserProvider);

      return currentUserAsync.when(
        data: (user) {
          final isLoggedIn = user != null;
          final isAuthRoute = state.matchedLocation.startsWith('/auth');

          if (!isLoggedIn && !isAuthRoute) {
            return '/auth/login';
          }

          if (isLoggedIn && isAuthRoute) {
            return '/';
          }

          return null;
        },
        loading: () => null,
        error: (error, stack) => '/auth/login',
      );
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterView(),
      ),

      // Main app routes
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/services',
            name: 'services',
            builder: (context, state) => const ServicesView(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-service',
                builder: (context, state) {
                  final type = state.uri.queryParameters['type'] ?? 'offer';
                  return CreateServiceView(type: type);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/wallet',
            name: 'wallet',
            builder: (context, state) => const WalletView(),
          ),
          GoRoute(
            path: '/timebank',
            name: 'timebank',
            builder: (context, state) => const TimeBankView(),
          ),
          GoRoute(
            path: '/community',
            name: 'community',
            builder: (context, state) => const CommunityView(),
            routes: [
              GoRoute(
                path: 'create-post',
                name: 'create-post',
                builder: (context, state) => const CreatePostView(),
              ),
            ],
          ),
          GoRoute(
            path: '/events',
            name: 'events',
            builder: (context, state) => const EventsView(),
          ),
          GoRoute(
            path: '/messages',
            name: 'messages',
            builder: (context, state) => const ConversationsView(),
            routes: [
              GoRoute(
                path: 'chat/:id',
                name: 'chat',
                builder: (context, state) {
                  final chatId = state.pathParameters['id']!;
                  return ChatView(chatId: chatId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/bookings',
            name: 'bookings',
            builder: (context, state) => const BookingsView(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileView(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-profile',
                builder: (context, state) => const EditProfileView(),
              ),
            ],
          ),
          GoRoute(
            path: '/admin',
            name: 'admin',
            builder: (context, state) => const AdminDashboardView(),
          ),
        ],
      ),
    ],
  );
});

final routerProvider = goRouterProvider;