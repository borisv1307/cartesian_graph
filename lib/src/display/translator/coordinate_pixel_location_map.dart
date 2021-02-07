import 'dart:math';

import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/src/display/cluster_location.dart';

class CoordinatePixelPointLocationMap{
  Map<Coordinates, ClusterLocation> locationMap = Map();

  operator [](Coordinates coordinates) {
    ClusterLocation location = locationMap[coordinates];
    if(location == null){
      Coordinates closest = _getClosestValue(coordinates);
      location = locationMap[closest];
    }

    return location;
  }

  operator []=(Coordinates coordinates, ClusterLocation location) {
    this.locationMap[coordinates] = location;
  }

  Coordinates _getClosestValue(Coordinates search){
    double distance = double.maxFinite;
    Coordinates closest;
    for(Coordinates coordinates in locationMap.keys){
      double xDistance = coordinates.x-search.x;
      double yDistance = coordinates.y-search.y;

      double pivotDistance = sqrt((xDistance * xDistance) + (yDistance * yDistance));
      if(pivotDistance < distance){
        distance = pivotDistance;
        closest = coordinates;
      }
    }

    return closest;
  }

  Coordinates findCoordinates(ClusterLocation cluster){
    Coordinates coordinates = locationMap.map((k,v) => MapEntry(v, k))[cluster];
    return coordinates;
  }
}