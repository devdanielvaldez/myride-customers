import 'dart:convert';
import 'package:http/http.dart' as http;

class TripController {
  Future<Object> createTrips(driverId, tripId) async {
    print('entro en trip');
    final url = 'https://apimyride.dark-innovations.com/trips';
    final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "tripId": tripId,
          "driverId": driverId
        }),
        headers: {
          'Content-Type': 'application/json'
        }
    );

    if(response.statusCode == 201) {
      print('respondio trip');
      final resp = jsonDecode(response.body);
      return resp;
    } else {
      return {
        "ok": false
      };
    }
  }

  Future<Object> updateTrips(tripId, latitude, longitude) async {
    print('entro en trip update');
    final url = 'https://apimyride.dark-innovations.com/trips/${tripId}/locations';
    final response = await http.put(
        Uri.parse(url),
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude
        }),
        headers: {
          'Content-Type': 'application/json'
        }
    );

    if(response.statusCode == 201) {
      print('respondio trip');
      final resp = jsonDecode(response.body);
      return resp;
    } else {
      return {
        "ok": false
      };
    }
  }
}