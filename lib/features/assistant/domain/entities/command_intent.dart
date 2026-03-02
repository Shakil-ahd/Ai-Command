import 'package:equatable/equatable.dart';

class CommandIntent extends Equatable {
  final IntentType type;
  final String? targetAppName;
  final String? targetContact;
  final String? url;
  final String? searchQuery;
  final String? targetSetting;
  final String rawText;
  final String? replyText;
  final List<CommandIntent> subCommands;

  const CommandIntent({
    required this.type,
    required this.rawText,
    this.targetAppName,
    this.targetContact,
    this.url,
    this.searchQuery,
    this.targetSetting,
    this.replyText,
    this.subCommands = const [],
  });

  factory CommandIntent.fromJson(Map<String, dynamic> json, String rawText) {
    try {
      final String typeString = json['type'] as String? ?? 'unknown';
      IntentType type = IntentType.values.firstWhere(
        (e) => e.name == typeString,
        orElse: () => IntentType.unknown,
      );

      return CommandIntent(
        type: type,
        rawText: rawText,
        targetAppName: json['targetAppName'] as String?,
        targetContact: json['targetContact'] as String?,
        url: json['url'] as String?,
        searchQuery: json['searchQuery'] as String?,
        targetSetting: json['targetSetting'] as String?,
        replyText: json['replyText'] as String?,
      );
    } catch (e) {
      return CommandIntent(type: IntentType.unknown, rawText: rawText);
    }
  }

  @override
  List<Object?> get props => [
        type,
        targetAppName,
        targetContact,
        url,
        searchQuery,
        targetSetting,
        rawText,
        replyText,
      ];
}

enum IntentType {
  openApp,
  makeCall,
  openUrl,
  youtubeSearch,
  reopen,
  multiCommand,
  turnOnFlashlight,
  turnOffFlashlight,
  turnOnWifi,
  turnOffWifi,
  turnOnBluetooth,
  turnOffBluetooth,
  openSettings,
  openCamera,
  generalChat,
  clearChat,
  noInternet,
  unknown,
}
