import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'connectivity_event_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;
  Timer? _periodicCheck;

  ConnectivityBloc() : super(const ConnectivityState()) {
    on<ConnectivityChangedEvent>((event, emit) {
      if (state.isConnected != event.isConnected) {
        emit(ConnectivityState(isConnected: event.isConnected));
      }
    });

    on<CheckConnectivityEvent>((event, emit) async {
      final isConnected = await _checkRealInternet();
      add(ConnectivityChangedEvent(isConnected));
    });

    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      await Future.delayed(const Duration(milliseconds: 500));
      final isConnected = await _checkRealInternet();
      add(ConnectivityChangedEvent(isConnected));
    });

    _periodicCheck = Timer.periodic(const Duration(seconds: 5), (_) {
      add(CheckConnectivityEvent());
    });

    add(CheckConnectivityEvent());
  }

  Future<bool> _checkRealInternet() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) return false;

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      final request = await client
          .headUrl(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 4));
      final response =
          await request.close().timeout(const Duration(seconds: 4));
      client.close(force: true);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> checkNow() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (results.contains(ConnectivityResult.none)) return false;

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      final request = await client
          .headUrl(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 4));
      final response =
          await request.close().timeout(const Duration(seconds: 4));
      client.close(force: true);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _periodicCheck?.cancel();
    return super.close();
  }
}
