import 'package:Cookie/screens/add_example_screen.dart';
import 'package:Cookie/screens/initial_screen.dart';
import 'package:Cookie/screens/login_screen.dart';
import 'package:Cookie/screens/profile/profile_info_screen.dart';
import 'package:Cookie/screens/transaction/transaction_details_screen.dart';
import 'package:Cookie/screens/webview/about_us_screen.dart';
import 'package:Cookie/screens/webview/contact_us_screen.dart';
import 'package:Cookie/screens/webview/privacy_policy_screen.dart';
import 'package:Cookie/screens/webview/terms_and_conditions_screen.dart';
import 'package:flutter/material.dart';
import 'helpers/functions.dart';

void main() async {
  runApp(const CookieApp());
}

class CookieApp extends StatefulWidget {
  const CookieApp({super.key});

  @override
  State<CookieApp> createState() => _CookieAppState();
}

class _CookieAppState extends State<CookieApp> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cookie - reward converter',
      themeMode: ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      routes: {
        '/ad-example': (context) => AdExampleApp(),
        '/profile-info': (context) => ProfileInfoScreen(),
        '/login': (context) => LoginScreen(),
        '/about-us': (context) => AboutUsScreen(),
        '/privacy-policy': (context) => PrivacyPolicyScreen(),
        '/terms-and-conditions': (context) => TermsAndConditionsScreen(),
        '/contact-us': (context) => ContactUsScreen(),
        '/transaction-details': (context) => TransactionDetailsScreen(
              arguments: ModalRoute.of(context)!.settings.arguments as Map,
            ),
      },
      home: FutureBuilder(
        future: isUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != false) {
              return InitialScreen();
            } else {
              return LoginScreen();
            }
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
