import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/data/birth_place_catalog.dart';
import '../../models/app_models.dart';
import '../../models/profile_models.dart';
import 'birth_place_selector.dart';
import 'profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.user,
    required this.onSave,
    required this.onUploadAvatar,
    required this.onSearchBirthPlaces,
  });

  final UserProfile user;
  final Future<String?> Function(UpdateProfileInput input) onSave;
  final Future<String> Function({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) onUploadAvatar;
  final Future<List<BirthPlaceOption>> Function(String query)
      onSearchBirthPlaces;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _picker = ImagePicker();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;
  late final TextEditingController _zodiacSignController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _birthTimeController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _utcOffsetController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  BirthPlaceOption? _selectedBirthPlace;
  String _timeZoneId = '';

  String? _avatarUrl;
  Uint8List? _pendingAvatarBytes;
  String? _pendingAvatarFileName;
  String? _pendingAvatarMimeType;
  String? _errorMessage;
  bool _isSaving = false;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _nicknameController = TextEditingController(text: user.nickname);
    _emailController = TextEditingController(text: user.email);
    _locationController = TextEditingController(text: user.location);
    _zodiacSignController = TextEditingController(text: user.zodiacSign);
    _birthDateController =
        TextEditingController(text: user.natalChart.birthDate);
    _birthTimeController =
        TextEditingController(text: user.natalChart.birthTime);
    _cityController = TextEditingController(text: user.natalChart.city);
    _countryController = TextEditingController(text: user.natalChart.country);
    _utcOffsetController =
        TextEditingController(text: user.natalChart.utcOffset);
    _latitudeController = TextEditingController(
      text: user.natalChart.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: user.natalChart.longitude?.toString() ?? '',
    );
    _selectedBirthPlace = findBirthPlaceOption(
      city: user.natalChart.city,
      country: user.natalChart.country,
    );
    _timeZoneId = user.natalChart.timeZoneId.isNotEmpty
        ? user.natalChart.timeZoneId
        : _selectedBirthPlace?.timeZoneId ?? user.timezone;
    _avatarUrl = user.avatarUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _zodiacSignController.dispose();
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _utcOffsetController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _errorMessage = null;
      _isPickingImage = true;
    });

    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 82,
      );
      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      final mimeType = _mimeTypeFor(file.name);
      setState(() {
        _pendingAvatarBytes = bytes;
        _pendingAvatarFileName = file.name;
        _pendingAvatarMimeType = mimeType;
        _avatarUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
      });
    } catch (error) {
      setState(() {
        _errorMessage =
            'No se pudo seleccionar la foto. Revisa permisos de galería.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_selectedBirthPlace != null) {
      _applyBirthPlace(_selectedBirthPlace!);
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();
    final birthDate = _birthDateController.text.trim();
    final birthTime = _birthTimeController.text.trim();
    final utcOffset = _utcOffsetController.text.trim();
    final latitudeText = _latitudeController.text.trim();
    final longitudeText = _longitudeController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        city.isEmpty ||
        country.isEmpty ||
        birthDate.isEmpty ||
        birthTime.isEmpty) {
      setState(() {
        _errorMessage =
            'Completa nombre, apellido, ciudad, país, fecha y hora de nacimiento.';
      });
      return;
    }

    if (utcOffset.isNotEmpty &&
        !RegExp(r'^[+-]\d{2}:\d{2}$').hasMatch(utcOffset)) {
      setState(() {
        _errorMessage = 'El UTC offset debe tener formato +/-HH:MM.';
      });
      return;
    }

    final latitude =
        latitudeText.isEmpty ? null : double.tryParse(latitudeText);
    final longitude =
        longitudeText.isEmpty ? null : double.tryParse(longitudeText);

    if (latitudeText.isNotEmpty && latitude == null) {
      setState(() {
        _errorMessage = 'La latitud debe ser numérica.';
      });
      return;
    }

    if (longitudeText.isNotEmpty && longitude == null) {
      setState(() {
        _errorMessage = 'La longitud debe ser numérica.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    String avatarUrl = _avatarUrl?.trim() ?? '';
    if (_pendingAvatarBytes != null &&
        _pendingAvatarFileName != null &&
        _pendingAvatarMimeType != null) {
      try {
        avatarUrl = await widget.onUploadAvatar(
          bytes: _pendingAvatarBytes!,
          fileName: _pendingAvatarFileName!,
          contentType: _pendingAvatarMimeType!,
        );
      } catch (error) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isSaving = false;
          _errorMessage = error.toString().replaceFirst('Exception: ', '');
        });
        return;
      }
    }

    final errorMessage = await widget.onSave(
      UpdateProfileInput(
        firstName: firstName,
        lastName: lastName,
        nickname: _nicknameController.text.trim(),
        email: _emailController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? '$city, $country'
            : _locationController.text.trim(),
        zodiacSign: _zodiacSignController.text.trim(),
        birthDate: birthDate,
        birthTime: birthTime,
        city: city,
        state: _selectedBirthPlace?.state.isNotEmpty == true
            ? _selectedBirthPlace!.state
            : null,
        country: country,
        timeZoneId: _timeZoneId,
        utcOffset: utcOffset,
        latitude: latitude,
        longitude: longitude,
        avatarUrl: avatarUrl,
      ),
    );

    if (!mounted) {
      return;
    }

    if (errorMessage == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSaving = false;
      _errorMessage = errorMessage;
    });
  }

  void _applyBirthPlace(BirthPlaceOption place) {
    _cityController.text = place.city;
    _countryController.text = place.country;
    if (place.state.trim().isNotEmpty) {
      _locationController.text =
          '${place.city}, ${place.state}, ${place.country}';
    }
    _timeZoneId = place.timeZoneId;
    _utcOffsetController.text = place.utcOffset;
    _latitudeController.text = place.latitude.toString();
    _longitudeController.text = place.longitude.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Column(
                children: [
                  ProfileAvatar(
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    avatarUrl: _avatarUrl ?? '',
                    radius: 42,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.tonal(
                        onPressed:
                            _isPickingImage || _isSaving ? null : _pickImage,
                        child: _isPickingImage
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Elegir foto'),
                      ),
                      TextButton(
                        onPressed: (_avatarUrl ?? '').isEmpty || _isSaving
                            ? null
                            : () {
                                setState(() {
                                  _avatarUrl = '';
                                });
                              },
                        child: const Text('Quitar foto'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(label: 'Identidad'),
            const SizedBox(height: 12),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Apodo',
                hintText: 'Cómo quieres que te veamos dentro de la app',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            const SizedBox(height: 24),
            _SectionTitle(label: 'Datos astrológicos'),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Ubicación actual',
                hintText: 'Lima, Perú',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _zodiacSignController,
              decoration: const InputDecoration(
                labelText: 'Signo zodiacal',
                hintText: 'Se completa automáticamente si no lo editas',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _birthDateController,
              decoration: const InputDecoration(
                labelText: 'Fecha de nacimiento',
                hintText: '2000-11-28',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _birthTimeController,
              decoration: const InputDecoration(
                labelText: 'Hora de nacimiento',
                hintText: '01:40',
              ),
            ),
            const SizedBox(height: 12),
            BirthPlaceSelector(
              selectedPlace: _selectedBirthPlace,
              onSearchRemote: widget.onSearchBirthPlaces,
              onSelected: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedBirthPlace = value;
                  _applyBirthPlace(value);
                });
              },
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE6D3BE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cityController.text.isEmpty
                        ? 'Aún no seleccionaste un lugar natal'
                        : '${_cityController.text}, ${_countryController.text}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _utcOffsetController.text.isEmpty
                        ? 'Selecciona una ciudad del listado para completar UTC y coordenadas.'
                        : 'UTC ${_utcOffsetController.text} · Lat ${_latitudeController.text} · Lon ${_longitudeController.text}',
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECE8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFF8B2C1F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving || _isPickingImage ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }

  String _mimeTypeFor(String fileName) {
    final normalized = fileName.toLowerCase();
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }

    if (normalized.endsWith('.heic')) {
      return 'image/heic';
    }

    return 'image/jpeg';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
