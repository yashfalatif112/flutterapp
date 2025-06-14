import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceMessageService {
  static final VoiceMessageService _instance = VoiceMessageService._internal();
  factory VoiceMessageService() => _instance;
  VoiceMessageService._internal();

  final _audioRecorder = AudioRecorder();
  AudioPlayer? _audioPlayer;
  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  Future<void> startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final directory = await getTemporaryDirectory();
        _currentRecordingPath = '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _currentRecordingPath!,
        );
        _isRecording = true;
      }
    } catch (e) {
      print('Error starting recording: $e');
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    
    try {
      await _audioRecorder.stop();
      _isRecording = false;
      return _currentRecordingPath;
    } catch (e) {
      print('Error stopping recording: $e');
      rethrow;
    }
  }

  Future<String> uploadVoiceMessage(String filePath, String chatId) async {
    try {
      final file = File(filePath);
      final fileName = 'voice_messages/$chatId/${DateTime.now().millisecondsSinceEpoch}.m4a';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      // Clean up the temporary file
      await file.delete();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading voice message: $e');
      rethrow;
    }
  }

  Future<void> playVoiceMessage(String url) async {
    try {
      if (_isPlaying) {
        await stopPlaying();
      }
      
      _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();
      
      await _audioPlayer!.play(UrlSource(url));
      _isPlaying = true;
      
      _audioPlayer!.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      print('Error playing voice message: $e');
      rethrow;
    }
  }

  Future<void> stopPlaying() async {
    if (_isPlaying && _audioPlayer != null) {
      await _audioPlayer!.stop();
      _isPlaying = false;
    }
  }

  void dispose() {
    _audioPlayer?.dispose();
    _audioRecorder.dispose();
  }
} 