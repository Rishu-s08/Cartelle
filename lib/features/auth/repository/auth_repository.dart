import 'package:cartelle/core/constants/firebase_constants.dart';
import 'package:cartelle/core/failure.dart';
import 'package:cartelle/core/modals/user_model.dart';
import 'package:cartelle/core/providers/firebase_providers.dart';
import 'package:cartelle/core/typedefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authStateProvider = StreamProvider((ref) {
  return ref.read(firebaseAuthProvider).authStateChanges();
});

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    firebaseAuth: ref.read(firebaseAuthProvider),
    firebaseFirestore: ref.read(firebaseFirestoreProvider),
    googleSignIn: ref.read(googleSignInProvider),
  );
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firebaseFirestore,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firebaseFirestore = firebaseFirestore,
       _googleSignIn = googleSignIn;

  CollectionReference get _user =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);

  FutureEither<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
      //   email,
      // );
      // if (methods.contains('google.com')) {
      //   return left(
      //     Failure(
      //       'This email is already linked with Google sign-in. Please use Google login.',
      //     ),
      //   );
      // }
      // if (methods.contains('password')) {
      //   return left(
      //     Failure(
      //       'An account already exists with this email. Please use email login.',
      //     ),
      //   );
      // }
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        return left(Failure('User not found'));
      }

      await sendEmailVerification();
      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          name: displayName,
          createdAt: DateTime.now(),
          isAuthenticated: true,
        );
        await _user.doc(user.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(user.uid).first;
      }

      return right(userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return left(Failure('Invalid email address'));
      } else if (e.code == 'email-already-in-use') {
        return left(Failure('Email is already in use'));
      } else if (e.code == 'weak-password') {
        return left(Failure('Password should be at least 6 characters'));
      } else if (e.code == 'missing-email' || e.code == 'internal-error') {
        return left(Failure('Email or password cannot be empty'));
      } else {
        return left(Failure(e.message ?? 'Authentication error'));
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      final userModel = await getUserData(user!.uid).first;
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'invalid-user' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        throw Failure('Invalid email or password');
      } else {
        throw Failure(e.message ?? 'Authentication error');
      }
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  FutureVoid sendEmailVerification() async {
    final user = _firebaseAuth.currentUser!;
    if (!(user.emailVerified)) {
      await user.sendEmailVerification();
      return right(null);
    } else {
      return left(
        Failure("User is Already Verified! Please click verified or login"),
      );
    }
  }

  Future<bool> isEmailVerifiedYet() async {
    final user = _firebaseAuth.currentUser;
    await user!.reload();
    return user.emailVerified;
  }

  FutureEither<UserModel> authenticateWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        clientId:
            '908353144240-hnm9pkdepo8u3qp9sfj22uk1n5nvvmff.apps.googleusercontent.com',
      );
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );

      // Get authorization for Firebase scopes if needed
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      UserModel userModel;
      final user = userCredential.user!;
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          name: user.displayName ?? 'No name',
          createdAt: DateTime.now(),
          isAuthenticated: true,
        );

        await _user.doc(user.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(user.uid).first;
      }

      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.toString();
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _user.doc(uid).snapshots().map((event) {
      final data = event.data();
      if (data == null) {
        throw Exception('user data not found');
      } else {
        return UserModel.fromMap(data as Map<String, dynamic>);
      }
    });
  }

  FutureVoid signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
