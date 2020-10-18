import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

class PixelMap{
  final int width;
  final int height;
  final Color _backgroundColor;
  final Int32List _pixels;


  PixelMap(this.width,this.height,this._backgroundColor):
    _pixels = Int32List(width * height);


  void updatePixel(int x, int y, Color color){
    int pixel = ((width * height) - (width - x) - (y*width));
    if(pixel < (width*height) && pixel >= 0) {
      _pixels[pixel] = color.value;
    }
  }

  void render(ImageDecoderCallback callback){
    for(int i=0; i < width*height;i++){
      if(_pixels[i]==0){
        _pixels[i] = _backgroundColor.value;
      }
    }
    decodeImageFromPixels(_pixels.buffer.asUint8List(), width, height, PixelFormat.bgra8888, callback);
  }
}