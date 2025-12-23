import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:flutter/material.dart';


@RoutePage()
class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.localized.payment,
      ),
      body: const Center(
        child: Text('Здесь можно добавить работу с настройкой карты и оплаты.'),
      ),
    );
  }
}