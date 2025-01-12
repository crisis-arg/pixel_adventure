import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/levels.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(0xff211f30);

  late final CameraComponent cam;
  final Player player = Player(character: 'Pink Man');
  late JoystickComponent joystick;
  bool showJoystick = kIsWeb;

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
    cam.priority = 0;

    addAll([cam, world]);

    if (!showJoystick) {
      addJoystick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!showJoystick) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 1,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 38),
      //  position: Vector2(70, size.y - 80),
    );
    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
      case JoystickDirection.left:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
      case JoystickDirection.right:
        player.horizontalMovement = 1;
        break;
      default:
        // player.playerDirection = PlayerDirection.none;
        break;
    }
  }
}
