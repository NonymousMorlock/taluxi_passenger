import 'package:flutter/material.dart';
import 'package:taluxi/pages/home_page/home_page.dart';
import 'package:taluxi/pages/welcome_page.dart';
import 'package:taluxi_common/taluxi_common.dart';

// TODOimplement Model view presenter (MVP):, but test widgets before.
// TODOcheck test code coverage
void main() async {
  runApp(
    const App(
      buildHomePage: HomePage.new,
      buildWelcomePage: WelcomePage.new,
    ),
  );
}
