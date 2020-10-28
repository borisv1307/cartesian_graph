import 'dart:ui';
import 'package:cartesian_graph/bounds.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/src/display/display_size.dart';
import 'package:cartesian_graph/src/display/pixel_map.dart';
import 'package:cartesian_graph/src/display/pixel_point.dart';
import 'package:flutter/material.dart';

export 'graph_display.dart' hide GraphDisplay;

class GraphDisplay{
  final int density;
  final int _xLowerOffset;
  final int _yLowerOffset;
  PixelMap pixelMap;
  final double xPrecision;
  final double yPrecision;
  final int numXPixelPoints;
  final int numYPixelPoints;

  GraphDisplay._internal(this._xLowerOffset,this._yLowerOffset, this.pixelMap, this.density, this.xPrecision, this.yPrecision, this.numXPixelPoints, this.numYPixelPoints);

  factory GraphDisplay.bounds(Bounds bounds, DisplaySize displaySize, int density){
        int minXPixels = _calculatePixels(bounds.xMin,bounds.xMax,density);
        int minYPixels = _calculatePixels(bounds.yMin,bounds.yMax,density);

        double xPrecision = (minXPixels/(displaySize.width-density));
        double yPrecision = (minYPixels/(displaySize.height-density));

        PixelMap pixelMap = PixelMap(displaySize.width.toInt(),displaySize.height.toInt(), Color.fromRGBO(170, 200, 154, 1));
        int xLowerOffset = (bounds.xMin.abs()/xPrecision).round();
        int yLowerOffset = (bounds.yMin.abs()/yPrecision).round();
        return GraphDisplay._internal(xLowerOffset, yLowerOffset, pixelMap, density,xPrecision,yPrecision, (displaySize.width/density).round(),(displaySize.height/density).round());
  }

  static int _calculatePixels(int min, int max, int density){
    int range = (max - min);
    return range * density;
  }

  void _updatePixelPoint(PixelPoint point, Color color){
    for(int i = point.x*density;i<((point.x+1)*density);i++){
      for(int j = point.y*density;j<((point.y+1)*density);j++){
        pixelMap.updatePixel(i, j, color);
      }
    }
  }

  PixelPoint _calculatePixelPoint(Coordinates coordinates){
    int xPosition = _xLowerOffset + (coordinates.x/xPrecision).round();
    int yPosition = _yLowerOffset + (coordinates.y/yPrecision).round();

    return PixelPoint(xPosition, yPosition);
  }

  void plotSegment(Coordinates startCoordinates, Coordinates endCoordinates, Color color){
    PixelPoint start = _calculatePixelPoint(startCoordinates);
    PixelPoint end = _calculatePixelPoint(endCoordinates);

    int farX = startCoordinates.x.abs() > endCoordinates.x.abs() ? start.x : end.x;
    int closeY = startCoordinates.y.abs() > endCoordinates.y.abs() ? end.y : start.y;
    int farY = startCoordinates.y.abs() > endCoordinates.y.abs() ? start.y : end.y;

    _updatePixelPoint(start, Colors.purple);
    _updatePixelPoint(end, Colors.purple);

    int yDirection = closeY < farY ? 1 : -1;

    for(int i=closeY+yDirection;(yDirection > 0 && i<farY) || (yDirection < 0 && i>farY);i+= yDirection){
      _updatePixelPoint(PixelPoint(farX, i), color);
    }
  }

  void displayAxes(Color color){
    for(int i = 0; i<numXPixelPoints; i++){
      _updatePixelPoint(PixelPoint(i, _yLowerOffset), color);
    }

    for(int i = 0; i<numYPixelPoints; i++){
      _updatePixelPoint(PixelPoint(_xLowerOffset, i), color);
    }
  }

  void displayCursor(Coordinates cursorLocation){
    int width = (24/density).round();
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