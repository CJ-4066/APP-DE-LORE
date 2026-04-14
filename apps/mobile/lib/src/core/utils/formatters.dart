import '../../models/app_models.dart';

String formatMoney(Money amount) {
  final value = amount.amount % 1 == 0
      ? amount.amount.toStringAsFixed(0)
      : amount.amount.toStringAsFixed(2);
  return '${amount.currency} $value';
}

String formatSchedule(String isoString) {
  return _formatCalendarMoment(
    DateTime.parse(isoString).toLocal(),
    includeTime: true,
    includeYear: false,
  );
}

String formatTransitWindow(String startsAt, String endsAt) {
  final start = DateTime.parse(startsAt).toLocal();
  final end = DateTime.parse(endsAt).toLocal();
  final now = DateTime.now();
  final spansDifferentYears = start.year != end.year;
  final showStartYear = spansDifferentYears || start.year != now.year;
  final showEndYear = spansDifferentYears || end.year != now.year;

  return 'Vigente del ${_formatCalendarMoment(start, includeTime: false, includeYear: showStartYear)} al ${_formatCalendarMoment(end, includeTime: false, includeYear: showEndYear)}';
}

int specialistRatingStars(
  double rating, {
  int maxStars = 4,
  double scale = 5,
}) {
  final normalized = (rating / scale).clamp(0.0, 1.0);
  return (normalized * maxStars).round().clamp(0, maxStars).toInt();
}

int specialistRatingPercent(double rating, {double scale = 5}) {
  return ((rating / scale).clamp(0.0, 1.0) * 100).round();
}

String formatSpecialistRatingSummary(
  double rating, {
  int maxStars = 4,
  double scale = 5,
}) {
  final filledStars = specialistRatingStars(
    rating,
    maxStars: maxStars,
    scale: scale,
  );
  final emptyStars = maxStars - filledStars;
  final stars = '${'★' * filledStars}${'☆' * emptyStars}';
  return '$stars · ${specialistRatingPercent(rating, scale: scale)}%';
}

String _formatCalendarMoment(
  DateTime date, {
  required bool includeTime,
  required bool includeYear,
}) {
  const months = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];
  final month = months[date.month - 1];
  final yearText = includeYear ? ' ${date.year}' : '';
  if (!includeTime) {
    return '${date.day} $month$yearText';
  }

  final hours = date.hour.toString().padLeft(2, '0');
  final minutes = date.minute.toString().padLeft(2, '0');
  return '${date.day} $month$yearText · $hours:$minutes';
}

String joinList(List<String> items) {
  return items.join(' · ');
}
