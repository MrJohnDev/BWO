import 'dart:math';
import 'dart:ui';

import 'package:BWO/Utils/TapState.dart';
import 'package:BWO/ui/ButtonListUI.dart';
import 'package:BWO/ui/ButtonUI.dart';
import 'package:flame/anchor.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';

import '../../game_controller.dart';

class MapPreviewWindows {
  Paint p = Paint();
  TextConfig location = TextConfig(
      fontSize: 10.0,
      color: Color.fromRGBO(216, 165, 120, 1),
      fontFamily: "Blocktopia");

  Offset targetPos = Offset.zero;
  Offset newTarget = Offset.zero;

  ButtonListUI _buttonListUI = ButtonListUI([
    "Starter Village",
    "North Village",
    "East Village",
    "South Village",
    "West Village",
  ], GameController.screenSize.width / 2, 50, 90, 20, indexSelected: 0);

  bool _isMapMovingToPosition = false;

  MapPreviewWindows() {
    _buttonListUI.onPressedListener(
      callback: (buttonName, buttonIndex) {
        if (buttonIndex == 0) {
          moveMapToPosition(Offset(0, 0));
        } else if (buttonIndex == 1) {
          moveMapToPosition(Offset(0, -750));
        } else if (buttonIndex == 2) {
          moveMapToPosition(Offset(750, 0));
        } else if (buttonIndex == 3) {
          moveMapToPosition(Offset(0, 750));
        } else if (buttonIndex == 4) {
          moveMapToPosition(Offset(-750, 0));
        }
      },
    );
  }

  void draw(Canvas c) {
    Rect bounds = Rect.fromLTWH(60, 95, 150, 150);

    double blockSize = 32;
    //targetPos += Offset(-.5, -.5);

    movingMapToPosition();
    if (TapState.currentClickingAt(bounds) && _isMapMovingToPosition == false) {
      targetPos -= TapState.deltaPositionFromStart(limit: 40) *
          GameController.deltaTime *
          3;
    }

    p.color = Color.fromRGBO(139, 123, 90, .16);

    var gridX = targetPos.dx ~/ blockSize;
    var gridY = targetPos.dy ~/ blockSize;

    String legend = "...Endless World";

    c.save();
    c.clipRect(bounds); //start drawning inside mini map objects

    for (int x = gridX - 3; x < gridX + 4; x++) {
      var offset = Offset(-x * blockSize, 0);
      c.drawLine(
        bounds.topCenter + offset + Offset(targetPos.dx, 0),
        bounds.bottomCenter + offset + Offset(targetPos.dx, 0),
        p,
      );
    }

    for (int y = gridY - 3; y < gridY + 4; y++) {
      var offset = Offset(0, -y * blockSize);
      c.drawLine(
        bounds.centerLeft + offset + Offset(0, targetPos.dy),
        bounds.centerRight + offset + Offset(0, targetPos.dy),
        p,
      );
    }

    legend = drawArea(c, 81000, bounds.center, bounds.center, legend,
        "Near the end", "Near the end Field");

    legend = drawArea(c, 9000, bounds.center, bounds.center, legend,
        "Where the good stuff is...", "Craft Field");
    legend = drawArea(c, 3000, bounds.center, bounds.center, legend,
        "*Players vs Player", "Open PVP Field");
    legend = drawArea(c, 1000, bounds.center, bounds.center, legend,
        "Monsters Will Hunt you!", "Hunters Field");
    legend = drawArea(c, 500, bounds.center, bounds.center, legend,
        "Training Area", "Noobie Field");

    legend = drawArea(c, 50, bounds.center, bounds.center, legend, "Safe Area",
        "Starter Village");
    legend = drawArea(c, 50, bounds.center + Offset(0, -750), bounds.center,
        legend, "Safe Area", "North Village");
    legend = drawArea(c, 50, bounds.center + Offset(0, 750), bounds.center,
        legend, "Safe Area", "South Village");
    legend = drawArea(c, 50, bounds.center + Offset(750, 0), bounds.center,
        legend, "Safe Area", "East Village");
    legend = drawArea(c, 50, bounds.center + Offset(-750, 0), bounds.center,
        legend, "Safe Area", "West Village");

    c.restore(); //finish drawning inside mini map objects

    p.color = Color.fromRGBO(216, 165, 120, 1);
    p.strokeWidth = 1;
    p.style = PaintingStyle.stroke;
    c.drawRect(bounds, p);

    p.color = Color.fromRGBO(216, 165, 120, 1);
    c.drawLine(bounds.centerLeft, bounds.centerRight, p);
    c.drawLine(bounds.topCenter, bounds.bottomCenter, p);

    location.render(c, " ${-targetPos.dx.toInt()}, ${-targetPos.dy.toInt()}",
        Position.fromOffset(bounds.center),
        anchor: Anchor.bottomLeft);

    location.render(c, " $legend", Position.fromOffset(bounds.bottomLeft),
        anchor: Anchor.bottomLeft);

    location.render(
        c, "Initial Location:", Position(bounds.right + 5, bounds.top + 0),
        anchor: Anchor.topLeft);

    /*_bCenterVillage
        .setBounds(Rect.fromLTWH(bounds.right + 5, bounds.top + 15, 100, 18));*/
    _buttonListUI.setPos(bounds.right + 5, bounds.top + 15);
    _buttonListUI.draw(c);
  }

  String drawArea(Canvas c, double distance, Offset point, Offset midPoint,
      String defaultLegend, String mLegend, String rectName) {
    String legend = defaultLegend;
    // safe area
    Rect safeCityArea = Rect.fromCenter(
        center: point + targetPos, width: distance * 2, height: distance * 2);

    p.color = Color.fromRGBO(216, 165, 120, 1);
    p.strokeWidth = 2;
    c.drawRect(safeCityArea, p);

    if (mLegend == "Safe Area") {
      Paint p2 = Paint();
      p2.color = Color.fromRGBO(216, 165, 120, .1);
      p2.style = PaintingStyle.fill;
      c.drawRect(safeCityArea, p2);
    }

    location.render(c, rectName, Position.fromOffset(safeCityArea.topLeft),
        anchor: Anchor.bottomLeft);

    Rectangle r1 = Rectangle(safeCityArea.left, safeCityArea.top,
        safeCityArea.width, safeCityArea.height);
    Rectangle r2 = Rectangle(midPoint.dx, midPoint.dy, 1, 1);

    if (r1.intersects(r2)) {
      legend = mLegend;
    }
    return legend;
  }

  void movingMapToPosition() {
    if (_isMapMovingToPosition) {
      double distance = (targetPos - newTarget).distance;

      if (distance < 1) {
        _isMapMovingToPosition = false;
        targetPos = newTarget;
      }

      targetPos =
          Offset.lerp(targetPos, newTarget, GameController.deltaTime * 4);
    }
  }

  void moveMapToPosition(Offset newTarget) {
    this.newTarget = -newTarget; //invert position to correct pos of map
    _isMapMovingToPosition = true;
  }
}
