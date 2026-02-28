import 'package:equatable/equatable.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();
  @override
  List<Object?> get props => [];
}

class CheckPermissionsEvent extends PermissionEvent {}

class RequestPermissionsEvent extends PermissionEvent {}

class OpenAppSettingsEvent extends PermissionEvent {}

// ── States ────────────────────────────────────────────────────────────────────

class PermissionState extends Equatable {
  final bool micGranted;
  final bool contactsGranted;
  final bool callGranted;
  final bool isChecking;

  const PermissionState({
    this.micGranted = false,
    this.contactsGranted = false,
    this.callGranted = false,
    this.isChecking = true,
  });

  bool get allCriticalGranted => micGranted;
  bool get allGranted => micGranted && contactsGranted && callGranted;

  PermissionState copyWith({
    bool? micGranted,
    bool? contactsGranted,
    bool? callGranted,
    bool? isChecking,
  }) {
    return PermissionState(
      micGranted: micGranted ?? this.micGranted,
      contactsGranted: contactsGranted ?? this.contactsGranted,
      callGranted: callGranted ?? this.callGranted,
      isChecking: isChecking ?? this.isChecking,
    );
  }

  @override
  List<Object?> get props =>
      [micGranted, contactsGranted, callGranted, isChecking];
}
