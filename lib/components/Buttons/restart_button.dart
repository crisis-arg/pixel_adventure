import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class RestartButton extends SpriteComponent with HasGameRef<PixelAdventure> {
  RestartButton({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  final double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(
      game.images.fromCache('Menu/Buttons/Restart.png'),
    );
    return super.onLoad();
  }
}
