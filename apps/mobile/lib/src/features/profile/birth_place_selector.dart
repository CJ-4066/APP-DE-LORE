import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/data/birth_place_catalog.dart';

class BirthPlaceSelector extends StatelessWidget {
  const BirthPlaceSelector({
    super.key,
    required this.selectedPlace,
    required this.onSelected,
    this.onSearchRemote,
    this.label = 'Lugar de nacimiento',
    this.hintText = 'Busca tu ciudad natal',
  });

  final BirthPlaceOption? selectedPlace;
  final ValueChanged<BirthPlaceOption?> onSelected;
  final Future<List<BirthPlaceOption>> Function(String query)? onSearchRemote;
  final String label;
  final String hintText;

  Future<void> _openSearch(BuildContext context) async {
    final selected = await showModalBottomSheet<BirthPlaceOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFBF6),
      builder: (_) => _BirthPlaceSearchSheet(
        selectedPlace: selectedPlace,
        hintText: hintText,
        onSearchRemote: onSearchRemote,
      ),
    );

    if (selected != null) {
      onSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = selectedPlace;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openSearch(context),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE6D3BE)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_city_rounded,
                  color: Color(0xFF6B4A2D),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: place == null
                      ? Text(
                          hintText,
                          style: const TextStyle(
                            color: Color(0xFF85786B),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.city,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D252B),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              place.locationLine,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF665D55),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.search_rounded),
              ],
            ),
          ),
        ),
        if (place != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EADB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Zona ${place.timeZoneId} · UTC ${place.utcOffset}'),
                const SizedBox(height: 2),
                Text(
                  'Lat ${place.latitude.toStringAsFixed(4)} · Lon ${place.longitude.toStringAsFixed(4)}',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BirthPlaceSearchSheet extends StatefulWidget {
  const _BirthPlaceSearchSheet({
    required this.selectedPlace,
    required this.hintText,
    this.onSearchRemote,
  });

  final BirthPlaceOption? selectedPlace;
  final String hintText;
  final Future<List<BirthPlaceOption>> Function(String query)? onSearchRemote;

  @override
  State<_BirthPlaceSearchSheet> createState() => _BirthPlaceSearchSheetState();
}

class _BirthPlaceSearchSheetState extends State<_BirthPlaceSearchSheet> {
  late final TextEditingController _queryController;
  Timer? _debounce;
  List<BirthPlaceOption> _results = const <BirthPlaceOption>[];
  bool _isLoading = false;
  int _searchToken = 0;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _results = searchBirthPlaceCatalog('', limit: 14);
    _queryController.addListener(_scheduleSearch);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController
      ..removeListener(_scheduleSearch)
      ..dispose();
    super.dispose();
  }

  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), _runSearch);
  }

  Future<void> _runSearch() async {
    final query = _queryController.text.trim();
    final local = searchBirthPlaceCatalog(query, limit: 14);
    final token = ++_searchToken;

    setState(() {
      _results = local;
      _isLoading = query.length >= 2 && widget.onSearchRemote != null;
    });

    if (query.length < 2 || widget.onSearchRemote == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final remote = await widget.onSearchRemote!(query);
      if (!mounted || token != _searchToken) {
        return;
      }

      setState(() {
        _results = _mergePlaces(local, remote);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || token != _searchToken) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 18 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _queryController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Buscar ciudad',
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: _results.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No encontré lugares con esa búsqueda. Prueba con ciudad, provincia o país.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final place = _results[index];
                        final isSelected = widget.selectedPlace?.id == place.id;

                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFB56F3A)
                                  : const Color(0xFFE7D7C6),
                            ),
                          ),
                          tileColor: isSelected
                              ? const Color(0xFFFFF2E4)
                              : Colors.white,
                          title: Text(
                            place.city,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${place.locationLine} · ${place.timeZoneId}',
                          ),
                          trailing: Text(
                            'UTC ${place.utcOffset}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onTap: () => Navigator.of(context).pop(place),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

List<BirthPlaceOption> _mergePlaces(
  List<BirthPlaceOption> local,
  List<BirthPlaceOption> remote,
) {
  final merged = <BirthPlaceOption>[];
  final seen = <String>{};

  for (final place in [...local, ...remote]) {
    final key = _normalizeBirthPlaceText(
      '${place.city}|${place.state}|${place.country}|${place.timeZoneId}',
    );
    if (seen.add(key)) {
      merged.add(place);
    }
  }

  return merged;
}

String _normalizeBirthPlaceText(String value) {
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
