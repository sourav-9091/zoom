import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:zoom/resources/auth_methods.dart';
import 'package:zoom/resources/firestore_methods.dart';

class JitsiMeetMethods {
  final AuthMethods _authMethods = AuthMethods();
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  final _jitsiMeetPlugin = JitsiMeet();

  void createMeeting({
    required String roomName,
    required bool isAudioMuted,
    required bool isVideoMuted,
    String username = '',
  }) async {
    try {
      String name;
      if (username.isEmpty) {
        name = _authMethods.user.displayName!;
      } else {
        name = username;
      }

      var options = JitsiMeetConferenceOptions(
        room: roomName,
        configOverrides: {
          "startWithAudioMuted": isAudioMuted,
          "startWithVideoMuted": isVideoMuted,
        },
        featureFlags: {
          FeatureFlags.welcomePageEnabled: false,
          FeatureFlags.resolution: FeatureFlagVideoResolutions.resolution360p,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: name,
          email: _authMethods.user.email,
          avatar: _authMethods.user.photoURL,
        ),
      );

      var listener = JitsiMeetEventListener(
        conferenceJoined: (url) {
          print("Conference joined: url: $url");
        },
        conferenceTerminated: (url, error) {
          print("Conference terminated: url: $url, error: $error");
        },
        conferenceWillJoin: (url) {
          print("Conference will join: url: $url");
        },
      );

      _firestoreMethods.addToMeetingHistory(roomName);
      await _jitsiMeetPlugin.join(options, listener);
    } catch (error) {
      print("error: $error");
    }
  }
}
