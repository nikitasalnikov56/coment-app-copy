import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/utils/image_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProfileAvatarWithRating extends StatelessWidget {
  final String imageAva;
  final int rating;

  const ProfileAvatarWithRating({
    super.key,
    required this.imageAva,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Profile avatar
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 90,
            width: 90,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7573F3), width: 3),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.1),
              //     blurRadius: 6,
              //   ),
              // ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                child: Image.network(
                  imageAva,
                  fit: BoxFit.cover,
                  loadingBuilder: ImageUtil.loadingBuilder,
                ),
              ),
            ),
          ),

          // Rating overlay
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rating.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SvgPicture.asset(AssetsConstants.icStar),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
