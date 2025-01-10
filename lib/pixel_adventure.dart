import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/levels/levels.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents {
  @override
  Color backgroundColor() => const Color(0xff211f30);

  late final CameraComponent cam;
  final Player player = Player(character: 'Pink Man');


  @override
  FutureOr<void> onLoad() async {
    //Load al images into cache
    await images.loadAllImages();

    final world = Levels(
      levelName: 'level-02',
      player: player,
    );
    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);
    return super.onLoad();
  }
}
