import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
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
    this.canManageCourses = false,
  });

  final AppBootstrap data;
  final Future<void> Function() onRefresh;
  final bool canManageCourses;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  _LibrarySection _selectedSection = _LibrarySection.rituals;

  @override
  Widget build(BuildContext context) {
    if (widget.canManageCourses) {
      return _CourseManagerView(
        data: widget.data,
        onRefresh: widget.onRefresh,
      );
    }

    final ritualsCount = 4;
    final coursesCount = widget.data.courses.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppPalette.shellGradientTop,
            AppPalette.shellGradientBottom,
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
                  AppPalette.midnight,
                  AppPalette.indigo,
                  AppPalette.orchid,
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

class _CourseManagerView extends StatelessWidget {
  const _CourseManagerView({
    required this.data,
    required this.onRefresh,
  });

  final AppBootstrap data;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final courses = data.courses;
    final lessonCount = courses.fold<int>(
      0,
      (sum, course) => sum + course.lessonCount,
    );
    final featuredCount = courses.where((course) => course.featured).length;
    final premiumCount = courses.where((course) => course.premium).length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppPalette.shellGradientTop,
            AppPalette.shellGradientBottom,
          ],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              MysticBannerCard(
                eyebrow: 'Gestión académica',
                title: 'Cursos y PDFs',
                subtitle:
                    'Administra rutas formativas, lecciones, materiales descargables y estado de publicación.',
                glyphKind: MysticGlyphKind.course,
                gradient: const [
                  AppPalette.midnight,
                  AppPalette.indigo,
                  AppPalette.orchid,
                ],
                tags: [
                  '${courses.length} cursos',
                  '$lessonCount lecciones',
                  '$featuredCount destacados',
                  '$premiumCount premium',
                ],
                primaryLabel: 'Actualizar',
                onPrimaryTap: () {
                  onRefresh();
                },
              ),
              const SizedBox(height: 18),
              _CourseManagerMetrics(
                courseCount: courses.length,
                lessonCount: lessonCount,
                featuredCount: featuredCount,
                premiumCount: premiumCount,
              ),
              const SizedBox(height: 22),
              Text(
                'Contenido publicado',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppPalette.butterflyInk,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              if (courses.isEmpty)
                const MysticMiniBanner(
                  title: 'Sin cursos cargados',
                  subtitle:
                      'Cuando se conecte la creación de cursos, aquí se administrarán PDFs, módulos y lecciones.',
                  glyphKind: MysticGlyphKind.course,
                  accent: AppPalette.indigo,
                )
              else
                ...courses.map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CourseAdminCard(course: course),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseManagerMetrics extends StatelessWidget {
  const _CourseManagerMetrics({
    required this.courseCount,
    required this.lessonCount,
    required this.featuredCount,
    required this.premiumCount,
  });

  final int courseCount;
  final int lessonCount;
  final int featuredCount;
  final int premiumCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _CourseMetricTile(
              width: width,
              icon: Icons.auto_stories_outlined,
              label: 'Cursos',
              value: '$courseCount',
              color: AppPalette.indigo,
            ),
            _CourseMetricTile(
              width: width,
              icon: Icons.article_outlined,
              label: 'Lecciones/PDF',
              value: '$lessonCount',
              color: AppPalette.royalViolet,
            ),
            _CourseMetricTile(
              width: width,
              icon: Icons.auto_awesome_rounded,
              label: 'Destacados',
              value: '$featuredCount',
              color: AppPalette.flameGold,
            ),
            _CourseMetricTile(
              width: width,
              icon: Icons.workspace_premium_outlined,
              label: 'Premium',
              value: '$premiumCount',
              color: AppPalette.berry,
            ),
          ],
        );
      },
    );
  }
}

class _CourseMetricTile extends StatelessWidget {
  const _CourseMetricTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: AppPalette.moonIvory,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppPalette.border),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppPalette.butterflyInk,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppPalette.mutedLavender,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseAdminCard extends StatelessWidget {
  const _CourseAdminCard({
    required this.course,
  });

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.moonIvory,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppPalette.softLilac,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: AppPalette.indigo,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppPalette.butterflyInk,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  course.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.mutedLavender,
                        height: 1.32,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _CourseStatusPill(
                      label: '${course.lessonCount} lecciones',
                    ),
                    _CourseStatusPill(
                      label: '${course.estimatedHours.toStringAsFixed(1)} h',
                    ),
                    if (course.featured)
                      const _CourseStatusPill(label: 'Destacado'),
                    if (course.premium)
                      const _CourseStatusPill(label: 'Premium'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseStatusPill extends StatelessWidget {
  const _CourseStatusPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppPalette.petal,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppPalette.indigo,
              fontWeight: FontWeight.w900,
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
    final accent = selected ? AppPalette.indigo : AppPalette.mutedLavender;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppPalette.softLilac : AppPalette.moonIvory,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppPalette.borderStrong : AppPalette.border,
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
                accent: AppPalette.flameGold,
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
        accent: AppPalette.indigo,
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
                accent: AppPalette.indigo,
              ),
            ),
          )
          .toList(),
    );
  }
}
