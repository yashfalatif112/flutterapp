import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraManager {
  static const String appId = '5d2a2254ac774f13bf57006c2df53a5b';
  late RtcEngine _engine;

  Future<void> initialize(String channelName) async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
    await _engine.enableVideo();
    await _engine.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  RtcEngine get engine => _engine;
}
