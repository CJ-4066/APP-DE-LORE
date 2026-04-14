import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

Future<bool?> saveChartImage(String path) async {
  try {
    return await GallerySaver.saveImage(path);
  } on MissingPluginException {
    return false;
  }
}
