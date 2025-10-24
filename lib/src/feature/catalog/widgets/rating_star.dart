import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/bloc/product_info_cubit.dart';
import 'package:coment_app/src/feature/catalog/widgets/build_star_raiting_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RatePlaceWidget extends StatefulWidget {
  final int productID;
  final Function(int rating, String review)? onReviewSubmitted;

  const RatePlaceWidget({super.key, this.onReviewSubmitted, required this.productID});

  @override
  State<RatePlaceWidget> createState() => _RatePlaceWidgetState();
}

class _RatePlaceWidgetState extends State<RatePlaceWidget> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.grey2, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.localized.rate_this_place, style: AppTextStyles.fs16w600.copyWith(height: 1.7)),
          const SizedBox(height: 16),
          BuildStarRaitingWidget(
            selectedRating: _selectedRating,
            onRatingSelected: (rating) {
              setState(() {
                if (rating - 1 == 0 && _selectedRating == 1) {
                  _selectedRating = 0;
                } else {
                  _selectedRating = rating;
                }
              });
            },
          ),
          const SizedBox(height: 22),
          CustomButton(
            height: 43,
            onPressed: () {
              context.router
                  .push(LeaveFeedbackRoute(productID: widget.productID, selectedRating: _selectedRating))
                  .whenComplete(() {
                BlocProvider.of<ProductInfoCubit>(context).getProductInfo(id: widget.productID);
              });
            },
            style: null,
            child: Text(context.localized.leave_a_review, style: AppTextStyles.fs16w500.copyWith(height: 0.9)),
          )
        ],
      ),
    );
  }
}
