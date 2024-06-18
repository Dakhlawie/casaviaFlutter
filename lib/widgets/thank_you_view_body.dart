import 'package:casavia/model/user.dart';
import 'package:casavia/widgets/custom_check_icon.dart';
import 'package:casavia/widgets/custom_dashed_line.dart';
import 'package:casavia/widgets/thank_you_card.dart';
import 'package:flutter/material.dart';

class ThankYouViewBody extends StatefulWidget {
  final User user;
  final double total;
  final String currency;

  const ThankYouViewBody({
    super.key,
    required this.user,
    required this.total,
    required this.currency,
  });

  @override
  _ThankYouViewBodyState createState() => _ThankYouViewBodyState();
}

class _ThankYouViewBodyState extends State<ThankYouViewBody> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ThankYouCard(
            user: widget.user,
            total: widget.total,
            currency: widget.currency,
          ),
          Positioned(
            bottom: MediaQuery.sizeOf(context).height * .2 + 20,
            left: 20 + 8,
            right: 20 + 8,
            child: const CustomDashedLine(),
          ),
          Positioned(
            left: -20,
            bottom: MediaQuery.sizeOf(context).height * .2,
            child: const CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
          Positioned(
            right: -20,
            bottom: MediaQuery.sizeOf(context).height * .2,
            child: const CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
          const Positioned(
            top: -50,
            left: 0,
            right: 0,
            child: CustomCheckIcon(),
          ),
        ],
      ),
    );
  }
}
