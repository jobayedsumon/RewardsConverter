import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CustomChip extends StatelessWidget {
  const CustomChip({
    super.key,
    this.package,
  });

  final package;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: const EdgeInsets.all(0.0),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: () {
        InAppPurchase.instance.buyConsumable(
            purchaseParam: PurchaseParam(productDetails: package),
            autoConsume: true);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 5.0,
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Rewards',
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  '${package.price}',
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                  child: Text(
                    '${package.id} Rewards',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
