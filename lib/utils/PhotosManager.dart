import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class PhotosManager {
  static savePictureToGallery(String picturePath) async {
    File file = File(picturePath);
    var fileInBytes = await file.readAsBytes();

    final result = await ImageGallerySaver.save(fileInBytes);
    return result;
  }
}
