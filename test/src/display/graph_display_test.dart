import 'package:cartesian_graph/bounds.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/src/display/display_size.dart';
import 'package:cartesian_graph/src/display/graph_display.dart';
import 'package:cartesian_graph/src/display/pixel_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockPixelMap extends Mock implements PixelMap{}

void main() {

  group('Underlying Pixel Map', (){
    GraphDisplay graphDisplay;
    setUpAll((){
      graphDisplay = GraphDisplay.bounds(Bounds(-1,1,-2,2),DisplaySize(5,15),2);
    });

    test('should have specified width', () {
      expect(graphDisplay.pixelMap.width,5);
    });

    test('should have specified height', () {
      expect(graphDisplay.pixelMap.height,15);
    });
  });

  group('Adjacent segment plotting unscaled',(){
    GraphDisplay graphDisplay;
    MockPixelMap mockPixelMap;
    setUp((){
      graphDisplay = GraphDisplay.bounds(Bounds(-1,1,-1,1),DisplaySize(3,3),1);
      mockPixelMap = MockPixelMap();
      graphDisplay.pixelMap = mockPixelMap;
      graphDisplay.plotSegment(Coordinates(0,0), Coordinates(0,1), Colors.black);
    });
    
    test('should update 2 pixels',(){
      verify(mockPixelMap.updatePixel(any,any,any)).called(2);
    });

    test('should plot start point',(){
      var call = verify(mockPixelMap.updatePixel(1,1,captureAny));
      call.called(1);
      expect(call.captured[0].value,Colors.purple.value);
    });

    test('should plot end point',(){
      var call = verify(mockPixelMap.updatePixel(1,2,captureAny));
      call.called(1);
      expect(call.captured[0].value,Colors.purple.value);
    });
  });

  group('Adjacent segment plotting scaled',(){
    MockPixelMap mockPixelMap;
    setUp((){
      GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(-1,1,-1,1),DisplaySize(6,6),2);
      mockPixelMap = MockPixelMap();
      graphDisplay.pixelMap = mockPixelMap;
      graphDisplay.plotSegment(Coordinates(0,0), Coordinates(0,1), Colors.black);
    });

    test('should update 8 pixels',(){
      verify(mockPixelMap.updatePixel(any,any,any)).called(8);
    });

    test('should plot start point',(){
      var call = verify(mockPixelMap.updatePixel(argThat(inInclusiveRange(2, 3)), argThat(inInclusiveRange(2, 3)),captureAny));
      call.called(4);
      call.captured.forEach((color) => expect(color.value,Colors.purple.value));
    });

    test('should plot end point',(){
      var call = verify(mockPixelMap.updatePixel(argThat(inInclusiveRange(2, 3)), argThat(inInclusiveRange(4, 5)),captureAny));
      call.called(4);
      call.captured.forEach((color) => expect(color.value,Colors.purple.value));
    });
  });

  group('Segment connection',(){
    MockPixelMap plotSegment(Coordinates start, Coordinates end){
      GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(-2,2,-2,2),DisplaySize(5,5),1);
      MockPixelMap mockPixelMap = MockPixelMap();
      graphDisplay.pixelMap = mockPixelMap;
      graphDisplay.plotSegment(start, end, Colors.black);

      return mockPixelMap;
    }

    group('with increasing y',(){
      group('and increasing x',() {
        MockPixelMap mockPixelMap;
        setUp(() {
          mockPixelMap = plotSegment(Coordinates(0, 0), Coordinates(1, 2));
        });

        test('should update 3 pixels', () {
          verify(mockPixelMap.updatePixel(any, any, any)).called(3);
        });

        test('should plot connection', () {
          var call = verify(mockPixelMap.updatePixel(3, 3, captureAny));
          call.called(1);
          expect(call.captured[0].value, Colors.black.value);
        });
      });

      group('and decreasing x',(){
        MockPixelMap mockPixelMap;
        setUp(() {
          mockPixelMap = plotSegment(Coordinates(0, 0), Coordinates(-1, 2));
        });

        test('should update 3 pixels', () {
          verify(mockPixelMap.updatePixel(any, any, any)).called(3);
        });

        test('should plot connection', () {
          var call = verify(mockPixelMap.updatePixel(1, 3, captureAny));
          call.called(1);
          expect(call.captured[0].value, Colors.black.value);
        });
      });

    });

    group('with decreasing y',(){
      group('and increasing x',() {
        MockPixelMap mockPixelMap;
        setUp(() {
          mockPixelMap = plotSegment(Coordinates(0, 0), Coordinates(1, -2));
        });

        test('should update 3 pixels', () {
          verify(mockPixelMap.updatePixel(any, any, any)).called(3);
        });

        test('should plot connection', () {
          var call = verify(mockPixelMap.updatePixel(3, 1, captureAny));
          call.called(1);
          expect(call.captured[0].value, Colors.black.value);
        });
      });

      group('and decreasing x',(){
        MockPixelMap mockPixelMap;
        setUp(() {
          mockPixelMap = plotSegment(Coordinates(0, 0), Coordinates(-1, -2));
        });

        test('should update 3 pixels', () {
          verify(mockPixelMap.updatePixel(any, any, any)).called(3);
        });

        test('should plot connection', () {
          var call = verify(mockPixelMap.updatePixel(1, 1, captureAny));
          call.called(1);
          expect(call.captured[0].value, Colors.black.value);
        });
      });

    });
  });

  group('Inexact pixel fit to bounds', (){
    GraphDisplay graphDisplay;
    MockPixelMap mockPixelMap;
    setUp((){
      graphDisplay = GraphDisplay.bounds(Bounds(-1,1,-72,72),DisplaySize(5,134),1);
      mockPixelMap = MockPixelMap();
      graphDisplay.pixelMap = mockPixelMap;
    });

    test('should draw finite downward line',(){
      graphDisplay.plotSegment(Coordinates(1,2), Coordinates(0,0), Colors.black);
      verify(mockPixelMap.updatePixel(any, any, any)).called(3);
    });

    test('should draw finite upward line',(){
      graphDisplay.plotSegment(Coordinates(0,0), Coordinates(1,2), Colors.black);
      verify(mockPixelMap.updatePixel(any, any, any)).called(3);
    });
  });

  group('Device display size allows for increased precision',(){
    GraphDisplay graphDisplay;
    setUp((){
      graphDisplay = GraphDisplay.bounds(Bounds(-1,1,-2,2),DisplaySize(5,17),1);
    });

    test('should calculate x precision',(){
      expect(graphDisplay.xPrecision,0.5);
    });

    test('should calculate y precision',(){
      expect(graphDisplay.yPrecision,0.25);
    });
    
    group('allows for more precise plotting',(){
      MockPixelMap mockPixelMap;
      setUp((){
        mockPixelMap = MockPixelMap();
        graphDisplay.pixelMap = mockPixelMap;
        graphDisplay.plotSegment(Coordinates(0.5,0), Coordinates(1,0.5), Colors.black);
      });

      test('should plot start point',(){
        var call = verify(mockPixelMap.updatePixel(3,8,captureAny));
        call.called(1);
        expect(call.captured[0].value,Colors.purple.value);
      });

      test('should plot end point',(){
        var call = verify(mockPixelMap.updatePixel(4,10,captureAny));
        call.called(1);
        expect(call.captured[0].value,Colors.purple.value);
      });

      test('should plot connection',(){
        var call = verify(mockPixelMap.updatePixel(4,9,captureAny));
        call.called(1);
        expect(call.captured[0].value,Colors.black.value);
      });

    });
  });
  group('Displaying axes',(){
    group('Centered axes',(){
      MockPixelMap mockPixelMap;
      setUpAll((){
        GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(-1,1,-1,1),DisplaySize(3,3),1);
        mockPixelMap = MockPixelMap();
        graphDisplay.pixelMap = mockPixelMap;
        graphDisplay.displayAxes(Colors.black);
      });

      test('should display intersection',(){
        var center = verify(mockPixelMap.updatePixel(1,1,captureAny));
        expect(center.captured[0].value,Colors.black.value);
      });

      test('should display x axis',(){
        var left = verify(mockPixelMap.updatePixel(0,1,captureAny));

        var right = verify(mockPixelMap.updatePixel(2,1,captureAny));

        expect(left.captured[0].value,Colors.black.value);
        expect(right.captured[0].value,Colors.black.value);
      });

      test('should display y axis',(){
        var left = verify(mockPixelMap.updatePixel(1,0,captureAny));
        var right = verify(mockPixelMap.updatePixel(1,2,captureAny));

        expect(left.captured[0].value,Colors.black.value);
        expect(right.captured[0].value,Colors.black.value);
      });

      test('should not display other points',(){
        verifyNever(mockPixelMap.updatePixel(any,any,any));
      });
    });

    group('Off centered axes',(){
      MockPixelMap mockPixelMap;
      setUpAll((){
        GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(0,2,-2,0),DisplaySize(3,3),1);
        mockPixelMap = MockPixelMap();
        graphDisplay.pixelMap = mockPixelMap;
        graphDisplay.displayAxes(Colors.black);
      });

      test('should display intersection',(){
        var center = verify(mockPixelMap.updatePixel(0,2,captureAny));
        expect(center.captured[0].value,Colors.black.value);
      });

      test('should display x axis',(){
        var left = verify(mockPixelMap.updatePixel(1,2,captureAny));
        var right = verify(mockPixelMap.updatePixel(2,2,captureAny));

        expect(left.captured[0].value,Colors.black.value);
        expect(right.captured[0].value,Colors.black.value);
      });

      test('should display y axis',(){
        var left = verify(mockPixelMap.updatePixel(0,0,captureAny));
        var right = verify(mockPixelMap.updatePixel(0,1,captureAny));

        expect(left.captured[0].value,Colors.black.value);
        expect(right.captured[0].value,Colors.black.value);
      });

      test('should not display other points',(){
        verifyNever(mockPixelMap.updatePixel(any,any,any));
      });
    });

    group('Precision not exact from bounds and display size',(){
      MockPixelMap mockPixelMap;
      setUpAll((){
        GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(-2,3,-2,3),DisplaySize(4,4),1);
        mockPixelMap = MockPixelMap();
        graphDisplay.pixelMap = mockPixelMap;
        graphDisplay.displayAxes(Colors.black);
      });

      test('should display intersection',(){
        var center = verify(mockPixelMap.updatePixel(1,1,captureAny));
        expect(center.captured[0].value,Colors.black.value);
      });

      test('should display x axis',(){
        var left = verify(mockPixelMap.updatePixel(0,1,captureAny));
        var right = verify(mockPixelMap.updatePixel(2,1,captureAny));
        var farRight = verify(mockPixelMap.updatePixel(3,1,captureAny));

        expect(left.captured[0].value,Colors.black.value);
        expect(right.captured[0].value,Colors.black.value);
        expect(farRight.captured[0].value,Colors.black.value);
      });

      test('should display y axis',(){
        var lower = verify(mockPixelMap.updatePixel(1,0,captureAny));
        var upper = verify(mockPixelMap.updatePixel(1,2,captureAny));
        var topUpper = verify(mockPixelMap.updatePixel(1,3,captureAny));

        expect(lower.captured[0].value,Colors.black.value);
        expect(upper.captured[0].value,Colors.black.value);
        expect(topUpper.captured[0].value,Colors.black.value);
      });

      test('should not display other points',(){
        verifyNever(mockPixelMap.updatePixel(any,any,any));
      });
    });
  });
}