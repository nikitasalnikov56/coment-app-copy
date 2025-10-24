import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:coment_app/src/core/presentation/widgets/other/custom_loading_overlay_widget.dart';

@RoutePage()
class TempPage extends StatelessWidget {
  const TempPage({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
       
          titleSpacing: 0,
      
          centerTitle: false,
          title: Text(
            title,
            style: title.length > 20
                ? TextStyle(
                    fontSize: title.length > 24 ? 18 : 20,
                    fontWeight: FontWeight.w700,
                  )
                : const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 34 / 28,
                  ),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 72,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      padding: const EdgeInsets.all(16),
                     
                    ),
                  ),
                  const Gap(16),
                  const Center(
                    child: CustomLoadingOverlayWidget(),
                  ),
                  const Gap(16),
                  const Text(
                    'context.localized.thisSectionIsUnderDevelopment',
                  ),
                  const Gap(8),
                  const Text(
                    '',
                  
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}


