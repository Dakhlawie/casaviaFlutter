import 'package:casavia/Screens/core/reservationfinal.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReservationSecondStep extends StatefulWidget {
  final Hebergement hebergement;
  final String checkIn;
  final String checkOut;
  final double prix;
  final String currency;
  final User user;
  final int nbRooms;
  final List<int> roomIds;

  const ReservationSecondStep(
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
  State<ReservationSecondStep> createState() => _ReservationSecondStepState();
}

class _ReservationSecondStepState extends State<ReservationSecondStep> {
  int currentStep = 1;
  String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'CAD':
        return 'CA\$';
      case 'CHF':
        return 'CHF';
      case 'AUD':
        return 'A\$';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'SEK':
        return 'kr';
      case 'BRL':
        return 'R\$';
      case 'TRY':
        return '₺';
      case 'AED':
        return 'د.إ';
      case 'AFN':
        return '؋';
      case 'ALL':
        return 'Lek';
      case 'TND':
        return 'DT';
      case 'AMD':
        return '֏';

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    int nbEtoile = int.tryParse(widget.hebergement.nbEtoile.toString()) ?? 0;
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
            _buildStepIndicator(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your Booking Overview",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'AbrilFatface',
                        fontSize: 20,
                      )),
                  SizedBox(height: 30),
                  Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                          image: DecorationImage(
                            image:
                                MemoryImage(widget.hebergement.images[0].image),
                            fit: BoxFit.fill,
                          ),
                        ),
                        height: 200,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.hebergement.nom,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'AbrilFatface',
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  '4.0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.hebergement.ville} ${widget.hebergement.pays}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                Icon(Icons.location_on,
                                    size: 12, color: Colors.grey[600]),
                                Text(
                                  ' 20 km',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Spacer(),
                                for (int i = 0; i < nbEtoile; i++)
                                  Icon(Icons.star,
                                      size: 12, color: Colors.blue[900]),
                              ],
                            ),
                            Divider(
                              color: Colors.grey,
                              thickness: 1,
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Start Date',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(widget.checkIn),
                                  ],
                                ),
                                SizedBox(width: 50),
                                Container(
                                  height: 30,
                                  child: VerticalDivider(
                                    width: 20,
                                    thickness: 1,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                SizedBox(width: 30),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'End Date',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(widget.checkOut),
                                  ],
                                ),
                              ],
                            ),
                            widget.hebergement.categorie.idCat == 1
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Divider(
                                        color: Colors.grey,
                                        thickness: 1,
                                        height: 20,
                                      ),
                                      Text(
                                        'You selected',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                          '${widget.nbRooms} ${widget.nbRooms > 1 ? "Rooms" : "Room"}'),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'AbrilFatface',
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '${getCurrencySymbol(widget.currency)} ${widget.prix}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Personnel Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'AbrilFatface',
                            fontSize: 20,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'First Name',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.user.nom,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Last Name',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.user.prenom,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.user.email,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Phone',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.user.tlf!,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Country',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.user.pays!,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Cancellation Policy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'AbrilFatface',
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.blue[900],
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    if (widget
                                            .hebergement.politiqueAnnulation ==
                                        'Free cancellation')
                                      TextSpan(
                                        text: 'Free cancellation',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      )
                                    else if (widget
                                            .hebergement.politiqueAnnulation ==
                                        'non refundable')
                                      TextSpan(
                                        text: 'Non refundable',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      )
                                    else if (widget
                                            .hebergement.politiqueAnnulation ==
                                        '48')
                                      TextSpan(
                                        text:
                                            'You can cancel your reservation free of charge up to 48 hours before the scheduled check-in time. Cancellations made within 48 hours of check-in will incur a fee equivalent to ${widget.hebergement.cancellationfees}.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      )
                                    else if (widget
                                            .hebergement.politiqueAnnulation ==
                                        '24')
                                      TextSpan(
                                        text:
                                            'You can cancel your reservation free of charge up to 24 hours before the scheduled check-in time. Cancellations made within 24 hours of check-in will incur a fee equivalent to ${widget.hebergement.cancellationfees}.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      )
                                    else if (widget
                                            .hebergement.politiqueAnnulation ==
                                        '72')
                                      TextSpan(
                                        text:
                                            'You can cancel your reservation free of charge up to 72 hours before the scheduled check-in time. Cancellations made within 72 hours of check-in will incur a fee equivalent to ${widget.hebergement.cancellationfees}.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: () {},
                  //     style: ElevatedButton.styleFrom(
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //       padding: EdgeInsets.all(12),
                  //       backgroundColor: Colors.blue[900],
                  //     ),
                  //     child: Text('Next',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontFamily: 'AbrilFatface',
                  //         )),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => FinalStepReservartion(
                            hebergement: widget.hebergement,
                            checkIn: widget.checkIn,
                            checkOut: widget.checkOut,
                            prix: widget.prix,
                            currency: widget.currency,
                            user: widget.user!,
                            nbRooms: widget.nbRooms,
                            roomIds: widget.roomIds,
                          )));
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(12),
              backgroundColor: Colors.blue[900],
            ),
            child: Text('NEXT',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'AbrilFatface',
                )),
          ),
        ),
      ),
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
