import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/levels/levels.dart';

class PixelAdventure extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xff211f30);

  late final CameraComponent cam;

  @override
  FutureOr<void> onLoad() {
    final world = Levels();
    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);
    return super.onLoad();
  }
}
