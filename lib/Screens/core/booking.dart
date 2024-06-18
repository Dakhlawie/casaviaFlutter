import 'package:casavia/Screens/core/rate.dart';
import 'package:casavia/Screens/core/update_reservation.dart';
import 'package:casavia/model/notification.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/ReservationService.dart';
import 'package:casavia/services/notificationService.dart';
import 'package:casavia/services/payementService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:casavia/model/user.dart';
import 'package:flutter_svg/svg.dart';
import 'package:casavia/model/reservation.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Future<List<Reservation>> pendingOrConfirmedReservations =
      Future.value([]);
  late Future<List<Reservation>> completedReservations = Future.value([]);
  ReservationService reservationService = ReservationService();

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
      setState(() {
        pendingOrConfirmedReservations =
            reservationService.getPendingOrConfirmedReservationsByUser(userId);
        completedReservations =
            reservationService.getCompletedReservationsByUser(userId);
      });
    }
    print('USERID');
    print(userId);
  }

  void _updateReservations(int userId) {
    pendingOrConfirmedReservations =
        reservationService.getPendingOrConfirmedReservationsByUser(userId);
    completedReservations =
        reservationService.getCompletedReservationsByUser(userId);
  }

  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'My Bookings',
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 30.0,
                  fontFamily: 'AbrilFatface',
                ),
              ),
              SizedBox(height: 40),
              Container(
                height: 60,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 0;
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Text(
                            'Upcoming',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedTabIndex == 0
                                  ? Colors.black
                                  : Colors.grey,
                              fontWeight: _selectedTabIndex == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 60),
                    Container(
                      height: 30,
                      child: VerticalDivider(
                        width: 20,
                        thickness: 1,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(width: 60),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 1;
                        });
                      },
                      child: Text(
                        'Finished',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedTabIndex == 1
                              ? Colors.black
                              : Colors.grey,
                          fontWeight: _selectedTabIndex == 1
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: _selectedTabIndex == 0
                    ? UpcomingBookings(
                        futureReservations: pendingOrConfirmedReservations,
                        onUpdate: () {
                          int? userId =
                              Provider.of<UserModel>(context, listen: false)
                                  .userId;
                          if (userId != null) {
                            setState(() {
                              _updateReservations(userId);
                            });
                          }
                        },
                      )
                    : FinishedBookings(
                        futureReservations: completedReservations),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpcomingBookings extends StatelessWidget {
  final Future<List<Reservation>> futureReservations;
  final VoidCallback onUpdate;
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

  UpcomingBookings({required this.futureReservations, required this.onUpdate});

  void _cancelBooking() {
    PayementService()
        .refundPayment('PAYID-MZRZKQQ5PP11559F88231839', 200, 'EUR');
  }

  Color _getBadgeColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.blue[900]!;
      case 'CONFIRMED':
        return Colors.green;
      case 'UPDATED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> cancelReservation(
      Reservation reservation, BuildContext context) async {
    reservation.etat = 'CANCELED';
    await ReservationService().annulerReservation(reservation.id!);

    NotificationMessage newNotification = NotificationMessage(
      title: "Reservation Cancelled",
      date: DateTime.now(),
      seen: false,
      type: NotificationType.BOOKING,
    );

    try {
      await NotificationService().sendNotificationToPerson(
          newNotification, reservation.hebergement!.person.personId!);
    } catch (e) {
      print('Failed to send notification: $e');
    }

    onUpdate();
    Navigator.pop(context);
    _showCustomSuccessDialog(context);
  }

  void _showCustomSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue[900],
                    size: 40.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Reservation cancelled !',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AbrilFatface',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                'Your reservation has been cancelled ',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCancelBooking(
      BuildContext context, Reservation reservation) async {
    final cancellationPolicy = reservation.hebergement!.politiqueAnnulation;
    final checkInDate = DateFormat('dd/MM/yyyy').parse(reservation.dateCheckIn);
    final now = DateTime.now();
    final hoursUntilCheckIn = checkInDate.difference(now).inHours;

    if (cancellationPolicy == 'non refundable') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 40.0,
            ),
            SizedBox(width: 10),
            Text(
              'Reminder',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'AbrilFatface',
              ),
            )
          ]),
          content: Text('The amount paid will not be refunded.'),
          actions: [
            TextButton(
              onPressed: () async {
                cancelReservation(reservation, context);
              },
              child: Text('Proceed'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else if (cancellationPolicy == 'Free cancellation') {
      cancelReservation(reservation, context);
    } else {
      int policyHours;
      if (cancellationPolicy == '72') {
        policyHours = 72;
      } else if (cancellationPolicy == '48') {
        policyHours = 48;
      } else if (cancellationPolicy == '24') {
        policyHours = 24;
      } else {
        policyHours = 0;
      }

      if (hoursUntilCheckIn <= policyHours) {
        final cancellationFees = reservation.hebergement!.cancellationfees;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(children: [
              Icon(
                Icons.error,
                color: Colors.red,
                size: 40.0,
              ),
              SizedBox(width: 10),
              Text(
                'Reminder',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AbrilFatface',
                ),
              ),
            ]),
            content: Text(
                'If you cancel your reservation now, a cancellation fee of $cancellationFees will be applied.'),
            actions: [
              TextButton(
                onPressed: () async {
                  cancelReservation(reservation, context);
                },
                child: Text('Proceed'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      } else {
        cancelReservation(reservation, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reservation>>(
      future: futureReservations,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/reservation.svg',
                    height: 200.0,
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'No upcoming bookings',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AbrilFatface',
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final reservation = snapshot.data![index];
              int? nbEtoiles;
              if (reservation.hebergement!.categorie.idCat == 1) {
                nbEtoiles = int.parse(reservation.hebergement!.nbEtoile);
              }
              return Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                          image: DecorationImage(
                            image: MemoryImage(
                                reservation.hebergement!.images[0].image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        height: 200,
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(reservation.etat),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            reservation.etat,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                              reservation.hebergement!.nom,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'AbrilFatface',
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '${getCurrencySymbol(reservation.currency)}${reservation.prix}',
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
                              '${reservation.hebergement!.ville}, ${reservation.hebergement!.pays}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            Visibility(
                              visible:
                                  reservation.hebergement!.categorie!.idCat ==
                                      1,
                              child: Text(
                                '${reservation.nbRooms} Room',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
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
                              reservation.hebergement!.distance,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            Spacer(),
                            if (reservation.hebergement!.categorie.idCat == 1)
                              for (int i = 0; i < nbEtoiles!; i++)
                                Visibility(
                                  visible: reservation
                                          .hebergement!.categorie!.idCat ==
                                      1,
                                  child: Icon(Icons.star,
                                      size: 12, color: Colors.blue[900]),
                                ),
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
                                Text(reservation.dateCheckIn),
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
                                Text(reservation.dateCheckOut),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateReservationPage(
                                        reservation: reservation,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Change booking'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[900],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _handleCancelBooking(context, reservation);
                                },
                                child: Text('Cancel booking'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              );
            },
          );
        }
      },
    );
  }
}

class FinishedBookings extends StatelessWidget {
  final Future<List<Reservation>> futureReservations;

  FinishedBookings({required this.futureReservations});
  List<bool?> hasLeftReviewList = [];

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
    return FutureBuilder<List<Reservation>>(
      future: futureReservations,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No reservations found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final reservation = snapshot.data![index];
              int? nbEtoiles;
              if (reservation.hebergement!.categorie.idCat == 1) {
                nbEtoiles = int.parse(reservation.hebergement!.nbEtoile);
              }
              return Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 120,
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: MemoryImage(
                                  reservation.hebergement!.images[0].image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    reservation.hebergement!.nom,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'AbrilFatface',
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${reservation.hebergement!.ville}, ${reservation.hebergement!.pays}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${getCurrencySymbol(reservation.currency)}${reservation.prix}',
                                style: TextStyle(),
                              ),
                              SizedBox(height: 10),
                              Visibility(
                                visible:
                                    reservation.hebergement!.categorie!.idCat ==
                                        1,
                                child: Text(
                                  '${reservation.nbRooms} Room',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Divider(
                                color: Colors.grey,
                                thickness: 1,
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Start Date',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(reservation.dateCheckIn),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'End Date',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(reservation.dateCheckOut),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              );
            },
          );
        }
      },
    );
  }
}
