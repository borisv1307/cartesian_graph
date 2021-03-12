import 'dart:async';
import 'dart:ui';

import 'package:cartesian_graph/cartesian_graph.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/graph_bounds.dart';
import 'package:cartesian_graph/line.dart';
import 'package:cartesian_graph/pixel_location.dart';
import 'package:cartesian_graph/segment_bounds.dart';
import 'package:cartesian_graph/src/coordinates_calculator.dart';
import 'package:cartesian_graph/src/display/display_size.dart';
import 'package:cartesian_graph/src/display/graph_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:ui' as ui;


class MockGraphDisplay extends Mock implements GraphDisplay {
  ui.Image _image;
  List<double> xCoordinates = [0,1];

  MockGraphDisplay([this._image]);

  @override
  void render(ImageDecoderCallback callback) async{
    callback(_image);
  }

}

class MockImage extends Mock implements ui.Image{}
class MockCalculator extends Mock implements CoordinatesCalculator{}

// ignore: must_be_immutable
class TestableCartesianGraph extends CartesianGraph{
  final GraphDisplay _graphDisplay;
  TestableCartesianGraph(GraphBounds bounds, this._graphDisplay, CoordinatesCalculator coordinatesCalculator, {List<Coordinates> coordinates = const [], coordinatesBuilder,lines, Coordinates cursorLocation, PixelLocation cursorPixelLocation,Color cursorColor=Colors.blue}):
        super(bounds,coordinates: coordinates, coordinatesBuilder: coordinatesBuilder, lines: lines,cursorLocation: cursorLocation,cursorColor: cursorColor, coordinatesCalculator: coordinatesCalculator);

  @override
  GraphDisplay createGraphDisplay(GraphBounds bounds, DisplaySize displaySize, int density){
    return _graphDisplay;
  }


}
void main() {
  Widget _makeTestable(CartesianGraph graph){
    return MediaQuery(data: MediaQueryData(size:Size(50,100)), child: MaterialApp(home:graph));
  }

  Future<ui.Image> _createMockImage() async{
    PictureRecorder recorder = PictureRecorder();
    Canvas(recorder);
    ui.Image image = await recorder.endRecording().toImage(5, 5);
    return image;
  }

  group('Graph Display', (){

    test('is created',(){
      CartesianGraph cartesianGraph = CartesianGraph(GraphBounds(-1,1,-1,1), coordinatesCalculator: MockCalculator());
      expect(cartesianGraph.createGraphDisplay(GraphBounds(-1,1,-1,1), DisplaySize(2,2), 1),isInstanceOf<GraphDisplay>());
    });

    testWidgets(('is present'), (WidgetTester tester) async{
      GraphBounds expectedBounds = GraphBounds(-1,1,-1,1);
      await tester.pumpWidget(_makeTestable(TestableCartesianGraph(expectedBounds,MockGraphDisplay(await _createMockImage()),MockCalculator())));
      await tester.pumpAndSettle();

      expect(find.byType(TestableCartesianGraph), findsNWidgets(1));
    });

  });


  testWidgets(('Cartesian Graph initially shows progress indicator'), (WidgetTester tester) async{
    MockGraphDisplay mockGraphDisplay = MockGraphDisplay(await _createMockImage());
    await tester.pumpWidget(_makeTestable(TestableCartesianGraph(GraphBounds(-1,1,-1,1), mockGraphDisplay,MockCalculator())));
    expect(find.byType(CircularProgressIndicator),findsOneWidget);
  });

  testWidgets(('Cartesian Graph displays image'), (WidgetTester tester) async{
    var mockImage = await _createMockImage();
    MockGraphDisplay mockGraphDisplay = MockGraphDisplay(mockImage);
    await tester.pumpWidget(_makeTestable(TestableCartesianGraph(GraphBounds(-1,1,-1,1),mockGraphDisplay,MockCalculator())));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(RawImage), findsNWidgets(1));

    RawImage rawImage = find.byType(RawImage).evaluate().single.widget as RawImage;
    expect(rawImage.image,mockImage);
  });

  group('Segment plotting',(){
    GraphDisplay graphDisplay;
    MockCalculator mockCalculator;

    List<Coordinates> coordinates = [Coordinates(-1,-1),Coordinates(0,0),Coordinates(1,1)];
    List<double> actualBuilderCoordinates;
    List<Coordinates> testBuilder(List<double> xCoordinates){
      actualBuilderCoordinates = xCoordinates;
      return [Coordinates(-1,1), Coordinates(0,1)];
    }

    Future setup(WidgetTester tester) async{
      graphDisplay = MockGraphDisplay(await _createMockImage());
      mockCalculator = MockCalculator();
      when(mockCalculator.calculate('2x', any, any)).thenReturn([Coordinates(0,-1), Coordinates(1,-1)]);

      TestableCartesianGraph graph = TestableCartesianGraph(GraphBounds(-1,1,-1,1),graphDisplay,mockCalculator,coordinates: coordinates,
        coordinatesBuilder:testBuilder, lines: [Line('2x',segmentBounds: SegmentBounds(xMin:0))],cursorLocation: Coordinates(0,0),cursorPixelLocation: PixelLocation(1,1));
      await tester.pumpWidget(_makeTestable(graph));
      await tester.pumpAndSettle();
    }

    testWidgets(('plots provided coordinates as segments'), (WidgetTester tester) async{
      await setup(tester);
      verify(graphDisplay.plotSegment(any, any, any)).called(4);
    });

    testWidgets(('plots first segment of coordinates'), (WidgetTester tester) async{
      await setup(tester);
      verify(graphDisplay.plotSegment(Coordinates(-1,-1), Coordinates(0,0), Colors.black)).called(1);
    });

    testWidgets(('plots second segment of coordinates'), (WidgetTester tester) async{
      await setup(tester);
      verify(graphDisplay.plotSegment(Coordinates(0,0), Coordinates(1,1), Colors.black)).called(1);
    });

    group('plots builder',(){
      testWidgets(('provides correct x coordinates to builder'), (WidgetTester tester) async{
        await setup(tester);
        expect(actualBuilderCoordinates,[0,1]);
      });

      testWidgets(('plots provided coordinates builder coordinates as segment'), (WidgetTester tester) async{
        await setup(tester);
        verify(graphDisplay.plotSegment(Coordinates(-1,1), Coordinates(0,1), Colors.black)).called(1);
      });
    });

    group('plots equation',(){
      testWidgets('calculates y value with equation',(WidgetTester tester) async{
        await setup(tester);
        verify(mockCalculator.calculate('2x', [0,1], SegmentBounds(xMin:0))).called(1);
      });

      testWidgets('display coordinates with equation',(WidgetTester tester) async{
        await setup(tester);
        verify(graphDisplay.plotSegment(Coordinates(0,-1), Coordinates(1,-1), Colors.black)).called(1);
      });
    });

    group('Cursor plotting',(){
      testWidgets('displays cursor by coordinates',(WidgetTester tester) async{
        await setup(tester);
        verify(graphDisplay.displayCursorByCoordinates(Coordinates(0,0),Colors.blue)).called(1);
      });

      testWidgets('displays cursor with specified color',(WidgetTester tester) async{
        graphDisplay = MockGraphDisplay(await _createMockImage());
        mockCalculator = MockCalculator();
        when(mockCalculator.calculate('2x', any,any)).thenReturn([Coordinates(-1, 1)]);

        TestableCartesianGraph graph = TestableCartesianGraph(GraphBounds(-1,1,-1,1),graphDisplay,mockCalculator,coordinates: coordinates,
            coordinatesBuilder:testBuilder, lines: [Line('2x')],cursorLocation: Coordinates(0,0),cursorPixelLocation: PixelLocation(1,1),cursorColor: Colors.red,);
        await tester.pumpWidget(_makeTestable(graph));
        await tester.pumpAndSettle();

        verify(graphDisplay.displayCursorByCoordinates(Coordinates(0,0),Colors.red)).called(1);
      });
    });
  });
}