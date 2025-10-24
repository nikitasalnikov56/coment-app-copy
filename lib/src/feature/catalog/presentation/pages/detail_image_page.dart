import 'dart:developer';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:coment_app/src/feature/main/model/feedback_dto.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class DetailImagePage extends StatefulWidget {
  final List<ImageDTO>? images;
  const DetailImagePage({
    super.key,
    this.images,
  });

  @override
  State<DetailImagePage> createState() => _DetailImagePageState();
}

class _DetailImagePageState extends State<DetailImagePage> {
  int imageIndex = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: imageIndex);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
      ),
      backgroundColor: AppColors.muteGrey,
      body: Column(
        children: [
          const Gap(34),
          SizedBox(
            height: 430,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  imageIndex = index;
                  log('$imageIndex', name: 'image index');
                });
              },
              itemCount: widget.images!.isNotEmpty ? widget.images?.length : 1,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                  child: InteractiveViewer(
                    panEnabled: false,
                    boundaryMargin: const EdgeInsets.all(100),
                    minScale: 0.5,
                    maxScale: 2,
                    child: widget.images!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.images![index].image ?? '', // Display the image based on the index
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: 430,
                          )
                        : Image.asset(AssetsConstants.buket),
                  ),
                );
              },
            ),
          ),
          const Gap(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images!.isNotEmpty ? widget.images!.length : 1, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: imageIndex == index ? 24 : 16,
                height: 4,
                decoration: BoxDecoration(
                  color: imageIndex == index ? AppColors.black : AppColors.buttonGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const Gap(16),
          SizedBox(
            height: 60,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.images!.isNotEmpty ? widget.images?.length : 1,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      imageIndex = index;
                      log('$imageIndex', name: 'image index');
                    });

                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.images!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.images![index].image ?? '', // Display the image based on the index
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 430,
                              )
                            : Image.asset(AssetsConstants.buket),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
