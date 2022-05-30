import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterfire_login/user_auth.dart';
import 'package:flutterfire_login/user_auth_result.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final userAuthProvider = StateNotifierProvider<FlutterfireAuthNotifier, UserAuth>((ref) => FlutterfireAuthNotifier());

class FlutterfireAuthNotifier extends StateNotifier<UserAuth> {
  FlutterfireAuthNotifier() : super(UserAuth.none);

  void logout() {
    state = UserAuth.none;
  }

  Future<UserAuthResult> emailSignIn(String email, String password) {
    debugPrint('emailSignIn');
    return _waitForCredentials(FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password));
  }

  Future<UserAuthResult> createUser(String email, String password) {
    debugPrint('createUser');
    return _waitForCredentials(FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password));
  }

  Future<UserAuthResult> resetPassword(String email) {
    final completer = Completer<UserAuthResult>();

    debugPrint('resetPassword');
    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((result) {
      debugPrint('resetPassword : success');
      completer.complete(UserAuthResult.success(UserAuth.none));
    }).catchError((error, stacktrace) {
      debugPrint('resetPassword : error : ${error.toString()}');
      completer.complete(UserAuthResult.error(error.toString()));
    });

    return completer.future;
  }

  Future<UserAuthResult> anonymousSignIn() {
    debugPrint('anonymousSignIn');
    return _waitForCredentials(FirebaseAuth.instance.signInAnonymously());
  }

  Future<UserAuthResult> googleSignIn() {
    debugPrint('googleSignIn');
    final completer = Completer<UserAuthResult>();

    _createGoogleCredentials().then((credentials) {
      _waitForCredentials(FirebaseAuth.instance.signInWithCredential(credentials)).then((userAuthResults) {
        debugPrint('googleSignIn : success : $userAuthResults');
        completer.complete(userAuthResults);
      }).catchError((error) {
        debugPrint('googleSignIn : error : Could not get UserAuthResults: ${error.toString()}');
        completer.completeError("Could not get UserAuthResults: ${error.toString()}");
      });
    }).catchError((error) {
      debugPrint('googleSignIn : error : Could not get Google credentials: ${error.toString()}');
      completer.completeError("Could not get Google credentials: ${error.toString()}");
    });

    return completer.future;
  }

  Future<UserAuthResult> appleSignIn() async {
    debugPrint('appleSignIn');
    final completer = Completer<UserAuthResult>();

    _createAppleCredentials().then((oAuthCredential) {
      _waitForCredentials(FirebaseAuth.instance.signInWithCredential(oAuthCredential)).then((userAuthResults) {
        completer.complete(userAuthResults);
      }).catchError((error) {
        completer.completeError("Could not get the UserAuthResults: ${error.toString()}");
      });
    }).catchError((error) {
      completer.completeError("Could not get the Apple credentials: ${error.toString()}");
    });

    return completer.future;
  }

  Future<UserAuthResult> phoneSignIn(mobileNumber) async {
    final completer = Completer<UserAuthResult>();

    debugPrint('phoneSignIn: mobile number: $mobileNumber');
    FirebaseAuth.instance.signInWithPhoneNumber(mobileNumber).then((confirmationResult) {
      completer.complete(UserAuthResult.confirmation(confirmationResult));
    }).onError((error, stackTrace) {
      completer.complete(UserAuthResult.error(error.toString()));
    });

    return completer.future;
  }

  Future<UserAuthResult> verifyPhoneNumber(ConfirmationResult confirmationResult, String verificationCode) async {
    return _waitForCredentials(confirmationResult.confirm(verificationCode));
  }

  Future<OAuthCredential> _createAppleCredentials() {
    final completer = Completer<OAuthCredential>();

    debugPrint('_createAppleCredentials');
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    final rawNonce = List.generate(32, (_) => charset[random.nextInt(charset.length)]).join();
    final bytes = utf8.encode(rawNonce);
    final digest = sha256.convert(bytes);
    final nonce = digest.toString();
    SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    ).then((appleCredential) {
      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      completer.complete(oAuthCredential);
    }).catchError((error) {
      completer.completeError('Could mot get Apple ID credentials.');
    });

    return completer.future;
  }

  Future<OAuthCredential> _createGoogleCredentials() {
    final completer = Completer<OAuthCredential>();

    debugPrint('_createGoogleCredentials');
    GoogleSignIn().signIn().then((googleUser) {
      if (googleUser == null) {
        completer.completeError("User is not logged into Google.");
      } else {
        googleUser.authentication.then((googleAuth) {
          final oAuthCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          completer.complete(oAuthCredential);
        }).catchError((error) {
          completer.completeError("Could not get googleAuth: ${error.toString()}");
        });
      }
    }).catchError((error) {
      completer.completeError("Could not sign in user: ${error.toString()}");
    });

    return completer.future;
  }

  Future<UserAuthResult> _waitForCredentials(Future<UserCredential> credentialFuture) {
    final completer = Completer<UserAuthResult>();
    debugPrint('_handleCredentialsFuture: Handling credentials....');
    try {
      credentialFuture.then((credentials) {
        final userAuthResult = _processCredentials(credentials);
        debugPrint('(1) _handleCredentialsFuture errorString: $userAuthResult');
        completer.complete(userAuthResult);
      }).onError((error, stackTrace) {
        final errorString = error.toString();
        debugPrint('(2) _handleCredentialsFuture errorString: $errorString');
        completer.completeError(errorString);
      });
    } catch (error) {
      final errorString = error.toString();
      debugPrint('(3) _handleCredentialsFuture errorString: $errorString');
      completer.completeError(errorString);
    }
    return completer.future;
  }

  UserAuthResult _processCredentials(UserCredential credentials) {
    debugPrint('_handleCredentials: $credentials');

    try {
      final user = credentials.user;
      if (user == null) {
        return UserAuthResult.error('Credentials did not contain a user.');
      }

      debugPrint('New user has been created: $user');

      final userAuth = UserAuth(
        uuid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
      );
      state = userAuth;

      debugPrint('user has been updated: $user');

      return UserAuthResult.success(userAuth);
    } catch (error) {
      return UserAuthResult.error(error.toString());
    }
  }
}
