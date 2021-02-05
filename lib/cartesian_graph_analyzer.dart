import 'package:cartesian_graph/cartesian_graph.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/pixel_location.dart';

class CartesianGraphAnalyzer{
  final CartesianGraph cartesianGraph;

  CartesianGraphAnalyzer(this.cartesianGraph);

  Coordinates calculateCoordinates(PixelLocation location){
    return this.cartesianGraph.display.calculateCoordinates(location);
  }
}