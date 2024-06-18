import 'package:casavia/Screens/core/acommodation.dart';
import 'package:casavia/Screens/core/filter.dart';
import 'package:casavia/Screens/core/filters.dart';
import 'package:casavia/model/animator.dart';
import 'package:casavia/model/categorie.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/services/CategorieService.dart';
import 'package:casavia/services/HebergementService.dart';
import 'package:casavia/widgets/custom_button.dart';
import 'package:casavia/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class ListAcommodation extends StatefulWidget {
  final String ville;
  final String checkIn;
  final String checkOut;
  const ListAcommodation(
      {super.key,
      required this.ville,
      required this.checkIn,
      required this.checkOut});
  @override
  State<ListAcommodation> createState() => _ListAcommodationState();
}

class _ListAcommodationState extends State<ListAcommodation> {
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
        return 'TND';
      case 'AMD':
        return '֏';

      default:
        return '';
    }
  }

  List<bool> _starSelections = [false, false, false, false, false];
  double _price = 500;
  bool _fair = false;
  bool _pleasant = false;
  bool _good = false;
  bool _veryGood = false;
  bool _wonderful = false;
  bool _freeCancellation = false;
  bool _freeCancellationApartement = false;
  bool _work = false;
  bool _leisure = false;
  bool _oneBedroom = false;
  bool _twoBedrooms = false;
  bool _threeBedrooms = false;
  bool _fourBedrooms = false;
  double _minPrice = 20;
  double _maxPrice = 600;
  double min = 20;
  double max = 600;
  int _selectedOption = 0;
  int _selectedOptionApartement = 0;
  int _selectedOptionVilla = 0;
  RangeValues _currentRangeValues = RangeValues(20, 600);
  RangeValues rangeValues = RangeValues(20, 600);
  String currency = 'EUR';
  int? _selectedReviewScore;
  int? _selectedRating;
  String? _selectedPurpose;
  int? _reviewScore;
  int? _numberOfBedrooms;

  int? numberOfBedrooms;
  Future<void> _loadCurrencyAndConvertPrices() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCurrency = prefs.getString('selectedCurrency') ?? 'EUR';
    print(storedCurrency);
    if (storedCurrency != currency) {
      try {
        Map<String, double> convertedPrices = await HebergementService()
            .convertPriceRange(_minPrice, _maxPrice, currency, storedCurrency);
        setState(() {
          _minPrice = convertedPrices['convertedMinPrice']!;
          _maxPrice = convertedPrices['convertedMaxPrice']!;
          min = convertedPrices['convertedMinPrice']!;
          max = convertedPrices['convertedMaxPrice']!;
          _currentRangeValues = RangeValues(_minPrice, _maxPrice);
          rangeValues = RangeValues(min, max);
          currency = storedCurrency;
          print(_minPrice);
          print(_maxPrice);
          print(_currentRangeValues);
        });
      } catch (e) {
        print('Failed to convert prices: $e');
      }
    }
  }

  void _showFilterVillaDialog() {
    String currencySymbol = getCurrencySymbol(currency);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: MediaQuery.of(context).size.height *
                0.5, // Set height to half the screen
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ' ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Price (for 1 night)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _maxPrice,
                    min: _minPrice,
                    max: max,
                    divisions: 100,
                    activeColor: Colors.blue[900],
                    label: '${currencySymbol}${_maxPrice.round()}',
                    onChanged: (double value) {
                      setState(() {
                        _maxPrice = value;
                        print(_maxPrice);
                      });
                    },
                  ),
                  Divider(),
                  SizedBox(height: 20),
                  Text(
                    'Review Score',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  RadioListTile<int>(
                    title: Text('Poor: 1 or more /5'),
                    value: 1,
                    groupValue: _reviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _reviewScore = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Fair: 2 or more /5'),
                    value: 2,
                    groupValue: _reviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _reviewScore = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Good: 3 or more /5'),
                    value: 3,
                    groupValue: _reviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _reviewScore = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Very Good: 4 or more /5'),
                    value: 4,
                    groupValue: _reviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _reviewScore = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Excellent: 5 or more /5'),
                    value: 5,
                    groupValue: _reviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _reviewScore = value!;
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
                    value: _freeCancellationApartement,
                    onChanged: (bool? value) {
                      setState(() {
                        _freeCancellationApartement = value!;
                      });
                    },
                  ),
                  Divider(),
                  SizedBox(height: 20),
                  Text(
                    'Number of bedrooms',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  RadioListTile<int>(
                    title: Text('1+ bedrooms'),
                    value: 1,
                    groupValue: _numberOfBedrooms,
                    onChanged: (int? value) {
                      setState(() {
                        _numberOfBedrooms = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('2+ bedrooms'),
                    value: 2,
                    groupValue: _numberOfBedrooms,
                    onChanged: (int? value) {
                      setState(() {
                        _numberOfBedrooms = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('3+ bedrooms'),
                    value: 3,
                    groupValue: _numberOfBedrooms,
                    onChanged: (int? value) {
                      setState(() {
                        _numberOfBedrooms = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('4+ bedrooms'),
                    value: 4,
                    groupValue: _numberOfBedrooms,
                    onChanged: (int? value) {
                      setState(() {
                        _numberOfBedrooms = value!;
                      });
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await applyFiltersVilla();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
          );
        });
      },
    );
  }

  void _showFilterApartementDialog() {
    String currencySymbol = getCurrencySymbol(currency);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: MediaQuery.of(context).size.height *
                0.5, // Set height to half the screen
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ' ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Price (for 1 night)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _maxPrice,
                    min: _minPrice,
                    max: max,
                    divisions: 100,
                    activeColor: Colors.blue[900],
                    label: '${currencySymbol}${_maxPrice.round()}',
                    onChanged: (double value) {
                      setState(() {
                        _maxPrice = value;
                        print(_maxPrice);
                      });
                    },
                  ),
                  Divider(),
                  SizedBox(height: 20),
                  Text(
                    'Review Score',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  RadioListTile<int>(
                    title: Text('Poor: 1 or more /5'),
                    value: 1,
                    groupValue: _reviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _reviewScore = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Fair: 2 or more /5'),
                    value: 2,
                    groupValue: _reviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _reviewScore = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Good: 3 or more /5'),
                    value: 3,
                    groupValue: _reviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _reviewScore = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Very Good: 4 or more /5'),
                    value: 4,
                    groupValue: _reviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _reviewScore = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Excellent: 5 or more /5'),
                    value: 5,
                    groupValue: _reviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _reviewScore = value!;
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
                    value: _freeCancellationApartement,
                    onChanged: (bool? value) {
                      setState(() {
                        _freeCancellationApartement = value!;
                      });
                    },
                  ),
                  Divider(),
                  SizedBox(height: 20),
                  Text(
                    'Number of bedrooms',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  RadioListTile<int>(
                    title: Text('1+ bedrooms'),
                    value: 1,
                    groupValue: _numberOfBedrooms,
                    onChanged: (int? value) {
                      setState(() {
                        _numberOfBedrooms = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('2+ bedrooms'),
                    value: 2,
                    groupValue: _numberOfBedrooms,
                    onChanged: (int? value) {
                      setState(() {
                        _numberOfBedrooms = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('3+ bedrooms'),
                    value: 3,
                    groupValue: _numberOfBedrooms,
                    onChanged: (int? value) {
                      setState(() {
                        _numberOfBedrooms = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('4+ bedrooms'),
                    value: 4,
                    groupValue: _numberOfBedrooms,
                    onChanged: (int? value) {
                      setState(() {
                        _numberOfBedrooms = value!;
                      });
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await applyFiltersApartement();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
          );
        });
      },
    );
  }

  void _showFilterHotelDialog() {
    String currencySymbol = getCurrencySymbol(currency);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: MediaQuery.of(context).size.height *
                0.5, // Set height to half the screen
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ' ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Price (for 1 night)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _maxPrice,
                    min: _minPrice,
                    max: max,
                    divisions: 100,
                    activeColor: Colors.blue[900],
                    label: '${currencySymbol}${_maxPrice.round()}',
                    onChanged: (double value) {
                      setState(() {
                        _maxPrice = value;
                        print(_maxPrice);
                      });
                    },
                  ),
                  Divider(),
                  SizedBox(height: 20),
                  Text(
                    'Review Score',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  RadioListTile<int>(
                    title: Text('Poor: 1 or more /5'),
                    value: 1,
                    groupValue: _selectedReviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedReviewScore = value;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Fair: 2 or more /5'),
                    value: 2,
                    groupValue: _selectedReviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedReviewScore = value;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Good: 3 or more /5'),
                    value: 3,
                    groupValue: _selectedReviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedReviewScore = value;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Very Good: 4 or more /5'),
                    value: 4,
                    groupValue: _selectedReviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedReviewScore = value;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Excellent: 5 or more /5'),
                    value: 5,
                    groupValue: _selectedReviewScore,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedReviewScore = value;
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
                  RadioListTile<String>(
                    title: Text('Work'),
                    value: 'work',
                    groupValue: _selectedPurpose,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPurpose = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
          );
        });
      },
    );
  }

  Future<void> _getSortedHebergements() async {
    List<Hebergement> hebergements = await _availabalehotel;

    switch (_selectedOption) {
      case 1:
        hebergements = await HebergementService()
            .sortHebergementsByNbEtoilesDesc(hebergements);
        break;
      case 2:
        hebergements = await HebergementService()
            .sortHebergementsByNbEtoilesAsc(hebergements);
        break;
      case 3:
        hebergements = await HebergementService()
            .sortHebergementsByMoyenneDesc(hebergements);
        break;
      case 4:
        hebergements = await HebergementService()
            .sortHebergementsByMoyenneAsc(hebergements);
        break;
      case 5:
        hebergements = await HebergementService()
            .sortHebergementsByPrixChambreAsc(hebergements);
        break;
      default:
        hebergements = [];
    }

    setState(() {
      _availabalehotel = Future.value(hebergements);
    });
  }

  Future<void> _getSortedVilla() async {
    List<Hebergement> hebergements = await _availabalevillas;

    switch (_selectedOptionVilla) {
      case 1:
        hebergements = await HebergementService()
            .sortOtherHebergementsByMoyenneDesc(hebergements);
        break;
      case 2:
        hebergements =
            await HebergementService().sortHebergementsByPrixAsc(hebergements);
        break;

      default:
        hebergements = [];
    }

    setState(() {
      _availabalevillas = Future.value(hebergements);
    });
  }

  Future<void> _getSortedApartement() async {
    List<Hebergement> hebergements = await _availabaleAppartement;

    switch (_selectedOptionApartement) {
      case 1:
        hebergements = await HebergementService()
            .sortOtherHebergementsByMoyenneDesc(hebergements);
        break;
      case 2:
        hebergements =
            await HebergementService().sortHebergementsByPrixAsc(hebergements);
        break;

      default:
        hebergements = [];
    }

    setState(() {
      _availabaleAppartement = Future.value(hebergements);
    });
  }

  void _showSortHotelDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    RadioListTile<int>(
                      title: Text('Property rating (5 to 0)'),
                      value: 1,
                      groupValue: _selectedOption,
                      activeColor: Colors.blue[900],
                      onChanged: (int? value) {
                        setState(() {
                          _selectedOption = value!;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      title: Text('Property rating (0 to 5)'),
                      value: 2,
                      groupValue: _selectedOption,
                      activeColor: Colors.blue[900],
                      onChanged: (int? value) {
                        setState(() {
                          _selectedOption = value!;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      title: Text('Best reviewed first'),
                      value: 3,
                      groupValue: _selectedOption,
                      activeColor: Colors.blue[900],
                      onChanged: (int? value) {
                        setState(() {
                          _selectedOption = value!;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      title: Text('Price (lowest first)'),
                      value: 4,
                      groupValue: _selectedOption,
                      activeColor: Colors.blue[900],
                      onChanged: (int? value) {
                        setState(() {
                          _selectedOption = value!;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _getSortedHebergements();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
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
            );
          },
        );
      },
    );
  }

  void _showSortApartementDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.3,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    RadioListTile<int>(
                      title: Text('Best reviewed first'),
                      value: 1,
                      groupValue: _selectedOptionApartement,
                      activeColor: Colors.blue[900],
                      onChanged: (int? value) {
                        setState(() {
                          _selectedOption = value!;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      title: Text('Price (lowest first)'),
                      value: 2,
                      groupValue: _selectedOptionApartement,
                      activeColor: Colors.blue[900],
                      onChanged: (int? value) {
                        setState(() {
                          _selectedOption = value!;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _getSortedApartement();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
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
            );
          },
        );
      },
    );
  }

  void _showSortVillaDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.3,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    RadioListTile<int>(
                      title: Text('Best reviewed first'),
                      value: 1,
                      groupValue: _selectedOptionVilla,
                      activeColor: Colors.blue[900],
                      onChanged: (int? value) {
                        setState(() {
                          _selectedOption = value!;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      title: Text('Price (lowest first)'),
                      value: 2,
                      groupValue: _selectedOptionVilla,
                      activeColor: Colors.blue[900],
                      onChanged: (int? value) {
                        setState(() {
                          _selectedOption = value!;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _getSortedVilla();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
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
            );
          },
        );
      },
    );
  }

  Future<void> applyFiltersVilla() async {
    List<Hebergement> hebergements = await _availabalevillas;

    if (_freeCancellationApartement) {
      hebergements =
          await _hebergementService.findByFreeCancellation(hebergements);
    }

    if (_reviewScore != null) {
      double upperBound = _reviewScore! + 1;
      hebergements =
          await _hebergementService.findOtherHebergementsByOverallAverage(
              hebergements, _reviewScore!.toDouble(), upperBound);
    }
    if (_numberOfBedrooms != null) {
      hebergements = await _hebergementService.findByNbChambres(
          hebergements, _numberOfBedrooms!);
    }
    if (_minPrice != null && _maxPrice != null) {
      hebergements = await _hebergementService.findHebergementsByPrixMaxPrixMin(
          hebergements, _minPrice, _maxPrice);
    }

    setState(() {
      _availabalevillas = Future.value(hebergements);
    });
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
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

                    if (isCheckIn) {
                      // Logique pour Check In
                    } else {
                      // Logique pour Check Out
                    }
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

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.blue[900],
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: CustomTextField(
                          readOnly: false,
                          controller: _destinationController,
                          label: 'Localisation'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.blue[900]),
                    SizedBox(width: 20),
                    Expanded(
                      child: CustomTextField(
                        readOnly: true,
                        label: 'Check In',
                        controller: _checkInController,
                        onTap: () {
                          _showCalendarDialog(
                              context, _checkInController, true);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.blue[900]),
                    SizedBox(width: 20),
                    Expanded(
                      child: CustomTextField(
                        readOnly: true,
                        label: 'Check Out',
                        controller: _checkOutController,
                        onTap: () {
                          _showCalendarDialog(
                              context, _checkOutController, false);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  buttonText: 'Search',
                  onPressed: () {
                    _availabalehotel =
                        _hebergementService.fetchAvailableHebergements(
                            _destinationController.text,
                            1,
                            _checkInController.text,
                            _checkOutController.text);
                    _availabalevillas = _hebergementService.fetchAvailable(
                        _destinationController.text,
                        2,
                        _checkInController.text,
                        _checkOutController.text);
                    _availabaleAppartement = _hebergementService.fetchAvailable(
                        _destinationController.text,
                        3,
                        _checkInController.text,
                        _checkOutController.text);
                    setState(() {});
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> applyFiltersApartement() async {
    List<Hebergement> hebergements = await _availabaleAppartement;

    if (_freeCancellationApartement) {
      hebergements =
          await _hebergementService.findByFreeCancellation(hebergements);
    }

    if (_reviewScore != null) {
      double upperBound = _reviewScore! + 1;
      hebergements =
          await _hebergementService.findOtherHebergementsByOverallAverage(
              hebergements, _reviewScore!.toDouble(), upperBound);
    }
    if (_numberOfBedrooms != null) {
      hebergements = await _hebergementService.findByNbChambres(
          hebergements, _numberOfBedrooms!);
    }
    if (_minPrice != null && _maxPrice != null) {
      hebergements = await _hebergementService.findHebergementsByPrixMaxPrixMin(
          hebergements, _minPrice, _maxPrice);
    }

    setState(() {
      _availabaleAppartement = Future.value(hebergements);
    });
  }

  Future<void> applyFilters() async {
    List<Hebergement> hebergements = await _availabalehotel;

    if (_freeCancellation) {
      hebergements =
          await _hebergementService.findByFreeCancellation(hebergements);
    }

    if (_selectedPurpose == 'work') {
      hebergements =
          await _hebergementService.findHebergementsByWork(hebergements);
    }

    if (_selectedReviewScore != null) {
      double upperBound = _selectedReviewScore! + 1;
      hebergements = await _hebergementService.findHebergementsByOverallAverage(
          hebergements, _selectedReviewScore!.toDouble(), upperBound);
    }

    if (_selectedRating != null) {
      hebergements = await _hebergementService.findHebergementsByNbEtoile(
          hebergements, _selectedRating.toString());
    }
    if (_minPrice != null && _maxPrice != null) {
      print(_maxPrice);
      print(_minPrice);
      hebergements =
          await _hebergementService.findHebergementsByChambrePriceRange(
              hebergements, _minPrice, _maxPrice);
    }

    setState(() {
      _availabalehotel = Future.value(hebergements);
    });
  }

  String selectedCategory = 'Hotel';
  int selectedCategoryIndex = 0;
  Future<List<Categorie>>? futureCategories;
  late Future<List<Hebergement>> _availabalehotel = Future.value([]);
  late Future<List<Hebergement>> _availabalevillas = Future.value([]);
  late Future<List<Hebergement>> _availabaleAppartement = Future.value([]);
  final HebergementService _hebergementService = HebergementService();
  @override
  void initState() {
    super.initState();
    final CategorieService _categorieService = CategorieService();
    _checkInController.text = widget.checkIn;
    _checkOutController.text = widget.checkOut;
    _destinationController.text = widget.ville;
    futureCategories = _categorieService.getAllCategories();
    _availabalehotel = _hebergementService.fetchAvailableHebergements(
        widget.ville, 1, widget.checkIn, widget.checkOut);
    _availabalevillas = _hebergementService.fetchAvailable(
        widget.ville, 2, widget.checkIn, widget.checkOut);
    _availabaleAppartement = _hebergementService.fetchAvailable(
        widget.ville, 3, widget.checkIn, widget.checkOut);
    _loadCurrencyAndConvertPrices();
  }

  String? selectedCurrency;
  void _loadAndConvertPrices() async {
    List<Hebergement> hotels = await _availabalehotel;
    List<Hebergement> villas = await _availabalevillas;
    List<Hebergement> appartements = await _availabaleAppartement;

    final prefs = await SharedPreferences.getInstance();
    final storedCurrency = prefs.getString('selectedCurrency');

    if (storedCurrency != null) {
      setState(() {
        selectedCurrency = storedCurrency;
      });
      print('Selected currency: $selectedCurrency');

      if (hotels.isNotEmpty) {
        print('Converting hotel prices...');
        hotels = await _hebergementService.convertHebergementPrices(
            hotels, selectedCurrency!);
      }

      if (villas.isNotEmpty) {
        print('Converting villa prices...');
        villas = await _hebergementService.convertHebergementPrices(
            villas, selectedCurrency!);
      }

      if (appartements.isNotEmpty) {
        print('Converting apartment prices...');
        appartements = await _hebergementService.convertHebergementPrices(
            appartements, selectedCurrency!);
      }
      setState(() {
        _availabalehotel = Future.value(hotels);
        _availabalevillas = Future.value(villas);
        _availabaleAppartement = Future.value(appartements);
      });
    }
  }

  Widget _buildStarCheckboxes() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Column(
        children: List.generate(5, (index) {
          return RadioListTile<int>(
            title: Row(
              children: List.generate(5, (starIndex) {
                return Icon(
                  starIndex <= index ? Icons.star : Icons.star_border,
                  color: starIndex <= index ? Colors.blue[900] : Colors.grey,
                );
              }),
            ),
            value: index + 1,
            groupValue: _selectedRating,
            onChanged: (int? value) {
              setState(() {
                _selectedRating = value;
              });
            },
          );
        }),
      );
    });
  }

  void _onFilterIconPressed() {
    if (selectedCategory == 'Hotel') {
      _showFilterHotelDialog();
    } else if (selectedCategory == 'Villa') {
      _showFilterVillaDialog();
    } else {
      _showFilterApartementDialog();
    }
  }

  void _onSortIconPressed() {
    if (selectedCategory == 'Hotel') {
      _showSortHotelDialog();
    } else if (selectedCategory == 'Villa') {
      _showSortVillaDialog();
    } else {
      _showSortApartementDialog();
    }
  }

  TextEditingController _destinationController = TextEditingController();
  TextEditingController _checkInController = TextEditingController();
  TextEditingController _checkOutController = TextEditingController();
  final List<String> categories = ['Hotel', 'Villa', 'Apartment'];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(FontAwesomeIcons.filter),
              onPressed: () {
                _onFilterIconPressed();
              },
            ),
            IconButton(
              icon: Icon(Icons.sort),
              onPressed: () {
                _onSortIconPressed();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText:
                      '${_destinationController.text}, ${_checkInController.text}, ${_checkOutController.text}',
                  suffixIcon: IconButton(
                    icon: Icon(FontAwesomeIcons.pencil),
                    onPressed: () {
                      showSearchDialog(context);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              FutureBuilder<List<Categorie>>(
                future: futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No categories available');
                  } else {
                    final categories = snapshot.data!;
                    return Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: List.generate(categories.length, (index) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategoryIndex = index;
                                  selectedCategory = categories[index].type;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedCategoryIndex == index
                                      ? Colors.blue[900]
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    categories[index].type,
                                    style: TextStyle(
                                      fontFamily: 'AbrilFatface',
                                      color: selectedCategoryIndex == index
                                          ? Colors.white
                                          : Colors.blue[900],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: _getSelectedCategoryWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getSelectedCategoryWidget() {
    switch (selectedCategoryIndex) {
      case 0:
        return HotelWidget(
          availableHotels: _availabalehotel,
          checkIn: _checkInController.text,
          checkOut: _checkOutController.text,
        );
      case 1:
        return VillaWidget(
          availablevilla: _availabalevillas,
          checkIn: _checkInController.text,
          checkOut: _checkOutController.text,
        );
      case 2:
        return ApartmentWidget(
          availableApartement: _availabaleAppartement,
          checkIn: _checkInController.text,
          checkOut: _checkOutController.text,
        );
      default:
        return Container();
    }
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue[900] : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.blue[900],
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}

class HotelWidget extends StatelessWidget {
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
        return 'TND';
      case 'AMD':
        return '֏';

      default:
        return '';
    }
  }

  String getReviewText(double average) {
    if (average >= 5) {
      return 'Excellent';
    } else if (average >= 4) {
      return 'Very Good';
    } else if (average >= 3) {
      return 'Good';
    } else if (average >= 2) {
      return 'Fair';
    } else if (average >= 1) {
      return 'Poor';
    } else {
      return '';
    }
  }

  final Future<List<Hebergement>> availableHotels;
  final String checkIn;
  final String checkOut;

  const HotelWidget(
      {required this.availableHotels,
      required this.checkIn,
      required this.checkOut,
      Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Hebergement>>(
      future: availableHotels,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No available hotels'));
        } else {
          final hotels = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: hotels.map((hotel) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AcommodationPage(
                            hebergement: hotel,
                            checkIn: checkIn,
                            checkOut: checkOut),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              child:
                                  HebergementImageAnimator(hebergement: hotel),
                            ),
                            if (hotel.nbAvis != 0)
                              Positioned(
                                left: 10,
                                top: 10,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    getReviewText(hotel.moyenne!),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    hotel.nom,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'AbrilFatface',
                                      fontSize: 20,
                                    ),
                                  ),
                                  FutureBuilder<double>(
                                    future: HebergementService()
                                        .findMinPriceChambre(
                                            hotel.hebergementId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else if (!snapshot.hasData) {
                                        return Container();
                                      } else {
                                        if (hotel.offres != null &&
                                            hotel.offres!.isNotEmpty) {
                                          return Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${hotel.offres![0].discount} % off',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Text(
                                            '${snapshot.data} ${getCurrencySymbol(hotel.currency)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${hotel.pays}, ${hotel.ville}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (hotel.offres == null ||
                                      hotel.offres!.isEmpty)
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
                                    '${hotel.distance}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Spacer(),
                                  for (int i = 0;
                                      i < int.parse(hotel.nbEtoile);
                                      i++)
                                    Icon(Icons.star,
                                        size: 12, color: Colors.blue[900]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}

class VillaWidget extends StatelessWidget {
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
        return 'TND';
      case 'AMD':
        return '֏';

      default:
        return '';
    }
  }

  String getReviewText(double average) {
    if (average >= 5) {
      return 'Excellent';
    } else if (average >= 4) {
      return 'Very Good';
    } else if (average >= 3) {
      return 'Good';
    } else if (average >= 2) {
      return 'Fair';
    } else if (average >= 1) {
      return 'Poor';
    } else {
      return '';
    }
  }

  final Future<List<Hebergement>> availablevilla;
  final String checkIn;
  final String checkOut;

  const VillaWidget(
      {required this.availablevilla,
      required this.checkIn,
      required this.checkOut,
      Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Hebergement>>(
      future: availablevilla,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No available villas'));
        } else {
          final villa = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: villa.map((villa) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AcommodationPage(
                            hebergement: villa,
                            checkIn: checkIn,
                            checkOut: checkOut),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              child:
                                  HebergementImageAnimator(hebergement: villa),
                            ),
                            if (villa.nbAvis != 0)
                              Positioned(
                                left: 10,
                                top: 10,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    getReviewText(villa.moyenne!),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    villa.nom,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'AbrilFatface',
                                      fontSize: 20,
                                    ),
                                  ),
                                  villa.offres != null &&
                                          villa.offres!.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${villa.prix} ${getCurrencySymbol(villa.currency)}',
                                              style: TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.grey,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '${(villa.prix - (villa.prix * (double.parse(villa.offres![0].discount) / 100))).toStringAsFixed(2)} ${getCurrencySymbol(villa.currency)}',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          '${villa.prix} ${getCurrencySymbol(villa.currency)}',
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
                                    '${villa.pays}, ${villa.ville}',
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
                                    '${villa.distance}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '${villa.nbChambres} Room , ${villa.nbSallesDeBains} Bathroom',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}

class ApartmentWidget extends StatelessWidget {
  String getReviewText(double average) {
    if (average >= 5) {
      return 'Excellent';
    } else if (average >= 4) {
      return 'Very Good';
    } else if (average >= 3) {
      return 'Good';
    } else if (average >= 2) {
      return 'Fair';
    } else if (average >= 1) {
      return 'Poor';
    } else {
      return '';
    }
  }

  final Future<List<Hebergement>> availableApartement;
  final String checkIn;
  final String checkOut;
  const ApartmentWidget(
      {required this.availableApartement,
      required this.checkIn,
      required this.checkOut,
      Key? key})
      : super(key: key);
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
        return 'TND';
      case 'AMD':
        return '֏';

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Hebergement>>(
      future: availableApartement,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No available Apartements'));
        } else {
          final apartement = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: apartement.map((apartement) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AcommodationPage(
                            hebergement: apartement,
                            checkIn: checkIn,
                            checkOut: checkOut),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              child: HebergementImageAnimator(
                                  hebergement: apartement),
                            ),
                            if (apartement.nbAvis != 0)
                              Positioned(
                                left: 10,
                                top: 10,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    getReviewText(apartement.moyenne!),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    apartement.nom,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'AbrilFatface',
                                      fontSize: 20,
                                    ),
                                  ),
                                  apartement.offres != null &&
                                          apartement.offres!.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${apartement.prix} ${getCurrencySymbol(apartement.currency)}',
                                              style: TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.grey,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '${(apartement.prix - (apartement.prix * (double.parse(apartement.offres![0].discount) / 100))).toStringAsFixed(2)} ${getCurrencySymbol(apartement.currency)}',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          '${apartement.prix} ${getCurrencySymbol(apartement.currency)}',
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
                                    '${apartement.pays}, ${apartement.ville}',
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
                                    '${apartement.distance}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '${apartement.nbChambres} Room , ${apartement.nbSallesDeBains} Bathroom',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
