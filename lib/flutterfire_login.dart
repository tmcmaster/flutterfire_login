import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_login/flutter_login.dart';
import 'package:flutterfire_auth/flutterfire_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FlutterfireLogin extends StatelessWidget {
  static const routeName = '/auth';

  final String appTitle;
  // final WidgetBuilder landingPageBuilder;
  final String landingPageRoute;
  final FlutterfireAuthNotifier authNotifier;
  final bool googleLogin;
  final bool iosLogin;
  final bool anonymousLogin;

  const FlutterfireLogin({
    Key? key,
    required this.appTitle,
    // required this.landingPageBuilder,
    required this.landingPageRoute,
    required this.authNotifier,
    this.googleLogin = false,
    this.iosLogin = false,
    this.anonymousLogin = false,
  }) : super(key: key);

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  Future<String?> _loginUser(LoginData data) {
    final completer = Completer<String?>();

    authNotifier.emailSignIn(data.name, data.password).then((userAuthResult) {
      completer.complete(userAuthResult.error);
    }).catchError((error) {
      completer.complete(error.toString());
    });

    return completer.future;
  }

  Future<String?> _signupUser(SignupData data) {
    if (data.name == null || data.name!.isEmpty) return Future.value("Name was not supplied");
    if (data.password == null || data.password!.isEmpty) return Future.value("Password was not supplied");

    final completer = Completer<String?>();

    authNotifier.createUser(data.name!, data.password!).then((userAuthResult) {
      completer.complete(userAuthResult.error);
    }).catchError((error) {
      completer.complete(error.toString());
    });

    return completer.future;
  }

  Future<String?> _recoverPassword(String name) {
    final completer = Completer<String?>();

    authNotifier.resetPassword(name).then((userAuthResult) {
      completer.complete(userAuthResult.error);
    }).catchError((error) {
      completer.complete(error.toString());
    });

    return completer.future;
  }

  Future<String?> _anonymousSignIn() {
    final completer = Completer<String?>();

    authNotifier.anonymousSignIn().then((userAuthResult) {
      completer.complete(userAuthResult.error);
    }).catchError((error) {
      completer.complete(error.toString());
    });

    return completer.future;
  }

  Future<String?> _googleSignIn() {
    final completer = Completer<String?>();

    authNotifier.googleSignIn().then((userAuthResult) {
      completer.complete(userAuthResult.error);
    }).catchError((error) {
      completer.complete(error.toString());
    });

    return completer.future;
  }

  Future<String?> _appleSignIn() {
    final completer = Completer<String?>();

    authNotifier.appleSignIn().then((userAuthResult) {
      completer.complete(userAuthResult.error);
    }).catchError((error) {
      completer.complete(error.toString());
    });

    return completer.future;
  }

  Future<String?> _signupConfirm(String error, LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: appTitle,
      //logo: const AssetImage('assets/splash.png'),
      logoTag: 'logo.tag',
      titleTag: 'title.tag',
      navigateBackAfterRecovery: true,
      messages: LoginMessages(
        recoverPasswordIntro:
            'Please enter the email address for the account you would like to change the password for.',
        recoverPasswordDescription: 'A reset password link will be sent to this email address.',
      ),
      //onConfirmRecover: _recoveryConfirm,
      onConfirmSignup: _signupConfirm,
      loginAfterSignUp: false,
      loginProviders: [
        if (googleLogin && Platform.isAndroid)
          LoginProvider(
            icon: FontAwesomeIcons.google,
            label: 'Google',
            callback: _googleSignIn,
          ),
        if (iosLogin && Platform.isIOS)
          LoginProvider(
            icon: FontAwesomeIcons.apple,
            label: 'Apple',
            callback: _appleSignIn,
          ),
        if (anonymousLogin)
          LoginProvider(
            icon: FontAwesomeIcons.userSecret,
            label: 'Private',
            callback: _anonymousSignIn,
          ),
      ],
      // termsOfService: [
      //   TermOfService(id: 'newsletter', mandatory: false, text: 'Newsletter subscription'),
      //   TermOfService(
      //       id: 'general-term',
      //       mandatory: true,
      //       text: 'Term of services',
      //       linkUrl: 'https://github.com/NearHuscarl/flutter_login'),
      // ],
      additionalSignupFields: [
        // const UserFormField(keyName: 'Username', icon: Icon(FontAwesomeIcons.userLarge)),
        const UserFormField(keyName: 'Name'),
        const UserFormField(keyName: 'Surname'),
        UserFormField(
          keyName: 'phone_number',
          displayName: 'Phone Number',
          userType: LoginUserType.phone,
          fieldValidator: (value) {
            var phoneRegExp = RegExp('^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\$');
            if (value != null && value.length < 7 && !phoneRegExp.hasMatch(value)) {
              return "This isn't a valid phone number";
            }
            return null;
          },
        ),
      ],
      initialAuthMode: AuthMode.login,
      // scrollable: true,
      // hideProvidersTitle: false,
      // loginAfterSignUp: false,
      // hideForgotPasswordButton: true,
      // hideSignUpButton: true,
      // disableCustomPageTransformer: true,
      // messages: LoginMessages(
      //   userHint: 'User',
      //   passwordHint: 'Pass',
      //   confirmPasswordHint: 'Confirm',
      //   loginButton: 'LOG IN',
      //   signupButton: 'REGISTER',
      //   forgotPasswordButton: 'Forgot huh?',
      //   recoverPasswordButton: 'HELP ME',
      //   goBackButton: 'GO BACK',
      //   confirmPasswordError: 'Not match!',
      //   recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
      //   recoverPasswordDescription: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
      //   recoverPasswordSuccess: 'Password rescued successfully',
      //   flushbarTitleError: 'Oh no!',
      //   flushbarTitleSuccess: 'Succes!',
      //   providersTitle: 'login with'
      // ),
      // theme: LoginTheme(
      //   primaryColor: Colors.teal,
      //   accentColor: Colors.yellow,
      //   errorColor: Colors.deepOrange,
      //   pageColorLight: Colors.indigo.shade300,
      //   pageColorDark: Colors.indigo.shade500,
      //   logoWidth: 0.80,
      //   titleStyle: TextStyle(
      //     color: Colors.greenAccent,
      //     fontFamily: 'Quicksand',
      //     letterSpacing: 4,
      //   ),
      //   // beforeHeroFontSize: 50,
      //   // afterHeroFontSize: 20,
      //   bodyStyle: TextStyle(
      //     fontStyle: FontStyle.italic,
      //     decoration: TextDecoration.underline,
      //   ),
      //   textFieldStyle: TextStyle(
      //     color: Colors.orange,
      //     shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
      //   ),
      //   buttonStyle: TextStyle(
      //     fontWeight: FontWeight.w800,
      //     color: Colors.yellow,
      //   ),
      //   cardTheme: CardTheme(
      //     color: Colors.yellow.shade100,
      //     elevation: 5,
      //     margin: EdgeInsets.only(top: 15),
      //     shape: ContinuousRectangleBorder(
      //         borderRadius: BorderRadius.circular(100.0)),
      //   ),
      //   inputTheme: InputDecorationTheme(
      //     filled: true,
      //     fillColor: Colors.purple.withOpacity(.1),
      //     contentPadding: EdgeInsets.zero,
      //     errorStyle: TextStyle(
      //       backgroundColor: Colors.orange,
      //       color: Colors.white,
      //     ),
      //     labelStyle: TextStyle(fontSize: 12),
      //     enabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.blue.shade700, width: 4),
      //       borderRadius: inputBorder,
      //     ),
      //     focusedBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.blue.shade400, width: 5),
      //       borderRadius: inputBorder,
      //     ),
      //     errorBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.red.shade700, width: 7),
      //       borderRadius: inputBorder,
      //     ),
      //     focusedErrorBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.red.shade400, width: 8),
      //       borderRadius: inputBorder,
      //     ),
      //     disabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.grey, width: 5),
      //       borderRadius: inputBorder,
      //     ),
      //   ),
      //   buttonTheme: LoginButtonTheme(
      //     splashColor: Colors.purple,
      //     backgroundColor: Colors.pinkAccent,
      //     highlightColor: Colors.lightGreen,
      //     elevation: 9.0,
      //     highlightElevation: 6.0,
      //     shape: BeveledRectangleBorder(
      //       borderRadius: BorderRadius.circular(10),
      //     ),
      //     // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      //     // shape: CircleBorder(side: BorderSide(color: Colors.green)),
      //     // shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(55.0)),
      //   ),
      // ),
      userValidator: (value) {
        if (!value!.contains('@')) {
          return "Not a valid email address";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value!.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: (loginData) {
        debugPrint('Login info');
        debugPrint('Name: ${loginData.name}');
        debugPrint('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSignup: (signupData) {
        debugPrint('Signup info');
        debugPrint('Name: ${signupData.name}');
        debugPrint('Password: ${signupData.password}');

        signupData.additionalSignupData?.forEach((key, value) {
          debugPrint('$key: $value');
        });
        if (signupData.termsOfService.isNotEmpty) {
          debugPrint('Terms of service: ');
          for (var element in signupData.termsOfService) {
            debugPrint(' - ${element.term.id}: ${element.accepted == true ? 'accepted' : 'rejected'}');
          }
        }
        return _signupUser(signupData);
      },
      onSubmitAnimationCompleted: () {
        debugPrint('Login has been successful. Routing to landing page.');
        Navigator.of(context).pushReplacementNamed(landingPageRoute);
      },
      onRecoverPassword: (name) {
        debugPrint('Recover password info');
        debugPrint('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
      showDebugButtons: false,
    );
  }
}
