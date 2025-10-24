import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/catalog/bloc/complain_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import 'package:coment_app/src/core/presentation/widgets/bottomsheet/custom_drag_handle.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';

class ComplainedBs extends StatefulWidget {
  const ComplainedBs({
    super.key,
    required this.feedId,
    this.isDislike,
    this.isComplainedDislike,
  });

  final int? feedId;
  final bool? isDislike;
  final Function(bool)? isComplainedDislike;

  static Future<void> show(BuildContext context, {int? feedID, bool? isDislike, Function(bool)? isComplainedDislike}) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ComplainCubit(
                repository: context.repository.catalogRepository,
              ),
            )
          ],
          child: ComplainedBs(
            feedId: feedID,
            isDislike: isDislike,
            isComplainedDislike: isComplainedDislike,
          ),
        ),
      );

  @override
  State<ComplainedBs> createState() => _ComplainedBsState();
}

class _ComplainedBsState extends State<ComplainedBs> {
  final TextEditingController textController = TextEditingController();
  bool? isLoading = false;

  int? _feedId = 1;

  bool successBS = false;

  @override
  void initState() {
    _feedId = widget.feedId;
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: successBS
            ? _successBS()
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomDragHandle(),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.isDislike == true ? 'Поделитесь вашим мнением' : context.localized.complain,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.fs18w700,
                              ),
                              IconButton(
                                onPressed: () {
                                  context.router.maybePop();
                                },
                                icon: SvgPicture.asset(
                                  AssetsConstants.close,
                                  height: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(context.localized.pleaseDescribeWhatIsWrongWithTheReviewSoThatWeCanDealWithFaster,
                              style: AppTextStyles.fs14w400),
                        ),
                        const Gap(12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {});
                            },
                            controller: textController,
                            decoration: InputDecoration(
                              hintText: context.localized.write,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            maxLines: 4,
                          ),
                        ),
                        const Gap(32),
                        BlocListener<ComplainCubit, ComplainState>(
                          listener: (context, state) {
                            state.maybeWhen(
                              orElse: () {
                                isLoading = false;
                                setState(() {});
                              },
                              loading: () {
                                isLoading = true;
                              },
                              loaded: () {
                                if (textController.text.isNotEmpty) {
                                  isLoading = false;
                                  successBS = true;
                                  setState(() {});
                                  widget.isComplainedDislike?.call(true);
                                }
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                onPressed: () {
                                  BlocProvider.of<ComplainCubit>(context).complain(
                                      text: textController.text,
                                      feedId: _feedId ?? 1,
                                      type: widget.isDislike == true ? 'dislike' : 'complaint');
                                  setState(() {});
                                },
                                style: textController.text.isNotEmpty
                                    ? CustomButtonStyles.mainButtonStyle(context)
                                    : CustomButtonStyles.greyButtonStyle(context),
                                child: isLoading == true
                                    ? const CircularProgressIndicator.adaptive()
                                    : Text(
                                        context.localized.send,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _successBS() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CustomDragHandle(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  context.router.maybePop();
                },
                icon: SvgPicture.asset(
                 AssetsConstants.close,
                  height: 26,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                size: 53.33,
                color: AppColors.mainColor,
              ),
              const Gap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(context.localized.thank_you_for_contacting_us,
                    textAlign: TextAlign.center, style: AppTextStyles.fs22w700),
              ),
              const Gap(22),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomButton(
            onPressed: () {
              context.router.maybePop();
            },
            style: CustomButtonStyles.mainButtonStyle(context),
            child: isLoading == true
                ? const CircularProgressIndicator.adaptive()
                : Text(context.localized.done, style: AppTextStyles.fs16w600),
          ),
        ),
        const Gap(16),
      ],
    );
  }
}
