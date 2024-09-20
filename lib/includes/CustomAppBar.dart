import 'package:rewards_converter/helpers/functions.dart';
import 'package:flutter/material.dart';

class CookieAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double balance;
  final bool showBalance;

  const CookieAppBar({Key? key, this.balance = 0.0, this.showBalance = true})
      : super(key: key);

  @override
  State<CookieAppBar> createState() => _CookieAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CookieAppBarState extends State<CookieAppBar> {
  @override
  Widget build(BuildContext context) {
    return widget.showBalance
        ? AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 50.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.wallet, color: Colors.red, size: 30.0),
                        Text(
                          widget.balance.toStringAsFixed(2),
                          style: TextStyle(fontSize: 20.0, color: Colors.red),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            backgroundColor: Colors.red[900],
            actions: [],
          )
        : AppBar(
            backgroundColor: Colors.red[900],
            title: Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: Center(
                child: Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 50.0),
              ),
            ),
          );
  }
}
