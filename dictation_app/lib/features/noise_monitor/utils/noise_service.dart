import 'dart:async';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class NoiseService {
  bool _isRecording = false;
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  
  // Callbacks
  Function(double)? onData;
  Function(Object)? onError;

  Future<bool> checkPermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      status = await Permission.microphone.request();
      return status.isGranted;
    }
    return false;
  }

  void start() async {
    try {
      if (await checkPermission()) {
        _noiseMeter ??= NoiseMeter();
        _noiseSubscription = _noiseMeter?.noise.listen(
          (NoiseReading noiseReading) {
            if (onData != null) {
              // noiseReading.meanDecibel or maxDecibel
              onData!(noiseReading.meanDecibel);
            }
          },
          onError: (Object error) {
            if (onError != null) onError!(error);
            stop();
          },
        );
        _isRecording = true;
      } else {
        if (onError != null) onError!(Exception("Microphone permission denied"));
      }
    } catch (err) {
      if (onError != null) onError!(err);
    }
  }

  void stop() {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription!.cancel();
        _noiseSubscription = null;
      }
      _isRecording = false;
    } catch (err) {
      if (onError != null) onError!(err);
    }
  }

  bool get isRecording => _isRecording;
}
