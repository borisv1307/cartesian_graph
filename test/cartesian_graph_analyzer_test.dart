import 'package:cartesian_graph/cartesian_graph.dart';
import 'package:cartesian_graph/cartesian_graph_analyzer.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/pixel_location.dart';
import 'package:cartesian_graph/src/display/graph_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';


class MockGraphDisplay extends Mock implements GraphDisplay {}
// ignore: must_be_immutable,invalid_override_different_default_values_named
class MockCartesianGraph extends Mock implements CartesianGraph{
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    super.toString();
    return 'sample';
  }
}

main(){
  group('Coordinate calculation',(){
    test('coordinates are calculated',(){
      MockGraphDisplay mockDisplay = MockGraphDisplay();

      MockCartesianGraph graph = MockCartesianGraph();
      when(graph.display).thenReturn(mockDisplay);
      when(mockDisplay.calculateCoordinates(PixelLocation(1, 1))).thenReturn(Coordinates(3, 2));

      CartesianGraphAnalyzer analyzer = CartesianGraphAnalyzer(graph);
      Coordinates coordinates = analyzer.calculateCoordinates(PixelLocation(1, 1));
      expect(coordinates, Coordinates(3,2));
    });
  });
}