import 'package:flutter/material.dart';

import '../../core/branding/renaciente_logo.dart';
import '../../core/i18n/app_i18n.dart';
import '../../core/data/birth_place_catalog.dart';
import '../../models/app_models.dart';
import '../../models/auth_models.dart';
import '../profile/birth_place_selector.dart';
import 'phone_countries.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.onContinue,
    required this.isBusy,
    this.errorMessage,
  });

  final PhoneCountry selectedCountry;
  final ValueChanged<PhoneCountry> onCountryChanged;
  final Future<void> Function(String phoneNumber) onContinue;
  final bool isBusy;
  final String? errorMessage;

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _AuthScaffold(
      title: l10n.tr('authPhoneTitle'),
      subtitle: l10n.tr('authPhoneSubtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownMenu<PhoneCountry>(
            initialSelection: widget.selectedCountry,
            width: double.infinity,
            enableFilter: true,
            enableSearch: true,
            label: Text(l10n.tr('country')),
            onSelected: (value) {
              if (value != null) {
                widget.onCountryChanged(value);
              }
            },
            dropdownMenuEntries: phoneCountries
                .map(
                  (country) => DropdownMenuEntry<PhoneCountry>(
                    value: country,
                    label: country.label,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.tr('phoneNumber'),
              prefixText: '${widget.selectedCountry.dialCode} ',
              hintText: '987654321',
            ),
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 12),
            _InlineError(message: widget.errorMessage!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.isBusy
                ? null
                : () => widget.onContinue(_phoneController.text),
            child: widget.isBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.tr('sendCode')),
          ),
        ],
      ),
    );
  }
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.debugCode,
    required this.onVerify,
    required this.onBack,
    required this.isBusy,
    this.errorMessage,
  });

  final String phoneNumber;
  final String debugCode;
  final Future<void> Function(String code) onVerify;
  final VoidCallback onBack;
  final bool isBusy;
  final String? errorMessage;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _AuthScaffold(
      title: l10n.tr('authOtpTitle'),
      subtitle: l10n.tr(
        'authOtpSubtitle',
        {'phone': widget.phoneNumber},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4E7D3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tr('demoCode'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  widget.debugCode,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: l10n.tr('securityCode'),
              hintText: '123456',
              counterText: '',
            ),
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 12),
            _InlineError(message: widget.errorMessage!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.isBusy
                ? null
                : () => widget.onVerify(_codeController.text),
            child: widget.isBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.tr('verifyCode')),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.isBusy ? null : widget.onBack,
            child: Text(l10n.tr('changeNumber')),
          ),
        ],
      ),
    );
  }
}

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({
    super.key,
    required this.phoneNumber,
    this.initialProfile,
    required this.onSave,
    required this.onSearchBirthPlaces,
    required this.isBusy,
    this.errorMessage,
  });

  final String phoneNumber;
  final UserProfile? initialProfile;
  final Future<void> Function(CompletePhoneProfileInput input) onSave;
  final Future<List<BirthPlaceOption>> Function(String query)
      onSearchBirthPlaces;
  final bool isBusy;
  final String? errorMessage;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _birthTimeController;
  BirthPlaceOption? _selectedBirthPlace;
  late String _accountType;

  @override
  void initState() {
    super.initState();
    final initialProfile = widget.initialProfile;
    final initialNatalChart = initialProfile?.natalChart;
    _firstNameController = TextEditingController(
      text: initialProfile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: initialProfile?.lastName ?? '',
    );
    _emailController = TextEditingController(text: initialProfile?.email ?? '');
    _birthDateController = TextEditingController(
      text: initialNatalChart?.birthDate ?? '',
    );
    _birthTimeController = TextEditingController(
      text: initialNatalChart?.birthTime ?? '',
    );
    _accountType =
        initialProfile?.accountType == 'specialist' ? 'specialist' : 'client';

    final initialCity = initialNatalChart?.city.trim() ?? '';
    final initialCountry = initialNatalChart?.country.trim() ?? '';
    _selectedBirthPlace = initialCity.isEmpty || initialCountry.isEmpty
        ? null
        : findBirthPlaceOption(
            city: initialCity,
            country: initialCountry,
          );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _birthTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _AuthScaffold(
      title: l10n.ts('Completa tu perfil'),
      subtitle: l10n.ts(
        'Teléfono verificado: {phone}. Antes de entrar necesitamos tus datos base para personalizar tarot, astrología y agenda.',
        {'phone': widget.phoneNumber},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.ts('Datos requeridos'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.ts(
              'Nombre, apellido, lugar de nacimiento, fecha y hora de nacimiento.',
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.ts('¿Cómo entrarás a la app?'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          _AccountTypeCard(
            title: l10n.ts('Cliente'),
            subtitle: l10n.ts(
              'Quiero comprar, reservar consultas, tomar cursos y participar en la comunidad.',
            ),
            icon: Icons.person_outline,
            selected: _accountType == 'client',
            onTap: () {
              setState(() {
                _accountType = 'client';
              });
            },
          ),
          const SizedBox(height: 10),
          _AccountTypeCard(
            title: l10n.ts('Especialista'),
            subtitle: l10n.ts(
              'Quiero gestionar consultas, precios, citas, contenido, comunidad y tienda.',
            ),
            icon: Icons.workspace_premium_outlined,
            selected: _accountType == 'specialist',
            onTap: () {
              setState(() {
                _accountType = 'specialist';
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(labelText: l10n.ts('Nombre')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(labelText: l10n.ts('Apellido')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.ts('Correo'),
              hintText: 'opcional@correo.com',
            ),
          ),
          const SizedBox(height: 12),
          BirthPlaceSelector(
            selectedPlace: _selectedBirthPlace,
            onSearchRemote: widget.onSearchBirthPlaces,
            onSelected: (value) {
              setState(() {
                _selectedBirthPlace = value;
              });
            },
            label: l10n.ts('Lugar de nacimiento'),
            hintText: l10n.ts('Busca ciudad y país'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _birthDateController,
            decoration: InputDecoration(
              labelText: l10n.ts('Fecha de nacimiento'),
              hintText: '2000-11-28',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _birthTimeController,
            decoration: InputDecoration(
              labelText: l10n.ts('Hora de nacimiento'),
              hintText: '01:40',
            ),
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 12),
            _InlineError(message: widget.errorMessage!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.isBusy
                ? null
                : () {
                    final place = _selectedBirthPlace;
                    if (place == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.ts(
                              'Selecciona tu lugar de nacimiento para completar coordenadas y zona horaria.',
                            ),
                          ),
                        ),
                      );
                      return;
                    }

                    widget.onSave(
                      CompletePhoneProfileInput(
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        email: _emailController.text,
                        city: place.city,
                        state: place.state,
                        country: place.country,
                        birthDate: _birthDateController.text,
                        birthTime: _birthTimeController.text,
                        timeZoneId: place.timeZoneId,
                        utcOffset: place.utcOffset,
                        latitude: place.latitude,
                        longitude: place.longitude,
                        accountType: _accountType,
                      ),
                    );
                  },
            child: widget.isBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.ts('Guardar perfil y entrar')),
          ),
        ],
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? const Color(0xFF5C3B52) : const Color(0xFF7A6B60);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF5C3B52).withValues(alpha: 0.10)
                : const Color(0xFFFFFCF8),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  selected ? const Color(0xFF5C3B52) : const Color(0xFFE8DAC7),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF182127),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF5E676E),
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF5E9),
              Color(0xFFFFFAF4),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RenacienteLogoLockup(
                  markSize: 68,
                  foregroundColor: Color(0xFF182127),
                  secondaryColor: Color(0xFF6B5C4D),
                  align: CrossAxisAlignment.start,
                  center: false,
                  showTagline: true,
                  tagline: 'Una lectura más limpia del momento',
                ),
                const SizedBox(height: 22),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9E2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF8B3A18),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
