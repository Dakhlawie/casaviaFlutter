class PriceRange {
  double minPrice;
  double maxPrice;
  String currency;

  PriceRange({
    required this.minPrice,
    required this.maxPrice,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'currency': currency,
    };
  }

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      minPrice: json['minPrice'],
      maxPrice: json['maxPrice'],
      currency: json['currency'],
    );
  }
}
