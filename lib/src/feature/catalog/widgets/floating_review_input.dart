import 'package:coment_app/src/core/constant/assets_constants.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FloatingReviewInput extends StatefulWidget {
  final String recipientName;
  final VoidCallback onClose;
  final ValueChanged<String> onSend;

  const FloatingReviewInput({
    super.key,
    required this.recipientName,
    required this.onClose,
    required this.onSend,
  });

  @override
  State<FloatingReviewInput> createState() => _FloatingReviewInputState();
}

class _FloatingReviewInputState extends State<FloatingReviewInput> {
  bool _isChanged = false;
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _handleSend() {
    widget.onSend(_replyController.text);
    _replyController.clear();
    setState(() => _isChanged = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "${context.localized.answer}: ",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      TextSpan(
                        text: widget.recipientName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.onClose();
                    _replyController.clear();
                  },
                  child: SvgPicture.asset(
                    AssetsConstants.icClose,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    onChanged: (value) => setState(() => _isChanged = value.isNotEmpty),
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: context.localized.your_response_to_the_comment,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                if (_isChanged) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: SvgPicture.asset(
                     AssetsConstants.icSend,
                    ),
                    onPressed: _handleSend,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
