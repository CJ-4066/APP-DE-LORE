class BirthPlaceOption {
  const BirthPlaceOption({
    required this.id,
    required this.city,
    required this.country,
    required this.utcOffset,
    required this.latitude,
    required this.longitude,
    this.state = '',
    this.timeZoneIdOverride,
  });

  final String id;
  final String city;
  final String country;
  final String utcOffset;
  final double latitude;
  final double longitude;
  final String state;
  final String? timeZoneIdOverride;

  String get label => '$city, $country';
  String get timeZoneId =>
      timeZoneIdOverride ?? _birthPlaceTimeZoneById[id] ?? 'UTC';
  String get locationLine =>
      [if (state.trim().isNotEmpty) state.trim(), country.trim()].join(', ');

  factory BirthPlaceOption.fromJson(Map<String, dynamic> json) {
    return BirthPlaceOption(
      id: json['id'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      utcOffset: json['utcOffset'] as String? ?? 'UTC',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      timeZoneIdOverride: json['timeZoneId'] as String?,
    );
  }
}

const _birthPlaceTimeZoneById = <String, String>{
  'uy-montevideo': 'America/Montevideo',
  'uy-canelones': 'America/Montevideo',
  'uy-maldonado': 'America/Montevideo',
  'uy-punta-del-este': 'America/Montevideo',
  'uy-salto': 'America/Montevideo',
  'uy-paysandu': 'America/Montevideo',
  'uy-rivera': 'America/Montevideo',
  'ar-buenos-aires': 'America/Argentina/Buenos_Aires',
  'ar-cordoba': 'America/Argentina/Cordoba',
  'ar-rosario': 'America/Argentina/Cordoba',
  'ar-mendoza': 'America/Argentina/Mendoza',
  'ar-la-plata': 'America/Argentina/Buenos_Aires',
  'ar-tucuman': 'America/Argentina/Tucuman',
  'cl-santiago': 'America/Santiago',
  'cl-valparaiso': 'America/Santiago',
  'cl-concepcion': 'America/Santiago',
  'cl-antofagasta': 'America/Santiago',
  'pe-lima': 'America/Lima',
  'pe-arequipa': 'America/Lima',
  'pe-cusco': 'America/Lima',
  'pe-trujillo': 'America/Lima',
  'pe-piura': 'America/Lima',
  'co-bogota': 'America/Bogota',
  'co-medellin': 'America/Bogota',
  'co-cali': 'America/Bogota',
  'co-barranquilla': 'America/Bogota',
  'co-cartagena': 'America/Bogota',
  'mx-cdmx': 'America/Mexico_City',
  'mx-guadalajara': 'America/Mexico_City',
  'mx-monterrey': 'America/Monterrey',
  'mx-puebla': 'America/Mexico_City',
  'mx-merida': 'America/Merida',
  'mx-tijuana': 'America/Tijuana',
  'br-sao-paulo': 'America/Sao_Paulo',
  'br-rio': 'America/Sao_Paulo',
  'br-porto-alegre': 'America/Sao_Paulo',
  'br-curitiba': 'America/Sao_Paulo',
  'br-brasilia': 'America/Sao_Paulo',
  'br-salvador': 'America/Bahia',
  'br-recife': 'America/Recife',
  'br-fortaleza': 'America/Fortaleza',
  'py-asuncion': 'America/Asuncion',
  'bo-la-paz': 'America/La_Paz',
  'bo-santa-cruz': 'America/La_Paz',
  'ec-quito': 'America/Guayaquil',
  'ec-guayaquil': 'America/Guayaquil',
  've-caracas': 'America/Caracas',
  've-maracaibo': 'America/Caracas',
  'cr-san-jose': 'America/Costa_Rica',
  'pa-panama': 'America/Panama',
  'do-santo-domingo': 'America/Santo_Domingo',
  'gt-guatemala': 'America/Guatemala',
  'sv-san-salvador': 'America/El_Salvador',
  'hn-tegucigalpa': 'America/Tegucigalpa',
  'ni-managua': 'America/Managua',
  'es-madrid': 'Europe/Madrid',
  'es-barcelona': 'Europe/Madrid',
  'es-valencia': 'Europe/Madrid',
  'es-sevilla': 'Europe/Madrid',
  'es-malaga': 'Europe/Madrid',
  'es-bilbao': 'Europe/Madrid',
  'us-miami': 'America/New_York',
  'us-ny': 'America/New_York',
  'us-la': 'America/Los_Angeles',
  'us-chicago': 'America/Chicago',
  'us-houston': 'America/Chicago',
  'fr-paris': 'Europe/Paris',
  'it-rome': 'Europe/Rome',
  'de-berlin': 'Europe/Berlin',
  'gb-london': 'Europe/London',
};

const birthPlaceCatalog = <BirthPlaceOption>[
  BirthPlaceOption(
      id: 'uy-montevideo',
      city: 'Montevideo',
      country: 'Uruguay',
      utcOffset: '-03:00',
      latitude: -34.9011,
      longitude: -56.1645),
  BirthPlaceOption(
      id: 'uy-canelones',
      city: 'Canelones',
      country: 'Uruguay',
      utcOffset: '-03:00',
      latitude: -34.5228,
      longitude: -56.2778),
  BirthPlaceOption(
      id: 'uy-maldonado',
      city: 'Maldonado',
      country: 'Uruguay',
      utcOffset: '-03:00',
      latitude: -34.9088,
      longitude: -54.9581),
  BirthPlaceOption(
      id: 'uy-punta-del-este',
      city: 'Punta del Este',
      country: 'Uruguay',
      utcOffset: '-03:00',
      latitude: -34.9680,
      longitude: -54.9500),
  BirthPlaceOption(
      id: 'uy-salto',
      city: 'Salto',
      country: 'Uruguay',
      utcOffset: '-03:00',
      latitude: -31.3833,
      longitude: -57.9667),
  BirthPlaceOption(
      id: 'uy-paysandu',
      city: 'Paysandu',
      country: 'Uruguay',
      utcOffset: '-03:00',
      latitude: -32.3214,
      longitude: -58.0756),
  BirthPlaceOption(
      id: 'uy-rivera',
      city: 'Rivera',
      country: 'Uruguay',
      utcOffset: '-03:00',
      latitude: -30.9053,
      longitude: -55.5508),
  BirthPlaceOption(
      id: 'ar-buenos-aires',
      city: 'Buenos Aires',
      country: 'Argentina',
      utcOffset: '-03:00',
      latitude: -34.6037,
      longitude: -58.3816),
  BirthPlaceOption(
      id: 'ar-cordoba',
      city: 'Cordoba',
      country: 'Argentina',
      utcOffset: '-03:00',
      latitude: -31.4201,
      longitude: -64.1888),
  BirthPlaceOption(
      id: 'ar-rosario',
      city: 'Rosario',
      country: 'Argentina',
      utcOffset: '-03:00',
      latitude: -32.9442,
      longitude: -60.6505),
  BirthPlaceOption(
      id: 'ar-mendoza',
      city: 'Mendoza',
      country: 'Argentina',
      utcOffset: '-03:00',
      latitude: -32.8895,
      longitude: -68.8458),
  BirthPlaceOption(
      id: 'ar-la-plata',
      city: 'La Plata',
      country: 'Argentina',
      utcOffset: '-03:00',
      latitude: -34.9214,
      longitude: -57.9544),
  BirthPlaceOption(
      id: 'ar-tucuman',
      city: 'San Miguel de Tucuman',
      country: 'Argentina',
      utcOffset: '-03:00',
      latitude: -26.8083,
      longitude: -65.2176),
  BirthPlaceOption(
      id: 'cl-santiago',
      city: 'Santiago',
      country: 'Chile',
      utcOffset: '-04:00',
      latitude: -33.4489,
      longitude: -70.6693),
  BirthPlaceOption(
      id: 'cl-valparaiso',
      city: 'Valparaiso',
      country: 'Chile',
      utcOffset: '-04:00',
      latitude: -33.0472,
      longitude: -71.6127),
  BirthPlaceOption(
      id: 'cl-concepcion',
      city: 'Concepcion',
      country: 'Chile',
      utcOffset: '-04:00',
      latitude: -36.8201,
      longitude: -73.0444),
  BirthPlaceOption(
      id: 'cl-antofagasta',
      city: 'Antofagasta',
      country: 'Chile',
      utcOffset: '-04:00',
      latitude: -23.6509,
      longitude: -70.3975),
  BirthPlaceOption(
      id: 'pe-lima',
      city: 'Lima',
      country: 'Perú',
      utcOffset: '-05:00',
      latitude: -12.0464,
      longitude: -77.0428),
  BirthPlaceOption(
      id: 'pe-arequipa',
      city: 'Arequipa',
      country: 'Perú',
      utcOffset: '-05:00',
      latitude: -16.4090,
      longitude: -71.5375),
  BirthPlaceOption(
      id: 'pe-cusco',
      city: 'Cusco',
      country: 'Perú',
      utcOffset: '-05:00',
      latitude: -13.5319,
      longitude: -71.9675),
  BirthPlaceOption(
      id: 'pe-trujillo',
      city: 'Trujillo',
      country: 'Perú',
      utcOffset: '-05:00',
      latitude: -8.1118,
      longitude: -79.0287),
  BirthPlaceOption(
      id: 'pe-piura',
      city: 'Piura',
      country: 'Perú',
      utcOffset: '-05:00',
      latitude: -5.1945,
      longitude: -80.6328),
  BirthPlaceOption(
      id: 'co-bogota',
      city: 'Bogota',
      country: 'Colombia',
      utcOffset: '-05:00',
      latitude: 4.7110,
      longitude: -74.0721),
  BirthPlaceOption(
      id: 'co-medellin',
      city: 'Medellin',
      country: 'Colombia',
      utcOffset: '-05:00',
      latitude: 6.2442,
      longitude: -75.5812),
  BirthPlaceOption(
      id: 'co-cali',
      city: 'Cali',
      country: 'Colombia',
      utcOffset: '-05:00',
      latitude: 3.4516,
      longitude: -76.5320),
  BirthPlaceOption(
      id: 'co-barranquilla',
      city: 'Barranquilla',
      country: 'Colombia',
      utcOffset: '-05:00',
      latitude: 10.9685,
      longitude: -74.7813),
  BirthPlaceOption(
      id: 'co-cartagena',
      city: 'Cartagena',
      country: 'Colombia',
      utcOffset: '-05:00',
      latitude: 10.3910,
      longitude: -75.4794),
  BirthPlaceOption(
      id: 'mx-cdmx',
      city: 'Ciudad de México',
      country: 'México',
      utcOffset: '-06:00',
      latitude: 19.4326,
      longitude: -99.1332),
  BirthPlaceOption(
      id: 'mx-guadalajara',
      city: 'Guadalajara',
      country: 'México',
      utcOffset: '-06:00',
      latitude: 20.6597,
      longitude: -103.3496),
  BirthPlaceOption(
      id: 'mx-monterrey',
      city: 'Monterrey',
      country: 'México',
      utcOffset: '-06:00',
      latitude: 25.6866,
      longitude: -100.3161),
  BirthPlaceOption(
      id: 'mx-puebla',
      city: 'Puebla',
      country: 'México',
      utcOffset: '-06:00',
      latitude: 19.0414,
      longitude: -98.2063),
  BirthPlaceOption(
      id: 'mx-merida',
      city: 'Mérida',
      country: 'México',
      utcOffset: '-06:00',
      latitude: 20.9674,
      longitude: -89.5926),
  BirthPlaceOption(
      id: 'mx-tijuana',
      city: 'Tijuana',
      country: 'México',
      utcOffset: '-08:00',
      latitude: 32.5149,
      longitude: -117.0382),
  BirthPlaceOption(
      id: 'br-sao-paulo',
      city: 'Sao Paulo',
      country: 'Brasil',
      utcOffset: '-03:00',
      latitude: -23.5505,
      longitude: -46.6333),
  BirthPlaceOption(
      id: 'br-rio',
      city: 'Rio de Janeiro',
      country: 'Brasil',
      utcOffset: '-03:00',
      latitude: -22.9068,
      longitude: -43.1729),
  BirthPlaceOption(
      id: 'br-porto-alegre',
      city: 'Porto Alegre',
      country: 'Brasil',
      utcOffset: '-03:00',
      latitude: -30.0346,
      longitude: -51.2177),
  BirthPlaceOption(
      id: 'br-curitiba',
      city: 'Curitiba',
      country: 'Brasil',
      utcOffset: '-03:00',
      latitude: -25.4284,
      longitude: -49.2733),
  BirthPlaceOption(
      id: 'br-brasilia',
      city: 'Brasilia',
      country: 'Brasil',
      utcOffset: '-03:00',
      latitude: -15.7939,
      longitude: -47.8828),
  BirthPlaceOption(
      id: 'br-salvador',
      city: 'Salvador',
      country: 'Brasil',
      utcOffset: '-03:00',
      latitude: -12.9777,
      longitude: -38.5016),
  BirthPlaceOption(
      id: 'br-recife',
      city: 'Recife',
      country: 'Brasil',
      utcOffset: '-03:00',
      latitude: -8.0476,
      longitude: -34.8770),
  BirthPlaceOption(
      id: 'br-fortaleza',
      city: 'Fortaleza',
      country: 'Brasil',
      utcOffset: '-03:00',
      latitude: -3.7319,
      longitude: -38.5267),
  BirthPlaceOption(
      id: 'py-asuncion',
      city: 'Asuncion',
      country: 'Paraguay',
      utcOffset: '-04:00',
      latitude: -25.2637,
      longitude: -57.5759),
  BirthPlaceOption(
      id: 'bo-la-paz',
      city: 'La Paz',
      country: 'Bolivia',
      utcOffset: '-04:00',
      latitude: -16.4897,
      longitude: -68.1193),
  BirthPlaceOption(
      id: 'bo-santa-cruz',
      city: 'Santa Cruz de la Sierra',
      country: 'Bolivia',
      utcOffset: '-04:00',
      latitude: -17.7833,
      longitude: -63.1821),
  BirthPlaceOption(
      id: 'ec-quito',
      city: 'Quito',
      country: 'Ecuador',
      utcOffset: '-05:00',
      latitude: -0.1807,
      longitude: -78.4678),
  BirthPlaceOption(
      id: 'ec-guayaquil',
      city: 'Guayaquil',
      country: 'Ecuador',
      utcOffset: '-05:00',
      latitude: -2.1709,
      longitude: -79.9224),
  BirthPlaceOption(
      id: 've-caracas',
      city: 'Caracas',
      country: 'Venezuela',
      utcOffset: '-04:00',
      latitude: 10.4806,
      longitude: -66.9036),
  BirthPlaceOption(
      id: 've-maracaibo',
      city: 'Maracaibo',
      country: 'Venezuela',
      utcOffset: '-04:00',
      latitude: 10.6545,
      longitude: -71.6500),
  BirthPlaceOption(
      id: 'cr-san-jose',
      city: 'San Jose',
      country: 'Costa Rica',
      utcOffset: '-06:00',
      latitude: 9.9281,
      longitude: -84.0907),
  BirthPlaceOption(
      id: 'pa-panama',
      city: 'Ciudad de Panama',
      country: 'Panama',
      utcOffset: '-05:00',
      latitude: 8.9824,
      longitude: -79.5199),
  BirthPlaceOption(
      id: 'do-santo-domingo',
      city: 'Santo Domingo',
      country: 'República Dominicana',
      utcOffset: '-04:00',
      latitude: 18.4861,
      longitude: -69.9312),
  BirthPlaceOption(
      id: 'gt-guatemala',
      city: 'Ciudad de Guatemala',
      country: 'Guatemala',
      utcOffset: '-06:00',
      latitude: 14.6349,
      longitude: -90.5069),
  BirthPlaceOption(
      id: 'sv-san-salvador',
      city: 'San Salvador',
      country: 'El Salvador',
      utcOffset: '-06:00',
      latitude: 13.6929,
      longitude: -89.2182),
  BirthPlaceOption(
      id: 'hn-tegucigalpa',
      city: 'Tegucigalpa',
      country: 'Honduras',
      utcOffset: '-06:00',
      latitude: 14.0723,
      longitude: -87.1921),
  BirthPlaceOption(
      id: 'ni-managua',
      city: 'Managua',
      country: 'Nicaragua',
      utcOffset: '-06:00',
      latitude: 12.1140,
      longitude: -86.2362),
  BirthPlaceOption(
      id: 'es-madrid',
      city: 'Madrid',
      country: 'España',
      utcOffset: '+01:00',
      latitude: 40.4168,
      longitude: -3.7038),
  BirthPlaceOption(
      id: 'es-barcelona',
      city: 'Barcelona',
      country: 'España',
      utcOffset: '+01:00',
      latitude: 41.3874,
      longitude: 2.1686),
  BirthPlaceOption(
      id: 'es-valencia',
      city: 'Valencia',
      country: 'España',
      utcOffset: '+01:00',
      latitude: 39.4699,
      longitude: -0.3763),
  BirthPlaceOption(
      id: 'es-sevilla',
      city: 'Sevilla',
      country: 'España',
      utcOffset: '+01:00',
      latitude: 37.3891,
      longitude: -5.9845),
  BirthPlaceOption(
      id: 'es-malaga',
      city: 'Málaga',
      country: 'España',
      utcOffset: '+01:00',
      latitude: 36.7213,
      longitude: -4.4214),
  BirthPlaceOption(
      id: 'es-bilbao',
      city: 'Bilbao',
      country: 'España',
      utcOffset: '+01:00',
      latitude: 43.2630,
      longitude: -2.9350),
  BirthPlaceOption(
      id: 'us-miami',
      city: 'Miami',
      country: 'Estados Unidos',
      utcOffset: '-05:00',
      latitude: 25.7617,
      longitude: -80.1918),
  BirthPlaceOption(
      id: 'us-ny',
      city: 'New York',
      country: 'Estados Unidos',
      utcOffset: '-05:00',
      latitude: 40.7128,
      longitude: -74.0060),
  BirthPlaceOption(
      id: 'us-la',
      city: 'Los Angeles',
      country: 'Estados Unidos',
      utcOffset: '-08:00',
      latitude: 34.0522,
      longitude: -118.2437),
  BirthPlaceOption(
      id: 'us-chicago',
      city: 'Chicago',
      country: 'Estados Unidos',
      utcOffset: '-06:00',
      latitude: 41.8781,
      longitude: -87.6298),
  BirthPlaceOption(
      id: 'us-houston',
      city: 'Houston',
      country: 'Estados Unidos',
      utcOffset: '-06:00',
      latitude: 29.7604,
      longitude: -95.3698),
  BirthPlaceOption(
      id: 'fr-paris',
      city: 'Paris',
      country: 'Francia',
      utcOffset: '+01:00',
      latitude: 48.8566,
      longitude: 2.3522),
  BirthPlaceOption(
      id: 'it-rome',
      city: 'Roma',
      country: 'Italia',
      utcOffset: '+01:00',
      latitude: 41.9028,
      longitude: 12.4964),
  BirthPlaceOption(
      id: 'de-berlin',
      city: 'Berlin',
      country: 'Alemania',
      utcOffset: '+01:00',
      latitude: 52.5200,
      longitude: 13.4050),
  BirthPlaceOption(
      id: 'gb-london',
      city: 'Londres',
      country: 'Reino Unido',
      utcOffset: '+00:00',
      latitude: 51.5072,
      longitude: -0.1276),
];

BirthPlaceOption? findBirthPlaceOption({
  required String city,
  required String country,
}) {
  final normalizedCity = _normalizePlace(city);
  final normalizedCountry = _normalizePlace(country);

  for (final item in birthPlaceCatalog) {
    if (_normalizePlace(item.city) == normalizedCity &&
        _normalizePlace(item.country) == normalizedCountry) {
      return item;
    }
  }

  return null;
}

List<BirthPlaceOption> searchBirthPlaceCatalog(
  String query, {
  int limit = 10,
}) {
  final normalizedQuery = _normalizePlace(query);
  final source = normalizedQuery.isEmpty
      ? birthPlaceCatalog
      : birthPlaceCatalog.where((item) {
          final haystack = _normalizePlace(
            '${item.city} ${item.state} ${item.country}',
          );
          return haystack.contains(normalizedQuery);
        });

  return source.take(limit).toList();
}

String _normalizePlace(String value) {
  return value
      .toLowerCase()
      .trim()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n');
}
