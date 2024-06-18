import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  double _price = 100;
  double _distance = 5.0;
  bool _freeBreakfast = true;
  bool _pool = true;
  bool _freeWifi = false;
  bool _freeParking = false;
  bool _apartment = true;
  bool _home = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
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
                'Filtter',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              SizedBox(height: 16),
              Text(
                'Price (for 1 night)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Slider(
                activeColor: Colors.blue[900],
                value: _price,
                min: 100,
                max: 1000,
                onChanged: (value) {
                  setState(() {
                    _price = value;
                  });
                },
                divisions: 18,
                label: '$_price\$',
              ),
              Divider(),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('Breakfast'),
                      value: _freeBreakfast,
                      onChanged: (value) {
                        setState(() {
                          _freeBreakfast = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.blue[900],
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('Pool'),
                      value: _pool,
                      onChanged: (value) {
                        setState(() {
                          _pool = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.blue[900],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text(' Wifi'),
                      value: _freeWifi,
                      onChanged: (value) {
                        setState(() {
                          _freeWifi = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.blue[900],
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text(' Parking'),
                      value: _freeParking,
                      onChanged: (value) {
                        setState(() {
                          _freeParking = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.blue[900],
                    ),
                  ),
                ],
              ),
              Divider(),
              Text(
                'Distance from city',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Slider(
                activeColor: Colors.blue[900],
                value: _distance,
                min: 0,
                max: 20,
                onChanged: (value) {
                  setState(() {
                    _distance = value;
                  });
                },
                divisions: 20,
                label: '${_distance.toStringAsFixed(1)} km',
              ),
              Divider(),
              Text(
                'Type of Accommodation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              CheckboxListTile(
                title: Text('All'),
                value: _apartment && _home,
                onChanged: (value) {
                  setState(() {
                    _apartment = value!;
                    _home = value;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: Colors.blue[900],
              ),
              CheckboxListTile(
                title: Text('Apartment'),
                value: _apartment,
                onChanged: (value) {
                  setState(() {
                    _apartment = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: Colors.blue[900],
              ),
              CheckboxListTile(
                title: Text('Home'),
                value: _home,
                onChanged: (value) {
                  setState(() {
                    _home = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: Colors.blue[900],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
