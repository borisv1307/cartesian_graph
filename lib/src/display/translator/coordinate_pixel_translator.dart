import 'dart:math';

import 'package:cartesian_graph/bounds.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/src/display/display_size.dart';
import 'package:cartesian_graph/src/display/pixel_point.dart';
import 'package:cartesian_graph/src/display/translator/coordinate_pixel_location_map.dart';
import 'package:cartesian_graph/src/display/translator/invalid_graph_exception.dart';

class CoordinatePixelTranslator{
  final CoordinatePixelPointLocationMap pixelLocations;
  final List<double> xCoordinates;

  CoordinatePixelTranslator._internal(this.pixelLocations, this.xCoordinates);

  factory CoordinatePixelTranslator(Bounds bounds,DisplaySize displaySize, int lineWeight){
    if(displaySize.width == 0 || displaySize.height == 0 || lineWeight < 1){
      throw InvalidGraphException();
    }

    List<double> xCoordinates = _calculateCoordinates(bounds.xMin, bounds.xMax, displaySize.width, lineWeight);
    List<double> yCoordinates = _calculateCoordinates(bounds.yMin, bounds.yMax, displaySize.height, lineWeight);

    final CoordinatePixelPointLocationMap pixelLocations = CoordinatePixelPointLocationMap();
    for(int i=0;i<xCoordinates.length;i++){
      for(int j=0;j<yCoordinates.length;j++){
        pixelLocations[Coordinates(xCoordinates[i],yCoordinates[j])] = PixelPoint(i, j);
      }
    }
    return CoordinatePixelTranslator._internal(pixelLocations, xCoordinates);
  }

  static List<double> _calculateCoordinates(int minBound, int maxBound, double size, int lineWeight){
    //checks if the visible range crosses the axis
    bool crossesAxis = (minBound < 0 && 0 < maxBound);
    //the length of the x range to display
    double range = (maxBound - minBound).toDouble();

    //total points on axis available to be assigned value
    double totalPoints = size/lineWeight;

    double precision;
    bool reverse = false;
    if(crossesAxis){
      double belowAxisPrecision = _calculatePrecision((0-minBound).toDouble(), minBound.abs().toDouble(), range, totalPoints);
      double aboveAxisPrecision = _calculatePrecision((maxBound-0).toDouble(), maxBound.abs().toDouble(), range, totalPoints);

      precision = max(belowAxisPrecision,aboveAxisPrecision);
      reverse = aboveAxisPrecision > belowAxisPrecision;
    }else{
      precision = _calculatePrecision(range + 1, range, range, totalPoints);
    }
    List<double> coordinates = _generatePoints(minBound.toDouble(), maxBound.toDouble(), precision, totalPoints,reverse);

    return coordinates;
  }

  static List<double> _generatePoints(double min, double max, double precision, double totalPoints, [bool reverse = false]){
    List<double> xCoordinates = [];
    double xValue = reverse ? max : min;
    double directionalPrecision = reverse ? precision * -1 : precision;
    for(int i = 0; i<totalPoints; i++){
      xCoordinates.add(xValue);
      xValue += directionalPrecision;
    }

    xCoordinates.sort();
    return xCoordinates;
  }

  static double _calculatePrecision(double points, double sampleRange, double range, double availablePoints){
    double xPrecision = (points)/((sampleRange/range)*availablePoints).truncate();
    return xPrecision;
  }

  PixelPoint calculatePixelPoint(Coordinates coordinates) {
    return this.pixelLocations[coordinates];
  }

}