import 'package:pixel_adventure/components/collitions_block.dart';
import 'package:pixel_adventure/components/player.dart';

bool checkCollision(Player player, CollisionsBlock block) {
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth =  hitbox.width;
  final playerHeight =  hitbox.height;

  final objectX = block.position.x;
  final objectY = block.position.y;
  final objectWidth = block.width;
  final objectHeight = block.height;

  final fixedX = player.scale.x < 0 ? playerX - (hitbox.offsetX*2) - playerWidth : playerX;
  final fixedy = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedy < objectY + objectHeight &&
      playerY + playerHeight > objectY &&
      fixedX < objectX + objectWidth &&
      fixedX + playerWidth > objectX);
}
