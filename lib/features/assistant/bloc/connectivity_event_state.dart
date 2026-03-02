import 'package:equatable/equatable.dart';

abstract class ConnectivityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConnectivityChangedEvent extends ConnectivityEvent {
  final bool isConnected;
  ConnectivityChangedEvent(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

class CheckConnectivityEvent extends ConnectivityEvent {}

class ConnectivityState extends Equatable {
  final bool isConnected;

  const ConnectivityState({this.isConnected = true});

  @override
  List<Object?> get props => [isConnected];
}
