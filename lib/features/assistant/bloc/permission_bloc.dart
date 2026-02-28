import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_event_state.dart';

/// Manages runtime permission checks and requests.
class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(const PermissionState()) {
    on<CheckPermissionsEvent>(_onCheck);
    on<RequestPermissionsEvent>(_onRequest);
    on<OpenAppSettingsEvent>(_onOpenSettings);
  }

  Future<void> _onCheck(
    CheckPermissionsEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(isChecking: true));
    final statuses = await [
      Permission.microphone,
      Permission.contacts,
      Permission.phone,
    ].request();

    emit(PermissionState(
      micGranted: statuses[Permission.microphone]?.isGranted ?? false,
      contactsGranted: statuses[Permission.contacts]?.isGranted ?? false,
      callGranted: statuses[Permission.phone]?.isGranted ?? false,
      isChecking: false,
    ));
  }

  Future<void> _onRequest(
    RequestPermissionsEvent event,
    Emitter<PermissionState> emit,
  ) async {
    await _onCheck(CheckPermissionsEvent(), emit);
  }

  Future<void> _onOpenSettings(
    OpenAppSettingsEvent event,
    Emitter<PermissionState> emit,
  ) async {
    await openAppSettings();
  }
}
