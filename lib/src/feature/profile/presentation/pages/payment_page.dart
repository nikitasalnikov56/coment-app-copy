import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/feature/profile/presentation/widgets/select_payment_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/profile/bloc/payment_cubit.dart';

extension BrandToCardNetwork on String {
  // CardNetwork toCardNetwork() {
  //   switch (this) {
  //     case 'visa':
  //       return CardNetwork.visa;
  //     case 'mastercard':
  //       return CardNetwork.mastercard;
  //     // Другие бренды → CardNetwork.other (т.к. нет unionpay/humo/uzcard в пакете)
  //     default:
  //       return CardNetwork.other;
  //   }
  // }

  Color getCardColor() {
    switch (this) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color.fromARGB(255, 173, 17, 22);
      case 'humo':
        return const Color(0xFF009EE2);
      case 'uzcard':
        return const Color.fromARGB(255, 44, 3, 107);
      case 'unionpay':
        return const Color(0xFFA10000);
      case 'kzt':
        return const Color(0xFFD1B700);
      default:
        return Colors.grey;
    }
  }

  String getCardTypeName() {
    switch (this) {
      case 'humo':
        return 'HUMO';
      case 'uzcard':
        return 'UZCARD';
      case 'unionpay':
        return 'UNIONPAY';
      case 'kzt':
        return 'KAZAKHSTAN';
      case 'visa':
        return 'VISA';
      case 'mastercard':
        return 'MASTERCARD';
      default:
        return toUpperCase();
    }
  }
}

@RoutePage()
class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PaymentCubit(context.repository.paymentRemoteDS)..loadCards(),
      child: const _PaymentView(),
    );
  }
}

class _PaymentView extends StatefulWidget {
  const _PaymentView();

  @override
  State<_PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<_PaymentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: const Color(0xFFD3E7FE),
        svgColor: const Color(0xFF6571D5),
        title: context.localized.payment,
        textStyle: AppTextStyles.fs18w500,
        actions: const [
          SizedBox(
            width: 50,
          ),
        ],
      ),
      body: const SelectPaymentMethod(),
    );
  }
}
