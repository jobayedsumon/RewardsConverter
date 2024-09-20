import 'package:rewards_converter/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Map arguments;

  const TransactionDetailsScreen({Key? key, required this.arguments})
      : super(key: key);

  Map get transaction => arguments['transaction'];

  int get type => arguments['type'];

  @override
  Widget build(BuildContext context) {
    print(transaction);
    return Scaffold(
      appBar: AppBar(
        title: Text(type == 1 ? 'Deposit Details' : 'Withdrawal Details'),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${type == 1 ? 'Deposit' : 'Withdrawal'} Amount',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '\$${(transaction['rewards'] / 100).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${type == 1 ? 'Deposit' : 'Withdrawal'} ID',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey.shade700,
                                    )),
                                Text(
                                  '${transaction['id']}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  TransactionStatus[transaction['status']]
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: transaction['status'] == 4
                                          ? Colors.green
                                          : transaction['status'] == 3
                                              ? Colors.red
                                              : Colors.orange),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date & Time',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey.shade700,
                                    )),
                                Text(
                                  DateFormat('dd/MM/yyyy hh:mm a')
                                      .format(DateTime.parse(
                                    transaction['created_at'],
                                  )),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
            _TimelineDelivery(type: type, status: transaction['status']),
            type == 2 && transaction['status'] < 3
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'You\'ll receive the Payment before ${DateFormat('dd MMMM yyyy').format(DateTime.parse(transaction['created_at']).add(Duration(days: 6)))}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class _TimelineDelivery extends StatelessWidget {
  final int type;
  final int status;

  _TimelineDelivery({
    Key? key,
    required this.type,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool disabled = status < 3;

    return Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            isFirst: true,
            indicatorStyle: IndicatorStyle(
              width: 25,
              color: Colors.green,
              padding: EdgeInsets.all(6),
              iconStyle: IconStyle(
                color: Colors.white,
                iconData: Icons.check,
              ),
            ),
            endChild: _RightChild(
              title: 'Request Placed',
            ),
            afterLineStyle: const LineStyle(
              color: Colors.green,
            ),
          ),
          TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            indicatorStyle: IndicatorStyle(
              width: 25,
              color: Colors.orange,
              padding: EdgeInsets.all(6),
              iconStyle: IconStyle(
                color: Colors.white,
                iconData: Icons.pending,
              ),
            ),
            endChild: _RightChild(
              title: 'Request Under Processing',
            ),
            beforeLineStyle: const LineStyle(
              color: Colors.green,
            ),
            afterLineStyle: const LineStyle(
              color: Colors.orange,
            ),
          ),
          TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            indicatorStyle: IndicatorStyle(
              width: 25,
              color: status < 2 ? Colors.grey : Colors.yellow,
              padding: EdgeInsets.all(6),
              iconStyle: IconStyle(
                color: Colors.white,
                iconData: Icons.pending,
              ),
            ),
            endChild: _RightChild(
              disabled: status < 2,
              title: 'Request Undergoing Checks',
            ),
            beforeLineStyle: const LineStyle(
              color: Colors.orange,
            ),
            afterLineStyle: LineStyle(
              color: disabled ? Colors.grey : Colors.yellow,
            ),
          ),
          TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            isLast: true,
            indicatorStyle: IndicatorStyle(
              width: 25,
              color: disabled
                  ? Colors.grey
                  : status == 3
                      ? Colors.red
                      : Colors.green,
              padding: EdgeInsets.all(6),
              iconStyle: IconStyle(
                color: Colors.white,
                iconData: status == 3 ? Icons.close : Icons.check,
              ),
            ),
            endChild: _RightChild(
              title:
                  '${TransactionType[type]} ${status == 3 ? 'Cancelled' : 'Successful'}',
              disabled: disabled,
            ),
            beforeLineStyle: LineStyle(
              color: disabled ? Colors.grey : Colors.yellow,
            ),
          ),
        ],
      ),
    );
  }
}

class _RightChild extends StatelessWidget {
  const _RightChild({
    Key key = const Key('RightChild'),
    this.title = '',
    this.disabled = false,
  }) : super(key: key);

  final String title;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: disabled ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
