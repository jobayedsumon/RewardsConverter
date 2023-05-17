import 'package:Cookie/helpers/functions.dart';
import 'package:Cookie/includes/CookieAppBar.dart';
import 'package:flutter/material.dart';
import '../components/MultiSelect.dart';
import '../components/Transaction.dart';
import '../helpers/dioUtil.dart';

final items = <MultiSelectDialogItem<Map>>[
  MultiSelectDialogItem(
    name: 'Type',
    type: 'sep',
    value: {
      'type': 'type',
      'id': 0,
    },
  ),
  MultiSelectDialogItem(
    name: 'Deposit',
    type: 'data',
    value: {
      'type': 'type',
      'id': 1,
    },
  ),
  MultiSelectDialogItem(
    name: 'Withdrawal',
    type: 'data',
    value: {
      'type': 'type',
      'id': 2,
    },
  ),
  MultiSelectDialogItem(
    name: 'Status',
    type: 'sep',
    value: {
      'type': 'status',
      'id': 0,
    },
  ),
  MultiSelectDialogItem(
    name: 'Completed',
    type: 'data',
    value: {
      'type': 'status',
      'id': 4,
    },
  ),
  MultiSelectDialogItem(
    name: 'On Hold',
    type: 'data',
    value: {
      'type': 'status',
      'id': 2,
    },
  ),
  MultiSelectDialogItem(
    name: 'Processing',
    type: 'data',
    value: {
      'type': 'status',
      'id': 1,
    },
  ),
  MultiSelectDialogItem(
    name: 'Cancelled',
    type: 'data',
    value: {
      'type': 'status',
      'id': 3,
    },
  ),
];

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  var dio = DioUtil.getInstance();
  bool isLoading = true;

  List transactions = [];
  List originalTransactions = [];
  double totalWithdrawal = 0.0;
  List filters = [];
  double balance = 0.0;

  @override
  void initState() {
    super.initState();
    getBalance().then((value) {
      setState(() {
        balance = value;
      });
    });
    getTransactions();
  }

  void _showMultiSelect(BuildContext context) async {
    final selectedValues = await showDialog<Set>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: items,
          initialSelectedValues: filters.toSet(),
        );
      },
    );

    if (selectedValues != null) {
      setState(() {
        filters = selectedValues.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CookieAppBar(balance: balance),
      body: RefreshIndicator(
        onRefresh: () async {
          await getTransactions();
          return;
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '\$${(totalWithdrawal / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Total Withdrawal'),
                    ],
                  ),
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 1.0,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        _showMultiSelect(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            filters.length > 0
                                ? 'Filters Applied'
                                : 'Filter by Types and Status',
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 5.0,
                        ),
                        onPressed: () {
                          filterTransactions();
                        },
                        child: Text('Filter')),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 1.0,
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : transactions.length > 0
                      ? Column(
                          children: transactions
                              .map((transaction) => Transaction(
                                  transaction: transaction,
                                  type: transaction['type']))
                              .toList(),
                        )
                      : Center(
                          child: Text('No Transaction Found'),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Future getTransactions() async {
    try {
      var response = await dio.post('/transaction');
      var data = response.data;
      if (data['success']) {
        setState(() {
          transactions = data['transactions'];
          originalTransactions = data['transactions'];
          totalWithdrawal = data['total_withdrawal'].toDouble();
          filters = [];
          isLoading = false;
          balance = data['balance'].toDouble();
        });
        await setBalance(data['balance'].toDouble());
      }
    } catch (e) {
      print(e);
    }
  }

  void filterTransactions() {
    var type = filters
        .where((filter) => filter['type'] == 'type')
        .map((e) => e['id'])
        .toList();

    var status = filters
        .where((filter) => filter['type'] == 'status')
        .map((e) => e['id'])
        .toList();

    var filteredTransactions = originalTransactions.where((transaction) {
      if (type.length > 0 && status.length > 0) {
        return type.contains(transaction['type']) &&
            status.contains(transaction['status']);
      } else if (type.length > 0) {
        return type.contains(transaction['type']);
      } else if (status.length > 0) {
        return status.contains(transaction['status']);
      } else {
        return true;
      }
    }).toList();

    setState(() {
      transactions = filteredTransactions;
    });
  }
}
