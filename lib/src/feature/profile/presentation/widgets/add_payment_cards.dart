import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/profile/bloc/payment_cubit.dart';
import 'package:coment_app/src/feature/profile/models/request/save_payment_card_request.dart';
import 'package:coment_app/src/feature/profile/models/response/save_payment_card_response.dart'
    as my;
import 'package:coment_app/src/feature/profile/presentation/pages/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AddPaymentCards extends StatefulWidget {
  const AddPaymentCards({super.key});

  @override
  State<AddPaymentCards> createState() => _AddPaymentCardsState();
}

class _AddPaymentCardsState extends State<AddPaymentCards> {
  final _numberCtrl = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _cardHolderNameCtrl = TextEditingController();
  String? _detectedBrand;

  // Добавь FocusNode'ы
  final _monthFocus = FocusNode();
  final _yearFocus = FocusNode();
  final _nameFocus = FocusNode();

  @override
  void dispose() {
    _numberCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    _cardHolderNameCtrl.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _onNumberChanged(String value) {
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    String? brand = _detectBrand(clean);
    if (brand != _detectedBrand) {
      setState(() => _detectedBrand = brand);
    }
    final formatted = _formatCardNumber(clean);
    if (_numberCtrl.text != formatted) {
      _numberCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  String _formatCardNumber(String clean) {
    if (clean.isEmpty) return '';
    final cleanTruncated = clean.length > 16 ? clean.substring(0, 16) : clean;
    final parts = <String>[];
    for (int i = 0; i < cleanTruncated.length; i += 4) {
      parts.add(
        cleanTruncated.substring(
          i,
          i + 4 > cleanTruncated.length ? cleanTruncated.length : i + 4,
        ),
      );
    }
    return parts.join(' ');
  }

  String? _detectBrand(String clean) {
    if (clean.startsWith('4')) return 'visa';
    if (RegExp(r'^5[1-5]|^2[2-7]').hasMatch(clean)) return 'mastercard';
    if (clean.startsWith('9860')) return 'humo';
    if (clean.startsWith('8600') || clean.startsWith('5614')) return 'uzcard';
    if (RegExp(r'^62|^81|^99').hasMatch(clean)) return 'unionpay';
    if (clean.startsWith('4') || clean.startsWith('5')) return 'kzt';
    return null;
  }

  Widget cardImage(String brand) {
    if (brand == 'humo') {
      return Image.asset(AssetsConstants.humo);
    } else if (brand == 'uzcard') {
      return Container(
          width: 35,
          height: 40,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(3.5)),
          child: Image.asset(AssetsConstants.uzcard));
    } else if (brand == 'mastercard') {
      return SizedBox(
        width: 50,
        height: 40,
        child: Image.asset(
          AssetsConstants.mastercard,
        ),
      );
    } else if (brand == 'unionpay') {
      return Image.asset(AssetsConstants.unionpay);
    } else {
      return SvgPicture.asset(AssetsConstants.visa);
    }
  }

  void _addCard(BuildContext context) {
    final cleanNumber = _numberCtrl.text.replaceAll(' ', '');
    if (cleanNumber.length < 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.localized.invalid_card_number,
          ),
        ),
      );
      return;
    }
    if (_monthCtrl.text.length != 2 || _yearCtrl.text.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.localized.specify_expiry_date,
          ),
        ),
      );
      return;
    }
    // if (_cardHolderNameCtrl.text.length < 3) {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(const SnackBar(content: Text('Укажите CVV')));
    //   return;
    // }

    final token = 'fake_token_${DateTime.now().millisecondsSinceEpoch}';
    final last4 = cleanNumber.substring(cleanNumber.length - 4);
    final brand = _detectedBrand ?? 'unknown';
    final expMonth = _monthCtrl.text;
    final expYear = _yearCtrl.text;
    final cardHolderName = _cardHolderNameCtrl.text;

    if (cardHolderName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.localized.specify_cardholder_name,
          ),
        ),
      );
      return;
    }

    context.read<PaymentCubit>().saveCard(
          SavePaymentCardRequest(
            token: token,
            last4: last4,
            brand: brand,
            expMonth: expMonth,
            expYear: expYear,
            cardHolderName: cardHolderName,
          ),
        );

    _numberCtrl.clear();
    _monthCtrl.clear();
    _yearCtrl.clear();
    _cardHolderNameCtrl.clear();
    setState(() => _detectedBrand = null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        state.whenOrNull(
          success: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(context.localized.card_added),
                  backgroundColor: Colors.green),
            );
          },
          failure: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('${context.localized.error} $error'),
                  backgroundColor: Colors.red),
            );
          },
        );
      },
      builder: (context, state) {
        List<my.SavedPaymentCardResponse> paymentCards = [];
        bool isLoading = false;

        state.maybeWhen(
          loaded: (cards) {
            paymentCards = cards;
          },
          loading: () {
            isLoading = true;
          },
          orElse: () {},
        );

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              if (paymentCards.isNotEmpty) ...[
                Text(context.localized.saved_cards,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                for (final card in paymentCards)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      height: 250,
                      child: Card(
                        color: card.brand.getCardColor(),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    card.brand == 'visa' ||
                                            card.brand == 'master'
                                        ? Icons.credit_card
                                        : Icons.account_balance,
                                    color: Colors.white,
                                  ),
                                  const Spacer(),
                                  Text(
                                    '•••• •••• •••• ${card.last4}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${card.expMonth}/${card.expYear}',
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    card.cardHolderName,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(
                                // width: 10,
                                // height: 13.56,

                                child: cardImage(card.brand),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
              Text(context.localized.add_new_card,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextField(
                controller: _numberCtrl,
                onChanged: _onNumberChanged,
                decoration: InputDecoration(
                  labelText: context.localized.card_number,
                  prefixIcon: _detectedBrand != null
                      ? Icon(
                          _detectedBrand == 'visa' || _detectedBrand == 'master'
                              ? Icons.credit_card
                              : Icons.account_balance,
                          color: _detectedBrand!.getCardColor(),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _monthCtrl,
                      focusNode: _monthFocus,
                      decoration: InputDecoration(
                        labelText: context.localized.expiry_month,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      onChanged: (value) {
                        if (value.length == 2) {
                          _yearFocus.requestFocus();
                        }

                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _yearCtrl,
                      focusNode: _yearFocus,
                      decoration: InputDecoration(
                        labelText: context.localized.expiry_year,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      onChanged: (value) {
                        if (value.length == 2) {
                          _nameFocus.requestFocus();
                        }

                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              TextField(
                controller: _cardHolderNameCtrl,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: context.localized.cardholder_name,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _addCard(context),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(context.localized.attach_card),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
