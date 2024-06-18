import 'package:casavia/Screens/core/GeneralSettings.dart';
import 'package:casavia/Screens/core/thank_you_view.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/notification.dart';
import 'package:casavia/model/payement.dart';
import 'package:casavia/model/reservation.dart';
import 'package:casavia/model/user.dart';
import 'package:casavia/services/HebergementService.dart';
import 'package:casavia/services/ReservationService.dart';
import 'package:casavia/services/notificationService.dart';
import 'package:casavia/services/payementService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class FinalStepReservartion extends StatefulWidget {
  final Hebergement hebergement;
  final String checkIn;
  final String checkOut;
  final double prix;
  final String currency;
  final User user;
  final int nbRooms;
  final List<int> roomIds;
  const FinalStepReservartion(
      {super.key,
      required this.hebergement,
      required this.checkIn,
      required this.checkOut,
      required this.currency,
      required this.prix,
      required this.user,
      required this.nbRooms,
      required this.roomIds});

  @override
  State<FinalStepReservartion> createState() => _FinalStepReservartionState();
}

class _FinalStepReservartionState extends State<FinalStepReservartion> {
  late HebergementService hebergementService = HebergementService();
  int currentStep = 2;
  bool success = false;
  // Future<void> generatePayment() async {
  //   double convertedPrice = await hebergementService.convertPrice(
  //       widget.prix, widget.currency, 'TND');
  //   print("Converted price: $convertedPrice");
  //   String trackingId = "txn_${DateTime.now().millisecondsSinceEpoch}";
  //   var url = Uri.parse('https://developers.flouci.com/api/generate_payment');

  //   var payload = jsonEncode({
  //     "app_token": "bc006d24-9ebb-421f-be88-8a161cab0da1",
  //     "app_secret": "4df723c9-59cf-4976-b858-9f381fef6aa7",
  //     "accept_card": "true",
  //     "amount": convertedPrice.toString(),
  //     "success_link": "https://example.website.com/success",
  //     "fail_link": "https://example.website.com/fail",
  //     "session_timeout_secs": 1200,
  //     "developer_tracking_id": trackingId
  //   });

  //   var headers = {'Content-Type': 'application/json'};

  //   try {
  //     var response = await http.post(url, headers: headers, body: payload);
  //     if (response.statusCode == 200) {
  //       var responseData = jsonDecode(response.body);
  //       print('Response body: ${response.body}');
  //       var paymentLink = responseData['result']['link'];
  //       if (await canLaunch(paymentLink)) {
  //         await launch(paymentLink);
  //         setState(() {
  //           success = true;
  //         });
  //       } else {
  //         throw 'Could not launch $paymentLink';
  //       }
  //     } else {
  //       print('Request failed with status: ${response.statusCode}.');
  //     }
  //   } catch (e) {
  //     print('Caught exception: $e');
  //   }
  // }
  String? formattedAmount;
  String formatAmount(double amount) {
    int formattedAmount = (amount * 1000).round();
    return formattedAmount.toString();
  }

  Future<void> generatePayment() async {
    var url = Uri.parse('https://developers.flouci.com/api/generate_payment');
    double convertedPrice = await hebergementService.convertPriceToTND(
        widget.prix, widget.currency);
    String amount = this.formatAmount(convertedPrice);
    setState(() {
      formattedAmount = amount;
    });

    var payload = jsonEncode({
      "app_token": "bc006d24-9ebb-421f-be88-8a161cab0da1",
      "app_secret": "4df723c9-59cf-4976-b858-9f381fef6aa7",
      "accept_card": "true",
      "amount": amount,
      "success_link": "https://example.website.com/success",
      "fail_link": "https://example.website.com/fail",
      "session_timeout_secs": 1200,
      "developer_tracking_id": "29d0dbc4-36a6-4af1-af8f-f42228a55e1b"
    });

    var headers = {'Content-Type': 'application/json'};

    try {
      var response = await http.post(url, headers: headers, body: payload);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var paymentLink = responseData['result']['link'];
        if (await canLaunch(paymentLink)) {
          await launch(paymentLink);
        } else {
          throw 'Could not launch $paymentLink';
        }

        Map<String, dynamic> paymentData = {
          "transactionId": "exampleTransactionId",
          "payerId": "examplePayerId",
          "currency": widget.currency,
          "total": widget.prix,
          "paymentStatus": "COMPLETED",
          "paymentMethod": "Flouci",
        };

        Reservation rv;

        if (widget.hebergement.categorie.idCat == 1) {
          rv = Reservation(
            dateCheckIn: widget.checkIn,
            dateCheckOut: widget.checkOut,
            prix: widget.prix,
            etat: 'PENDING',
            currency: widget.currency,
            nbRooms: widget.nbRooms,
            rooms: widget.roomIds,
          );
        } else {
          rv = Reservation(
            dateCheckIn: widget.checkIn,
            dateCheckOut: widget.checkOut,
            prix: widget.prix,
            etat: 'PENDING',
            currency: widget.currency,
          );
        }
        Reservation? r = await ReservationService().ajouterReservation(
            rv, widget.user.id, widget.hebergement.hebergementId);

        Payment payment = Payment(
          currency: paymentData['currency'],
          total: double.parse(paymentData['total']),
          paymentStatus: paymentData['paymentStatus'],
          paymentMethod: paymentData['paymentMethod'],
        );
        await PayementService().addPayment(payment, r!.id!);
        setState(() {
          success = true;
        });
        NotificationMessage newNotification = NotificationMessage(
          title: "You have a new booking",
          date: DateTime.now(),
          seen: false,
          type: NotificationType.BOOKING,
        );

        try {
          await NotificationService().sendNotificationToPerson(
              newNotification, widget.hebergement!.person.personId!);
        } catch (e) {
          print('Failed to send notification: $e');
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Caught exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (success) {
      Future.delayed(Duration.zero, () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ThankYouView(
              user: widget.user,
              total: widget.prix,
              currency: widget.currency,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      });
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Payement",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'AbrilFatface',
                        fontSize: 20,
                      )),
                  SizedBox(height: 20),
                  Text("Choose a payement method",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      )),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => PaypalCheckout(
                                sandboxMode: true,
                                clientId:
                                    "AbtcnIBx4eBk0q6F5js_0nBA6AhFT_8k9xRputSo6_WKuajQFzBMA6FrlQKOZD8Zp1b018zm3d_-By-c",
                                secretKey:
                                    "ELs48lqln2mPC6PcbILzA1DWzadC1OFiTW_r9ukwobIPqdqbH6iRdp57P1t0mGnmF7q7ZAtY0koIm5XR",
                                returnURL: "success.snippetcoder.com",
                                cancelURL: "cancel.snippetcoder.com",
                                transactions: [
                                  {
                                    "amount": {
                                      "total": widget.prix.toString(),
                                      "currency": widget.currency,
                                      "details": {
                                        "subtotal": widget.prix.toString(),
                                        "shipping": '0',
                                        "shipping_discount": 0
                                      }
                                    },
                                    "description":
                                        "The payment transaction description.",
                                    "item_list": {
                                      "items": [
                                        {
                                          "name": widget.hebergement.nom,
                                          "quantity": 1,
                                          "price": widget.prix.toString(),
                                          "currency": widget.currency
                                        }
                                      ],
                                    }
                                  }
                                ],
                                note:
                                    "Contact us for any questions on your order.",
                                onSuccess: (Map params) async {
                                  print("onSuccess: $params");
                                  Map<String, dynamic> paymentData = {
                                    "transactionId": params['data']['id'],
                                    "payerId": params['data']['payer']
                                        ['payer_info']['payer_id'],
                                    "currency": params['data']['transactions']
                                        [0]['amount']['currency'],
                                    "total": params['data']['transactions'][0]
                                        ['amount']['total'],
                                    "paymentStatus": params['data']['state'],
                                    "paymentMethod": params['data']['payer']
                                        ['payment_method'],
                                  };
                                  Reservation rv;

                                  if (widget.hebergement.categorie.idCat == 1) {
                                    rv = Reservation(
                                      dateCheckIn: widget.checkIn,
                                      dateCheckOut: widget.checkOut,
                                      prix: widget.prix,
                                      etat: 'PENDING',
                                      currency: widget.currency,
                                      nbRooms: widget.nbRooms,
                                      rooms: widget.roomIds,
                                    );
                                  } else {
                                    rv = Reservation(
                                      dateCheckIn: widget.checkIn,
                                      dateCheckOut: widget.checkOut,
                                      prix: widget.prix,
                                      etat: 'PENDING',
                                      currency: widget.currency,
                                    );
                                  }
                                  Reservation? r = await ReservationService()
                                      .ajouterReservation(rv, widget.user.id,
                                          widget.hebergement.hebergementId);

                                  Payment payment = Payment(
                                    transactionId: paymentData['transactionId'],
                                    payerId: paymentData['payerId'],
                                    currency: paymentData['currency'],
                                    total: double.parse(paymentData['total']),
                                    paymentStatus: paymentData['paymentStatus'],
                                    paymentMethod: paymentData['paymentMethod'],
                                  );
                                  print("hhhhhhhhhhhhhhhhhhhhhhhh");
                                  print(r!.id!);
                                  await PayementService()
                                      .addPayment(payment, r!.id!);
                                  setState(() {
                                    success = true;
                                  });
                                  NotificationMessage newNotification =
                                      NotificationMessage(
                                    title: "You have a new booking",
                                    date: DateTime.now(),
                                    seen: false,
                                    type: NotificationType.BOOKING,
                                  );

                                  try {
                                    await NotificationService()
                                        .sendNotificationToPerson(
                                            newNotification,
                                            widget
                                                .hebergement!.person.personId!);
                                  } catch (e) {
                                    print('Failed to send notification: $e');
                                  }
                                },
                                onError: (error) {
                                  print("onError: $error");
                                  Navigator.pop(context);
                                },
                                onCancel: () {
                                  print('cancelled:');
                                },
                              ),
                            ),
                          );
                        },
                        child: _buildPaymentMethodContainer(
                          'assets/payementPaypal.png',
                          'PayPal',
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          generatePayment();
                        },
                        child: _buildPaymentMethodContainer(
                            'assets/payementFlouci.png', 'Flouci'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(12),
              backgroundColor: Colors.blue[900],
            ),
            child: Text('Book',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'AbrilFatface',
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodContainer(String imagePath, String methodName) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          methodName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStep(currentStep >= 0, '1'),
          _buildLine(currentStep > 0),
          _buildStep(currentStep > 0, '2'),
          _buildLine(currentStep > 1),
          _buildStep(currentStep > 1, '✔'),
        ],
      ),
    );
  }

  Widget _buildStep(bool isActive, String text) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isActive ? Colors.blue[900] : Colors.grey[300],
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? Colors.blue[900] : Colors.grey[300],
      ),
    );
  }
}
