// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/extensions/build_context.dart';
import 'package:coment_app/src/core/presentation/widgets/buttons/custom_button.dart';
import 'package:coment_app/src/core/presentation/widgets/dialog/toaster.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/core/utils/image_util.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:coment_app/src/feature/app/router/app_router.dart';
import 'package:coment_app/src/feature/catalog/bloc/complain_cubit.dart';
import 'package:coment_app/src/feature/catalog/bloc/like_comment_cubit.dart';
import 'package:coment_app/src/feature/catalog/bloc/product_info_cubit.dart';
import 'package:coment_app/src/feature/catalog/widgets/build_star_raiting_widget.dart';
import 'package:coment_app/src/feature/catalog/widgets/raiting_detail.dart';
import 'package:coment_app/src/feature/catalog/widgets/review_avatar.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:coment_app/src/feature/main/model/product_dto.dart';
import 'package:coment_app/src/feature/main/presentation/widgets/popular_feedback_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ProductDetailPage extends StatefulWidget implements AutoRouteWrapper {
  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
          create: (context) => ProductInfoCubit(
              repository: context.repository.catalogRepository)),
      BlocProvider(
        create: (context) => LikeCommentCubit(
          repository: context.repository.catalogRepository,
        ),
      ),
      BlocProvider(
        create: (context) => ComplainCubit(
          repository: context.repository.catalogRepository,
        ),
      ),
    ], child: this);
  }
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int totalRatingVotes = 0;
  int _selectedRating = 0;

  // like / dislike
  List<bool> isLike = [];
  List<bool> isDislike = [];
  List<bool> pressedDislike = [];
  List<bool> isLikeLoading = [];
  List<bool> isDislikeLoading = [];

  //geocoding & map
  late Future<LatLng?> _geocodedPosition;

  @override
  void initState() {
    BlocProvider.of<ProductInfoCubit>(context)
        .getProductInfo(id: widget.productId);

    super.initState();
  }


Future<LatLng?> _geocodeAddress(String country, String city, String address) async {
  final query = Uri.encodeComponent('$country, $city, $address');
  final url = 'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';

  try {
    final response = await Dio().get(url, options: Options(headers: {
      'User-Agent': 'ComentApp/1.0 (contact@coment.app)'
    }));
    if (response.data is List && response.data.isNotEmpty) {
      final lat = double.parse(response.data[0]['lat']);
      final lon = double.parse(response.data[0]['lon']);
      return LatLng(lat, lon);
    }
  } catch (e) {
    // ignore
  }
  return null;
}


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductInfoCubit, ProductInfoState>(
        listener: (context, state) {
      state.maybeWhen(
        orElse: () {},
        loaded: (data) {
          isLike = [];
          isDislike = [];
          isDislikeLoading = [];
          isLikeLoading = [];
          totalRatingVotes = 0;
          totalRatingVotes += data.ratingCounts?.five ?? 0;
          totalRatingVotes += data.ratingCounts?.four ?? 0;
          totalRatingVotes += data.ratingCounts?.three ?? 0;
          totalRatingVotes += data.ratingCounts?.two ?? 0;
          totalRatingVotes += data.ratingCounts?.one ?? 0;

          for (int i = 0; i < (data.feedback ?? []).length; i++) {
            data.feedback?[i].isLike == 1
                ? isLike.add(true)
                : isLike.add(false);
            data.feedback?[i].isDislike == 1
                ? isDislike.add(true)
                : isDislike.add(false);
            pressedDislike.add(false);
            isDislikeLoading.add(false);
            isLikeLoading.add(false);
            // log('${data.feedback?[i].dislikes}', name: 'dis');
            // log('${data.feedback?[i].likes}', name: 'is');
            log('==$isDislikeLoading');
            log('===$isDislikeLoading');
          }

          // 🔹 ЗАПУСК ГЕОКОДИНГА
          final address = data.address ?? '';
          final city = data.city?.name ?? '';
          final country = data.country?.name ?? '';

          if (address.isNotEmpty) {
            _geocodedPosition = _geocodeAddress(country, city, address);
          } else {
            _geocodedPosition = Future.value(null);
          }

        },
      );
    }, builder: (context, state) {
      return state.maybeWhen(
        orElse: () => const Scaffold(
          appBar: CustomAppBar(),
          body: Center(
            child: Text('error'),
          ),
        ),
        loading: () => const Scaffold(
          appBar: CustomAppBar(),
          body: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
        loaded: (data) {
          return Scaffold(
            appBar: const CustomAppBar(),
            body: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.list(
                    children: [
                      ///
                      /// <--`image, title, location, phone number, website, rating quantity`-->
                      ///
                      _headerWidget(data),

                      ///
                      /// <--`put rating widget`-->
                      ///
                      _putRating(data.id ?? 0),

                      const Gap(26),

                      ///
                      /// <--`reviews raiting`-->
                      ///
                      _ratingInfo(data),

                      ///
                      /// <--`feedback images`-->
                      ///
                      _feedbackImages(data),

                      ///
                      /// <--`feedbacks`-->
                      ///
                      _feedbacks(data.feedback ?? []),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  int getFeedbackItemCount(bool fromReadAllPage, List feedback) {
    if (fromReadAllPage) return feedback.length;
    return feedback.length > 2 ? 2 : feedback.length;
  }

  Widget _feedbacks(
    List<FeedbackDTO> feedback,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 30),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: getFeedbackItemCount(false, feedback),
      itemBuilder: (context, index) {
        return BlocListener<LikeCommentCubit, LikeCommentState>(
          listener: (context, state) {
            state.maybeWhen(
              orElse: () {
                isLikeLoading[index] = false;
                if (pressedDislike[index] == true) {
                  isDislikeLoading[index] = false;
                }
                setState(() {});
              },
              error: (message) {
                isLikeLoading[index] = false;
                if (pressedDislike[index] == true) {
                  isDislikeLoading[index] = false;
                }
                setState(() {});
                if (message.contains('You cannot rate your own review')) {
                  Toaster.showErrorTopShortToast(
                      context, 'Нельзя оценить свой отзыв');
                } else {
                  Toaster.showErrorTopShortToast(context, message);
                }
              },
              loadedLike: () {
                isLikeLoading[index] = false;
                if (pressedDislike[index] == true) {
                  isDislikeLoading[index] = false;
                }
                BlocProvider.of<ProductInfoCubit>(context).getProductInfo(
                    id: widget.productId, hasDelay: false, hasLoading: false);
                setState(() {});
              },
              loadedDislike: () async {
                isLikeLoading[index] = false;
                if (pressedDislike[index] == true) {
                  isDislikeLoading[index] = false;
                }
                if (!isLike[index] &&
                    isDislike[index] &&
                    pressedDislike[index] == false) {
                  BlocProvider.of<LikeCommentCubit>(context).likeComment(
                      feedbackId: feedback[index].id ?? 0, type: 'like');
                }
                if (pressedDislike[index] == true && !isDislike[index]) {
                  BlocProvider.of<LikeCommentCubit>(context).likeComment(
                      feedbackId: feedback[index].id ?? 0, type: 'dislike');
                }
                BlocProvider.of<ProductInfoCubit>(context).getProductInfo(
                    id: widget.productId, hasDelay: false, hasLoading: false);
                setState(() {});
              },
            );
          },
          child: Column(
            children: [
              const Gap(14),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReviewAvatar(
                      imageAva: feedback[index].user?.avatar ?? NOT_FOUND_IMAGE,
                      rating: feedback[index].user?.rating ?? 1,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(feedback[index].user?.name ?? '',
                                      style: AppTextStyles.fs14w600.copyWith(
                                          color: const Color(0xff605b5b),
                                          height: 1.3)),
                                  const SizedBox(height: 4),
                                  Text(
                                      feedback[index].createdAt != null
                                          ? formatDate(
                                              feedback[index].createdAt!,
                                              context.currentLocale.toString())
                                          : '—',
                                      style: AppTextStyles.fs12w500.copyWith(
                                          color: const Color(0xFFA7A7A7),
                                          height: 1.3)),
                                ],
                              ),
                              Row(
                                children: List.generate(
                                    5,
                                    (indexx) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4),
                                          child: SvgPicture.asset(
                                            AssetsConstants.icStar,
                                            height: 10,
                                            width: 10,
                                            colorFilter: getStarColorFilter(
                                                feedback[index].rating ?? 0,
                                                indexx),
                                          ),
                                        )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            feedback[index].comment ?? '',
                            style: AppTextStyles.fs14w400.copyWith(
                                color: AppColors.text,
                                height: 1.3,
                                letterSpacing: -0.5),
                          ),
                          if ((feedback[index].images ?? []).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: feedback[index].images?.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        context.router.push(
                                          DetailImageRoute(
                                            images: feedback[index].images,
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: SizedBox(
                                          height: 80,
                                          width: 80,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              feedback[index]
                                                      .images?[index]
                                                      .image ??
                                                  '',
                                              fit: BoxFit.cover,
                                              loadingBuilder:
                                                  ImageUtil.loadingBuilder,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                          const Gap(10),
                          InkWell(
                            onTap: () {
                              context.router
                                  .push(FeedbackDetailRoute(
                                      needPageCard: false,
                                      id: feedback[index].id ?? 0,
                                      userId: feedback[index].user?.id ?? 0))
                                  .whenComplete(() {
                                BlocProvider.of<ProductInfoCubit>(context)
                                    .getProductInfo(
                                        id: widget.productId,
                                        hasDelay: false,
                                        hasLoading: false);
                              });
                            },
                            child: Text(
                              context.localized.read_the_entire_review,
                              style: AppTextStyles.fs12w500.copyWith(
                                  color: AppColors.mainColor, height: 1.3),
                            ),
                          ),
                          const Gap(4),

                          ///
                          ///Like unlike Buttons
                          ///

                          // Row(
                          //   children: [
                          //     if (isLikeLoading[index] == true)
                          //       const Padding(
                          //         padding: EdgeInsets.all(3.0),
                          //         child: CircularProgressIndicator.adaptive(
                          //           backgroundColor: AppColors.mainColor,
                          //         ),
                          //       )
                          //     else
                          //       GestureDetector(
                          //         onTap: context.appBloc.isAuthenticated
                          //             ? () {
                          //                 if (!isLike[index] &&
                          //                     !isDislike[index]) {
                          //                   BlocProvider.of<LikeCommentCubit>(
                          //                           context)
                          //                       .likeComment(
                          //                           feedbackId:
                          //                               feedback[index].id ?? 0,
                          //                           type: 'like');
                          //                   pressedDislike[index] = false;
                          //                   isLikeLoading[index] = true;
                          //                   setState(() {});
                          //                 } else if (isLike[index] &&
                          //                     !isDislike[index]) {
                          //                   BlocProvider.of<LikeCommentCubit>(
                          //                           context)
                          //                       .dislikeComment(
                          //                           feedbackId:
                          //                               feedback[index].id ??
                          //                                   0);
                          //                   pressedDislike[index] = false;
                          //                   isLikeLoading[index] = true;
                          //                   setState(() {});
                          //                 } else if (!isLike[index] &&
                          //                     isDislike[index]) {
                          //                   BlocProvider.of<LikeCommentCubit>(
                          //                           context)
                          //                       .dislikeComment(
                          //                           feedbackId:
                          //                               feedback[index].id ??
                          //                                   0);
                          //                   pressedDislike[index] = false;
                          //                   isLikeLoading[index] = true;
                          //                   setState(() {});
                          //                 }
                          //               }
                          //             : () {
                          //                 context.router
                          //                     .push(const RegisterRoute());
                          //               },
                          //         child: Padding(
                          //           padding: const EdgeInsets.all(4.0),
                          //           child: SvgPicture.asset(
                          //             AssetsConstants.icLike,
                          //             colorFilter: isLike[index] == true
                          //                 ? const ColorFilter.mode(
                          //                     AppColors.mainColor,
                          //                     BlendMode.srcIn)
                          //                 : const ColorFilter.mode(
                          //                     Color(0xffc1c0c0),
                          //                     BlendMode.srcIn),
                          //           ),
                          //         ),
                          //       ),
                          //     Text(
                          //         feedback[index].likes == null
                          //             ? '0'
                          //             : '${feedback[index].likes}',
                          //         style: AppTextStyles.fs12w500.copyWith(
                          //             color: AppColors.greyTextColor3)),
                          //     const SizedBox(width: 4),
                          //     if (isDislikeLoading[index] == true)
                          //       const Padding(
                          //         padding: EdgeInsets.all(3.0),
                          //         child: CircularProgressIndicator.adaptive(
                          //           backgroundColor: AppColors.mainColor,
                          //         ),
                          //       )
                          //     else
                          //       GestureDetector(
                          //         onTap: context.appBloc.isAuthenticated
                          //             ? () {
                          //                 if (!isDislike[index] &&
                          //                     !isLike[index]) {
                          //                   ComplainedBs.show(
                          //                     context,
                          //                     feedID: feedback[index].id,
                          //                     isDislike: true,
                          //                     isComplainedDislike:
                          //                         (isComplained) {
                          //                       BlocProvider.of<
                          //                                   LikeCommentCubit>(
                          //                               context)
                          //                           .likeComment(
                          //                               feedbackId:
                          //                                   feedback[index]
                          //                                           .id ??
                          //                                       0,
                          //                               type: 'dislike');
                          //                       pressedDislike[index] = true;
                          //                       setState(() {});
                          //                     },
                          //                   );
                          //                 } else if (isDislike[index] &&
                          //                     !isLike[index]) {
                          //                   BlocProvider.of<LikeCommentCubit>(
                          //                           context)
                          //                       .dislikeComment(
                          //                           feedbackId:
                          //                               feedback[index].id ??
                          //                                   0);
                          //                   pressedDislike[index] = true;
                          //                   setState(() {});
                          //                 } else if (!isDislike[index] &&
                          //                     isLike[index]) {
                          //                   ComplainedBs.show(
                          //                     context,
                          //                     feedID: feedback[index].id,
                          //                     isDislike: true,
                          //                     isComplainedDislike:
                          //                         (isComplained) {
                          //                       BlocProvider.of<
                          //                                   LikeCommentCubit>(
                          //                               context)
                          //                           .dislikeComment(
                          //                               feedbackId:
                          //                                   feedback[index]
                          //                                           .id ??
                          //                                       0);
                          //                       pressedDislike[index] = true;
                          //                       setState(() {});
                          //                     },
                          //                   );
                          //                 }
                          //               }
                          //             : () {
                          //                 context.router
                          //                     .push(const RegisterRoute());
                          //               },
                          //         child: Padding(
                          //           padding: const EdgeInsets.all(4.0),
                          //           child: SvgPicture.asset(
                          //             AssetsConstants.icDislike,
                          //             colorFilter: isDislike[index] == true
                          //                 ? const ColorFilter.mode(
                          //                     AppColors.mainColor,
                          //                     BlendMode.srcIn)
                          //                 : const ColorFilter.mode(
                          //                     Color(0xffc1c0c0),
                          //                     BlendMode.srcIn),
                          //           ),
                          //         ),
                          //       ),
                          //     const SizedBox(width: 6),
                          //     SvgPicture.asset(AssetsConstants.icComment),
                          //     const SizedBox(width: 4),
                          //     Text(
                          //       feedback[index].repliesCount.toString(),
                          //       style: AppTextStyles.fs12w500
                          //           .copyWith(color: AppColors.greyTextColor3),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(14),
              if (index == 0)
                const Divider(
                  thickness: 0.4,
                  height: 0.4,
                  color: AppColors.borderTextField,
                )
            ],
          ),
        );
      },
    );
  }

  ColorFilter? getStarColorFilter(int rating, int index) {
    return rating == 5
        ? null
        : rating == 4
            ? (index == 4
                ? const ColorFilter.mode(AppColors.base400, BlendMode.srcIn)
                : null)
            : rating == 3
                ? (index == 3 || index == 4
                    ? const ColorFilter.mode(AppColors.base400, BlendMode.srcIn)
                    : null)
                : rating == 2
                    ? (index == 2 || index == 3 || index == 4
                        ? const ColorFilter.mode(
                            AppColors.base400, BlendMode.srcIn)
                        : null)
                    : rating == 1
                        ? (index == 1 || index == 2 || index == 3 || index == 4
                            ? const ColorFilter.mode(
                                AppColors.base400, BlendMode.srcIn)
                            : null)
                        : (index == 0 ||
                                index == 1 ||
                                index == 2 ||
                                index == 3 ||
                                index == 4
                            ? const ColorFilter.mode(
                                AppColors.base400, BlendMode.srcIn)
                            : const ColorFilter.mode(
                                AppColors.base400, BlendMode.srcIn));
  }

  Widget _putRating(int productId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: AppColors.grey2, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.localized.rate_this_place,
              style: AppTextStyles.fs16w600.copyWith(height: 1.7)),
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
              if (!context.appBloc.isAuthenticated) {
                context.router.push(const RegisterRoute());
              } else {
                context.router
                    .push(LeaveFeedbackRoute(
                        productID: productId, selectedRating: _selectedRating))
                    .whenComplete(() {
                  BlocProvider.of<ProductInfoCubit>(context)
                      .getProductInfo(id: productId);

                  setState(() {});
                });
              }
            },
            style: null,
            child: Text(context.localized.leave_a_review,
                style: AppTextStyles.fs16w500.copyWith(height: 0.9)),
          )
        ],
      ),
    );
  }

  Widget _feedbackImages(ProductDTO data) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              context.localized.user_photos,
              style: AppTextStyles.fs14w500,
            ),
          ],
        ),
        const Gap(10),

        ///
        /// photos
        ///
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: (data.feedbackImages ?? []).length >= 4
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: List.generate(
              (data.feedbackImages ?? []).length > 4
                  ? 4
                  : (data.feedbackImages ?? []).length,
              (index) => Container(
                height: 80,
                width: 80,
                margin: (data.feedbackImages ?? []).length >= 4
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    context.router.push(DetailAllImageRoute(
                      images: data.feedbackImages ?? [],
                    ));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: index == 3
                        ? Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: (data.feedbackImages ?? [])[index],
                                fit: BoxFit.cover,
                                height: 80,
                                width: 80,
                                progressIndicatorBuilder:
                                    ImageUtil.cachedLoadingBuilder,
                              ),
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Center(
                                  child: Text(
                                    'ЕЩЕ ${(data.feedbackImages ?? []).length - 3} +',
                                    style: AppTextStyles.fs12w600
                                        .copyWith(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : CachedNetworkImage(
                            imageUrl: (data.feedbackImages ?? [])[index],
                            fit: BoxFit.cover,
                            height: 80,
                            width: 80,
                            progressIndicatorBuilder:
                                ImageUtil.cachedLoadingBuilder,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const Gap(12),
      ],
    );
  }

  Widget _ratingInfo(ProductDTO data) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${context.localized.reviews} (${data.feedbackCount})",
              style: AppTextStyles.fs16w600,
            ),
            InkWell(
              onTap: () {
                context.router.push(
                  ReadAllRoute(data: data, totalRatingVotes: totalRatingVotes),
                );
              },
              child: Text(context.localized.read_all,
                  style: AppTextStyles.fs12w600.copyWith(
                    color: AppColors.mainColor,
                  )),
            ),
          ],
        ),
        const Gap(14),
        RaitingDetail(
          averageRating: data.rating ?? 0.0,
          totalReviews: data.feedbackCount ?? 0,
          ratingDistribution: {
            5: calculateRatingPercentage(
                5, data.ratingCounts?.five ?? 0, totalRatingVotes),
            4: calculateRatingPercentage(
                4, data.ratingCounts?.four ?? 0, totalRatingVotes),
            3: calculateRatingPercentage(
                3, data.ratingCounts?.three ?? 0, totalRatingVotes),
            2: calculateRatingPercentage(
                2, data.ratingCounts?.two ?? 0, totalRatingVotes),
            1: calculateRatingPercentage(
                1, data.ratingCounts?.one ?? 0, totalRatingVotes),
          },
        ),
        const Gap(20),
      ],
    );
  }

  double calculateRatingPercentage(int star, int starCount, int totalVotes) {
    if (totalVotes == 0) return 0.0;
    return (starCount / totalVotes) * 100;
  }

  Widget _headerWidget(ProductDTO data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(5),
        GestureDetector(
          onTap: () {
            context.router
                .push(DetailAvatarRoute(image: data.image ?? NOT_FOUND_IMAGE));
          },
          child: Container(
            width: double.infinity,
            height: 148,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CachedNetworkImage(
                imageUrl: data.image ?? NOT_FOUND_IMAGE,
                fit: BoxFit.cover,
                width: double.infinity,
                progressIndicatorBuilder: ImageUtil.cachedLoadingBuilder,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            data.name ?? '',
            style: AppTextStyles.fs16w500.copyWith(height: 1.45),
          ),
        ),
        if (data.address != null && data.address != '')
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                SvgPicture.asset(AssetsConstants.icLocation),
                const Gap(6),
                Text(
                  data.address ?? '',
                  style: AppTextStyles.fs14w500,
                )
              ],
            ),
          ),
        if (data.organisationPhone != null && data.organisationPhone != '')
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                SvgPicture.asset(AssetsConstants.phone),
                const Gap(6),
                Text(
                  data.organisationPhone ?? '',
                  style: AppTextStyles.fs14w500,
                )
              ],
            ),
          ),
        if (data.websiteUrl != null && data.websiteUrl != '')
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: GestureDetector(
              onTap: () {
                launchUrl(Uri.parse(data.websiteUrl ?? ''));
              },
              child: Row(
                children: [
                  SvgPicture.asset(AssetsConstants.link),
                  const Gap(6),
                  Text(
                    context.localized.linkTotheWebsite,
                    style: AppTextStyles.fs14w500.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  )
                ],
              ),
            ),
          ),
        const Gap(10),
        _mapWidget(data),
        const Gap(10),
        Row(
          children: [
            SvgPicture.asset(AssetsConstants.icStar),
            const Gap(6),
            Text(
              data.rating != null ? data.rating.toString() : '0',
              style: AppTextStyles.fs16w500,
            ),
            const Gap(10),
            Text(
                data.feedbackCount != null
                    ? (data.feedbackCount == 0 || data.feedbackCount == 1)
                        ? '(${data.feedbackCount} ${context.localized.feedbackLittle})'
                        : '(${data.feedbackCount} ${context.localized.reviewsLittle})'
                    : '(0 ${context.localized.feedbackLittle})',
                style: AppTextStyles.fs14w500
                    .copyWith(color: AppColors.greyTextColor2, height: 1.45)),
          ],
        ),
        const Gap(18),
      ],
    );
  }

  // Widget _mapWidget(ProductDTO data) {
  //   final address = data.address ?? '';
  //   final cityName = data.city?.name ?? '';
  //   final countryName = data.country?.name ?? '';


  //   return GestureDetector(
  //     onTap: () {
  //       context.router.push(
  //         MapRoute(
  //           country: countryName,
  //           city: cityName,
  //           address: address,
  //         ),
  //       );
  //     },
  //     child: Container(
  //       height: 120,
  //       decoration: BoxDecoration(
  //         color: AppColors.grey2,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Center(
  //         child: 
  //         Text(
  //           context.localized.showOnMap,
  //           style: AppTextStyles.fs14w500.copyWith(
  //             color: AppColors.mainColor,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
Widget _mapWidget(ProductDTO data) {
  return GestureDetector(
    onTap: () {
     
      context.router.push(
        MapRoute(
          country: data.country?.name ?? '',
          city: data.city?.name ?? '',
          address: data.address ?? '',
        ),
      );
    },
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.grey2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: FutureBuilder<LatLng?>(
        future: _geocodedPosition,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final center = snapshot.data!;
            return IgnorePointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.coment.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 24,
                        height: 24,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            // fallback — текст, если геокодинг не удался
            return Center(
              child: Text(
                context.localized.showOnMap,
                style: AppTextStyles.fs14w500.copyWith(color: AppColors.mainColor),
              ),
            );
          }
        },
      ),
    ),
  );
}

}
