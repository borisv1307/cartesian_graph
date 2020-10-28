import 'dart:ui';
import 'package:cartesian_graph/bounds.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/src/display/display_size.dart';
import 'package:cartesian_graph/src/display/pixel_map.dart';
import 'package:cartesian_graph/src/display/pixel_point.dart';
import 'package:cartesian_graph/src/display/translator/coordinate_pixel_translator.dart';
import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';

export 'graph_display.dart' hide GraphDisplay;

class GraphDisplay{
  final int lineWeight;
  PixelMap pixelMap;
  final int _numXPixelPoints;
  final int _numYPixelPoints;
  CoordinatePixelTranslator translator;
  final Bounds bounds;
  final List<double> xCoordinates;

  GraphDisplay._internal(this.pixelMap, this.lineWeight, this._numXPixelPoints, this._numYPixelPoints, this.translator, this.bounds, this.xCoordinates);

  factory GraphDisplay.bounds(Bounds bounds, DisplaySize displaySize, int density){
    PixelMap pixelMap = PixelMap(displaySize.width.toInt(),displaySize.height.toInt(), Color.fromRGBO(170, 200, 154, 1));
    CoordinatePixelTranslator translator = CoordinatePixelTranslator(bounds,displaySize,density);
    GraphDisplay graphDisplay =  GraphDisplay._internal(pixelMap, density, (displaySize.width/density).round(),(displaySize.height/density).round(),translator, bounds,translator.xCoordinates);

    return graphDisplay;
  }

  void _updatePixelPoint(PixelPoint point, Color color){
    for(int i = point.x*lineWeight;i<((point.x+1)*lineWeight);i++){
      for(int j = point.y*lineWeight;j<((point.y+1)*lineWeight);j++){
        pixelMap.updatePixel(i, j, color);
      }
    }
  }

  PixelPoint _calculatePixelPoint(Coordinates coordinates){
    return translator.calculatePixelPoint(coordinates);
  }

  void plotSegment(Coordinates firstCoordinates, Coordinates secondCoordinates, Color color){
    if(this.bounds.isWithin(firstCoordinates) || this.bounds.isWithin(secondCoordinates)){
      PixelPoint first = _calculatePixelPoint(firstCoordinates);
      PixelPoint second = _calculatePixelPoint(secondCoordinates);

      int startX = firstCoordinates.x.abs() > secondCoordinates.x.abs() ? second.x : first.x;
      int endX = firstCoordinates.x.abs() > secondCoordinates.x.abs() ? first.x : second.x;
      int startY = firstCoordinates.y.abs() > secondCoordinates.y.abs() ? second.y : first.y;
      int endY = firstCoordinates.y.abs() > secondCoordinates.y.abs() ? first.y : second.y;

      _updatePixelPoint(PixelPoint(startX, startY), Colors.black);

      int ySpan = endY - startY;
      int xSpan = endX - startX;

      int xSlope = 1;
      int ySlope = ySpan;
      if(xSpan != 0) {
        Fraction slope = Fraction(ySpan, xSpan);
        xSlope = xSpan.abs();
        slope.reduce();
        ySlope = slope.numerator != 0 ? slope.numerator.abs() : 1;
      }

      int yDirection = endY.compareTo(startY);
      int xDirection = endX.compareTo(startX);

      int y = startY + yDirection;
      int x = startX + xDirection;
      for(int i = 0; i < xSlope; i++){
        for(int j = 0; j < ySlope; j++){
          _updatePixelPoint(PixelPoint(x, y), color);
          y+= yDirection;
        }
        x+= xDirection;
      }
    }
  }

  void displayAxes(Color color){
    PixelPoint center = this.translator.calculatePixelPoint(Coordinates(0, 0));

    if(bounds.isYWithin(0)) {
      for (int i = 0; i < _numXPixelPoints; i++) {
        _updatePixelPoint(PixelPoint(i, center.y), color);
      }
    }
    if(bounds.isXWithin(0)) {
      for (int i = 0; i < _numYPixelPoints; i++) {
        _updatePixelPoint(PixelPoint(center.x, i), color);
      }
    }
  }

  void displayCursor(Coordinates cursorLocation){
    int width = (24/lineWeight).round();
    for(int i = (cursorLocation.x-width).toInt(); i<(cursorLocation.x+width).toInt(); i++){
        _updatePixelPoint(PixelPoint(i, cursorLocation.y.toInt()), Colors.blue);
    }

    for(int i = (cursorLocation.y-width).toInt(); i<(cursorLocation.y+width).toInt(); i++){
      _updatePixelPoint(PixelPoint(cursorLocation.x.toInt(), i), Colors.blue);
    }
  }

  void render(ImageDecoderCallback callback){
    pixelMap.render(callback);
  }
}