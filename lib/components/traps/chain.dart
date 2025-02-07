import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Chain extends SpriteComponent with HasGameRef<PixelAdventure> {
  bool isVertical;
  Chain({
    this.isVertical = false,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    if (isVertical) {
      sprite = Sprite(
        game.images.fromCache('Traps/Platforms/ChainV3.png'),
      );
    } else {
      sprite = Sprite(
        game.images.fromCache('Traps/Platforms/ChainH.png'),
      );
    }
    return super.onLoad();
  }
}
