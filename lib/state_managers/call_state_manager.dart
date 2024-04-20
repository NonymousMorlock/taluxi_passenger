import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:network_communication/network_communication.dart';
import 'package:real_time_location/real_time_location.dart';
import 'package:taluxi_common/taluxi_common.dart';

class CallStateManager {
  CallStateManager({
    required List<Map<String, Coordinates>> callRecipients,
    required String currenUserId,
    VoIPProvider? voIPProvider,
  })  : _voIPPrivider = voIPProvider ?? VoIPProvider.instance,
        _callRecipients = callRecipients,
        _makingCallAudioPlayer = AudioPlayer(),
        _hangUpAudioPlayer = AudioPlayer(),
        _currentUserId = currenUserId;

  final VoIPProvider _voIPPrivider;
  final AudioPlayer _makingCallAudioPlayer;
  final AudioPlayer _hangUpAudioPlayer;
  final _callStateStreamController = StreamController<CallState>();
  final List<Map<String, Coordinates>> _callRecipients;

  // -1 because it will be incremented when calling event for the first call.
  int currentRecipientIndex = -1;

  final String _currentUserId;
  var _speakerIsOn = false;
  var _microphoneIsOn = true;

  Stream<CallState> get callState => _callStateStreamController.stream;

  Stream<VoIPConnectionState> get connectionState =>
      _voIPPrivider.connectionStateStream;

  Future<void> initialize() async {
    try {
      await _voIPPrivider.initialize(_currentUserId);
      await _makingCallAudioPlayer.initialize(
        fileName: 'assets/audio/make_call.mp3',
        loop: true,
      );
      await callNextRecipient();
      await _hangUpAudioPlayer.initialize(fileName: 'assets/audio/hang_up.mp3');
    } catch (e) {
      debugPrint('\n\n__Call_state_manage error init: $e ___\n\n');
    }
  }

  Future<void> callNextRecipient() async {
    if (++currentRecipientIndex >= _callRecipients.length) {
      return _callStateStreamController.add(AllRecipientHaveBeenCalled());
    }
    await _voIPPrivider.makeCall(
      callId: _currentUserId,
      recipientId: _callRecipients[currentRecipientIndex].keys.first,
      onCallSuccess: _onCallSuccess,
      onCallAccepted: _onCallAccepted,
      onCallFailed: _onCallFailed,
      onCallRejected: _onCallRejected,
      onCallLeft: _onCallLeft,
    );
  }

  Future<void> _onCallSuccess() async {
    _callStateStreamController.add(CallSuccess());
    await _makingCallAudioPlayer.play();
  }

  Future<void> _onCallAccepted() async => _makingCallAudioPlayer.stop();

  void _onCallFailed(CallFailureReason reason) {
    if (reason == CallFailureReason.timedOut) {
      _makingCallAudioPlayer.stop();
      _callStateStreamController.add(NoResponse());
    } else {
      _callStateStreamController.add(CallFailed());
    }
  }

  Future<void> _onCallRejected() async {
    await _makingCallAudioPlayer.stop();
    await _hangUpAudioPlayer.play();
    _callStateStreamController.add(CallRejected());
  }

  Future<void> _onCallLeft(CallLeaveReason reason) async {
    await _hangUpAudioPlayer.play();
    await Future<void>.delayed(
      const Duration(seconds: 2),
    ); // Wait the end of hang up sound
    if (reason == CallLeaveReason.hangUp) {
      _callStateStreamController.add(CallLeft());
    } else {
      _callStateStreamController
          .add(CallLeft(reason: 'La connexion du conducteur a été perdu'));
    }
  }

  void toggleSpeaker() {
    _speakerIsOn
        ? _voIPPrivider.disableSpeaker()
        : _voIPPrivider.enableSpeaker();
    _speakerIsOn = !_speakerIsOn;
  }

  Future<void> leaveCall() async {
    await _makingCallAudioPlayer.stop();
    await _voIPPrivider.leaveCall();
  }

  void toggleMicrophone() {
    _microphoneIsOn
        ? _voIPPrivider.disableMicrophone()
        : _voIPPrivider.enableMicrophone();
    _microphoneIsOn = !_microphoneIsOn;
  }

  // void setNewCallRecipients(List<Map<String, dynamic>> callRecipients) {
  //   _callRecipients = callRecipients;
  //   _currentRecipientIndex = 0;
  // }

  Future<void> dispose() async {
    await _voIPPrivider.destroy();
    await _makingCallAudioPlayer.dispose();
    await _hangUpAudioPlayer.dispose();
    await _callStateStreamController.close();
  }
}

class CallState {}

class AllRecipientHaveBeenCalled extends CallState {}

class CallSuccess extends CallState {}

// class CallAccepted extends CallState {}

class NoResponse extends CallState {}

class CallFailed extends CallState {
  CallFailed({this.reason = "Nous n'avons pas pu joindre le conducteur."});

  final String reason;
}

class CallLeft extends CallState {
  CallLeft({this.reason = 'Le conducteur a raccroché'});

  final String reason;
}

class CallRejected extends CallState {}
