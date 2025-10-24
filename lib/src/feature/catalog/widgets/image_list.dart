import 'package:flutter/material.dart';

class ImageList extends StatelessWidget {
  final List<ImageData> images;

  const ImageList({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final image = images[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16), // Rounded corners
                  child: Image.asset(
                    image.path,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                if (image.overlayText != null)
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Center(
                      child: Text(
                        image.overlayText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (image.showPlayIcon)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ImageData {
  final String path;
  final String? overlayText;
  final bool showPlayIcon;

  ImageData({
    required this.path,
    this.overlayText,
    this.showPlayIcon = false,
  });
}

