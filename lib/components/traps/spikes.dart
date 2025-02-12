import 'dart:async';

import 'package:flame/components.dart';
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
  @override
  FutureOr<void> onLoad() {
    if (spikePosition == 1) {
      sprite = Sprite(game.images.fromCache('Traps/Spikes/Idle.png'));
    }
    if (spikePosition == 2) {
      sprite = Sprite(game.images.fromCache('Traps/Spikes/spikeDown.png'));
    }
     if (spikePosition == 3) {
      sprite = Sprite(game.images.fromCache('Traps/Spikes/spikeLeft.png'));
    }
     if (spikePosition == 4) {
      sprite = Sprite(game.images.fromCache('Traps/Spikes/spikeRight.png'));
    }

    return super.onLoad();
  }
}
