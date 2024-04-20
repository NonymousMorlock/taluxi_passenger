import 'dart:async';

import 'package:flutter/material.dart';
import 'package:network_communication/network_communication.dart';
import 'package:real_time_location/real_time_location.dart';
import 'package:taluxi/pages/taxi_tracking_page/taxi_tracking_page.dart';
import 'package:taluxi/state_managers/call_state_manager.dart';
import 'package:taluxi_common/taluxi_common.dart';

class CallPage extends StatefulWidget {
  const CallPage({
    required this.callRecipients,
    required this.currentUserId,
    super.key,
    this.metadataTextColor = const Color(0xAD000000),
  });

  final List<Map<String, Coordinates>> callRecipients;
  final String currentUserId;
  final Color metadataTextColor;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late CallStateManager _callStateManager;
  var _connectionStateColorIndicator = mainLightColor;
  var _connectionStateTextIndicator = 'CONNEXION EN COURS';
  var _callMade = false;
  var _speakerIsOn = false;
  var _microphoneIsOn = true;

  @override
  void initState() {
    super.initState();
    _initializeStateManager();
  }

  Future<void> _initializeStateManager() async {
    _callStateManager = CallStateManager(
      callRecipients: widget.callRecipients,
      currenUserId: widget.currentUserId,
    );
    await _callStateManager.initialize();
    _callStateManager.callState.listen(_handleCallState);
    _callStateManager.connectionState.listen(_handleConnectionState);
  }

  @override
  void dispose() {
    _callStateManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return _callMade
        ? Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/call_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              constraints: const BoxConstraints.expand(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Column(
                    children: [
                      Text(
                        'Selena Gomez',
                        textScaler: TextScaler.linear(2.3),
                        maxLines: 1,
                      ),
                      SizedBox(height: 25),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://s.abcnews.com/images/GMA/selena-gomez-gty-jt-200204_hpMain_16x9_992.jpg',
                        ),
                        minRadius: 100,
                      ),
                    ],
                  ),
                  connectionStateIndicator(),
                  SizedBox(height: screenSize.height * .1),
                  callActionsControllers(),
                ],
              ),
            ),
          )
        : const WaitingPage(message: 'Appel en cours');
  }

  Widget connectionStateIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _connectionStateTextIndicator,
          style: TextStyle(color: widget.metadataTextColor),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          backgroundColor: _connectionStateColorIndicator,
          maxRadius: 8,
        ),
      ],
    );
  }

  Row callActionsControllers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          heroTag: 'speakerButton',
          backgroundColor: const Color(0xA2009CB8),
          child: Icon(
            Icons.volume_up,
            color: _speakerIsOn ? Colors.red : Colors.white,
          ),
          onPressed: () {
            _callStateManager.toggleSpeaker();
            setState(() => _speakerIsOn = !_speakerIsOn);
          },
        ),
        FloatingActionButton(
          heroTag: 'hangUpButton',
          backgroundColor: Colors.red,
          child: const Icon(Icons.call_end, size: 35),
          onPressed: () async {
            await _callStateManager.leaveCall();

            _showCallEndDialog();
          },
        ),
        FloatingActionButton(
          heroTag: 'microphoneButton',
          backgroundColor: const Color(0xA2009CB8),
          child: Icon(
            Icons.mic_off,
            color: _microphoneIsOn ? Colors.white : Colors.red,
          ),
          onPressed: () {
            _callStateManager.toggleMicrophone();
            setState(() => _microphoneIsOn = !_microphoneIsOn);
          },
        ),
      ],
    );
  }

  void _handleCallState(CallState callState) {
    if (callState is CallSuccess) return setState(() => _callMade = true);
    if (callState is NoResponse) return _suggestCallingNextDriver();
    if (callState is CallFailed) {
      return _suggestCallingNextDriver(callState.reason);
    }
    if (callState is CallLeft) return _showCallEndDialog(callState.reason);
    if (callState is CallRejected) {
      return _suggestCallingNextDriver("Le conducteur a raccroché l'appel");
    }
    if (callState is AllRecipientHaveBeenCalled) _suggestToTryAgainLater();
  }

  void _handleConnectionState(VoIPConnectionState connectionState) {
    switch (connectionState) {
      case VoIPConnectionState.connected:
        setState(() {
          _connectionStateTextIndicator = 'CONNEXION ÉTABLIE';
          _connectionStateColorIndicator = Colors.green;
        });
      case VoIPConnectionState.connecting:
        setState(() {
          _connectionStateColorIndicator = mainLightColor;
          _connectionStateTextIndicator = 'CONNEXION EN COURS';
        });
      case VoIPConnectionState.disconnected:
        setState(() {
          _connectionStateColorIndicator = Colors.red;
          _connectionStateTextIndicator = 'CONNEXION PERDUE';
        });
      case VoIPConnectionState.reconnecting:
        setState(() {
          _connectionStateColorIndicator = mainLightLessColor;
          _connectionStateTextIndicator = 'RECONNEXION EN COURS';
        });
    }
  }

  void _suggestCallingNextDriver([String? text]) {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        var autoCallCounter = 7;
        return StatefulBuilder(
          builder: (context, setState) {
            final autoCallTimer = Timer(
              const Duration(seconds: 1),
              () => setState(() {
                if (--autoCallCounter == 0) {
                  Navigator.of(context).pop();
                  _callStateManager.callNextRecipient();
                }
              }),
            );
            return AlertDialog(
              content: Text(text ?? "Le conducteur n'a pas pris l'appel"),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    autoCallTimer.cancel();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annulé'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainLightColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _callStateManager.callNextRecipient();
                  },
                  child: Text('Appeler un autre ($autoCallCounter)'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCallEndDialog([String? title]) {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title ?? "Vous avez raccrochez l'appel"),
          content: const Text(
            "Êtes vous tombés d'accord avec le conducteur avant la fin de "
            "l'appel pour qu'il vienne vous conduire à votre destination ?",
          ),
          actions: [
            Center(
              widthFactor: 2,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _callStateManager.callNextRecipient();
                    },
                    child: const Text('Non, appeler un autre'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      final dataOfDriverToTrack = widget.callRecipients[
                          _callStateManager.currentRecipientIndex];
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              TaxiTrackingPage(dataOfDriverToTrack),
                        ),
                      );
                    },
                    child: const Text('Oui, afficher sa position sur la carte'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _suggestToTryAgainLater() {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Désolé'),
          content: Text(
            'Nous avons tenté de joindre ${widget.callRecipients.length} '
            'conducteurs sans succès, veuillez réessayer plus tard.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
