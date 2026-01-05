import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/feature/profile/presentation/widgets/add_payment_cards.dart';
import 'package:coment_app/src/feature/profile/presentation/widgets/make_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_card/payment_card.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/profile/bloc/payment_cubit.dart';

extension BrandToCardNetwork on String {
  CardNetwork toCardNetwork() {
    switch (this) {
      case 'visa':
        return CardNetwork.visa;
      case 'mastercard':
        return CardNetwork.mastercard;
      // Другие бренды → CardNetwork.other (т.к. нет unionpay/humo/uzcard в пакете)
      default:
        return CardNetwork.other;
    }
  }

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
  int _currentIndex = 0;

  void onTap(int value) {
    setState(() {
      _currentIndex = value;
    });
  }

  List<Widget> screens = [
    const AddPaymentCards(),
    const MakePayment(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.localized.payment),
      bottomNavigationBar: SizedBox(

        height: MediaQuery.of(context).size.height / 10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: _currentIndex == 0 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            ColoredBox(
              color: AppColors.mainColor,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: 3,
              ),
            ),
            Expanded(
              // height: MediaQuery.of(context).size.height / 10,
              child: BottomNavigationBar(
                backgroundColor: AppColors.backgroundColor,
                selectedLabelStyle: AppTextStyles.fs12w600,
                unselectedLabelStyle: AppTextStyles.fs12w600,
                selectedItemColor: AppColors.mainColor,
                unselectedItemColor: AppColors.greyText,
                iconSize: 30,
                currentIndex: _currentIndex,
                onTap: (value) => onTap(value),
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.add_card),
                    label: context.localized.add_new_card,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.payments_outlined),
                    label: context.localized.payment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: screens[_currentIndex],
    );
  }
}
