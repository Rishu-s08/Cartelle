import 'package:cartelle/core/common/loader.dart';
import 'package:cartelle/core/common/snackbar.dart';
import 'package:cartelle/core/constants/route_constants.dart';
import 'package:cartelle/features/auth/controller/auth_controller.dart';
import 'package:cartelle/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signInWithEmailAndPass(BuildContext context) async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      showSnackbar(context, "Please fill all fields");
      return;
    }
    final success = await ref
        .read(authControllerProvider.notifier)
        .signInWithEmailAndPass(
          context,
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
    if (context.mounted && success) {
      context.goNamed(RouteConstants.homeRoute);
    }
  }

  void authenticateWithGoogle(BuildContext context) {
    ref.read(authControllerProvider.notifier).authenticateWithGoogle(context);
  }

  void navigateToSignUp(BuildContext context) {
    context.goNamed(RouteConstants.signUpRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return isLoading
        ? Loader()
        : Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 80),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Login",
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.copyWith(fontSize: 50),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Welcome back!",
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.copyWith(
                          fontSize: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    hintText: "Email",
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: "Password",
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Checkbox(value: false, onChanged: (val) {}),
                                    const Text("Remember me"),
                                    const Spacer(),
                                    TextButton(
                                      onPressed:
                                          () => navigateToSignUp(context),
                                      child: const Text("Create Account"),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed:
                                      () => signInWithEmailAndPass(context),
                                  child: const Text("Next"),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: const [
                                    Expanded(child: Divider()),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Text("or"),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed:
                                      () => authenticateWithGoogle(context),
                                  icon: const Icon(Icons.g_mobiledata),
                                  label: const Text("Login with Google"),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
