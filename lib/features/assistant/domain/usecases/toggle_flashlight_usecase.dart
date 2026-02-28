import 'package:torch_light/torch_light.dart';
import '../../../../core/utils/result.dart';

class ToggleFlashlightUseCase {
  Future<Result<bool>> call({required bool turnOn}) async {
    try {
      final isTorchAvailable = await TorchLight.isTorchAvailable();
      if (!isTorchAvailable) {
        return Failure('Flashlight is not available on this device.');
      }

      if (turnOn) {
        await TorchLight.enableTorch();
        return Success(true);
      } else {
        await TorchLight.disableTorch();
        return Success(false);
      }
    } catch (e) {
      return Failure('Could not toggle flashlight: $e');
    }
  }
}
