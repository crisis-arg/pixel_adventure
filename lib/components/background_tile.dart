import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;
  BackgroundTile({
    this.color = 'Gray',
    position,
  }) : super(position: position, priority: -1);

  @override
  FutureOr<void> onLoad() {
    size = Vector2.all(66.6);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));

    return super.onLoad();
  }
}
