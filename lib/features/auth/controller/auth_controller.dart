import 'package:cartelle/core/common/snackbar.dart';
import 'package:cartelle/core/modals/user_model.dart';
import 'package:cartelle/features/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  return ref.read(authControllerProvider.notifier).getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
    : _authRepository = authRepository,
      _ref = ref,
      super(false);

  void authenticateWithGoogle(BuildContext context) async {
    state = true;
    final user = await _authRepository.authenticateWithGoogle();
    state = false;
    user.fold(
      (l) => showSnackbar(context, l.message),
      (r) => _ref.read(userProvider.notifier).update((state) => r),
    );
  }

  Future<bool> signUpWithEmailAndPass(
    BuildContext context,
    String email,
    String password,
    String displayName,
  ) async {
    state = true;
    final user = await _authRepository.signUpWithEmailAndPassword(
      displayName: displayName,
      email: email,
      password: password,
    );
    state = false;
    user.fold(
      (l) {
        showSnackbar(context, l.message);
        return false;
      },
      (r) {
        _ref.read(userProvider.notifier).update((state) => r);
        return true;
      },
    );
    return user.isRight();
  }

  void sendEmailVerification(BuildContext context) async {
    final verified = await _authRepository.sendEmailVerification();
    verified.fold(
      (l) => showSnackbar(context, l.message),
      (r) => showSnackbar(context, "Verify Link send succesfully"),
    );
  }

  Future<bool> signInWithEmailAndPass(
    BuildContext context,
    String email,
    String password,
  ) async {
    state = true;
    final user = await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    state = false;
    user.fold(
      (l) {
        showSnackbar(context, l.message);
        return false;
      },
      (r) {
        _ref.read(userProvider.notifier).update((state) => r);
        return true;
      },
    );
    return user.isRight();
  }

  Future<bool> isEmailVerifiedYet() async {
    return await _authRepository.isEmailVerifiedYet();
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void signOut(BuildContext context) async {
    state = true;
    final result = await _authRepository.signOut();
    state = false;
    result.fold(
      (l) => showSnackbar(context, l.message),
      (r) => _ref.read(userProvider.notifier).update((state) => null),
    );
  }
}
