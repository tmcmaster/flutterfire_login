import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_login/flutter_login.dart';
import 'package:flutterfire_login/flutterfire_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FlutterfireLogin extends StatelessWidget {
  static const routeName = '/auth';

  static const ColorScheme _defaultColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFE09A11),
    onPrimary: Color(0xFFEEEEED),
    secondary: Color(0xFF747474),
    onSecondary: Color(0xFFE09A11),
    error: Color(0xFFFF1818),
    onError: Color(0xFFEEEEED),
    background: Color(0xFFEEEEED),
    onBackground: Color(0xFF747474),
    surface: Color(0xFFAFA594),
    onSurface: Color(0xFFEEEEED),
  );

  final String appTitle;
  final ColorScheme colorScheme;
  final String landingPageRoute;
  final FlutterfireAuthNotifier authNotifier;
  final bool googleLogin;
  final bool iosLogin;
  final bool anonymousLogin;

  const FlutterfireLogin({
    Key? key,
    required this.appTitle,
    this.colorScheme = _defaultColorScheme,
    required this.landingPageRoute,
    required this.authNotifier,
    this.googleLogin = false,
    this.iosLogin = false,
    this.anonymousLogin = false,
  }) : super(key: key);

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  LoginTheme get loginTheme => LoginTheme(
        primaryColor: colorScheme.primary,
        accentColor: colorScheme.secondary,
        errorColor: colorScheme.error,
        pageColorLight: colorScheme.background,
        pageColorDark: colorScheme.background,
        logoWidth: 0.80,
        titleStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontFamily: 'Quicksand',
          letterSpacing: 4,
        ),
        // beforeHeroFontSize: 50,
        // afterHeroFontSize: 20,
        bodyStyle: const TextStyle(
          fontStyle: FontStyle.italic,
          //decoration: TextDecoration.underline,
        ),
        textFieldStyle: TextStyle(
          color: colorScheme.onSecondary,
          //shadows: [Shadow(color: colorScheme.background, blurRadius: 2)],
        ),
        buttonStyle: TextStyle(
          fontWeight: FontWeight.w800,
          color: colorScheme.onPrimary,
        ),
        cardTheme: CardTheme(
          color: colorScheme.surface,
          elevation: 5,
          margin: EdgeInsets.only(top: 15),
          shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
        ),
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.secondary.withOpacity(1),
          contentPadding: EdgeInsets.zero,
          errorStyle: const TextStyle(
            backgroundColor: Colors.orange,
            color: Colors.white,
          ),
          labelStyle: const TextStyle(fontSize: 12),
          // enabledBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.blue.shade700, width: 4),
          //   borderRadius: inputBorder,
          // ),
          // focusedBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.blue.shade400, width: 5),
          //   borderRadius: inputBorder,
          // ),
          // errorBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.red.shade700, width: 7),
          //   borderRadius: inputBorder,
          // ),
          // focusedErrorBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.red.shade400, width: 8),
          //   borderRadius: inputBorder,
          // ),
          // disabledBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.grey, width: 5),
          //   borderRadius: inputBorder,
          // ),
        ),
        // buttonTheme: LoginButtonTheme(
        //   splashColor: Colors.purple,
        //   backgroundColor: colorScheme.primary,
        //   highlightColor: Colors.lightGreen,
        //   elevation: 9.0,
        //   highlightElevation: 6.0,
        //   // shape: BeveledRectangleBorder(
        //   //   borderRadius: BorderRadius.circular(10),
        //   // ),
        //   // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        //   // shape: CircleBorder(side: BorderSide(color: Colors.green)),
        //   // shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(55.0)),
        // ),
      );

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
    final inputBorder = BorderRadius.circular(20.0);
    return FlutterLogin(
      title: appTitle,
      //logo: const AssetImage('assets/images/icon.png'),
      logoTag: 'logo.tag',
      titleTag: 'title.tag',
      navigateBackAfterRecovery: true,
      messages: LoginMessages(
        userHint: 'Email',
        recoverPasswordIntro: 'Password Reset',
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
      hideProvidersTitle: true,
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
      theme: loginTheme,
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
