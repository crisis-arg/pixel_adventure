import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class RestartButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  RestartButton({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(
      game.images.fromCache('Menu/Buttons/Restart.png'),
    );
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.restartLevel();
    super.onTapDown(event);
  }
}
