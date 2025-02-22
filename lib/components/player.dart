import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/collitions_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/components/traps/Lift.dart';
import 'package:pixel_adventure/components/traps/falling_platforms.dart';
import 'package:pixel_adventure/components/traps/jump_pad.dart';
import 'package:pixel_adventure/components/traps/rock_head.dart';
import 'package:pixel_adventure/components/traps/saw.dart';
import 'package:pixel_adventure/components/traps/spikes.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  hit,
  jump,
  doublejump,
  fall,
  walljump,
  appearing,
  disappearing,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;

  Player({
    position,
    this.character = 'Pink Man',
  }) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation doubleJumpAnimation;
  late final SpriteAnimation walljumpAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disppearingAnimation;

  final double stepTime = 0.05;
  final double _gravity = 9.8;
  late double _jumpForce = 260;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double movement = 1;
  final double wallSlideSpeed = 10;
  // double verticalMovement = 0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  List<CollisionsBlock> collisionsBlocks = [];
  Lift? lift;
  RockHead? rockHead;
  bool isOnGround = false;
  bool hasJumped = false;
  bool doubleJump = false;
  bool isTouchingWall = false;
  bool wallSlideState = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
  bool isJumpPad = false;
  bool isLift = false;
  bool isRockHeadH = false;
  bool isRockHeadV = false;
  bool isRockHeadCircularV = false;
  bool isRockHeadCircularH = false;
  bool jumpForDevice = kIsWeb;

  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    priority = 10;
    _loadAllAnimations();
    startingPosition = Vector2(position.x, position.y);
    // debugMode = true;
    // debugColor = Colors.white;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        if (lift != null) {
          movement = lift!.moveDirection;
        }
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollision();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollision();
        _wallSlide(fixedDeltaTime);
        // print('delta time: $dt');
      }
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD);

    if (!isRockHeadH) {
      horizontalMovement += isLeftKeyPressed ? -1 : 0;
      horizontalMovement += isRightKeyPressed ? 1 : 0;
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      hasJumped = true;
    }
    if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.space) {
      hasJumped = false;
    }

    // verticalMovement += hasJumped ? -1 : 1;

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    if (!reachedCheckpoint) {
      if (other is Fruit) {
        other.collidingWithPlayer();
      }
      if (other is Saw) {
        respawn();
      }
      if (other is Checkpoint) {
        _reachedCheckpoint();
      }
      if (other is FallingPlatforms) {
        other.isPlayer = true;
      }
      if (other is JumpPad) {
        isJumpPad = true;
      }

      if (other is Lift) {
        other.isPlayerOn = true;
        if (other.isVertical == false) {
          lift = other;
          isLift = true;
        }
      }

      if (other is CollisionsBlock) {
        other.isPlayerCollision = true;
        if (other.isVertical && other.isLift) {
          other.isPlayerOnLift = true;
        }
      }
      if (other is RockHead) {
        if (!other.isVertical && !other.isCircular) {
          isRockHeadH = true;
          rockHead = other;
          moveSpeed = other.moveSpeed;
          movement = other.moveDirection;
        } else if (other.isVertical && !other.isCircular) {
          isRockHeadV = true;
          rockHead = other;
          moveSpeed = other.moveSpeed;
          movement = other.moveDirection;
        } else if (other.isCircular) {
          if (other.isCircularV) {
            isRockHeadCircularV = true;
            rockHead = other;
            moveSpeed = other.moveSpeed;
            movement = other.moveDirection;
          } else {
            isRockHeadCircularH = true;
            rockHead = other;
            moveSpeed = other.moveSpeed;
            movement = other.moveDirection;
          }
        }
      }
      if (other is Spikes) {
        respawn();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    lift = null;
    isLift = false;    
    if (other is Lift) {
      other.isPlayerOn = false;
    }
    if (other is CollisionsBlock) {
      other.isPlayerOnLift = false;
    }
    if (other is RockHead) {
      rockHead = null;
      moveSpeed = 100;
      isRockHeadH = false;
      isRockHeadV = false;
      isRockHeadCircularV = false;
      isRockHeadCircularH = false;
      movement = 1;
    }
    super.onCollisionEnd(other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runAnimation = _spriteAnimation("Run", 12);
    hitAnimation = _spriteAnimation('Hit', 7)..loop = false;
    jumpAnimation = _spriteAnimation('Jump', 1);
    fallAnimation = _spriteAnimation('Fall', 1);
    doubleJumpAnimation = _spriteAnimation('Double Jump', 6);
    walljumpAnimation = _spriteAnimation('Wall Jump', 5);
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disppearingAnimation = _specialSpriteAnimation('Disappearing', 7);
    //List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.doublejump: doubleJumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.walljump: walljumpAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disppearingAnimation,
    };
    //set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        loop: false,
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    // velocity = Vector2(dirX, 0.0);
    position.x += velocity.x * dt;

    if (velocity.y > _gravity) isOnGround = false;

    if (isLift) {
      position.x += movement * 50 * dt;
    }
    if (isRockHeadH) {
      moveSpeed = moveSpeed * 1.01;
      position.x += movement * moveSpeed * dt;
    }
    if (isRockHeadV) {
      moveSpeed = moveSpeed * 1.01;
      position.y += movement * moveSpeed * dt;
    }
    if (isRockHeadCircularV) {
      moveSpeed = moveSpeed * 1.01;
      position.x += movement * moveSpeed * dt;
    } else if (isRockHeadCircularH) {
      moveSpeed = moveSpeed * 1.01;
      position.y += movement * moveSpeed * dt;
    }

    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }

    if (hasJumped && doubleJump) {
      _playerJump(dt);
      doubleJump = false;
    }

    if (isJumpPad) {
      _playerJump(dt);
      isJumpPad = false;
    }
  }

  void _playerJump(double dt) {
    if (game.playSound) {
      FlameAudio.play('jump.wav', volume: game.soundVolume * .50);
    }
    _jumpForce = isJumpPad ? 400 : 260;
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    hasJumped = false;
    isOnGround = false;
    doubleJump = true;
  }

  void _wallSlide(double dt) {
    if (isTouchingWall && !isOnGround && !isRockHeadH) {
      // isTouchingWall = false;
      velocity.y = wallSlideSpeed;
      // velocity.y = velocity.y.clamp(-_terminalVelocity, wallSlideSpeed);
      position.y += velocity.y * dt;
      wallSlideState = true;
    }
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    if (velocity.x < 0 || velocity.x > 0) {
      playerState = PlayerState.running;
    }
    if (velocity.y < 0) {
      playerState = PlayerState.jump;
      if (!doubleJump) {
        playerState = PlayerState.doublejump;
      }
    }
    if (velocity.y > _gravity) {
      playerState = PlayerState.fall;
      if (wallSlideState) {
        playerState = PlayerState.walljump;
        wallSlideState = false;
      }
    }

    current = playerState;
    // print(
    //     'velocity.x: ${velocity.x}, scale.x: ${scale.x}, playerState: $playerState , current: $current');
    // print("position: $position.x");
    // print('movement: $horizontalMovement');
  }

  void _checkHorizontalCollision() {
    for (final block in collisionsBlocks) {
      if (!block.isPlatform) {
        // print(block.isPlatform);
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            isTouchingWall = true;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.offsetX + hitbox.width;
            isTouchingWall = true;
            break;
          }
        } else {
          isTouchingWall = false;
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;

    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
    // print('Yvelo:$velocity.y');
  }

  void _checkVerticalCollision() {
    for (final block in collisionsBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
            doubleJump = false;
          }
        }
      }
    }
  }

  void respawn() {
    gotHit = true;
    if (game.playSound) {
      FlameAudio.play('hit.wav');
    }
    current = PlayerState.hit;
    final hitAnimation = animationTickers![PlayerState.hit]!;
    hitAnimation.completed.whenComplete(() {
      if (game.playSound) {
        FlameAudio.play('appear.wav');
      }
      current = PlayerState.appearing;
      scale.x = 1;
      position = startingPosition - Vector2.all(32);
      hitAnimation.reset();
      final appearingAnimation = animationTickers![PlayerState.appearing]!;
      appearingAnimation.completed.whenComplete(() {
        position = startingPosition;
        current = PlayerState.idle;
        gotHit = false;
        appearingAnimation.reset();
      });
    });
  }

  void _reachedCheckpoint() async {
    reachedCheckpoint = true;
    if (game.playSound) {
      FlameAudio.play('reachedCheckpoint.wav');
    }
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }
    current = PlayerState.disappearing;
    await animationTicker?.completed;
    FlameAudio.play('win.wav');
    reachedCheckpoint = false;
    removeFromParent();
    const waitToChangeDuration = Duration(seconds: 3);
    Future.delayed(
      waitToChangeDuration,
      () {
        game.loadNextLevel();
      },
    );
  }
}
