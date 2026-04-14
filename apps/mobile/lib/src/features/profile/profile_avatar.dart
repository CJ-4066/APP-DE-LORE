import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/app_models.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    this.radius = 28,
  });

  final String firstName;
  final String lastName;
  final String avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final imageProvider = resolveAvatarImageProvider(avatarUrl);
    final initials = buildUserInitials(firstName, lastName);

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFF4E7D3),
      foregroundColor: const Color(0xFF182127),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}

ImageProvider<Object>? resolveAvatarImageProvider(String? avatarUrl) {
  final value = (avatarUrl ?? '').trim();
  if (value.isEmpty) {
    return null;
  }

  final bytes = decodeAvatarBytes(value);
  if (bytes != null) {
    return MemoryImage(bytes);
  }

  final uri = Uri.tryParse(value);
  if (uri != null && uri.hasScheme) {
    return NetworkImage(value);
  }

  return null;
}

Uint8List? decodeAvatarBytes(String? avatarUrl) {
  final value = (avatarUrl ?? '').trim();
  if (value.isEmpty) {
    return null;
  }

  final encoded = value.contains(',') ? value.split(',').last : value;
  try {
    return base64Decode(encoded);
  } catch (_) {
    return null;
  }
}

String buildUserInitials(String firstName, String lastName) {
  final first = firstName.trim();
  final last = lastName.trim();
  if (first.isNotEmpty && last.isNotEmpty) {
    return '${first[0]}${last[0]}'.toUpperCase();
  }
  if (first.isNotEmpty) {
    return first[0].toUpperCase();
  }
  if (last.isNotEmpty) {
    return last[0].toUpperCase();
  }

  return 'LR';
}

String displayUserName(UserProfile user) {
  final nickname = user.nickname.trim();
  if (nickname.isNotEmpty) {
    return nickname;
  }

  final fullName = '${user.firstName} ${user.lastName}'.trim();
  return fullName.isEmpty ? 'Lo Renaciente' : fullName;
}
