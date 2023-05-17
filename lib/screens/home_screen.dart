import 'dart:async';
import 'package:Cookie/helpers/alerts.dart';
import 'package:Cookie/helpers/constants.dart';
import 'package:Cookie/helpers/dioUtil.dart';
import 'package:flutter/material.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/functions.dart';
import '../includes/CookieAppBar.dart';

const _colDivider = SizedBox(height: 10);
const double _maxWidthConstraint = 400;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRewardedAdLoaded = false;
  var dio = DioUtil.getInstance();
  double balance = 0.0;

  bool _buttonEnabled = true;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadLastClickTime();

    FacebookAudienceNetwork.init();

    getBalance().then((value) {
      setState(() {
        balance = value;
      });
    });

    _loadRewardedVideoAd();
  }

  void _loadRewardedVideoAd() {
    FacebookRewardedVideoAd.loadRewardedVideoAd(
      placementId: REWARDED_VIDEO_AD_PLACEMENT_ID,
      listener: (result, value) async {
        print("Rewarded Ad: $result --> $value");
        if (result == RewardedVideoAdResult.LOADED) {
          setState(() {
            _isRewardedAdLoaded = true;
          });
        }
        if (result == RewardedVideoAdResult.VIDEO_COMPLETE) {
          /// Reward the user for watching an Ad.
          try {
            var response = await dio.post('/customer/reward', data: {
              'placement_id': REWARDED_VIDEO_AD_PLACEMENT_ID,
            });
            var data = response.data;
            if (data['success']) {
              showSuccess(context, data['message']);
              setState(() {
                balance = data['balance'].toDouble();
              });
              await setBalance(data['balance'].toDouble());
            } else {
              showError(context, data['message']);
            }
          } catch (e) {
            print(e);
            showError(context, 'Something went wrong');
          }
        }

        /// Once a Rewarded Ad has been closed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == RewardedVideoAdResult.VIDEO_CLOSED &&
            (value == true || value["invalidated"] == true)) {
          setState(() {
            _isRewardedAdLoaded = false;
          });

          _loadRewardedVideoAd();

          _onButtonClick();
        }
      },
    );
  }

  _showRewardedAd() {
    if (_isRewardedAdLoaded == true)
      FacebookRewardedVideoAd.showRewardedVideoAd();
    else
      print("Rewarded Ad not yet loaded!");
  }

  @override
  void dispose() {
    super.dispose();
    FacebookRewardedVideoAd.destroyRewardedVideoAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CookieAppBar(balance: balance),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: _maxWidthConstraint,
            child: Card(
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text('Convert Rewards in following Steps:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0))),
                    _colDivider,
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text('1. Go to Store Section and Buy Cookies')),
                    _colDivider,
                    Text(
                        '2. For Redeem Cookies, Go to Profile section and Click on Withdraw.'),
                    _colDivider,
                    Text(
                        '3. In the Withdraw Page, enter cookies and click on Withdraw button.'),
                    _colDivider,
                    _colDivider,
                    Text(
                        'Note: You will receive 60% of the amount you have converted. '
                        'It will take 4 - 6 days to credit the amount into your account.'),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _buttonEnabled ? _showRewardedAd : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: _buttonEnabled
                    ? Text(
                        "TRY YOUR LUCK!",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text((_remainingTime.inSeconds > 0
                        ? 'Please wait ${_remainingTime.inMinutes}:${_remainingTime.inSeconds.remainder(60)} minutes to try again!'
                        : 'Loading...')),
              )
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: FacebookNativeAd(
              placementId: NATIVE_BANNER_AD_PLACEMENT_ID,
              adType: NativeAdType.NATIVE_BANNER_AD,
              bannerAdSize: NativeBannerAdSize.HEIGHT_100,
              width: double.infinity,
              backgroundColor: Colors.red[900],
              titleColor: Colors.white,
              descriptionColor: Colors.white,
              buttonColor: Colors.black,
              buttonTitleColor: Colors.white,
              buttonBorderColor: Colors.black,
              height: 100,
              listener: (result, value) {
                print("Native Banner Ad: $result --> $value");
              },
            ),
          ),
        )
      ]),
    );
  }

  void _onButtonClick() async {
    setState(() {
      _buttonEnabled = false;
      _remainingTime = Duration(minutes: 5);
    });
    await _saveLastClickTime(DateTime.now());
    final timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime -= Duration(seconds: 1);
        } else {
          _buttonEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _saveLastClickTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_click_time', time.toIso8601String());
  }

  Future<void> _loadLastClickTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClickTimeString = prefs.getString('last_click_time');
    if (lastClickTimeString != null) {
      final lastClickTime = DateTime.parse(lastClickTimeString);
      final timeDifference = DateTime.now().difference(lastClickTime);
      if (timeDifference < Duration(minutes: 5)) {
        setState(() {
          _buttonEnabled = false;
          _remainingTime = Duration(minutes: 5) - timeDifference;
        });
        _startCountdownTimer();
      }
    }
  }

  void _startCountdownTimer() {
    final timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime -= Duration(seconds: 1);
        } else {
          _buttonEnabled = true;
          timer.cancel();
        }
      });
    });
  }
}
