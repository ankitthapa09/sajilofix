class GeoAddress {
  final String address;
  final String? district;
  final String? municipality;
  final String? ward;
  final String? landmark;
  final double latitude;
  final double longitude;

  const GeoAddress({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.district,
    this.municipality,
    this.ward,
    this.landmark,
  });

  factory GeoAddress.fromJson(Map<String, dynamic> json) {
    return GeoAddress(
      address: (json['address'] ?? '').toString(),
      district: json['district']?.toString(),
      municipality: json['municipality']?.toString(),
      ward: json['ward']?.toString(),
      landmark: json['landmark']?.toString(),
      latitude: _toDouble(json['latitude']) ?? 0,
      longitude: _toDouble(json['longitude']) ?? 0,
    );
  }

  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
