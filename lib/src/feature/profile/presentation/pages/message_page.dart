import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/presentation/widgets/textfields/custom_textfield.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        actions: [
          Expanded(flex: 2, child: SizedBox()),
          Expanded(
            flex: 8,

            child:  CustomTextField(),
          ),
          Expanded(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }
}
