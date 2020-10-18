import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cartesian_graph/src/display/pixel_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:ui' as ui;


Color colorFromBGRA(int raw){
  int r = (raw)&0xFF;
  int g = (raw>>8)&0xFF;
  int b = (raw>>16)&0xFF;
  int a = (raw>>24)&0xFF;
  return Color.fromARGB(a, r, g, b);
}

void main() {
  group('Pixel map', (){
    PixelMap pixelMap;
    setUp((){
      pixelMap = PixelMap(5,10,Colors.black);
    });
    test('should provide accurate width', () {

      expect(pixelMap.width,5);
    });

    test('should provide accurate height', () {
      PixelMap pixelMap = PixelMap(5,10,Colors.black);
      expect(pixelMap.height,10);
    });
  });

  group('Image from pixel map',(){
    int height = 2;
    int width = 4;
    PixelMap pixelMap;

    void assertHeight(ui.Image image) async{
      expect(image.height, height);
    }

    void assertWidth(ui.Image image) async{
      expect(image.width, width);
    }

    setUp((){
      pixelMap = PixelMap(width,height,Colors.black);
    });

    test('has correct width',(){
      pixelMap.render(expectAsync1(assertWidth));
    });

    test('has correct height',(){
      pixelMap.render(expectAsync1(assertHeight));
    });
  });

  group('Invalid pixel map updates',(){
    Color expectedColor;

    void assertBGRAColor(ui.Image image) async{
      Future byteData = image.toByteData();
      byteData.then((data){
        ByteData out = data;
        expect(colorFromBGRA(out.buffer.asInt32List()[0]).value, expectedColor.value);
      });
      expect(byteData,completes);
    }

    PixelMap pixelMap;
    setUp((){
      pixelMap = PixelMap(1,1,Colors.black);
    });

    test('of pixel location are displayed',(){
      expectedColor = Colors.red;
      pixelMap.updatePixel(0, 0, expectedColor);
      pixelMap.render(expectAsync1(assertBGRAColor));
    });

    test('that are not made display background color',(){
      expectedColor = Colors.black;
      pixelMap.render(expectAsync1(assertBGRAColor));
    });

    test('with negative X do not take effect',(){
      expectedColor = Colors.black;
      pixelMap.updatePixel(-1, 0, Colors.red);
      pixelMap.render(expectAsync1(assertBGRAColor));
    });

    test('with negative Y do not take effect',(){
      expectedColor = Colors.black;
      pixelMap.updatePixel(0, -1, Colors.red);
      pixelMap.render(expectAsync1(assertBGRAColor));
    });

    test('with out of bounds X do not take effect',(){
      expectedColor = Colors.black;
      pixelMap.updatePixel(1, 0, Colors.red);
      pixelMap.render(expectAsync1(assertBGRAColor));
    });

    test('with out of bounds Y do not take effect',(){
      expectedColor = Colors.black;
      pixelMap.updatePixel(0, 1, Colors.red);
      pixelMap.render(expectAsync1(assertBGRAColor));
    });
  });

  group('Valid pixel map location updates',(){
    Color expectedColor;
    int expectedIndex;
    void assertBGRAColor(ui.Image image) async{
      Future byteData = image.toByteData();
      byteData.then((data){
        ByteData out = data;
        expect(colorFromBGRA(out.buffer.asInt32List()[expectedIndex]).value, expectedColor.value);
      });
      expect(byteData,completes);
    }

    PixelMap pixelMap;
    setUp((){
      pixelMap = PixelMap(2,2,Colors.black);
      pixelMap.updatePixel(0, 1, Colors.red);
      pixelMap.updatePixel(1, 0, Colors.green);
      pixelMap.updatePixel(1, 1, Colors.orange);
    });

    test('first pixel accurately',(){
      expectedIndex = 0;
      expectedColor = Colors.red;
      pixelMap.render(expectAsync1(assertBGRAColor));
    });

    test('middle pixel accurately',(){
      expectedIndex = 1;
      expectedColor = Colors.orange;
      pixelMap.render(expectAsync1(assertBGRAColor));
    });

    test('last pixel accurately',(){
      expectedIndex = 3;
      expectedColor = Colors.green;
      pixelMap.render(expectAsync1(assertBGRAColor));
    });

    test('background pixel accurately',(){
      expectedIndex = 2;
      expectedColor = Colors.black;
      pixelMap.render(expectAsync1(assertBGRAColor));
    });
  });
}