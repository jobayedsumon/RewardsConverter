import 'package:Cookie/helpers/alerts.dart';
import 'package:Cookie/helpers/constants.dart';
import 'package:Cookie/helpers/functions.dart';
import 'package:Cookie/screens/initial_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'profile',
    'email',
  ],
);

Future<void> _handleSignOut() => _googleSignIn.disconnect();

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _handleSignIn() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _handleSignOut();
      }
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (account != null) {
        login(account);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _googleSignIn.disconnect();
    super.dispose();
  }

  var dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.5,
              child: Image(
                image: AssetImage('assets/images/CookieLogoWhite.jpg'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good to see you :)',
                      style: TextStyle(
                          fontSize: 35.0, fontWeight: FontWeight.bold)),
                  Text('Connect your google account to get started with Cookie',
                      style: TextStyle(fontSize: 16.0)),
                  SizedBox(height: 30.0),
                  Center(
                    child: SignInButton(
                      buttonType: ButtonType.google,
                      buttonSize: ButtonSize.large,
                      onPressed: _handleSignIn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void login(account) async {
    try {
      var response = await dio.post(
        '/auth/login',
        data: {
          'uuid': account.id,
          'email': account.email,
          'name': account.displayName,
          'image': account.photoUrl,
        },
      );

      var data = response.data;

      if (data['success']) {
        print(data);

        var token = data['access_token'];
        var balance = data['balance'].toDouble();
        var settings = data['settings'];

        dio.options.headers['Authorization'] = 'Bearer $token';

        await setToken(token);
        await setBalance(balance);
        await setSettings(settings);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => InitialScreen()),
                  (route) => false);
        }
      } else {
        showError(context, data['message']);
      }
    } on DioError catch (e) {
      print(e);
    }
  }
}
