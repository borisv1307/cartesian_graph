import 'package:advanced_calculation/advanced_calculator.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/segment_bounds.dart';

class CoordinatesCalculator{
  final AdvancedCalculator _calculator;

  CoordinatesCalculator({AdvancedCalculator calculator}):
      this._calculator = calculator ?? AdvancedCalculator();


  List<Coordinates> calculate(String equation, List<double> xCoordinates, SegmentBounds segmentBounds){
    List<Coordinates> calculatedCoordinates = [];
    for(double xCoordinate in xCoordinates){
      double yCoordinate = _calculator.calculateEquation(equation, xCoordinate);
      Coordinates coordinates = Coordinates(xCoordinate, yCoordinate);
      if(_isBetween(coordinates.x,segmentBounds.xMin,segmentBounds.xMax) && _isBetween(coordinates.y,segmentBounds.yMin,segmentBounds.yMax)) {
        calculatedCoordinates.add(coordinates);
      }
    }

    return calculatedCoordinates;
  }

  bool _isBetween(double point, int min, int max){
    bool between = (min == null || point >= min) && (max == null || point <= max);
    return between;
  }
}