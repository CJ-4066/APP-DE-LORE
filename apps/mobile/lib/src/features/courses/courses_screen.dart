import 'package:flutter/material.dart';

import '../../core/widgets/mystic_ui.dart';
import '../../models/app_models.dart';

enum _LibrarySection {
  rituals,
  courses,
}

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({
    super.key,
    required this.data,
    required this.onRefresh,
  });

  final AppBootstrap data;
  final Future<void> Function() onRefresh;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  _LibrarySection _selectedSection = _LibrarySection.rituals;

  @override
  Widget build(BuildContext context) {
    final ritualsCount = 4;
    final coursesCount = widget.data.courses.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF8F1),
            Color(0xFFF8F3ED),
          ],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              MysticBannerCard(
                eyebrow: 'Biblioteca',
                title: 'Un hub simple para rituales y cursos',
                subtitle:
                    'Por ahora esta pestaña queda intencionalmente mínima para no competir con Inicio, Tarot y Citas.',
                glyphKind: MysticGlyphKind.course,
                gradient: const [
                  Color(0xFF1B2029),
                  Color(0xFF5B4B41),
                  Color(0xFFB68B61),
                ],
                tags: [
                  '$ritualsCount rituales base',
                  '$coursesCount cursos seed',
                  'menú reducido',
                  'listo para crecer',
                ],
                primaryLabel: 'Rituales',
                onPrimaryTap: () {
                  setState(() {
                    _selectedSection = _LibrarySection.rituals;
                  });
                },
                secondaryLabel: 'Cursos',
                onSecondaryTap: () {
                  setState(() {
                    _selectedSection = _LibrarySection.courses;
                  });
                },
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MenuChip(
                    label: 'Rituales',
                    selected: _selectedSection == _LibrarySection.rituals,
                    onTap: () {
                      setState(() {
                        _selectedSection = _LibrarySection.rituals;
                      });
                    },
                  ),
                  _MenuChip(
                    label: 'Cursos',
                    selected: _selectedSection == _LibrarySection.courses,
                    onTap: () {
                      setState(() {
                        _selectedSection = _LibrarySection.courses;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _selectedSection == _LibrarySection.rituals
                    ? _RitualsPanel(key: const ValueKey('rituals'))
                    : _CoursesPanel(
                        key: const ValueKey('courses'),
                        courses: widget.data.courses,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuChip extends StatelessWidget {
  const _MenuChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? const Color(0xFF5C4A40) : const Color(0xFF8A7669);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.26)
                : const Color(0xFFE7DED3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _RitualsPanel extends StatelessWidget {
  const _RitualsPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const rituals = [
      (
        'Apertura suave',
        'Respira, enciende una vela y escribe una intención concreta para el día.',
      ),
      (
        'Cierre de ruido',
        'Haz una pausa de 5 minutos, ordena tu mesa y anota qué energía no quieres arrastrar.',
      ),
      (
        'Ritual lunar breve',
        'Observa la fase actual, formula una pregunta y deja un solo gesto simbólico.',
      ),
      (
        'Protección simple',
        'Define un límite claro para hoy y repítelo antes de entrar a conversaciones intensas.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rituals
          .map(
            (ritual) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MysticMiniBanner(
                title: ritual.$1,
                subtitle: ritual.$2,
                glyphKind: MysticGlyphKind.ritual,
                accent: const Color(0xFF8B5A3C),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CoursesPanel extends StatelessWidget {
  const _CoursesPanel({
    super.key,
    required this.courses,
  });

  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return const MysticMiniBanner(
        title: 'No hay cursos cargados',
        subtitle:
            'Cuando quieras volver a expandir esta pestaña, aquí puede entrar el catálogo completo.',
        glyphKind: MysticGlyphKind.course,
        accent: Color(0xFF5C7A72),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: courses
          .take(4)
          .map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MysticMiniBanner(
                title: course.title,
                subtitle:
                    '${course.subtitle}\n${course.lessonCount} lecciones · ${course.estimatedHours.toStringAsFixed(1)} h',
                glyphKind: MysticGlyphKind.course,
                accent: const Color(0xFF5C7A72),
              ),
            ),
          )
          .toList(),
    );
  }
}
