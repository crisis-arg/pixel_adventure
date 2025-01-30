import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CollisionsBlock extends PositionComponent {
  bool isPlatform;
  final double offNeg;
  final double offPos;
  CollisionsBlock({
    this.offNeg = 0,
    this.offPos = 0,
    this.isPlatform = false,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        ) {
    debugMode = true;
  }
  static const moveSpeed = 5;
  static const tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    rangeNeg = position.y - offNeg * tileSize;
    rangePos = position.y + offPos * tileSize;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isPlatform) {
      _movement(dt);
    }
    super.update(dt);
  }

  void _movement(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }
}
