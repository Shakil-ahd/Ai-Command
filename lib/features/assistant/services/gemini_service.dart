import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/constants/api_constants.dart';
import '../domain/entities/command_intent.dart';

class GeminiService {
  GeminiService();

  Future<CommandIntent?> detectIntentWithGemini(String command) async {
    try {
      String apiKey = ApiConstants.geminiApiKey;
      if (apiKey == 'YOUR_GEMINI_API_KEY_HERE' || apiKey.isEmpty) return null;

      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final prompt = '''
You are "SakoAI", an intelligent smartphone assistant. The user will give you a command in English.
Determine the intent and return a raw JSON object ONLY! No markdown, no comments, no extra text.

You MUST also include a "replyText" field in the JSON with a conversational, friendly response confirming the action. 
CRITICAL RULE: The "replyText" MUST be in English.

Intent types are strictly: openApp, makeCall, openUrl, youtubeSearch, reopen, multiCommand, turnOnFlashlight, turnOffFlashlight, turnOnWifi, turnOffWifi, turnOnBluetooth, turnOffBluetooth, openSettings, openCamera, generalChat, clearChat, unknown.

If opening an app: {"type": "openApp", "targetAppName": "app name in english", "replyText": "Opening Facebook..."}
If calling someone: {"type": "makeCall", "targetContact": "contact name in english", "replyText": "Calling Mom now."}
If clearing or resetting chat/messages: {"type": "clearChat", "replyText": "Chat cleared."}
If opening website: {"type": "openUrl", "url": "valid url starting with https://", "replyText": "Opening website."}
If searching youtube: {"type": "youtubeSearch", "searchQuery": "search topic", "replyText": "Searching YouTube for flutter."}
If repeat/reopen: {"type": "reopen", "replyText": "Got it, opening it again."}
If turn on flashlight/torch: {"type": "turnOnFlashlight", "replyText": "Turning on the flashlight."}
If turn off flashlight/torch: {"type": "turnOffFlashlight", "replyText": "Turning off the flashlight."}
If turn on Wi-Fi: {"type": "turnOnWifi", "replyText": "Turning on Wi-Fi."}
If turn off Wi-Fi: {"type": "turnOffWifi", "replyText": "Turning off Wi-Fi."}
If turn on Bluetooth: {"type": "turnOnBluetooth", "replyText": "Turning on Bluetooth."}
If turn off Bluetooth: {"type": "turnOffBluetooth", "replyText": "Turning off Bluetooth."}
If opening settings (display or general): {"type": "openSettings", "targetSetting": "display or general", "replyText": "Opening settings."}
If opening camera to take photo: {"type": "openCamera", "replyText": "Opening camera."}
If asking who you are or what you can do: {"type": "generalChat", "replyText": "I am SakoAI. I can open apps, make calls, search YouTube, use the camera, control flashlight and settings like Wi-Fi or Bluetooth."}
If multiple commands: {"type": "multiCommand", "subCommands": [list of intent objects like the above], "replyText": "Running multiple tasks for you."}
If you don't understand completely, return {"type": "unknown", "replyText": "Sorry, I didn't understand that."}

Example user command: "turn on flashlight"
Return: {"type": "turnOnFlashlight", "replyText": "Turning on the flashlight."}

Example user command: "turn on wifi"
Return: {"type": "turnOnWifi", "replyText": "Turning on Wi-Fi."}

Example user command: "clear chat"
Return: {"type": "clearChat", "replyText": "Chat cleared."}

Example user command: "open facebook"
Return: {"type": "openApp", "targetAppName": "facebook", "replyText": "Opening facebook."}

User command: "$command"
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final resultText = response.text?.trim() ?? '';

      // Extract JSON using robust RegExp in case Gemini includes conversational filler
      String jsonStr = resultText;
      final jsonBlockRegex = RegExp(r'\{.*\}', dotAll: true);
      final match = jsonBlockRegex.firstMatch(resultText);

      if (match != null) {
        jsonStr = match.group(0)!;
      }

      final Map<String, dynamic> json = jsonDecode(jsonStr.trim());

      // Parse subCommands manually if present
      if (json['type'] == 'multiCommand' && json['subCommands'] is List) {
        final subs = (json['subCommands'] as List)
            .map((e) =>
                CommandIntent.fromJson(e as Map<String, dynamic>, command))
            .toList();
        return CommandIntent(
            type: IntentType.multiCommand, rawText: command, subCommands: subs);
      }

      return CommandIntent.fromJson(json, command);
    } catch (e) {
      print('[GeminiService] Error: \$e');
      return null;
    }
  }
}
