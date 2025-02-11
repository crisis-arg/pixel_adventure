import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/levels.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xff211f30);

  late CameraComponent cam;

  late JoystickComponent joystick;
  bool showJoystick = kIsWeb;
  bool playSound = true;
  double soundVolume = 1.0;
  List<String> levelNames = ['level-05', 'level-02', 'level-03', 'level-04'];
  List<String> background = ['Green', 'Pink', 'Purple', 'Brown'];
  int currentLevelIndex = 0;
  int backgroundIndex = 0;

  List<String> characterName = [
    'Pink Man',
    'Mask Dude',
    'Virtual Guy',
    'Ninja Frog'
  ];
  int characterIndex = 0;

  Player player = Player();

  @override
  FutureOr<void> onLoad() async {
    //Load al images into cache
    await images.loadAllImages();

    _loadLevel();

    if (!showJoystick) {
      add(JumpButton());
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
      margin: const EdgeInsets.only(left: 75, bottom: 60),
      //  position: Vector2(70, size.y - 80),
    );
    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
      case JoystickDirection.left:
        if (player.isRockHead) {
          player.horizontalMovement = 0;
        } else {
          player.horizontalMovement = -1;
        }
        break;
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
      case JoystickDirection.right:
        if (player.isRockHead) {
          player.horizontalMovement = 0;
        } else {
          player.horizontalMovement = 1;
        }
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Levels);
    if (currentLevelIndex < levelNames.length - 1) {
      backgroundIndex++;
      currentLevelIndex++;
      characterIndex++;
      _loadLevel();
    } else {
      backgroundIndex = 0;
      currentLevelIndex = 0;
      characterIndex = 0;
      _loadLevel();
    }
  }

  void restartLevel() {
    removeWhere((component) => component is Levels);
    _loadLevel();
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      FlameAudio.play('newLevel.wav');
      Levels world = Levels(
        levelName: levelNames[currentLevelIndex],
        player: player = Player(character: characterName[characterIndex]),
        backgroundColor: background[backgroundIndex],
      );
      cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640,
        height: 360,
      );
      cam.viewfinder.anchor = Anchor.topLeft;
      cam.priority = 0;

      addAll([cam, world]);
    });
  }
}
