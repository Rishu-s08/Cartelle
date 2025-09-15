import 'package:cartelle/app_router.dart';
import 'package:cartelle/core/sevices/geofence_location.dart';
import 'package:cartelle/core/sevices/notification_service.dart';
import 'package:cartelle/features/auth/repository/auth_repository.dart';
import 'package:cartelle/firebase_options.dart';
import 'package:cartelle/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final NotificationService notificationService = NotificationService();
  await notificationService.initialize();
  bg.BackgroundGeolocation.registerHeadlessTask(backgroundGeofenceHeadlessTask);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    final user = userAsync.maybeWhen(data: (user) => user, orElse: () => null);
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Cartelle',
      theme: AppTheme.cupcakeLightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.getRouter(user, ref),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    print('MyHomePage build');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cartelle",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
