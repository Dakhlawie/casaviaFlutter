import 'package:casavia/Screens/core/acommodation.dart';
import 'package:casavia/model/animator.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Whishlists extends StatefulWidget {
  final List<Hebergement> hebergements;
  final String country;
  const Whishlists(
      {Key? key, required this.hebergements, required this.country})
      : super(key: key);

  @override
  State<Whishlists> createState() => _WhishlistsState();
}

class _WhishlistsState extends State<Whishlists> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.separated(
        itemCount: widget.hebergements.length,
        separatorBuilder: (context, index) => SizedBox(height: 5),
        itemBuilder: (context, index) {
          Hebergement hebergement = widget.hebergements[index];
          return Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  DateTime today = DateTime.now();

                  DateTime tomorrow = today.add(Duration(days: 1));

                  DateTime dayAfterTomorrow = today.add(Duration(days: 2));

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AcommodationPage(
                        hebergement: hebergement,
                        // Passez les valeurs calculées de checkIn et checkOut
                        checkIn: DateFormat('dd/MM/yyyy').format(tomorrow),
                        checkOut:
                            DateFormat('dd/MM/yyyy').format(dayAfterTomorrow),
                      ),
                    ),
                  );
                },
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(10)),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: HebergementImageAnimator(
                              hebergement: hebergement),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${hebergement.nom}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("${hebergement.pays}, ${hebergement.ville}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
