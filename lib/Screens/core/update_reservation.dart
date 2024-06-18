import 'dart:typed_data';

import 'package:casavia/Screens/core/availableRooms.dart';
import 'package:casavia/model/chambre.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/notification.dart';
import 'package:casavia/model/reservation.dart';
import 'package:casavia/services/ChambresServices.dart';
import 'package:casavia/services/HebergementService.dart';
import 'package:casavia/services/ReservationService.dart';
import 'package:casavia/services/notificationService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class UpdateReservationPage extends StatefulWidget {
  final Reservation reservation;
  const UpdateReservationPage({super.key, required this.reservation});

  @override
  State<UpdateReservationPage> createState() => _UpdateReservationPageState();
}

class _UpdateReservationPageState extends State<UpdateReservationPage> {
  Hebergement? convertedHebergement;
  ChambresServices chambreServ = ChambresServices();
  HebergementService _hebergementService = HebergementService();
  List<Map<String, dynamic>> roomDetails = [];
  late TextEditingController _checkInController;
  late TextEditingController _checkOutController;
  List<Chambre> chambres = [];
  @override
  void initState() {
    super.initState();
    _convertHebergementPrices();
    _fetchRoomDetails();

    _checkInController =
        TextEditingController(text: widget.reservation.dateCheckIn);
    _checkOutController =
        TextEditingController(text: widget.reservation.dateCheckOut);
  }

  Future<void> _convertHebergementPrices() async {
    try {
      convertedHebergement = await _hebergementService.convertHebergement(
          widget.reservation.hebergement!, widget.reservation.currency);
      setState(() {
        widget.reservation.hebergement = convertedHebergement;
      });
      _fetchRoomDetails();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to convert hebergement prices: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
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

  void _showPaymentMethodDialog(BuildContext context, double totalAmount,
      double amountToPay, String currencySymbol) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Payment Method',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'The total reservation cost is $currencySymbol${totalAmount.toStringAsFixed(2)}. You will need to pay an additional $currencySymbol${amountToPay.toStringAsFixed(2)}.',
                style: TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPaymentMethodContainer(
                      'assets/payementFlouci.png', 'Flouci'),
                  _buildPaymentMethodContainer(
                      'assets/payementPaypal.png', 'PayPal'),
                ],
              ),
              SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdateBooking() async {
    print('hi');
    String checkIn = _checkInController.text;
    String checkOut = _checkOutController.text;

    try {
      DateTime checkInDate = DateFormat('dd/MM/yyyy').parse(checkIn);
      DateTime checkOutDate = DateFormat('dd/MM/yyyy').parse(checkOut);
      int numberOfNights = checkOutDate.difference(checkInDate).inDays;
      double previousPrice = widget.reservation.prix;
      double totalPrice = 0.0;

      if (widget.reservation.hebergement!.categorie.idCat != 1) {
        bool isAvailable =
            await _hebergementService.checkAvailabilityHebergement(
                widget.reservation.hebergement!.hebergementId,
                checkIn,
                checkOut);
        if (isAvailable) {
          totalPrice = convertedHebergement!.prix * numberOfNights;
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content:
                  Text('Selected dates are not available for the hebergement.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
      } else {
        print('hello');
        List<int> updatedRooms = [];
        List<String> availabilityErrors = [];

        for (var detail in roomDetails) {
          int count = detail['number'] ?? 0;
          int roomId = detail['roomId'];
          int availableRooms = await _hebergementService.getAvailableRooms(
              roomId, checkIn, checkOut);

          if (count > availableRooms) {
            availabilityErrors.add(
                'Only $availableRooms rooms left for the type ${detail['type']} for the selected dates.');
          } else {
            double roomPrice = detail['price'] ?? 0.0;
            totalPrice += roomPrice * count * numberOfNights;

            for (int i = 0; i < count; i++) {
              updatedRooms.add(roomId);
            }
          }
        }

        if (availabilityErrors.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    availabilityErrors.map((error) => Text(error)).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
          return;
        }

        widget.reservation.rooms = updatedRooms;
        widget.reservation.nbRooms = updatedRooms.length;
      }

      if (totalPrice > previousPrice) {
        _showPaymentMethodDialog(context, totalPrice,
            totalPrice - previousPrice, widget.reservation.currency);
      } else {
        Reservation rv = Reservation(
          dateCheckIn: checkIn,
          dateCheckOut: checkOut,
          prix: totalPrice,
          currency: widget.reservation.currency,
          etat: "UPDATED",
          nbRooms: widget.reservation.nbRooms,
          rooms: widget.reservation.rooms,
        );
        await ReservationService()
            .updateReservation(widget.reservation.id!, rv);
        NotificationMessage newNotification = NotificationMessage(
          title: "Reservation Updated",
          date: DateTime.now(),
          seen: false,
          type: NotificationType.BOOKING,
        );

        try {
          await NotificationService().sendNotificationToPerson(newNotification,
              widget.reservation.hebergement!.person.personId!);
        } catch (e) {
          print('Failed to send notification: $e');
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Reservation updated successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to update reservation: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> filterAvailableRooms() async {
    List<Chambre> availableRooms = [];
    List<List<int>> images = [];

    for (var chambre in widget.reservation.hebergement!.chambres!) {
      bool isAvailable = await _hebergementService.checkAvailability(
          chambre.chambreId, _checkInController.text, _checkOutController.text);
      if (isAvailable) {
        availableRooms.add(chambre);
        List<int>? imageBytes = await _hebergementService
            .getImageBytesForChambre(chambre.chambreId);
        images.add(imageBytes ?? []);
      }
    }

    setState(() {
      this.chambres = availableRooms;
      this.images = images;
    });
  }

  List<List<int>> images = [];

  void _showCalendarDialog(
      BuildContext context, TextEditingController controller, bool isCheckIn) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  isCheckIn ? 'Check In' : 'Check Out',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'AbrilFatface',
                  ),
                ),
              ),
              TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    controller.text =
                        DateFormat('dd/MM/yyyy').format(selectedDay);
                  });
                  Navigator.pop(context);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue[900],
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue[900],
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Center(
                    child: Text('Apply'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchRoomDetails() async {
    // Check if the category is 1 (hotel)
    if (widget.reservation.hebergement!.categorie.idCat != 1) {
      return;
    }

    List<Map<String, dynamic>> details = [];

    for (int roomId in widget.reservation.rooms ?? []) {
      Chambre chambre = await chambreServ.getChambreById(roomId);
      Chambre? convertedChambre = convertedHebergement?.chambres?.firstWhere(
        (c) => c.chambreId == chambre.chambreId,
        orElse: () => chambre,
      );

      Map<String, dynamic> roomDetail = {
        'roomId': roomId,
        'type': chambre.type,
        'view': chambre.view,
        'floor': chambre.floor,
        'price': convertedChambre?.prix ?? chambre.prix,
        'number': 1,
      };

      int existingIndex = details.indexWhere((detail) =>
          detail['type'] == chambre.type &&
          detail['view'] == chambre.view &&
          detail['floor'] == chambre.floor);

      if (existingIndex != -1) {
        details[existingIndex]['number']++;
      } else {
        details.add(roomDetail);
      }
    }

    setState(() {
      roomDetails = details;
    });
  }

  void updateRoomCount(int index, int change) {
    setState(() {
      int currentValue = roomDetails[index]['number'] ?? 1;
      int newValue = currentValue + change;
      if (newValue > 0) {
        roomDetails[index]['number'] = newValue;
      }
    });
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update your booking',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AbrilFatface',
                ),
              ),
              SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Stack(
                  children: [
                    Image.memory(
                        widget.reservation.hebergement!.images[0].image),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Text(
                        widget.reservation.hebergement!.nom,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AbrilFatface',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reservation Number',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'AbrilFatface',
                    ),
                  ),
                  Text(
                    widget.reservation.numeroReservation!,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(height: 10),
              Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.grey[600]),
                              onPressed: () {
                                _showCalendarDialog(
                                    context, _checkInController, true);
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Start Date',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(_checkInController.text),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: 30,
                      child: VerticalDivider(
                        width: 20,
                        thickness: 1,
                        color: Colors.grey[400],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.grey[600]),
                              onPressed: () {
                                _showCalendarDialog(
                                    context, _checkOutController, false);
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'End Date',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(_checkOutController.text),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
              ),
              SizedBox(height: 16),
              if (widget.reservation.hebergement!.categorie.idCat == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rooms',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'AbrilFatface',
                      ),
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.add, color: Colors.blue[900]),
                    //   onPressed: () async {
                    //     _selectRoom(context);
                    //   },
                    // ),
                  ],
                ),
              if (widget.reservation.hebergement!.categorie.idCat == 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: DataTable(
                      columnSpacing: 32.0,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Type',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Number',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        DataColumn(
                          label: Text('Actions'),
                        ),
                      ],
                      rows: List<DataRow>.generate(
                        roomDetails.length,
                        (index) => DataRow(
                          cells: <DataCell>[
                            DataCell(
                                Text(roomDetails[index]['type'].toString())),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove,
                                        color: roomDetails[index]['number'] == 1
                                            ? Colors.grey
                                            : Colors.blue),
                                    onPressed: roomDetails[index]['number'] == 1
                                        ? null
                                        : () {
                                            updateRoomCount(index, -1);
                                          },
                                  ),
                                  Text((roomDetails[index]['number'] ?? 0)
                                      .toString()),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      updateRoomCount(index, 1);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            DataCell(IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  roomDetails.removeAt(index);
                                });
                              },
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _handleUpdateBooking();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(12),
              backgroundColor: Colors.blue[900],
            ),
            child: Text('Update Booking',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'AbrilFatface',
                )),
          ),
        ),
      ),
    );
  }
}
