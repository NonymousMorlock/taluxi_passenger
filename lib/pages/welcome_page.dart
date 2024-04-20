import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taluxi_common/taluxi_common.dart';
import 'package:user_manager/user_manager.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late AuthenticationProvider authProvider;
  bool waitDialogIsShown = false;
  bool signInRequested = false;
  final _buttonTextStyle = const TextStyle(fontSize: 20, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthenticationProvider>(context);
    if (authProvider.authState == AuthState.authenticating && signInRequested) {
      Future.delayed(Duration.zero, () async {
        waitDialogIsShown = true;
        showWaitDialog('Connexion en cours', context);
        signInRequested = false;
      });
    }
    final screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              colorFilter:
                  ColorFilter.mode(Color(0x65010101), BlendMode.luminosity),
              fit: BoxFit.cover,
              image: AssetImage('assets/images/bg.jpg'),
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Logo(
                  fontSize: 60,
                  taxiColor: Colors.white,
                  luxeColor: const Color(0xFFFFAE00),
                ),
                SizedBox(height: screenSize.height * .17),
                _loginButton(),
                const SizedBox(height: 20),
                _signUpButton(),
                const SizedBox(height: 20),
                const CustomDivider(),
                FacebookLoginButton(
                  onClick: () async {
                    signInRequested = true;
                    await authProvider
                        .signInWithFacebook()
                        .then(
                          (_) => Navigator.of(context)
                              .popUntil((route) => route.isFirst),
                        )
                        .catchError(_onSignInError);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSignInError(Object error) async {
    if (waitDialogIsShown) {
      Navigator.of(context).pop();
      waitDialogIsShown = false;
    }
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Echec de la connexion'),
          content: Text(error.toString()),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Fermer'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _loginButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) =>
                ChangeNotifierProvider<AuthenticationProvider>.value(
              value: authProvider,
              child: const AuthenticationPage(authType: AuthType.login),
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 14.5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xffdf8e33).withAlpha(100),
              offset: const Offset(2, 4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
          gradient: mainLinearGradient,
        ),
        child: Text(
          'Se connecter',
          style: _buttonTextStyle,
        ),
      ),
    );
  }

  Widget _signUpButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) =>
                ChangeNotifierProvider<AuthenticationProvider>.value(
              value: authProvider,
              child: const AuthenticationPage(authType: AuthType.signUp),
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0x10000000),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          'Créer un compte',
          style: _buttonTextStyle,
        ),
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    const divider = Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Divider(
          color: Colors.white,
          thickness: 1,
        ),
      ),
    );
    return const Row(
      children: [
        divider,
        Text(
          'ou',
          style: TextStyle(color: Colors.white),
        ),
        divider,
      ],
    );
  }
}
