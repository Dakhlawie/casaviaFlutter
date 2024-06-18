import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class GeocodingService {
  final Dio _dio = Dio();

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    final response = await _dio.get(
      'https://nominatim.openstreetmap.org/search',
      queryParameters: {
        'q': address,
        'format': 'json',
        'addressdetails': 1,
      },
    );

    if (response.data.isNotEmpty) {
      final data = response.data[0];
      final lat = double.parse(data['lat']);
      final lon = double.parse(data['lon']);
      return LatLng(lat, lon);
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getSuggestions(String query) async {
    final response = await _dio.get(
      'https://nominatim.openstreetmap.org/search',
      queryParameters: {
        'q': query,
        'format': 'json',
        'addressdetails': 1,
        'limit': 5,
      },
    );

    return response.data.map<Map<String, dynamic>>((item) {
      return {
        'display_name': item['display_name'],
        'lat': item['lat'],
        'lon': item['lon'],
      };
    }).toList();
  }
}
