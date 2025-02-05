import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class JumpPad extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  JumpPad({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  final double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Trampoline/Idle.png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime,
          textureSize: Vector2.all(28),
        ));
    return super.onLoad();
  }
}
