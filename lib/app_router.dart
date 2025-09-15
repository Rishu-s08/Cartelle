import 'package:cartelle/core/constants/route_constants.dart';
import 'package:cartelle/features/add_list/screen/add_list_screen.dart';
import 'package:cartelle/features/add_list/screen/update_list_screen.dart';
import 'package:cartelle/features/add_reminder/screen/add_reminder_screen.dart';
import 'package:cartelle/features/auth/controller/auth_controller.dart';
import 'package:cartelle/features/auth/screens/email_verification.dart';
import 'package:cartelle/features/auth/screens/login_screen.dart';
import 'package:cartelle/features/auth/screens/sign_up_screen.dart';
import 'package:cartelle/features/home/screens/home_screen.dart';
import 'package:cartelle/features/location/screen/add_location_screen.dart';
import 'package:cartelle/features/profile/screen/about_screen.dart';
import 'package:cartelle/features/profile/screen/edit_profile_screen.dart';
import 'package:cartelle/features/profile/screen/profile_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter getRouter(User? user, WidgetRef ref) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) async {
        // await user?.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;
        user = refreshedUser;
        final isOnPublicRoutes = [
          '/login',
          '/signUp',
          '/email-verify',
        ].contains(state.matchedLocation);

        if (user == null && !isOnPublicRoutes) return '/login';

        if (user != null && !user!.emailVerified) {
          if (state.matchedLocation != '/email-verify') {
            return '/email-verify';
          }
          return null;
        }

        // If user is logged in and verified and tries to visit login/signup, send them to home
        if (user != null &&
            user!.emailVerified &&
            (state.matchedLocation == '/login' ||
                state.matchedLocation == '/signUp')) {
          final uid = user!.uid;
          try {
            final userModel =
                await ref
                    .read(authControllerProvider.notifier)
                    .getUserData(uid)
                    .first;
            ref.read(userProvider.notifier).state = userModel;
          } catch (e) {
            // Handle error or fallback
          }
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          name: RouteConstants.loginRoute,
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        GoRoute(
          name: RouteConstants.homeRoute,
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),

        GoRoute(
          name: RouteConstants.emailVerificationRoute,
          path: '/email-verify',
          builder: (context, state) => const EmailVerification(),
        ),

        GoRoute(
          name: RouteConstants.editListRoute,
          path: '/edit-list/:listId',
          builder:
              (context, state) =>
                  UpdateListScreen(listId: state.pathParameters['listId']!),
        ),
        GoRoute(
          name: RouteConstants.addLocationRoute,
          path: '/add-location',
          builder: (context, state) => AddLocationScreen(),
        ),

        GoRoute(
          name: RouteConstants.signUpRoute,
          path: '/signUp',
          builder: (context, state) => const SignUpScreen(),
        ),

        GoRoute(
          name: RouteConstants.profileSettingsRoute,
          path: '/profile-settings',
          builder: (context, state) => ProfileSettingsScreen(),
        ),

        GoRoute(
          name: RouteConstants.editProfileRoute,
          path: '/edit-profile',
          builder: (context, state) => EditProfileScreen(),
        ),

        GoRoute(
          name: RouteConstants.aboutRoute,
          path: '/about',
          builder: (context, state) => AboutScreen(),
        ),

        GoRoute(
          name: RouteConstants.addReminderRoute,
          path: '/add-reminder',
          builder: (context, state) => AddReminderScreen(),
        ),

        GoRoute(
          name: RouteConstants.addListRoute,
          path: '/add-list',
          builder: (context, state) => AddListScreen(),
        ),
      ],
    );
  }
}
