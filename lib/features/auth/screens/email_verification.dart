import 'package:cartelle/core/common/loader.dart';
import 'package:cartelle/core/common/snackbar.dart';
import 'package:cartelle/core/constants/route_constants.dart';
import 'package:cartelle/features/auth/controller/auth_controller.dart';
import 'package:cartelle/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EmailVerification extends ConsumerWidget {
  const EmailVerification({super.key});

  void isVerified(BuildContext context, WidgetRef ref) async {
    final isDoneVerified =
        await ref.read(authControllerProvider.notifier).isEmailVerifiedYet();
    if (!context.mounted) return;
    if (!isDoneVerified) {
      showSnackbar(
        context,
        "Email is not yet verified, Please verify your email brothaaaa 🫡",
      );
      return;
    }

    // Navigate to the home screen or wherever you want after verification
    navigateToHomeScreen(context);
    showSnackbar(context, "Email is verified, Welcome to Cartelle 🫡");
  }

  void navigateToHomeScreen(BuildContext context) {
    // Implement navigation to home screen
    // For example:
    context.goNamed(RouteConstants.homeRoute);
  }

  void resendEmailVerification(BuildContext context, WidgetRef ref) {
    ref.read(authControllerProvider.notifier).sendEmailVerification(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        "Email Verification",
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.copyWith(fontSize: 50),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please verify your email before proceeding...",
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
                                const SizedBox(height: 10),
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
                                      () =>
                                          resendEmailVerification(context, ref),
                                  child: const Text("Resend Email?"),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () => isVerified(context, ref),
                                  child: const Text("Verified?"),
                                ),
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
