import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/data/birth_place_catalog.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/mystic_ui.dart';
import '../../models/app_models.dart';
import '../../models/astro_models.dart';
import '../../models/profile_models.dart';
import 'astro_chart_wheel.dart';
import 'chart_image_store_stub.dart'
    if (dart.library.io) 'chart_image_store_io.dart'
    if (dart.library.js_interop) 'chart_image_store_web.dart'
    as chart_image_store;
import '../profile/birth_place_selector.dart';

part 'astral_chart_sections.dart';

enum _AstroFlowSection {
  setup,
  wheel,
  essence,
  technical,
  timing,
}

class AstralChartScreen extends StatefulWidget {
  const AstralChartScreen({
    super.key,
    required this.user,
    required this.onSaveProfile,
    required this.onGenerate,
    required this.onResolveUtcOffset,
    required this.onSearchBirthPlaces,
  });

  final UserProfile user;
  final Future<String?> Function(UpdateProfileInput input) onSaveProfile;
  final Future<AstroOverviewData> Function(AstroRequestInput input) onGenerate;
  final Future<AstroUtcOffsetResult> Function({
    required String birthDate,
    required String birthTime,
    required bool birthTimeUnknown,
    required String timeZoneId,
  }) onResolveUtcOffset;
  final Future<List<BirthPlaceOption>> Function(String query)
      onSearchBirthPlaces;

  @override
  State<AstralChartScreen> createState() => _AstralChartScreenState();
}

class _AstralChartScreenState extends State<AstralChartScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  late final TextEditingController _subjectNameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _birthTimeController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _utcOffsetController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  BirthPlaceOption? _selectedBirthPlace;
  String _timeZoneId = '';
  bool _birthTimeUnknown = false;

  AstroOverviewData? _result;
  String _houseSystem = 'placidus';
  final Set<String> _selectedPlanetKeys = <String>{
    'sun',
    'moon',
    'mercury',
    'venus',
    'mars',
    'jupiter',
    'saturn',
    'uranus',
    'neptune',
    'pluto',
  };
  String _nodeType = 'true';
  String _lilithType = 'mean';
  String _arabicPartsMode = 'sect';
  final Set<String> _technicalPointKeys = <String>{
    'north_node',
    'south_node',
    'chiron',
    'lilith',
    'fortune',
    'misfortune',
    'vertex',
    'ceres',
    'pallas',
    'juno',
    'vesta',
    'pholus',
  };
  String? _errorMessage;
  bool _isLoading = false;
  bool _isExporting = false;
  bool _showManualLocationFields = false;
  _AstroFlowSection _selectedSection = _AstroFlowSection.setup;

  @override
  void initState() {
    super.initState();
    final natalChart = widget.user.natalChart;
    _subjectNameController =
        TextEditingController(text: natalChart.subjectName);
    _birthDateController = TextEditingController(
      text: _formatBirthDateForForm(natalChart.birthDate),
    );
    _birthTimeController = TextEditingController(text: natalChart.birthTime);
    _birthTimeUnknown = natalChart.birthTimeUnknown;
    _cityController = TextEditingController(text: natalChart.city);
    _stateController = TextEditingController(text: natalChart.state);
    _countryController = TextEditingController(text: natalChart.country);
    _utcOffsetController = TextEditingController(text: natalChart.utcOffset);
    _latitudeController = TextEditingController(
      text: natalChart.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: natalChart.longitude?.toString() ?? '',
    );
    _selectedBirthPlace = findBirthPlaceOption(
      city: natalChart.city,
      country: natalChart.country,
    );
    _timeZoneId = natalChart.timeZoneId;
    if (_selectedBirthPlace != null) {
      _timeZoneId = _selectedBirthPlace!.timeZoneId;
    }
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _utcOffsetController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _generateChart() async {
    if (_selectedBirthPlace != null) {
      _applyBirthPlace(_selectedBirthPlace!);
    } else {
      await _tryResolveBirthPlaceFromManualFields();
      if (_selectedBirthPlace != null) {
        _applyBirthPlace(_selectedBirthPlace!);
      }
    }

    final subjectName = _subjectNameController.text.trim();
    final birthDate = _birthDateController.text.trim();
    final birthTime = _birthTimeController.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final country = _countryController.text.trim();
    final latitudeText = _latitudeController.text.trim();
    final longitudeText = _longitudeController.text.trim();
    final latitude = double.tryParse(latitudeText);
    final longitude = double.tryParse(longitudeText);

    if (birthDate.isEmpty ||
        city.isEmpty ||
        country.isEmpty ||
        latitudeText.isEmpty ||
        longitudeText.isEmpty) {
      setState(() {
        _errorMessage =
            'Completa fecha, país, ciudad, UTC offset y coordenadas para generar la carta.';
      });
      return;
    }

    if (!RegExp(r'^(\d{4}-\d{2}-\d{2}|\d{2}-\d{2}-\d{4})$')
        .hasMatch(birthDate)) {
      setState(() {
        _errorMessage = 'La fecha debe tener formato DD-MM-YYYY o YYYY-MM-DD.';
      });
      return;
    }

    if (!_birthTimeUnknown &&
        !RegExp(r'^(\d{2}:\d{2}|\d{2}:\d{2}:\d{2})$').hasMatch(birthTime)) {
      setState(() {
        _errorMessage =
            'La hora debe tener formato HH:MM o HH:MM:SS, o marcar hora desconocida.';
      });
      return;
    }

    if (_timeZoneId.isNotEmpty) {
      try {
        final offsetResult = await widget.onResolveUtcOffset(
          birthDate: birthDate,
          birthTime: _birthTimeUnknown ? '' : birthTime,
          birthTimeUnknown: _birthTimeUnknown,
          timeZoneId: _timeZoneId,
        );
        _utcOffsetController.text = offsetResult.utcOffset;
      } catch (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _errorMessage = error.toString().replaceFirst('Exception: ', '');
        });
        return;
      }
    }

    final utcOffset = _utcOffsetController.text.trim();
    if (!RegExp(r'^[+-]\d{2}:\d{2}$').hasMatch(utcOffset)) {
      setState(() {
        _errorMessage = 'El UTC offset debe tener formato +/-HH:MM.';
      });
      return;
    }

    if (latitude == null || latitude < -90 || latitude > 90) {
      setState(() {
        _errorMessage = 'La latitud debe estar entre -90 y 90.';
      });
      return;
    }

    if (longitude == null || longitude < -180 || longitude > 180) {
      setState(() {
        _errorMessage = 'La longitud debe estar entre -180 y 180.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final locationLabel = [city, state, country]
        .where((item) => item.trim().isNotEmpty)
        .join(', ');
    try {
      final saveError = await widget.onSaveProfile(
        UpdateProfileInput(
          location: locationLabel,
          zodiacSign: '',
          subjectName: subjectName,
          birthDate: birthDate,
          birthTime: _birthTimeUnknown ? '' : birthTime,
          birthTimeUnknown: _birthTimeUnknown,
          city: city,
          state: state,
          country: country,
          timeZoneId: _timeZoneId,
          utcOffset: utcOffset,
          latitude: latitude,
          longitude: longitude,
        ),
      );

      if (saveError != null) {
        setState(() {
          _isLoading = false;
          _errorMessage = saveError;
        });
        return;
      }

      final result = await widget.onGenerate(
        AstroRequestInput(
          subjectName: subjectName.isEmpty ? null : subjectName,
          birthDate: birthDate,
          birthTime: _birthTimeUnknown ? '' : birthTime,
          birthTimeUnknown: _birthTimeUnknown,
          utcOffset: utcOffset,
          timeZoneId: _timeZoneId.isEmpty ? null : _timeZoneId,
          selectedPlanets: _orderedSelectedPlanetKeys,
          nodeType: _nodeType,
          lilithType: _lilithType,
          arabicPartsMode: _arabicPartsMode,
          technicalPoints: _orderedTechnicalPointKeys,
          latitude: latitude,
          longitude: longitude,
          locationLabel: locationLabel,
          houseSystem: _houseSystem,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _result = result;
        _selectedPlanetKeys
          ..clear()
          ..addAll(result.natalChart.meta.selectedPlanets);
        _nodeType = result.natalChart.meta.nodeType;
        _lilithType = result.natalChart.meta.lilithType;
        _arabicPartsMode = result.natalChart.meta.arabicPartsMode;
        _technicalPointKeys
          ..clear()
          ..addAll(result.natalChart.meta.technicalPoints);
        _selectedSection = _AstroFlowSection.wheel;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<_ChartExportPayload> _buildClassicChartImagePayload() async {
    final result = _result;
    if (result == null) {
      throw Exception('Primero genera una carta natal.');
    }

    final bytes = await _screenshotController.captureFromWidget(
      Material(
        color: Colors.transparent,
        child: _ChartWheelExportImage(result: result.natalChart),
      ),
      context: context,
      pixelRatio: 2.8,
    );

    final fileName =
        'carta-astral-${DateTime.now().millisecondsSinceEpoch}.png';
    return _ChartExportPayload(
      bytes: bytes,
      fileName: fileName,
    );
  }

  Future<String> _persistChartImage(_ChartExportPayload payload) async {
    final directory = await getTemporaryDirectory();
    final xFile = XFile.fromData(
      payload.bytes,
      mimeType: 'image/png',
      name: payload.fileName,
    );
    final path = '${directory.path}/${payload.fileName}';
    await xFile.saveTo(path);
    return path;
  }

  Future<void> _downloadChartImage() async {
    final result = _result;
    if (result == null || _isExporting) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final payload = await _buildClassicChartImagePayload();

      if (kIsWeb) {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                payload.bytes,
                mimeType: 'image/png',
                name: payload.fileName,
              ),
            ],
            fileNameOverrides: [payload.fileName],
            title: 'Carta astral Lo Renaciente',
            downloadFallbackEnabled: true,
          ),
        );

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La imagen se preparó para descarga desde el navegador.',
            ),
          ),
        );
        return;
      }

      final filePath = await _persistChartImage(payload);
      final saved = await chart_image_store.saveChartImage(filePath);

      if (!mounted) {
        return;
      }

      if (saved != true) {
        throw Exception(
          'No fue posible guardar la imagen en Fotos desde este dispositivo. Usa Compartir para guardarla en Archivos o Fotos.',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'La rueda natal se guardó en Fotos.',
          ),
          action: SnackBarAction(
            label: 'Compartir',
            onPressed: () {
              _shareChartImage(payload);
            },
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo generar la imagen de la carta: ${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _shareCurrentChartImage() async {
    if (_result == null || _isExporting) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final payload = await _buildClassicChartImagePayload();
      if (!mounted) {
        return;
      }
      await _shareChartImage(payload);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo compartir la carta: ${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _shareChartImage(_ChartExportPayload payload) async {
    final box = context.findRenderObject();
    final renderBox = box is RenderBox ? box : null;

    await SharePlus.instance.share(
      ShareParams(
        text:
            'Mi carta astral de Lo Renaciente. Puedes guardarla tambien en Archivos o compartirla.',
        files: [
          XFile.fromData(
            payload.bytes,
            mimeType: 'image/png',
            name: payload.fileName,
          ),
        ],
        fileNameOverrides: [payload.fileName],
        subject: 'Carta astral Lo Renaciente',
        sharePositionOrigin: renderBox == null
            ? null
            : renderBox.localToGlobal(Offset.zero) & renderBox.size,
      ),
    );
  }

  Future<void> _tryResolveBirthPlaceFromManualFields() async {
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final country = _countryController.text.trim();
    final latitudeFilled = _latitudeController.text.trim().isNotEmpty;
    final longitudeFilled = _longitudeController.text.trim().isNotEmpty;
    final utcFilled = _utcOffsetController.text.trim().isNotEmpty;
    final timeZoneFilled = _timeZoneId.trim().isNotEmpty;

    if (city.isEmpty || country.isEmpty) {
      return;
    }
    if (latitudeFilled && longitudeFilled && utcFilled && timeZoneFilled) {
      return;
    }

    final query = [city, if (state.isNotEmpty) state, country].join(', ');
    try {
      final matches = await widget.onSearchBirthPlaces(query);
      if (!mounted || matches.isEmpty) {
        return;
      }

      final normalizedCity = _normalizePlaceText(city);
      final normalizedState = _normalizePlaceText(state);
      final normalizedCountry = _normalizePlaceText(country);

      BirthPlaceOption? bestMatch;
      for (final item in matches) {
        final itemCity = _normalizePlaceText(item.city);
        final itemState = _normalizePlaceText(item.state);
        final itemCountry = _normalizePlaceText(item.country);
        if (itemCity == normalizedCity && itemCountry == normalizedCountry) {
          bestMatch = item;
          if (normalizedState.isEmpty || itemState == normalizedState) {
            break;
          }
        }
      }

      final resolved = bestMatch ?? matches.first;
      setState(() {
        _selectedBirthPlace = resolved;
        _applyBirthPlace(resolved);
      });
    } catch (_) {
      return;
    }
  }

  void _applyBirthPlace(BirthPlaceOption place) {
    _cityController.text = place.city;
    _countryController.text = place.country;
    if (place.state.trim().isNotEmpty) {
      _stateController.text = place.state;
    } else if (_stateController.text.trim().isEmpty) {
      _stateController.text = place.country;
    }
    _timeZoneId = place.timeZoneId;
    _utcOffsetController.text = place.utcOffset;
    _latitudeController.text = place.latitude.toString();
    _longitudeController.text = place.longitude.toString();
  }

  List<String> get _orderedSelectedPlanetKeys {
    return _planetSelectionOptions
        .map((item) => item.key)
        .where(_selectedPlanetKeys.contains)
        .toList();
  }

  List<String> get _orderedTechnicalPointKeys {
    return _technicalPointOptions
        .map((item) => item.key)
        .where(_technicalPointKeys.contains)
        .toList();
  }

  String _normalizePlaceText(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  Widget _buildIntroHero(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF182127),
            Color(0xFF354A4D),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activa tu motor natal',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Esta sección ya usa el motor propio de Lo Renaciente para calcular carta natal, tránsitos, revoluciones y eventos próximos.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(label: Text('Carta natal')),
              Chip(label: Text('Tránsitos')),
              Chip(label: Text('Revoluciones')),
              Chip(label: Text('Eclipses')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNatalDataSection() {
    return _SectionCard(
      title: 'Datos natales',
      child: Column(
        children: [
          TextField(
            controller: _subjectNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre (opcional)',
              hintText: 'Nombre de la carta',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _birthDateController,
            decoration: const InputDecoration(
              labelText: 'Fecha de nacimiento',
              hintText: '00-00-0000',
            ),
          ),
          const SizedBox(height: 14),
          SwitchListTile.adaptive(
            value: _birthTimeUnknown,
            contentPadding: EdgeInsets.zero,
            title: const Text('Hora de nacimiento desconocida'),
            subtitle: const Text(
              'Si no conoces la hora exacta, el sistema calculará con una referencia media y la marcará como no exacta.',
            ),
            onChanged: (value) {
              setState(() {
                _birthTimeUnknown = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _birthTimeController,
                  enabled: !_birthTimeUnknown,
                  decoration: const InputDecoration(
                    labelText: 'Hora de nacimiento',
                    hintText: '00:00:00',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeZoneField()),
            ],
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
          _buildHouseSystemSelector(),
          const SizedBox(height: 12),
          _buildCalculationConfiguration(),
          const SizedBox(height: 16),
          _buildLocationSummary(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _showManualLocationFields = !_showManualLocationFields;
                      });
                    },
              icon: Icon(
                _showManualLocationFields
                    ? Icons.expand_less_rounded
                    : Icons.tune_rounded,
              ),
              label: Text(
                _showManualLocationFields
                    ? 'Ocultar edición técnica'
                    : 'Editar datos técnicos manualmente',
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _showManualLocationFields
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildManualLocationFields(),
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null) _buildErrorBanner(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _generateChart,
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generar carta astral'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeZoneField() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Zona horaria',
      ),
      child: Text(
        _timeZoneId.isEmpty ? 'Sin resolver' : _timeZoneId,
        style: TextStyle(
          color: _timeZoneId.isEmpty
              ? const Color(0xFF867A6C)
              : const Color(0xFF1E252B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHouseSystemSelector() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _HouseSystemChip(
            label: 'Placidus',
            selected: _houseSystem == 'placidus',
            onSelected: _isLoading
                ? null
                : () => setState(() {
                      _houseSystem = 'placidus';
                    }),
          ),
          _HouseSystemChip(
            label: 'Whole Sign',
            selected: _houseSystem == 'whole_sign',
            onSelected: _isLoading
                ? null
                : () => setState(() {
                      _houseSystem = 'whole_sign';
                    }),
          ),
          _HouseSystemChip(
            label: 'Equal',
            selected: _houseSystem == 'equal',
            onSelected: _isLoading
                ? null
                : () => setState(() {
                      _houseSystem = 'equal';
                    }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationConfiguration() {
    return _CalculationConfigurationPanel(
      selectedPlanetKeys: _selectedPlanetKeys,
      nodeType: _nodeType,
      lilithType: _lilithType,
      arabicPartsMode: _arabicPartsMode,
      selectedTechnicalPointKeys: _technicalPointKeys,
      isLoading: _isLoading,
      onPlanetChanged: (key, selected) {
        setState(() {
          if (selected) {
            _selectedPlanetKeys.add(key);
          } else if (_selectedPlanetKeys.length > 1) {
            _selectedPlanetKeys.remove(key);
          }
        });
      },
      onNodeTypeChanged: (value) {
        setState(() {
          _nodeType = value;
        });
      },
      onLilithTypeChanged: (value) {
        setState(() {
          _lilithType = value;
        });
      },
      onArabicPartsModeChanged: (value) {
        setState(() {
          _arabicPartsMode = value;
        });
      },
      onTechnicalPointChanged: (key, selected) {
        setState(() {
          if (selected) {
            _technicalPointKeys.add(key);
          } else if (_technicalPointKeys.length > 1) {
            _technicalPointKeys.remove(key);
          }
        });
      },
    );
  }

  Widget _buildLocationSummary() {
    final locationText = _cityController.text.isEmpty
        ? 'Aún no seleccionaste un lugar natal'
        : [
            _cityController.text,
            _stateController.text,
            _countryController.text,
          ].where((item) => item.trim().isNotEmpty).join(', ');

    final technicalText = _utcOffsetController.text.isEmpty
        ? 'Selecciona una ciudad del listado para completar automáticamente los datos técnicos.'
        : 'UTC ${_utcOffsetController.text} · Lat ${_latitudeController.text} · Lon ${_longitudeController.text}';

    return Container(
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
            locationText,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(technicalText),
          if (_timeZoneId.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              _timeZoneId,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF6A625B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualLocationFields() {
    return Column(
      children: [
        TextField(
          controller: _countryController,
          decoration: const InputDecoration(
            labelText: 'País',
            hintText: 'Perú',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _stateController,
          decoration: const InputDecoration(
            labelText: 'Provincia o estado',
            hintText: 'Opcional o para carga manual',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: 'Ciudad',
            hintText: 'Selecciona o escribe manualmente',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _utcOffsetController,
          decoration: const InputDecoration(
            labelText: 'UTC offset',
            hintText: '-05:00',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Latitud',
                  hintText: '-12.0464',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Longitud',
                  hintText: '-77.0428',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECE8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
          color: Color(0xFF8B2C1F),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFlowContent(ThemeData theme) {
    switch (_selectedSection) {
      case _AstroFlowSection.setup:
        return Column(
          key: const ValueKey('astro-setup'),
          children: [
            _buildNatalDataSection(),
            const SizedBox(height: 16),
            if (_result == null)
              _SectionCard(
                title: 'Vista previa',
                child: Text(
                  'Completa los datos natales y toca "Generar carta astral" para pasar a la rueda, la lectura técnica y los tiempos activos sin cargar toda la pantalla de una sola vez.',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
          ],
        );
      case _AstroFlowSection.wheel:
        if (_result == null) {
          return _buildFlowEmptyState(
            key: const ValueKey('astro-wheel-empty'),
            title: 'Genera la carta primero',
            subtitle:
                'La rueda, la descarga PNG y la ficha técnica aparecerán aquí apenas calcules tu carta natal.',
          );
        }
        return Column(
          key: const ValueKey('astro-wheel'),
          children: [
            _buildResultActions(),
            const SizedBox(height: 16),
            AstroChartWheelCard(result: _result!.natalChart),
          ],
        );
      case _AstroFlowSection.essence:
        if (_result == null) {
          return _buildFlowEmptyState(
            key: const ValueKey('astro-essence-empty'),
            title: 'Tu lectura central aún no está lista',
            subtitle:
                'Cuando generes la carta verás Sol, Luna, Ascendente, regencias, dominantes e interpretación en este bloque.',
          );
        }
        return Column(
          key: const ValueKey('astro-essence'),
          children: [
            _BigThreeCard(result: _result!.natalChart),
            const SizedBox(height: 16),
            _TriadDetailsCard(result: _result!.natalChart),
            const SizedBox(height: 16),
            _RulershipsCard(result: _result!.natalChart),
            const SizedBox(height: 16),
            _DominantsCard(result: _result!.natalChart),
            const SizedBox(height: 16),
            _MidheavenCard(result: _result!.natalChart),
            const SizedBox(height: 16),
            _buildInterpretationSection(_result!.natalChart),
          ],
        );
      case _AstroFlowSection.technical:
        if (_result == null) {
          return _buildFlowEmptyState(
            key: const ValueKey('astro-technical-empty'),
            title: 'Todavía no hay técnica para revisar',
            subtitle:
                'Este espacio mostrará puntos técnicos, planetas, casas y aspectos principales cuando la carta esté calculada.',
          );
        }
        return Column(
          key: const ValueKey('astro-technical'),
          children: [
            _TechnicalPointsCard(result: _result!.natalChart),
            const SizedBox(height: 16),
            _buildPlanetsAndHousesSection(_result!.natalChart),
            const SizedBox(height: 16),
            _buildAspectsSection(_result!.natalChart),
          ],
        );
      case _AstroFlowSection.timing:
        if (_result == null) {
          return _buildFlowEmptyState(
            key: const ValueKey('astro-timing-empty'),
            title: 'Aún no tenemos tiempos activos',
            subtitle:
                'Tránsitos, revoluciones y eventos próximos aparecerán aquí cuando generes la carta.',
          );
        }
        return Column(
          key: const ValueKey('astro-timing'),
          children: [
            _buildTransitsSection(_result!),
            const SizedBox(height: 16),
            _buildReturnsSection(_result!),
            const SizedBox(height: 16),
            _buildEventsSection(_result!),
          ],
        );
    }
  }

  Widget _buildFlowEmptyState({
    required Key key,
    required String title,
    required String subtitle,
  }) {
    return _SectionCard(
      key: key,
      title: title,
      child: Text(subtitle),
    );
  }

  Widget _buildResultActions() {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _isExporting ? null : _downloadChartImage,
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            label: Text(
              _isExporting ? 'Generando imagen...' : 'Descargar carta',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isExporting ? null : _shareCurrentChartImage,
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('Compartir imagen'),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanetsAndHousesSection(AstroNatalChartResult natalChart) {
    return _SectionCard(
      title: 'Planetas y casas',
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: natalChart.planets
                .take(8)
                .map(
                  (planet) => _PillStat(
                    title: _displayAstroLabel(planet.label),
                    value:
                        '${planet.sign} · Casa ${planet.house}${planet.retrograde ? ' · R' : ''}',
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Column(
            children: natalChart.houses
                .take(12)
                .map(
                  (house) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          'Casa ${house.number}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${house.cuspDegreeFormatted} · Regente ${_displayAstroLabel(house.ruler)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectsSection(AstroNatalChartResult natalChart) {
    return _SectionCard(
      title: 'Aspectos principales',
      child: Column(
        children: natalChart.aspects
            .take(10)
            .map(
              (aspect) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${aspect.left} · ${aspect.right}'),
                subtitle: Text(
                  '${aspect.type} · ${_aspectPrecisionLabel(aspect.precision)}',
                ),
                trailing: Text(
                  'Orb ${aspect.orb.toStringAsFixed(1)}°/${aspect.maxOrb.toStringAsFixed(1)}°',
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInterpretationSection(AstroNatalChartResult natalChart) {
    return _SectionCard(
      title: 'Interpretación base',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: natalChart.interpretation
            .map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text('• $line'),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTransitsSection(AstroOverviewData result) {
    return _SectionCard(
      title: 'Transitos del momento',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fecha de cálculo: ${formatSchedule(result.transits.targetDateUtc)}',
          ),
          const SizedBox(height: 12),
          ...result.transits.highlights.take(6).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('• $item'),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildReturnsSection(AstroOverviewData result) {
    return _SectionCard(
      title: 'Revoluciones',
      child: Column(
        children: [
          _TimelineRow(
            label: 'Próxima revolución solar',
            value: formatSchedule(result.returns.solarReturn.startsAt),
            detail: result.returns.solarReturn.degree,
          ),
          const SizedBox(height: 12),
          _TimelineRow(
            label: 'Próxima revolución lunar',
            value: formatSchedule(result.returns.lunarReturn.startsAt),
            detail: result.returns.lunarReturn.degree,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection(AstroOverviewData result) {
    return _SectionCard(
      title: 'Eventos próximos',
      child: Column(
        children: [
          ...result.events.moonPhases.take(4).map(
                (event) => _TimelineRow(
                  label: event.label,
                  value: formatSchedule(event.startsAt),
                  detail: event.kind,
                ),
              ),
          if (result.events.eclipses.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...result.events.eclipses.take(4).map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TimelineRow(
                      label: event.label,
                      value: formatSchedule(event.startsAt),
                      detail: event.visibility.isEmpty
                          ? event.sourceLabel.isEmpty
                              ? event.kind
                              : '${event.kind} · ${event.sourceLabel}'
                          : event.sourceLabel.isEmpty
                              ? '${event.kind} · ${event.visibility}'
                              : '${event.kind} · ${event.visibility} · ${event.sourceLabel}',
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const sections = <MysticFlowOption>[
      MysticFlowOption(
        label: 'Configura',
        caption: 'Datos natales y ajustes',
        glyphKind: MysticGlyphKind.person,
      ),
      MysticFlowOption(
        label: 'Rueda',
        caption: 'Carta, ficha y exportación',
        glyphKind: MysticGlyphKind.astral,
      ),
      MysticFlowOption(
        label: 'Esencia',
        caption: 'Tríada, regencias y sentido',
        glyphKind: MysticGlyphKind.subscription,
      ),
      MysticFlowOption(
        label: 'Técnica',
        caption: 'Puntos, casas y aspectos',
        glyphKind: MysticGlyphKind.generic,
      ),
      MysticFlowOption(
        label: 'Tiempo',
        caption: 'Tránsitos y eventos',
        glyphKind: MysticGlyphKind.ritual,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carta Astral'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _buildIntroHero(theme),
          const SizedBox(height: 18),
          MysticFlowNavigator(
            items: sections,
            selectedIndex: _AstroFlowSection.values.indexOf(_selectedSection),
            onSelect: (index) {
              setState(() {
                _selectedSection = _AstroFlowSection.values[index];
              });
            },
            accent: const Color(0xFF355B52),
          ),
          const SizedBox(height: 18),
          MysticSlideSwitcher(
            child: _buildFlowContent(theme),
          ),
        ],
      ),
    );
  }
}

class _ChartExportPayload {
  const _ChartExportPayload({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;
}
