import 'dart:ui';
import 'package:cartesian_graph/bounds.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/pixel_location.dart';
import 'package:cartesian_graph/src/display/cluster_location.dart';
import 'package:cartesian_graph/src/display/display_size.dart';
import 'package:cartesian_graph/src/display/pixel_map.dart';
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

  void _updatePixelCluster(ClusterLocation cluster, Color color){
    for(int i = cluster.x*lineWeight;i<((cluster.x+1)*lineWeight);i++){
      for(int j = cluster.y*lineWeight;j<((cluster.y+1)*lineWeight);j++){
        pixelMap.updatePixel(i, j, color);
      }
    }
  }

  ClusterLocation _calculatePixelCluster(Coordinates coordinates){
    return translator.translateCoordinates(coordinates);
  }

  void plotSegment(Coordinates firstCoordinates, Coordinates secondCoordinates, Color color){
    if(this.bounds.isWithin(firstCoordinates) || this.bounds.isWithin(secondCoordinates)){
      ClusterLocation first = _calculatePixelCluster(firstCoordinates);
      ClusterLocation second = _calculatePixelCluster(secondCoordinates);

      int startX = first.x;
      int endX = second.x;
      int startY = first.y;
      int endY = second.y;

      if(firstCoordinates.x.abs() > secondCoordinates.x.abs()){
        startX = second.x;
        endX = first.x;
        startY = second.y;
        endY = first.y;
      }

      _updatePixelCluster(ClusterLocation(startX, startY), color);

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
          _updatePixelCluster(ClusterLocation(x, y), color);
          y+= yDirection;
        }
        x+= xDirection;
      }
    }
  }

  void displayAxes(Color color){
    ClusterLocation center = this.translator.translateCoordinates(Coordinates(0, 0));

    if(bounds.isYWithin(0)) {
      for (int i = 0; i < _numXPixelPoints; i++) {
        _updatePixelCluster(ClusterLocation(i, center.y), color);
      }
    }
    if(bounds.isXWithin(0)) {
      for (int i = 0; i < _numYPixelPoints; i++) {
        _updatePixelCluster(ClusterLocation(center.x, i), color);
      }
    }
  }

  void displayCursorByCoordinates(Coordinates cursorLocation){
    ClusterLocation cursor = _calculatePixelCluster(cursorLocation);
    _displayCursor(cursor);
  }

  Coordinates calculateCoordinates(PixelLocation location){
    ClusterLocation cluster = ClusterLocation(location.x~/this.lineWeight, location.y~/this.lineWeight);
    Coordinates coordinates = translator.translateCluster(cluster);
    return coordinates;
  }

  void _displayCursor(ClusterLocation location){
    int width = (24/lineWeight).round();
    for(int i = (location.x-width).toInt(); i<(location.x+width).toInt(); i++){
      _updatePixelCluster(ClusterLocation(i, location.y.toInt()), Colors.blue);
    }

    for(int i = (location.y-width).toInt(); i<(location.y+width).toInt(); i++){
      _updatePixelCluster(ClusterLocation(location.x.toInt(), i), Colors.blue);
    }
  }

  void render(ImageDecoderCallback callback){
    pixelMap.render(callback);
  }
}