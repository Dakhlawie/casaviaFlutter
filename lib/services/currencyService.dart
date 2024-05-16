import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyService {
  final String apiKey = 'acfa6afb0d7efdf27fcdcb8a';

  Future<double> getConversionRate(String baseCurrency, String targetCurrency) async {
    String apiKey = "acfa6afb0d7efdf27fcdcb8a";  
    var url = Uri.parse('https://v6.exchangerate-api.com/v6/$apiKey/latest/$baseCurrency');

    print("Request URL: $url");
    var response = await http.get(url);

    if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("DATA:$data");
        if (data['result'] == 'success') {
            var rates = data['conversion_rates'];
            double rate = rates[targetCurrency];
            if (rate != null) {
                return rate;
            } else {
                throw Exception('No rate found for currency: $targetCurrency');
            }
        } else {
            throw Exception('Failed to convert currency: ${data['error-type']}');
        }
    } else {
        print('HTTP status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to fetch data: HTTP status ${response.statusCode}');
    }
}

}
