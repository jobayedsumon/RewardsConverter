import 'package:flutter/material.dart';
import 'Transaction.dart';

class WithdrawalList extends StatefulWidget {
  final List withdrawals;

  const WithdrawalList({Key? key, required this.withdrawals}) : super(key: key);

  @override
  State<WithdrawalList> createState() => _WithdrawalListState();
}

class _WithdrawalListState extends State<WithdrawalList> {
  @override
  Widget build(BuildContext context) {
    return widget.withdrawals.length > 0
        ? SingleChildScrollView(
            child: Column(
              children: widget.withdrawals
                  .map(
                    (transaction) =>
                        Transaction(transaction: transaction, type: 2),
                  )
                  .toList(),
            ),
          )
        : Center(
            child: Text('No Withdrawal Found'),
          );
  }
}
