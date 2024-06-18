import 'package:casavia/model/user.dart';
import 'package:casavia/widgets/cutom_app_bar.dart';
import 'package:casavia/widgets/thank_you_view_body.dart';
import 'package:flutter/material.dart';

class ThankYouView extends StatefulWidget {
  final User user;
  final double total;
  final String currency;
  const ThankYouView({
    super.key,
    required this.user,
    required this.total,
    required this.currency,
  });

  @override
  _ThankYouViewState createState() => _ThankYouViewState();
}

class _ThankYouViewState extends State<ThankYouView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context: context),
      body: Transform.translate(
          offset: const Offset(0, -16),
          child: ThankYouViewBody(
            user: widget.user,
            total: widget.total,
            currency: widget.currency,
          )),
    );
  }
}
