import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedTabIndex = 0;
  Widget _getBookingTabContent() {
    if (_selectedTabIndex == 0) {
      return UpcomingBookings();
    } else {
      return FinishedBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
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
                            Positioned(
                              top: -2,
                              right: -11,
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(220, 217, 66, 20),
                                  shape: BoxShape.circle,
                                ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedTabIndex == 0) ...[
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 16, bottom: 16, right: 8.0),
                        child: Text(
                          'You have 1 upcoming booking',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/hotel_room_4.jpg'), // Remplacez par votre chemin d'image
                                fit: BoxFit.cover,
                              ),
                            ),
                            height:
                                200, // Ajustez la hauteur selon votre besoin
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
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'City Hotel Murila',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'AbrilFatface',
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      '\$240',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Barcelona, Spain',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '/per night',
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
                                      '2 km to city',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Spacer(),
                                    for (int i = 0; i < 5; i++)
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Travel Date',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text('13 Nov - 18 Nov'),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Number of Rooms',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text('1 Room - 2 People'),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        child: Text('Change booking'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.blue[900], // background
                                          foregroundColor: Colors.white,
                                          side:
                                              BorderSide.none, // Aucune bordure
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          // foreground
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {},
                                        child: Text('Cancel booking'),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.grey[200],
                                          foregroundColor: Colors.black,
                                          side: BorderSide.none,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpcomingBookings extends StatefulWidget {
  @override
  _UpcomingBookingsState createState() => _UpcomingBookingsState();
}

class _UpcomingBookingsState extends State<UpcomingBookings> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('You have 1 upcoming booking'),
        ),
        Card(
          child: Column(
            children: [
              Image.asset('assets/hotel_2.png'),
              ListTile(
                title: Text('City Hotel Murila'),
                subtitle: Text('Barcelona, Spain'),
                trailing: Text('\$240 / per night'),
              ),
              Row(
                children: [],
              ),
              ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Change booking'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Cancel booking'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FinishedBookings extends StatefulWidget {
  @override
  _FinishedBookingsState createState() => _FinishedBookingsState();
}

class _FinishedBookingsState extends State<FinishedBookings> {
  List<String> finishedBookings = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: finishedBookings.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(finishedBookings[index]),
            subtitle: Text('Date de séjour'),
            trailing: Icon(Icons.check, color: Colors.green),
          ),
        );
      },
    );
  }
}
