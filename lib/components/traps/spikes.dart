import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Spikes extends SpriteComponent with HasGameRef<PixelAdventure> {
  double spikePosition;
  Spikes({
    this.spikePosition = 0,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  CustomHitbox topHitbox = CustomHitbox(
    offsetX: 3,
    offsetY: 0,
    width: 10,
    height: 8,
  );

   CustomHitbox bottomHitbox= CustomHitbox(
   offsetX: 3,
    offsetY: 8,
    width: 10,
    height: 8,
  );


  CustomHitbox leftHitbox = CustomHitbox(
    offsetX: 0,
    offsetY: 3,
    width: 8,
    height: 10,
  );

  CustomHitbox rightHitbox = CustomHitbox(
    offsetX: 8,
    offsetY: 3,
    width: 8,
    height: 10,
  );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    if (spikePosition == 1) {
      sprite = Sprite(game.images.fromCache('Traps/Spikes/Idle.png'));
     add(
        RectangleHitbox(
          position: Vector2(bottomHitbox.offsetX, bottomHitbox.offsetY),
          size: Vector2(bottomHitbox.width, bottomHitbox.height),
          collisionType: CollisionType.active,
        ),
      );
    }
    if (spikePosition == 2) {
      sprite = Sprite(game.images.fromCache('Traps/Spikes/spikeDown.png'));
        add(
        RectangleHitbox(
          position: Vector2(topHitbox.offsetX, topHitbox.offsetY),
          size: Vector2(topHitbox.width, topHitbox.height),
          collisionType: CollisionType.active,
        ),
      );
    }
    if (spikePosition == 3) {
      sprite = Sprite(game.images.fromCache('Traps/Spikes/spikeLeft.png'));
      add(
        RectangleHitbox(
          position: Vector2(leftHitbox.offsetX, leftHitbox.offsetY),
          size: Vector2(leftHitbox.width, leftHitbox.height),
          collisionType: CollisionType.active,
        ),
      );
    }
    if (spikePosition == 4) {
      sprite = Sprite(game.images.fromCache('Traps/Spikes/spikeRight.png'));
      add(
        RectangleHitbox(
          position: Vector2(rightHitbox.offsetX, rightHitbox.offsetY),
          size: Vector2(rightHitbox.width, rightHitbox.height),
          collisionType: CollisionType.active,
        ),
      );
    }

    return super.onLoad();
  }
}
