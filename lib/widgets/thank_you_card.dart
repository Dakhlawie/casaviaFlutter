import 'package:casavia/model/user.dart';
import 'package:casavia/theme/styles.dart';
import 'package:casavia/widgets/card_info_widget.dart';
import 'package:casavia/widgets/payment_info_item.dart';
import 'package:casavia/widgets/total_price_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ThankYouCard extends StatefulWidget {
  final User user;
  final double total;
  final String currency;

  const ThankYouCard({
    super.key,
    required this.user,
    required this.total,
    required this.currency,
  });

  @override
  _ThankYouCardState createState() => _ThankYouCardState();
}

class _ThankYouCardState extends State<ThankYouCard> {
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    final String formattedTime = DateFormat('hh:mm a').format(now);
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: const Color(0xFFEDEDED),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 50 + 16, left: 22, right: 22),
        child: Column(
          children: [
            const Text(
              'Thank you!',
              textAlign: TextAlign.center,
              style: Styles.style25,
            ),
            Text(
              'Your transaction was successful',
              textAlign: TextAlign.center,
              style: Styles.style20,
            ),
            const SizedBox(
              height: 42,
            ),
            PaymentItemInfo(
              title: 'Date',
              value: formattedDate,
            ),
            const SizedBox(
              height: 40,
            ),
            PaymentItemInfo(
              title: 'Time',
              value: formattedTime,
            ),
            const SizedBox(
              height: 40,
            ),
            PaymentItemInfo(
              title: 'By',
              value: '${widget.user.nom} ${widget.user.prenom}',
            ),
            const Divider(
              height: 60,
              thickness: 2,
            ),
            TotalPrice(
                title: 'Total', value: '${widget.currency} ${widget.total}'),
            const SizedBox(
              height: 30,
            ),
            // const CardInfoWidget(),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  FontAwesomeIcons.barcode,
                  size: 64,
                ),
                Container(
                  width: 113,
                  height: 58,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          width: 1.50, color: Color.fromARGB(255, 33, 40, 243)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'PAID',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromARGB(255, 33, 40, 243),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: ((MediaQuery.sizeOf(context).height * .2 + 20) / 2) - 29,
            ),
          ],
        ),
      ),
    );
  }
}
