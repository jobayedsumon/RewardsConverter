import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ButtonTimer extends StatefulWidget {
  @override
  _ButtonTimerState createState() => _ButtonTimerState();
}

class _ButtonTimerState extends State<ButtonTimer> {
  bool _buttonEnabled = true;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadLastClickTime();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _buttonEnabled ? _onButtonClick : null,
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
      ),
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
