library cartesian_graph;

import 'package:advanced_calculation/advanced_calculator.dart';
import 'package:cartesian_graph/bounds.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/src/display/display_size.dart';
import 'package:cartesian_graph/src/display/graph_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';


export 'cartesian_graph.dart' hide CartesianGraph;

// ignore: must_be_immutable
class CartesianGraph extends StatelessWidget{
  final List<Coordinates> coordinates;
  final Coordinates cursorLocation;
  final int density = 4;
  final Color legendColor;
  final Color lineColor;
  final Bounds bounds;
  final List<Coordinates> Function(List<double>) coordinatesBuilder;
  final List<String> equations;
  GraphDisplay display;


  CartesianGraph(this.bounds, {this.coordinates= const [], this.cursorLocation,this.legendColor = Colors.blueGrey, this.lineColor = Colors.black, this.coordinatesBuilder, this.equations});

  Future<ui.Image> _makeImage(double containerWidth, double containerHeight){
    final c = Completer<ui.Image>();
    display = createGraphDisplay(this.bounds,DisplaySize(containerWidth,containerHeight),density);
    display.displayAxes(legendColor);

    if(cursorLocation != null){
      display.displayCursorByCoordinates(cursorLocation);
    }

    if(coordinatesBuilder != null){
      List<Coordinates> builderCoordinates = coordinatesBuilder(display.xCoordinates);
      _plotCoordinates(display, builderCoordinates);
    }

    for (int i = 0; i < equations.length; i++) {
      if (equations[i] != null){
        AdvancedCalculator calculator = createCoordinateCalculator();
        List<Coordinates> calculatedCoordinates = [];
        for(double xCoordinate in display.xCoordinates){
          double yCoordinate = calculator.calculateEquation(equations[i], xCoordinate);
          calculatedCoordinates.add(Coordinates(xCoordinate, yCoordinate));
        }
        _plotCoordinates(display, calculatedCoordinates);
      }
    }

    _plotCoordinates(display, coordinates);

    display.render(c.complete);

    return c.future;
  }

  void _plotCoordinates(GraphDisplay display, List<Coordinates> coordinates){
    for(int i = 0; i< coordinates.length-1;i++){
      display.plotSegment(coordinates[i],coordinates[i+1], lineColor);
    }
  }

  GraphDisplay createGraphDisplay(Bounds bounds, DisplaySize displaySize, int density){
    return GraphDisplay.bounds(bounds,displaySize,density);
  }

  AdvancedCalculator createCoordinateCalculator(){
    return AdvancedCalculator();
  }

  @override
  Widget build(BuildContext context) {
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints){
        return Container(
            child: FutureBuilder<ui.Image>(
              future: _makeImage(constraints.maxWidth * devicePixelRatio,constraints.maxHeight),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return RawImage(
                    image: snapshot.data,
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
        );
      }
    );
  }

}