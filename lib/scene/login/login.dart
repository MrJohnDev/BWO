import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../game_controller.dart';
import '../../ui/button_ui.dart';
import '../../utils/preload_assets.dart';
import '../scene_object.dart';
import 'auth.dart';
import 'auth_methods/firebase_auth.dart';

class Login extends SceneObject {
  final TextPaint _version = TextPaint(
      style: TextStyle(
          fontSize: 11,
          color: Color.fromRGBO(216, 165, 120, 1),
          fontFamily: "Blocktopia"));
  final TextPaint _title = TextPaint(
      style: TextStyle(
          fontSize: 22,
          color: Color.fromRGBO(216, 165, 120, 1),
          fontFamily: "Blocktopia"));
  final TextPaint _text = TextPaint(
      style: TextStyle(
          fontSize: 16,
          color: Color.fromRGBO(216, 165, 120, 1),
          fontFamily: "Blocktopia"));
  String _versionName = "-";

  Sprite _backPaper;

  ButtonUI _loginButton;
  AuthService _auth;

  Login() {
    _backPaper = PreloadAssets.getBackPaper1();
    _loginButton = ButtonUI(
        super.hud,
        Rect.fromLTWH(
          GameController.screenSize.width / 2,
          GameController.screenSize.height * 0.7,
          190,
          30,
        ),
        "Sign in with Google",
        padding: Rect.fromLTWH(15, 0, 0, 0),
        icon: PreloadAssets.getGoogleIcon());

    _loginButton.onPressedListener = () {
      _auth?.login();
    };

    loadVersion().then((value) {
      _versionName = value;
      _auth = FirebaseAuth(_versionName);
    });
  }

  void draw(Canvas c) {
    if (_loginButton == null) return;
    super.draw(c);

    _backPaper.renderRect(c, GameController.screenSize);

    _version.render(c, "Version: $_versionName", Vector2(50, 50));

    _title.render(c, "> A letter from the Dev", Vector2(50, 80));
    _text.render(
      c,
      """Hello Adventures!\n
It's a pleasure to finnaly announce
this pre-alpha test release: v$_versionName!

Blah blah blah.. lorem ipsum...
I don't know yet how i'm going
to Make this screen, So until
then, it will show updates notes
:). Oh BTW I know this Text
is not Correctly positioned 
on your screen yet. hehe.

I thanks you all for the support.
By Dannark""",
      Vector2(GameController.screenSize.width / 2, 120),
      anchor: Anchor.topCenter,
    );

    _loginButton.setPosition(
      Rect.fromLTWH(GameController.screenSize.width / 2,
          GameController.screenSize.height * 0.7, 190, 30),
    );
    if (_auth != null) {
      _loginButton.draw(c);
    }
  }

  Future<String> loadVersion() async {
    try {
      var packageInfo = await PackageInfo.fromPlatform();
      var version = packageInfo.version;
      return version;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return '1.0.0';
    }
  }
}
