import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helpers/constants.dart';

class Transaction extends StatelessWidget {
  final Map transaction;
  final int type;

  const Transaction({
    super.key,
    required this.transaction,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    int status = transaction['status'];
    double amount = transaction['cookies'] / 100;

    return MaterialButton(
      splashColor: Colors.transparent,
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/transaction-details',
          arguments: {
            'transaction': transaction,
            'type': type,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          elevation: 5.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              horizontalTitleGap: 0.0,
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              title: Row(
                children: [
                  Text('Amount: '),
                  type == 1
                      ? Text(
                          '+\$${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        )
                      : Text(
                          '-\$${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ref ID: ${transaction['id']}'),
                  Text(
                      'Date & Time: ${DateFormat('dd/MM/yyyy hh:mm a').format(
                        DateTime.parse(
                          transaction['created_at'],
                        ),
                      )}',
                      style: TextStyle(
                        fontSize: 12.0,
                      )),
                  transaction['status'] < 3
                      ? Text(
                          'You\'ll receive the Payment before ${DateFormat('dd MMMM yyyy').format(DateTime.parse(transaction['created_at']).add(Duration(days: 6)))}',
                          style: TextStyle(
                            fontSize: 10.0,
                          ),
                        )
                      : Container()
                ],
              ),
              trailing: Text(
                TransactionStatus[status].toString(),
                style: TextStyle(
                    color: status == 4
                        ? Colors.green
                        : status == 3
                            ? Colors.red
                            : Colors.orange),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
