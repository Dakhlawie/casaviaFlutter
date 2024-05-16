import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CountrySearchPage extends StatefulWidget {
  @override
  _CountrySearchPageState createState() => _CountrySearchPageState();
}

class _CountrySearchPageState extends State<CountrySearchPage> {
  TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];

  void _onSearchChanged(String query) async {
    if (query.length >= 1) {
      final urlCountry =
          Uri.parse('https://restcountries.com/v3.1/name/$query');
      final urlCity = Uri.parse(
          'https://wft-geo-db.p.rapidapi.com/v1/geo/cities?namePrefix=$query&limit=5');

      try {
        var responseCountry = await http.get(urlCountry);
        var responseCity = await http.get(urlCity, headers: {
          "X-RapidAPI-Key": "126797f85fmshb937e6affc858f0p1e3046jsn5955c4f72c42",
          "X-RapidAPI-Host": "wft-geo-db.p.rapidapi.com",
        });

        List<String> newSuggestions = [];

        if (responseCountry.statusCode == 200) {
          final List countries = json.decode(responseCountry.body);
          newSuggestions.addAll(countries
              .map<String>((country) => "${country['name']['common']}")
              .toList());
        } else {
          print('Failed to fetch countries: ${responseCountry.body}');
        }

        if (responseCity.statusCode == 200) {
          final data = json.decode(responseCity.body);
          newSuggestions.addAll(
              data['data'].map<String>((city) => "${city['name']}").toList());
        } else {
          print('Failed to fetch cities: ${responseCity.body}');
        }

        setState(() {
          _suggestions = newSuggestions;
        });
      } catch (e) {
        print('Error fetching data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.search, color: Colors.blue[900]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[900]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[900]!, width: 2.0),
                ),
                hintStyle: TextStyle(color: Colors.blue[900]),
              ),
              style: TextStyle(color: Colors.black),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_suggestions[index]),
                  onTap: () => Navigator.pop(context, _suggestions[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
