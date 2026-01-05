import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:flutter/material.dart';

class MakePayment extends StatefulWidget {
  const MakePayment({super.key});

  @override
  State<MakePayment> createState() => _MakePaymentState();
}

class _MakePaymentState extends State<MakePayment> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 3,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      children: [
        Card(
          child: Center(
            child: Image.asset(AssetsConstants.payme),
          ),
        ),
        Card(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(AssetsConstants.click),
              ),
            ),
          ),
        ),
        Card(
          child: Center(
            child: Image.asset(AssetsConstants.uzumBank),
          ),
        ),
      ],
    );
  }
}
