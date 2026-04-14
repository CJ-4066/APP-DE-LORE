class PhoneCountry {
  const PhoneCountry({
    required this.isoCode,
    required this.name,
    required this.dialCode,
  });

  final String isoCode;
  final String name;
  final String dialCode;

  String get label => '$name ($dialCode)';
}

const phoneCountries = <PhoneCountry>[
  PhoneCountry(isoCode: 'AR', name: 'Argentina', dialCode: '+54'),
  PhoneCountry(isoCode: 'BO', name: 'Bolivia', dialCode: '+591'),
  PhoneCountry(isoCode: 'BR', name: 'Brasil', dialCode: '+55'),
  PhoneCountry(isoCode: 'CA', name: 'Canadá', dialCode: '+1'),
  PhoneCountry(isoCode: 'CL', name: 'Chile', dialCode: '+56'),
  PhoneCountry(isoCode: 'CO', name: 'Colombia', dialCode: '+57'),
  PhoneCountry(isoCode: 'CR', name: 'Costa Rica', dialCode: '+506'),
  PhoneCountry(isoCode: 'DO', name: 'República Dominicana', dialCode: '+1'),
  PhoneCountry(isoCode: 'EC', name: 'Ecuador', dialCode: '+593'),
  PhoneCountry(isoCode: 'ES', name: 'España', dialCode: '+34'),
  PhoneCountry(isoCode: 'GT', name: 'Guatemala', dialCode: '+502'),
  PhoneCountry(isoCode: 'HN', name: 'Honduras', dialCode: '+504'),
  PhoneCountry(isoCode: 'MX', name: 'México', dialCode: '+52'),
  PhoneCountry(isoCode: 'NI', name: 'Nicaragua', dialCode: '+505'),
  PhoneCountry(isoCode: 'PA', name: 'Panamá', dialCode: '+507'),
  PhoneCountry(isoCode: 'PE', name: 'Perú', dialCode: '+51'),
  PhoneCountry(isoCode: 'PY', name: 'Paraguay', dialCode: '+595'),
  PhoneCountry(isoCode: 'SV', name: 'El Salvador', dialCode: '+503'),
  PhoneCountry(isoCode: 'US', name: 'Estados Unidos', dialCode: '+1'),
  PhoneCountry(isoCode: 'UY', name: 'Uruguay', dialCode: '+598'),
  PhoneCountry(isoCode: 'VE', name: 'Venezuela', dialCode: '+58'),
];

PhoneCountry resolveDefaultCountry(String? countryCode) {
  final normalizedCode = (countryCode ?? '').trim().toUpperCase();

  return phoneCountries.firstWhere(
    (country) => country.isoCode == normalizedCode,
    orElse: () => phoneCountries.firstWhere(
      (country) => country.isoCode == 'PE',
    ),
  );
}
