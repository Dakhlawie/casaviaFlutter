import 'package:casavia/model/hebergement.dart';
import 'package:casavia/services/GeocodingService%20.dart';
import 'package:casavia/services/RoutingService%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final Hebergement hebergement;

  const MapScreen({Key? key, required this.hebergement}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Map<String, dynamic>> _suggestions = [];
  final MapController _mapController = MapController();
  final LatLng _start = LatLng(48.8566, 2.3522);
  final LatLng _end = LatLng(48.8588443, 2.2943506);
  List<LatLng> _routeCoordinates = [];
  double _routeDistance = 0;
  double _routeDuration = 0;
  final RoutingService _routingService = RoutingService();
  final GeocodingService _geocodingService = GeocodingService();
  final TextEditingController _searchController = TextEditingController();
  List<String> _tileLayers = [
    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}.png',
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}.png',
    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png'
  ];
  int _currentLayerIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    try {
      final routeData = await _routingService.getRoute(start, end);

      print("Route data received: $routeData");
      if (routeData != null && routeData.containsKey('coordinates')) {
        setState(() {
          _routeCoordinates = List<LatLng>.from(routeData['coordinates']);
          _routeDistance = (routeData['distance'] as num).toDouble();
          _routeDuration = (routeData['duration'] as num).toDouble();
          print('hello');
        });
        print("***********************************");
        print(_routeCoordinates);
        print(_routeDistance);
        print(_routeDuration);
      } else {
        print("Route data is null or does not contain expected fields");
      }
    } catch (e) {
      print('Error in _getRoute: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching route: $e')));
    }
  }

  String _formatDuration(double duration) {
    final int minutes = (duration / 60).round();
    return '$minutes min';
  }

  String _formatDistance(double distance) {
    final double km = distance / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  Future<void> _searchLocation(String address) async {
    LatLng? coordinates =
        await _geocodingService.getCoordinatesFromAddress(address);
    if (coordinates != null) {
      _mapController.move(coordinates, 13.0);
      _getRoute(_start, coordinates);
      setState(() {
        _routeCoordinates = [coordinates];
      });
    } else {
      // handle location not found
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Location not found')));
    }
  }

  Future<void> _updateSuggestions(String query) async {
    List<Map<String, dynamic>> suggestions =
        await _geocodingService.getSuggestions(query);
    setState(() {
      _suggestions = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _start,
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                Visibility(
                  visible: _routeCoordinates.isNotEmpty,
                  child: PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routeCoordinates,
                        strokeWidth: 3.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _start,
                      child: BounceMarker(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.bed,
                            color: Colors.white,
                            size: 25.0,
                          ),
                        ),
                      ),
                    ),
                    if (_routeCoordinates.length > 1)
                      Marker(
                        width: 50.0,
                        height: 50.0,
                        point: _routeCoordinates[
                            (_routeCoordinates.length / 2).round()],
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Icon(Icons.directions_car,
                                  color: Colors.blue[900]),
                              SizedBox(width: 5),
                              Text(
                                _formatDuration(_routeDuration),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_routeCoordinates.length > 1)
                      Marker(
                        width: 50.0,
                        height: 50.0,
                        point: _routeCoordinates[
                            ((_routeCoordinates.length / 2) + 30).round()],
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Icon(Icons.straighten, color: Colors.blue[900]),
                              SizedBox(width: 5),
                              Text(
                                _formatDistance(_routeDistance),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_routeCoordinates.isNotEmpty)
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: _routeCoordinates.last,
                        child: BounceMarker(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.blue[900],
                        ),
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.blue[900],
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _updateSuggestions(value);
                        } else {
                          setState(() {
                            _suggestions = [];
                          });
                        }
                      },
                      onSubmitted: (value) {
                        _searchLocation(value);
                      },
                    ),
                  ),
                  if (_suggestions.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ListTile(
                            title: Text(suggestion['display_name']),
                            onTap: () {
                              _searchController.text =
                                  suggestion['display_name'];
                              _searchLocation(suggestion['display_name']);
                              setState(() {
                                _suggestions = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Container(
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
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: MemoryImage(
                                  widget.hebergement.images[0].image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.hebergement.nom,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'AbrilFatface',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.blue[900], size: 16),
                                  Icon(Icons.star,
                                      color: Colors.blue[900], size: 16),
                                  Icon(Icons.star,
                                      color: Colors.blue[900], size: 16),
                                  Icon(Icons.star,
                                      color: Colors.blue[900], size: 16),
                                  Icon(Icons.star_border,
                                      color: Colors.blue[900], size: 16),
                                  SizedBox(width: 5),
                                  Text(
                                    'Very Good',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.favorite_border,
                                color: Colors.blue[900]),
                            SizedBox(width: 5),
                            Icon(FontAwesomeIcons.share,
                                color: Colors.blue[900]),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '€194',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle button press
                        },
                        child: Text('Select rooms'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 300,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      _mapController.move(
                          _mapController.center, _mapController.zoom + 1);
                    },
                    child: Icon(Icons.add, color: Colors.blue[900]),
                    mini: true,
                  ),
                  SizedBox(height: 5),
                  FloatingActionButton(
                    onPressed: () {
                      _mapController.move(
                          _mapController.center, _mapController.zoom - 1);
                    },
                    child: Icon(Icons.remove, color: Colors.blue[900]),
                    mini: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BounceMarker extends StatefulWidget {
  final Widget child;

  BounceMarker({required this.child});

  @override
  _BounceMarkerState createState() => _BounceMarkerState();
}

class _BounceMarkerState extends State<BounceMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * _animation.value),
          child: child,
        );
      },
    );
  }
}
