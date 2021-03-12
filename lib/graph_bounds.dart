import 'package:cartesian_graph/coordinates.dart';

class GraphBounds{
  final int xMin;
  final int xMax;
  final int yMin;
  final int yMax;

  GraphBounds(this.xMin,this.xMax,this.yMin,this.yMax):
        assert(xMax > xMin, 'Maximum x must be greater than minimum x'),
        assert(yMax > yMin, 'Maximum y must be greater than minimum y');

  bool _isBetween(double item, int lowerBound, int upperBound){
    return (item >= lowerBound && item <= upperBound);
  }

  bool isWithin(Coordinates coordinates){
    return isXWithin(coordinates.x) && isYWithin(coordinates.y);
  }

  bool isXWithin(double xValue) {
    return _isBetween(xValue, xMin, xMax);
  }

  bool isYWithin(double yValue) {
    return _isBetween(yValue, yMin, yMax);
  }
}