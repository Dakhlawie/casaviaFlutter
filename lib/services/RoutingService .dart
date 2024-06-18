import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class RoutingService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getRoute(LatLng start, LatLng end) async {
    final url =
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    final response = await _dio.get(url, queryParameters: {
      'overview': 'full',
      'geometries': 'geojson',
      'steps': 'true',
    });
    print(response.statusCode);
    if (response.statusCode == 200 && response.data['routes'].isNotEmpty) {
      final route = response.data['routes'][0];
      final distance = route['distance'];
      final duration = route['duration'];
      print(route);
      print(distance);
      print(duration);
      final coordinates = route['geometry']['coordinates']
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList();
      print(coordinates);
      return {
        'coordinates': coordinates,
        'distance': distance,
        'duration': duration,
      };
    } else {
      throw Exception('No routes found');
    }
  }
}
