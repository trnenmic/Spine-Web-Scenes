import 'package:stagexl/stagexl.dart';


Bitmap loadBitmap(var cfg, int index, int instanceIndex, ResourceManager resourceManager) {
  Bitmap bitmap = new Bitmap(resourceManager.getBitmapData(cfg.bitmap[index].name));
  bitmap.x = cfg.bitmap[index].instance[instanceIndex].x;
  bitmap.y = cfg.bitmap[index].instance[instanceIndex].y;
  bitmap.name = cfg.bitmap[index].instance[instanceIndex].name;
  return bitmap;
}