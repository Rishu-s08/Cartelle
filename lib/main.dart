import 'package:cartelle/app_router.dart';
import 'package:cartelle/features/auth/repository/auth_repository.dart';
import 'package:cartelle/firebase_options.dart';
import 'package:cartelle/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: MyApp()));
}

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ref
//         .watch(authStateProvider)
//         .when(
//           data: (data) {
//             return MaterialApp.router(
//               title: 'Cartelle',
//               theme: AppTheme.cupcakeLightTheme,
//               debugShowCheckedModeBanner: false,
//               routerConfig: AppRouter.getRouter(data, ref),
//             );
//           },
//           error: (e, stackTrace) => ErrorText(error: e.toString()),
//           loading: () => Loader(),
//         );
//   }
// }

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    final user = userAsync.maybeWhen(data: (user) => user, orElse: () => null);

    return MaterialApp.router(
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
