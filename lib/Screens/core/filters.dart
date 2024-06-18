import 'package:flutter/material.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  double _price = 100;
  double _distance = 5.0;
  bool _freeBreakfast = true;
  bool _pool = true;
  bool _freeWifi = false;
  bool _freeParking = false;
  bool _apartment = false;
  bool _home = false;
  bool _hotel = false;
  bool _villa = false;
  bool _fair = false;
  bool _pleasant = false;
  bool _good = false;
  bool _veryGood = false;
  bool _wonderful = false;
  bool _freeCancellation = false;
  bool _work = false;
  bool _leisure = false;
  bool _oneBedroom = false;
  bool _twoBedrooms = false;
  bool _threeBedrooms = false;
  bool _fourBedrooms = false;
  bool _showFilters = false;
  List<bool> _starSelections = [false, false, false, false, false];
  void _selectCategory(String category) {
    setState(() {
      _resetFilters();
      _hotel = category == 'Hotel';
      _apartment = category == 'Apartment';
      _villa = category == 'Villa';
    });
  }

  void _resetFilters() {
    _price = 100;
    _distance = 5.0;
    _freeBreakfast = true;
    _pool = true;
    _freeWifi = false;
    _freeParking = false;
    _fair = false;
    _pleasant = false;
    _good = false;
    _veryGood = false;
    _wonderful = false;
    _freeCancellation = false;
    _work = false;
    _leisure = false;
    _oneBedroom = false;
    _twoBedrooms = false;
    _threeBedrooms = false;
    _fourBedrooms = false;
    _starSelections = [false, false, false, false, false];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryButton('Hotel', Icons.hotel, _hotel, () {
                      _selectCategory('Hotel');
                    }),
                    _buildCategoryButton('Villa', Icons.villa, _villa, () {
                      _selectCategory('Villa');
                    }),
                    _buildCategoryButton(
                        'Apartment', Icons.apartment, _apartment, () {
                      _selectCategory('Apartment');
                    }),
                  ],
                ),
                if (_hotel) ...[
                  SizedBox(height: 40),
                  Text(
                    'Price (for 1 night)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  SizedBox(height: 20),
                  Text(
                    'Review Score',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  CheckboxListTile(
                    title: Text('Fair: 1 or more /5'),
                    value: _fair,
                    onChanged: (bool? value) {
                      setState(() {
                        _fair = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Pleasant: 2 or more /5'),
                    value: _pleasant,
                    onChanged: (bool? value) {
                      setState(() {
                        _pleasant = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Good : 3 or more /5'),
                    value: _good,
                    onChanged: (bool? value) {
                      setState(() {
                        _good = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Very Good : 4 or more /5'),
                    value: _veryGood,
                    onChanged: (bool? value) {
                      setState(() {
                        _veryGood = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Wonderful : 5 or more /5'),
                    value: _wonderful,
                    onChanged: (bool? value) {
                      setState(() {
                        _wonderful = value!;
                      });
                    },
                  ),
                  Divider(),
                  SizedBox(height: 20),
                  Text(
                    'Rating',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  _buildStarCheckboxes(),
                  Divider(),
                  SizedBox(height: 20),
                  Text(
                    'Free Cancellation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  CheckboxListTile(
                    title: Text('Free Cancellation'),
                    value: _freeCancellation,
                    onChanged: (bool? value) {
                      setState(() {
                        _freeCancellation = value!;
                      });
                    },
                  ),
                  Divider(),
                  SizedBox(height: 20),
                  Text(
                    'Purpose',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  CheckboxListTile(
                    title: Text('Work'),
                    value: _work,
                    onChanged: (bool? value) {
                      setState(() {
                        _work = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Leisure'),
                    value: _leisure,
                    onChanged: (bool? value) {
                      setState(() {
                        _leisure = value!;
                      });
                    },
                  ),
                  SizedBox(height: 40),
                ],
                if (_villa || _apartment) ...[
                  SizedBox(height: 40),
                  Text(
                    'Price (for 1 night)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  SizedBox(height: 20),
                  Text(
                    'Review Score',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  CheckboxListTile(
                    title: Text('Fair: 1 or more /5'),
                    value: _fair,
                    onChanged: (bool? value) {
                      setState(() {
                        _fair = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Pleasant: 2 or more /5'),
                    value: _pleasant,
                    onChanged: (bool? value) {
                      setState(() {
                        _pleasant = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Good : 3 or more /5'),
                    value: _good,
                    onChanged: (bool? value) {
                      setState(() {
                        _good = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Very Good : 4 or more /5'),
                    value: _veryGood,
                    onChanged: (bool? value) {
                      setState(() {
                        _veryGood = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Wonderful : 5 or more /5'),
                    value: _wonderful,
                    onChanged: (bool? value) {
                      setState(() {
                        _wonderful = value!;
                      });
                    },
                  ),
                  Divider(),
                  SizedBox(height: 20),
                  Text(
                    'Free Cancellation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  CheckboxListTile(
                    title: Text('Free Cancellation'),
                    value: _freeCancellation,
                    onChanged: (bool? value) {
                      setState(() {
                        _freeCancellation = value!;
                      });
                    },
                  ),
                  Divider(),
                  SizedBox(height: 20),
                  Text(
                    'Number of bedrooms',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  CheckboxListTile(
                    title: Text('1+ bedrooms'),
                    value: _oneBedroom,
                    onChanged: (bool? value) {
                      setState(() {
                        _oneBedroom = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('2+ bedrooms'),
                    value: _twoBedrooms,
                    onChanged: (bool? value) {
                      setState(() {
                        _twoBedrooms = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('3+ bedrooms'),
                    value: _threeBedrooms,
                    onChanged: (bool? value) {
                      setState(() {
                        _threeBedrooms = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('4+ bedrooms'),
                    value: _fourBedrooms,
                    onChanged: (bool? value) {
                      setState(() {
                        _fourBedrooms = value!;
                      });
                    },
                  ),
                  SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: SizedBox(
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
        ));
  }

  Widget _buildCategoryButton(
      String title, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, // Fixed width
        height: 100, // Fixed height
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? Colors.blue[100] : Colors.white,
          border: Border.all(
            color: selected ? Color.fromARGB(255, 100, 184, 223) : Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue[900]),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarCheckboxes() {
    return Column(
      children: List.generate(5, (index) {
        return CheckboxListTile(
          title: Row(
            children: List.generate(5, (starIndex) {
              return Icon(
                starIndex <= index ? Icons.star : Icons.star_border,
                color: starIndex <= index ? Colors.blue[900] : Colors.grey,
              );
            }),
          ),
          value: _starSelections[index],
          onChanged: (bool? value) {
            setState(() {
              _starSelections[index] = value!;
            });
          },
        );
      }),
    );
  }
}
