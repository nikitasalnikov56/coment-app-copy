import 'package:cached_network_image/cached_network_image.dart';
import 'package:coment_app/src/core/constant/constants.dart';
import 'package:coment_app/src/core/theme/resources.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CatalogGridItem extends StatelessWidget {
  final int index;
  final void Function()? onTap;
  final String title;
  final String? image;

  const CatalogGridItem({
    super.key,
    required this.index,
    this.onTap,
    required this.title,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    imageUrl: (image ?? '').trim(),
                    placeholder: (context, url) =>
                      const Center(
                         child:  CircularProgressIndicator(
                         strokeWidth: 2,
                         constraints: BoxConstraints(
                           minHeight: 15,
                           minWidth: 15
                         ),
                                                  ),
                       ),
                        errorWidget: (context, url, error) => Image.asset(NOT_FOUND_IMAGE),
                        fit: BoxFit.cover,
                  )
                  // Image.network(image ?? NOT_FOUND_IMAGE),
                  ),
            ),
            const Gap(6),
            Text(
              title,
              // catalogTitle[index],
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.fs14w500,
            )
          ],
        ),
      ),
    );
  }
}
