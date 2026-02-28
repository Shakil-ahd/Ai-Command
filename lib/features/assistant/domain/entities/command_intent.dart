import 'package:equatable/equatable.dart';

/// The parsed result of intent detection on a raw command string.
class CommandIntent extends Equatable {
  final IntentType type;
  final String? targetAppName; // For OPEN_APP
  final String? targetContact; // For MAKE_CALL
  final String? url; // For OPEN_URL
  final String? searchQuery; // For YOUTUBE_SEARCH
  final String rawText;
  final List<CommandIntent> subCommands; // For MULTI_COMMAND

  const CommandIntent({
    required this.type,
    required this.rawText,
    this.targetAppName,
    this.targetContact,
    this.url,
    this.searchQuery,
    this.subCommands = const [],
  });

  @override
  List<Object?> get props => [
        type,
        targetAppName,
        targetContact,
        url,
        searchQuery,
        rawText,
      ];
}

enum IntentType {
  openApp,
  makeCall,
  openUrl,
  youtubeSearch,
  reopen, // "open it again"
  multiCommand, // multiple commands in one utterance
  unknown,
}
