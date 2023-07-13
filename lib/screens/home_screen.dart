import 'dart:async';
import 'package:Cookie/components/BannerAd.dart';
import 'package:Cookie/helpers/alerts.dart';
import 'package:Cookie/helpers/constants.dart';
import 'package:Cookie/helpers/dioUtil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/functions.dart';
import '../includes/CookieAppBar.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

const _colDivider = SizedBox(height: 10);
const double _maxWidthConstraint = 400;
const int minutesToWait = 5;

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
    // _loadLastClickTime();

    initializeAd();

    getBalance().then((value) {
      setState(() {
        balance = value;
      });
    });

    _loadRewardedVideoAd();
  }

  void _rewardUser() async {
    try {
      var response = await dio.post('/customer/reward', data: {
        'project_id': PROJECT_ID,
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

  void _loadRewardedVideoAd() {
    UnityAds.load(
      placementId: REWARDED_VIDEO_AD_PLACEMENT_ID,
      onComplete: (placementId) => {
        print('Load Complete $placementId'),
        setState(() {
          _isRewardedAdLoaded = true;
        }),
      },
      onFailed: (placementId, error, message) => {
        print('Load Failed $placementId, $error, $message'),
        setState(() {
          _isRewardedAdLoaded = false;
        }),
      },
    );
  }

  void _showRewardedAd() {
    if (_isRewardedAdLoaded == true) {
      UnityAds.showVideoAd(
        placementId: REWARDED_VIDEO_AD_PLACEMENT_ID,
        onStart: (placementId) => print('Video Ad $placementId started'),
        onClick: (placementId) => print('Video Ad $placementId click'),
        onSkipped: (placementId) => {
          print('Video Ad $placementId skipped'),
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You must watch the full video to get a reward!'),
              duration: Duration(seconds: 1),
            ),
          ),
          setState(() {
            _isRewardedAdLoaded = false;
          }),
          _loadRewardedVideoAd(),
        },
        onComplete: (placementId) => {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stay on this page for your reward!'),
              duration: Duration(seconds: 1),
            ),
          ),
          _rewardUser(),
          setState(() {
            _isRewardedAdLoaded = false;
          }),
          // _onButtonClick(),
          _loadRewardedVideoAd(),
        },
        onFailed: (placementId, error, message) =>
            print('Video Ad $placementId failed: $error $message'),
      );
    } else {
      print("Rewarded Ad not yet loaded!");
    }
  }

  @override
  void dispose() {
    super.dispose();
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
                  onPressed: _isRewardedAdLoaded ? _showRewardedAd : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                  child:
                      // _isRewardedAdLoaded
                      //     ?
                      Text(
                    "TRY YOUR LUCK!",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  //   : Text(
                  // (_remainingTime.inSeconds > 0
                  //     ? 'Please wait ${_remainingTime
                  //     .inMinutes}:${_remainingTime.inSeconds.remainder(
                  //     60)} minutes to try again!'
                  //     :
                  // 'Loading...'),
                  ),
            ],
          ),
        ),
        BannerAd()
      ]),
    );
  }

  void _onButtonClick() async {
    setState(() {
      _buttonEnabled = false;
      _remainingTime = Duration(minutes: minutesToWait);
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
      if (timeDifference < Duration(minutes: minutesToWait)) {
        setState(() {
          _buttonEnabled = false;
          _remainingTime = Duration(minutes: minutesToWait) - timeDifference;
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
