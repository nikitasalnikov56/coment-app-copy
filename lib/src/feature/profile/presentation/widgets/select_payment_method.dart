import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

enum Payments { payme, click, uzumBank }

class SelectPaymentMethod extends StatefulWidget {
  const SelectPaymentMethod({super.key});

  @override
  State<SelectPaymentMethod> createState() => _SelectPaymentMethodState();
}

class _SelectPaymentMethodState extends State<SelectPaymentMethod> {
  List<String> paymentMethods = ['Payme', 'Click', 'Uzum Bank'];
  List<String> paymentsLogos = [
    AssetsConstants.payme,
    AssetsConstants.click,
    AssetsConstants.uzumBank
  ];

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Gap(18),
          Text(
            context.localized.choosePaymentMethod,
            style: AppTextStyles.fs18w700.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(10),
          Text(
            context.localized.paymentSecurityInfo,
            style: AppTextStyles.fs15w400.copyWith(
              color: AppColors.greyTextColor,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
          const Gap(25),
          Expanded(
            child: GridView.builder(
              // padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 200),
              itemBuilder: (BuildContext context, int index) {
                final bool isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFDEE9FD)
                                : const Color(0xFFF9F9F7),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF757C96)
                                  : const Color(0xFF8C8E8C),
                            ),
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: Card(
                                color: const Color(0xFFC4EEF8),
                                child: Padding(
                                  padding: index != 0
                                      ? const EdgeInsetsGeometry.all(0)
                                      : const EdgeInsets.symmetric(
                                          vertical: 30, horizontal: 5),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      paymentsLogos[index],
                                      fit: index == 0 ? BoxFit.contain : BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // const Gap(15),
                            Text(
                              paymentMethods[index],
                              style: AppTextStyles.fs16w600
                                  .copyWith(height: 1 / 1),
                            ),
                            // const Gap(14),
                            Text(
                              '${context.localized.paySecurelyVia} ${paymentMethods[index]}',
                              style: AppTextStyles.fs12w600,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    
                   
                    Positioned(
                      right: 15,
                      top: 15,
                      child: AnimatedOpacity(
                        opacity: isSelected ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                                            
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C81E9),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(Icons.check, size: 12, color: AppColors.white,),
                          ),
                      ),
                    ),
                    ],
                  ),
                );

                // );
              },
              itemCount: paymentMethods.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Text(
              '* ${context.localized.redirectToSecurePage}',
              style: AppTextStyles.fs16w500,
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(15),
          CustomButton(
            onPressed: () {},
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(
                EdgeInsetsGeometry.symmetric(vertical: 16),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(25),
                ),
              ),
            ),
            child: Text(
              context.localized.proceedToPayment,
              style: AppTextStyles.fs16w500,
            ),
          ),
          const Gap(20),
        ],
      ),
    );
  }
}


// crossAxisCount: 3,
//               mainAxisSpacing: 6,
//               crossAxisSpacing: 6,
//               children: [
//                 Card(
//                   child: Center(
//                     child: Image.asset(AssetsConstants.payme),
//                   ),
//                 ),
//                 Card(
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(14.0),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(14),
//                         child: Image.asset(AssetsConstants.click),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Card(
//                   child: Center(
//                     child: Image.asset(AssetsConstants.uzumBank),
//                   ),
//                 ),
//               ],