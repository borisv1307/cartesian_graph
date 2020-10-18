import 'dart:async';
import 'dart:ui';

import 'package:cartesian_graph/bounds.dart';
import 'package:cartesian_graph/cartesian_graph.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/src/display/display_size.dart';
import 'package:cartesian_graph/src/display/graph_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:ui' as ui;


class MockGraphDisplay extends Mock implements GraphDisplay {
  ui.Image _image;

  MockGraphDisplay(this._image);

  @override
  void render(ImageDecoderCallback callback) async{
    callback(_image);
  }

}

class MockImage extends Mock implements ui.Image{}

class TestableCartesianGraph extends CartesianGraph{
  final GraphDisplay _graphDisplay;

  TestableCartesianGraph(Bounds bounds, this._graphDisplay, {List<Coordinates> coordinates, coordinatesBuilder}): super(bounds,coordinates: coordinates, coordinatesBuilder: coordinatesBuilder);

  @override
  GraphDisplay createGraphDisplay(Bounds bounds, DisplaySize displaySize, int density){
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
      CartesianGraph cartesianGraph = CartesianGraph(Bounds(-1,1,-1,1));
      expect(cartesianGraph.createGraphDisplay(Bounds(-1,1,-1,1), DisplaySize(2,2), 1),isInstanceOf<GraphDisplay>());
    });

    testWidgets(('is present'), (WidgetTester tester) async{
      Bounds expectedBounds = Bounds(-1,1,-1,1);
      await tester.pumpWidget(_makeTestable(TestableCartesianGraph(expectedBounds,MockGraphDisplay(await _createMockImage()))));
      await tester.pumpAndSettle();

      expect(find.byType(TestableCartesianGraph), findsNWidgets(1));
    });

  });

  group('Inputs are validated',(){
    test('both coordinates and coordinates builder cannot be provided together',(){
      expect(() => CartesianGraph(Bounds(-1,1,-1,1), coordinates: [],coordinatesBuilder: (x,y){return [];}), throwsAssertionError);
    });
  });

  testWidgets(('Cartesian Graph initially shows progress indicator'), (WidgetTester tester) async{
    MockGraphDisplay mockGraphDisplay = MockGraphDisplay(await _createMockImage());
    await tester.pumpWidget(_makeTestable(TestableCartesianGraph(Bounds(-1,1,-1,1), mockGraphDisplay)));
    expect(find.byType(CircularProgressIndicator),findsOneWidget);
  });

  testWidgets(('Cartesian Graph displays image'), (WidgetTester tester) async{
    var mockImage = await _createMockImage();
    MockGraphDisplay mockGraphDisplay = MockGraphDisplay(mockImage);
    await tester.pumpWidget(_makeTestable(TestableCartesianGraph(Bounds(-1,1,-1,1),mockGraphDisplay)));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(RawImage), findsNWidgets(1));

    RawImage rawImage = find.byType(RawImage).evaluate().single.widget as RawImage;
    expect(rawImage.image,mockImage);
  });

  group('Segment plotting',(){
    GraphDisplay graphDisplay;

    Future _createWidget(WidgetTester tester,{List<Coordinates> coordinates, coordinatesBuilder}) async{
      graphDisplay = MockGraphDisplay(await _createMockImage());
      TestableCartesianGraph graph = TestableCartesianGraph(Bounds(-1,1,-1,1),graphDisplay,coordinates: coordinates, coordinatesBuilder:coordinatesBuilder);
      await tester.pumpWidget(_makeTestable(graph));
      await tester.pumpAndSettle();
    }

    group('from provided coordinates',(){
      List<Coordinates> coordinates = [Coordinates(-1,-1),Coordinates(0,0),Coordinates(1,1)];

      testWidgets(('plots provided coordinates as segments'), (WidgetTester tester) async{
        await _createWidget(tester, coordinates: coordinates);
        verify(graphDisplay.plotSegment(any, any, any)).called(2);
      });

      testWidgets(('plots first segment'), (WidgetTester tester) async{
        await _createWidget(tester, coordinates: coordinates);
        verify(graphDisplay.plotSegment(Coordinates(-1,-1), Coordinates(0,0), Colors.black)).called(1);
      });

      testWidgets(('plots second segment'), (WidgetTester tester) async{
        await _createWidget(tester, coordinates: coordinates);
        verify(graphDisplay.plotSegment(Coordinates(0,0), Coordinates(1,1), Colors.black)).called(1);
      });
    });

    group('from coordinates builder',(){

      List<Coordinates> testBuilder(double xPrecision, double yPrecision){
        return [Coordinates(0,0), Coordinates(1,1)];
      }

      testWidgets(('plots provided coordinates as segment'), (WidgetTester tester) async{
        await _createWidget(tester, coordinatesBuilder: testBuilder);
        verify(graphDisplay.plotSegment(Coordinates(0,0), Coordinates(1,1), Colors.black)).called(1);
      });
    });
  });
}