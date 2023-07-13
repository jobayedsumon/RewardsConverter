import 'package:Cookie/helpers/alerts.dart';
import 'package:Cookie/helpers/functions.dart';
import 'package:Cookie/screens/initial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/dioUtil.dart';

class WithdrawalModal extends StatefulWidget {
  final profileData;

  const WithdrawalModal({
    super.key,
    this.profileData,
  });

  @override
  State<WithdrawalModal> createState() => _WithdrawalModalState();
}

class _WithdrawalModalState extends State<WithdrawalModal> {
  bool isChecked = false;
  var dio = DioUtil.getInstance();

  TextEditingController cookiesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String payoutMethod = '';

    switch (widget.profileData['payout_method']) {
      case 2:
        payoutMethod = 'Tether (USDT) - Binance.com';
        break;
      case 3:
        payoutMethod = 'Bkash';
        break;
      case 4:
        payoutMethod = 'Nagad';
        break;
      default:
        payoutMethod = '';
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Preview your Withdraw Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text('Payout Method: ${payoutMethod}',
                style: TextStyle(fontWeight: FontWeight.w500)),
            Text(
                '${widget.profileData['payout_method'] == 2 ? 'Binance Pay ID' : widget.profileData['payout_method'] == 3 ? 'Bkash Number' : widget.profileData['payout_method'] == 4 ? 'Nagad Number' : ''}: ${widget.profileData['payout_id'] ?? ''}',
                style: TextStyle(fontWeight: FontWeight.w500)),
            Text('Beneficiary: ${widget.profileData['beneficiary_name'] ?? ''}',
                style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 20.0),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
              ],
              controller: cookiesController,
              decoration: InputDecoration(
                labelText: 'Enter Cookies',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                icon: Icon(Icons.wallet),
                isDense: true,
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      'I agree to the Terms & Conditions and Privacy Policy.',
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: MaterialButton(
                onPressed: () {
                  withdraw();
                },
                child: Text('Withdraw'),
                color: Colors.red,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Note: You will Receive your payment in 7-14 days after the withdrawal request made so please be Patience.'
              ' For any query feel free to contact us or Read FAQs.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }

  void withdraw() {
    if (cookiesController.text.isEmpty) {
      showError(context, 'Please enter the number of cookies');
    } else if (!isChecked) {
      showError(context, 'Please agree to the terms and conditions');
    } else {
      double cookies = double.parse(cookiesController.text);
      if (cookies >= 1000) {
        if (cookies <= widget.profileData['balance']) {
          if (widget.profileData['payout_method'] != null &&
              widget.profileData['payout_id'] != null &&
              widget.profileData['beneficiary_name'] != null) {
            withdrawRequest(
                cookies,
                widget.profileData['payout_method'],
                widget.profileData['payout_id'],
                widget.profileData['beneficiary_name']);
          } else {
            showError(context, 'Please fully complete your payout info first');
          }
        } else {
          showError(context, 'You do not have enough cookies');
        }
      } else {
        showError(context, 'Minimum withdrawal is 1000 cookies');
      }
    }
  }

  void withdrawRequest(cookies, payoutMethod, payoutId, beneficiaryName) {
    try {
      dio.post('/transaction/withdraw', data: {
        'cookies': cookies,
        'payout_method': payoutMethod,
        'payout_id': payoutId,
        'beneficiary_name': beneficiaryName,
      }).then((response) {
        var data = response.data;
        if (data['success']) {
          setBalance(data['balance'].toDouble());
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => InitialScreen(initialIndex: 3)),
              (route) => false);
          showSuccess(context, data['message']);
        } else {
          showError(context, data['message']);
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
