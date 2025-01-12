import 'package:pixel_adventure/components/collitions_block.dart';
import 'package:pixel_adventure/components/player.dart';

bool checkCollision(Player player, CollisionsBlock block) {
  final playerX = player.position.x;
  final playerY = player.position.y;
  final playerWidth = player.width;
  final playerHeight = player.height;

  final objectX = block.position.x;
  final objectY = block.position.y;
  final objectWidth = block.width;
  final objectHeight = block.height;

  return (playerY < objectY + objectHeight &&
      playerY + playerHeight > objectY &&
      playerX < objectX + objectWidth &&
      playerX + playerWidth > objectX);
}
