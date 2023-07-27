import 'dart:convert';

import 'package:Cookie/components/WithdrawalModal.dart';
import 'package:Cookie/includes/CookieAppBar.dart';
import 'package:Cookie/screens/profile/profile_info_screen.dart';
import 'package:Cookie/screens/store_screen.dart';
import 'package:flutter/material.dart';
import '../../components/BannerAd.dart';
import '../../components/CustomerAvatar.dart';
import '../../helpers/constants.dart';
import '../../helpers/dioUtil.dart';
import '../../helpers/functions.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map profileData = {};
  var dio = DioUtil.getInstance();
  bool isLoading = true;
  double balance = 0.0;
  String usdToBDT = '0.00';

  void getProfileData() async {
    try {
      var response = await dio.post('/auth/me');
      var data = response.data;
      if (data['success']) {
        var user = data['user'];
        user['name'] = user['name'] != 'N/A' ? user['name'] : '';
        setState(() {
          profileData = user;
          isLoading = false;
          balance = user['balance'].toDouble();
        });
        await setBalance(user['balance'].toDouble());
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getBalance().then((value) {
      setState(() {
        balance = value;
      });
    });
    getSettings().then((value) {
      var settings = jsonDecode(value);
      var result = settings.where((item) => item['key'] == 'usd_to_bdt')?.first;
      if (result != null) {
        setState(() {
          usdToBDT = result['value'].toString();
        });
      }
    });
    getProfileData();
    initializeAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CookieAppBar(balance: balance),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              'Hello, ${profileData['name']}!',
                              style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        MaterialButton(
                          shape: CircleBorder(),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileInfoScreen(
                                      profileData: profileData,
                                      getProfileData: getProfileData),
                                ));
                          },
                          child: CustomerAvatar(
                            image: profileData['image'],
                            name: '${profileData['name']} ',
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 10.0),
              Card(
                elevation: 5.0,
                child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Balance',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '100 Cookies ~ 1 USD',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  '1 USD ~ ${usdToBDT} BDT',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey.shade800,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Text(
                              '\$${profileData['balance'] != null ? (profileData['balance'] / 100).toStringAsFixed(2) : '0.00'}',
                              style: TextStyle(
                                  fontSize: 30.0,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'USD',
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //create deposit and withdraw button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return StoreScreen(fromProfile: true);
                                    },
                                  ));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('DEPOSIT'),
                                    SizedBox(width: 10.0),
                                    Icon(Icons.call_received),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) => Padding(
                                            padding: MediaQuery.of(context)
                                                .viewInsets,
                                            child: WithdrawalModal(
                                              profileData: profileData,
                                            ),
                                          ));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('WITHDRAW'),
                                    SizedBox(width: 10.0),
                                    Icon(Icons.call_made),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ),
              SizedBox(height: 10.0),
              Divider(
                color: Colors.grey.shade400,
                thickness: 1.0,
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async => {
                        Navigator.pushNamed(context, '/about-us'),
                      },
                      child: Text('ABOUT US'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async => {
                        Navigator.pushNamed(context, '/privacy-policy'),
                      },
                      child: Text('PRIVACY POLICY'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async => {
                        Navigator.pushNamed(context, '/terms-and-conditions'),
                      },
                      child: Text('TERMS & CONDITIONS'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async => {
                        Navigator.pushNamed(context, '/contact-us'),
                      },
                      child: Text('CONTACT US'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async => {
                        logout().then((value) => {
                              if (value)
                                {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/login', (route) => false),
                                }
                              else
                                {print('logout error')}
                            }),
                      },
                      child: Text('LOGOUT'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                children: [BannerAd()],
              )
            ],
          ),
        ),
      ),
    );
  }
}
