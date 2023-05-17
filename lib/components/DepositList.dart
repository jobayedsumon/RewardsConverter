import 'package:flutter/material.dart';
import 'Transaction.dart';

class DepositList extends StatefulWidget {
  final List deposits;

  const DepositList({Key? key, required this.deposits}) : super(key: key);

  @override
  State<DepositList> createState() => _DepositListState();
}

class _DepositListState extends State<DepositList> {
  @override
  Widget build(BuildContext context) {
    return widget.deposits.length > 0
        ? SingleChildScrollView(
            child: Column(
              children: widget.deposits
                  .map(
                    (transaction) =>
                        Transaction(transaction: transaction, type: 1),
                  )
                  .toList(),
            ),
          )
        : Center(
            child: Text('No Deposit Found'),
          );
  }
}
