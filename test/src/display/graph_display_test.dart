import 'package:cartesian_graph/bounds.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/src/display/display_size.dart';
import 'package:cartesian_graph/src/display/graph_display.dart';
import 'package:cartesian_graph/src/display/pixel_cluster.dart';
import 'package:cartesian_graph/src/display/pixel_map.dart';
import 'package:cartesian_graph/src/display/translator/coordinate_pixel_translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockPixelMap extends Mock implements PixelMap{}
class MockCoordinatePixelTranslator extends Mock implements CoordinatePixelTranslator{}

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


  test('Provides generated x coordinates',(){
    GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(-1,1,-1,1),DisplaySize(3,3),1);
    expect(graphDisplay.translator.xCoordinates, graphDisplay.xCoordinates);
  });


  group('Adjacent segment plotting unscaled',(){
    GraphDisplay graphDisplay;
    MockPixelMap mockPixelMap;
    MockCoordinatePixelTranslator translator;
    setUp((){
      graphDisplay = GraphDisplay.bounds(Bounds(-1,1,-1,1),DisplaySize(3,3),1);
      mockPixelMap = MockPixelMap();
      graphDisplay.pixelMap = mockPixelMap;

      translator = MockCoordinatePixelTranslator();
      when(translator.calculatePixelCluster(Coordinates(0,0))).thenReturn(PixelCluster(1, 1));
      when(translator.calculatePixelCluster(Coordinates(0,1))).thenReturn(PixelCluster(1, 2));
      graphDisplay.translator = translator;

      graphDisplay.plotSegment(Coordinates(0,0), Coordinates(0,1), Colors.black);
    });
    
    test('should update 2 pixels',(){
      verify(mockPixelMap.updatePixel(any,any,any)).called(2);
    });

    test('should translate pixels',(){
      verify(translator.calculatePixelCluster(Coordinates(0,0))).called(1);
      verify(translator.calculatePixelCluster(Coordinates(0,1))).called(1);
    });

    test('should plot start point',(){
      var call = verify(mockPixelMap.updatePixel(1,1,captureAny));
      call.called(1);
      expect(call.captured[0].value,Colors.black.value);
    });

    test('should plot end point',(){
      var call = verify(mockPixelMap.updatePixel(1,2,captureAny));
      call.called(1);
      expect(call.captured[0].value,Colors.black.value);
    });
  });

  group('Adjacent segment plotting scaled',(){
    MockPixelMap mockPixelMap;
    MockCoordinatePixelTranslator mockTranslator;
    setUp((){
      GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(-1,1,-1,1),DisplaySize(6,6),2);
      mockPixelMap = MockPixelMap();
      graphDisplay.pixelMap = mockPixelMap;

      mockTranslator = MockCoordinatePixelTranslator();
      when(mockTranslator.calculatePixelCluster(Coordinates(0,0))).thenReturn(PixelCluster(1, 1));
      when(mockTranslator.calculatePixelCluster(Coordinates(0,1))).thenReturn(PixelCluster(1, 2));
      graphDisplay.translator = mockTranslator;

      graphDisplay.plotSegment(Coordinates(0,0), Coordinates(0,1), Colors.black);
    });

    test('should update 8 pixels',(){
      verify(mockPixelMap.updatePixel(any,any,any)).called(8);
    });

    test('should plot start point',(){
      var call = verify(mockPixelMap.updatePixel(argThat(inInclusiveRange(2, 3)), argThat(inInclusiveRange(2, 3)),captureAny));
      call.called(4);
      call.captured.forEach((color) => expect(color.value,Colors.black.value));
    });

    test('should plot end point',(){
      var call = verify(mockPixelMap.updatePixel(argThat(inInclusiveRange(2, 3)), argThat(inInclusiveRange(4, 5)),captureAny));
      call.called(4);
      call.captured.forEach((color) => expect(color.value,Colors.black.value));
    });
  });

  group('Segment connection',(){
    MockPixelMap plotSegment(Coordinates start, Coordinates end, MockCoordinatePixelTranslator mockTranslator){
      GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(-2,2,-2,2),DisplaySize(5,5),1);
      MockPixelMap mockPixelMap = MockPixelMap();
      graphDisplay.pixelMap = mockPixelMap;
      graphDisplay.translator = mockTranslator;
      graphDisplay.plotSegment(start, end, Colors.black);

      return mockPixelMap;
    }
    group('sequential x values',(){
      group('with increasing y',(){
        group('and increasing x',() {
          MockPixelMap mockPixelMap;
          MockCoordinatePixelTranslator mockTranslator;
          setUp(() {
            mockTranslator = MockCoordinatePixelTranslator();
            when(mockTranslator.calculatePixelCluster(Coordinates(0,0))).thenReturn(PixelCluster(2, 2));
            when(mockTranslator.calculatePixelCluster(Coordinates(1,2))).thenReturn(PixelCluster(3, 4));

            mockPixelMap = plotSegment(Coordinates(0, 0), Coordinates(1, 2),mockTranslator);
          });

          test('should calculate 2 pixels',(){
            verify(mockTranslator.calculatePixelCluster(any)).called(2);
          });

          test('should update 3 pixels', () {
            verify(mockPixelMap.updatePixel(2, 2, any)).called(1);
            verify(mockPixelMap.updatePixel(3, 3, any)).called(1);
            verify(mockPixelMap.updatePixel(3, 4, any)).called(1);
          });

          test('should plot connection', () {
            var call = verify(mockPixelMap.updatePixel(3, 3, captureAny));
            call.called(1);
            expect(call.captured[0].value, Colors.black.value);
          });
        });

        group('and decreasing x',(){
          MockPixelMap mockPixelMap;
          MockCoordinatePixelTranslator mockTranslator;
          setUp(() {
            mockTranslator = MockCoordinatePixelTranslator();
            when(mockTranslator.calculatePixelCluster(Coordinates(0,0))).thenReturn(PixelCluster(2, 2));
            when(mockTranslator.calculatePixelCluster(Coordinates(-1,2))).thenReturn(PixelCluster(1, 4));

            mockPixelMap = plotSegment(Coordinates(0, 0), Coordinates(-1, 2),mockTranslator);
          });

          test('should calculate 2 pixels',(){
            verify(mockTranslator.calculatePixelCluster(any)).called(2);
          });

          test('should update 3 pixels', () {
            verify(mockPixelMap.updatePixel(1, 4, any)).called(1);
            verify(mockPixelMap.updatePixel(1, 3, any)).called(1);
            verify(mockPixelMap.updatePixel(2, 2, any)).called(1);
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
          MockCoordinatePixelTranslator mockTranslator;

          setUp(() {
            mockTranslator = MockCoordinatePixelTranslator();
            when(mockTranslator.calculatePixelCluster(Coordinates(0,0))).thenReturn(PixelCluster(2, 2));
            when(mockTranslator.calculatePixelCluster(Coordinates(1,-2))).thenReturn(PixelCluster(3, 0));

            mockPixelMap = plotSegment(Coordinates(0, 0), Coordinates(1, -2),mockTranslator);
          });

          test('should calculate 2 pixels',(){
            verify(mockTranslator.calculatePixelCluster(any)).called(2);
          });

          test('should update 3 pixels', () {
            verify(mockPixelMap.updatePixel(2, 2, any)).called(1);
            verify(mockPixelMap.updatePixel(3, 1, any)).called(1);
            verify(mockPixelMap.updatePixel(3, 0, any)).called(1);
          });

          test('should plot connection', () {
            var call = verify(mockPixelMap.updatePixel(3, 1, captureAny));
            call.called(1);
            expect(call.captured[0].value, Colors.black.value);
          });
        });

        group('and decreasing x',(){
          MockPixelMap mockPixelMap;
          MockCoordinatePixelTranslator mockTranslator;

          setUp(() {
            mockTranslator = MockCoordinatePixelTranslator();
            when(mockTranslator.calculatePixelCluster(Coordinates(0,0))).thenReturn(PixelCluster(2, 2));
            when(mockTranslator.calculatePixelCluster(Coordinates(-1,-2))).thenReturn(PixelCluster(1, 0));

            mockPixelMap = plotSegment(Coordinates(0, 0), Coordinates(-1, -2),mockTranslator);
          });

          test('should update 3 pixels', () {
            verify(mockPixelMap.updatePixel(2, 2, any)).called(1);
            verify(mockPixelMap.updatePixel(1, 1, any)).called(1);
            verify(mockPixelMap.updatePixel(1, 0, any)).called(1);
          });

          test('should plot connection', () {
            var call = verify(mockPixelMap.updatePixel(1, 1, captureAny));
            call.called(1);
            expect(call.captured[0].value, Colors.black.value);
          });
        });

      });

      group('fourth quadrant',(){
        MockPixelMap mockPixelMap;
        MockCoordinatePixelTranslator mockTranslator;
        setUp(() {
          mockTranslator = MockCoordinatePixelTranslator();
          when(mockTranslator.calculatePixelCluster(Coordinates(1,-2))).thenReturn(PixelCluster(3,0));
          when(mockTranslator.calculatePixelCluster(Coordinates(2,-1))).thenReturn(PixelCluster(4, 1));

          mockPixelMap = plotSegment(Coordinates(1, -2), Coordinates(2, -1),mockTranslator);
        });

        test('should calculate 2 pixels',(){
          verify(mockTranslator.calculatePixelCluster(any)).called(2);
        });

        test('should update endpoints', () {
          verify(mockPixelMap.updatePixel(3, 0, any)).called(1);
          verify(mockPixelMap.updatePixel(4, 1, any)).called(1);
          verifyNever(mockPixelMap.updatePixel(any, any, any));
        });
      });
    });
    group('non-sequential x values',(){
      group('perfect diagonal gap of 1',() {
        MockPixelMap mockPixelMap;
        MockCoordinatePixelTranslator mockTranslator;
        setUpAll(() {
          mockTranslator = MockCoordinatePixelTranslator();
          when(mockTranslator.calculatePixelCluster(Coordinates(-1,-1))).thenReturn(PixelCluster(1, 1));
          when(mockTranslator.calculatePixelCluster(Coordinates(1,1))).thenReturn(PixelCluster(3, 3));

          mockPixelMap = plotSegment(Coordinates(-1, -1), Coordinates(1, 1),mockTranslator);
        });

        test('should calculate 2 pixels',(){
          verify(mockTranslator.calculatePixelCluster(Coordinates(-1,-1))).called(1);
          verify(mockTranslator.calculatePixelCluster(Coordinates(1,1))).called(1);
        });

        test('should connect endpoints', () {
          verify(mockPixelMap.updatePixel(2, 2, any)).called(1);
        });

        test('should update endpoints', () {
          verify(mockPixelMap.updatePixel(1, 1, any)).called(1);
          verify(mockPixelMap.updatePixel(3, 3, any)).called(1);
        });


        test('should update no other points', () {
          verifyNever(mockPixelMap.updatePixel(any, any, any));
        });
      });

      group('uneven diagonal gap',() {
        MockPixelMap mockPixelMap;
        MockCoordinatePixelTranslator mockTranslator;
        setUpAll(() {
          mockTranslator = MockCoordinatePixelTranslator();
          when(mockTranslator.calculatePixelCluster(Coordinates(-1,-2))).thenReturn(PixelCluster(1, 0));
          when(mockTranslator.calculatePixelCluster(Coordinates(1,2))).thenReturn(PixelCluster(3, 4));

          mockPixelMap = plotSegment(Coordinates(-1, -2), Coordinates(1, 2),mockTranslator);
        });

        test('should calculate 2 pixels',(){
          verify(mockTranslator.calculatePixelCluster(Coordinates(-1,-2))).called(1);
          verify(mockTranslator.calculatePixelCluster(Coordinates(1,2))).called(1);
        });

        test('should connect endpoints', () {
          verify(mockPixelMap.updatePixel(2, 1, any)).called(1);
          verify(mockPixelMap.updatePixel(2, 2, any)).called(1);
          verify(mockPixelMap.updatePixel(3, 3, any)).called(1);
        });

        test('should update endpoints', () {
          verify(mockPixelMap.updatePixel(1, 0, any)).called(1);
          verify(mockPixelMap.updatePixel(3, 4, any)).called(1);
        });

        test('should update no other points', () {
          verifyNever(mockPixelMap.updatePixel(any, any, any));
        });
      });
    });

    group('horizontal gap of 1',() {
      MockPixelMap mockPixelMap;
      MockCoordinatePixelTranslator mockTranslator;
      setUpAll(() {
        mockTranslator = MockCoordinatePixelTranslator();
        when(mockTranslator.calculatePixelCluster(Coordinates(-1,1))).thenReturn(PixelCluster(1, 3));
        when(mockTranslator.calculatePixelCluster(Coordinates(1,1))).thenReturn(PixelCluster(3, 3));

        mockPixelMap = plotSegment(Coordinates(-1, 1), Coordinates(1, 1),mockTranslator);
      });

      test('should calculate 2 pixels',(){
        verify(mockTranslator.calculatePixelCluster(Coordinates(-1,1))).called(1);
        verify(mockTranslator.calculatePixelCluster(Coordinates(1,1))).called(1);
      });

      test('should connect endpoints', () {
        verify(mockPixelMap.updatePixel(2, 3, any)).called(1);
      });

      test('should update endpoints', () {
        verify(mockPixelMap.updatePixel(1, 3, any)).called(1);
        verify(mockPixelMap.updatePixel(3, 3, any)).called(1);
      });

      test('should update no other points', () {
        verifyNever(mockPixelMap.updatePixel(any, any, any));
      });
    });

    group('vertical gap of 1',() {
      MockPixelMap mockPixelMap;
      MockCoordinatePixelTranslator mockTranslator;
      setUpAll(() {
        mockTranslator = MockCoordinatePixelTranslator();
        when(mockTranslator.calculatePixelCluster(Coordinates(1,0))).thenReturn(PixelCluster(3, 2));
        when(mockTranslator.calculatePixelCluster(Coordinates(1,2))).thenReturn(PixelCluster(3, 4));

        mockPixelMap = plotSegment(Coordinates(1, 0), Coordinates(1, 2),mockTranslator);
      });

      test('should calculate 2 pixels',(){
        verify(mockTranslator.calculatePixelCluster(Coordinates(1,0))).called(1);
        verify(mockTranslator.calculatePixelCluster(Coordinates(1,2))).called(1);
      });

      test('should connect endpoints', () {
        verify(mockPixelMap.updatePixel(3, 3, any)).called(1);
      });

      test('should update endpoints', () {
        verify(mockPixelMap.updatePixel(3, 2, any)).called(1);
        verify(mockPixelMap.updatePixel(3, 4, any)).called(1);
      });

      test('should update no other points', () {
        verifyNever(mockPixelMap.updatePixel(any, any, any));
      });
    });
  });



  test('Segments are entirely out of bounds are not displayed',(){
    MockPixelMap mockPixelMap = MockPixelMap();
    GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(1,3,1,3),DisplaySize(3,3),1);
    graphDisplay.pixelMap = mockPixelMap;

    graphDisplay.plotSegment(Coordinates(5,5), Coordinates(6,7), Colors.black);

    verifyNever(mockPixelMap.updatePixel(any, any, any));
  });

  group('Displaying axes',(){
    group('Centered axes',(){
      MockPixelMap mockPixelMap;
      MockCoordinatePixelTranslator mockTranslator;

      setUpAll((){
        GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(-1,1,-1,1),DisplaySize(3,3),1);
        mockPixelMap = MockPixelMap();
        graphDisplay.pixelMap = mockPixelMap;

        mockTranslator = MockCoordinatePixelTranslator();
        when(mockTranslator.calculatePixelCluster(Coordinates(0,0))).thenReturn(PixelCluster(1, 1));
        graphDisplay.translator = mockTranslator;

        graphDisplay.displayAxes(Colors.black);
      });

      test('should calculate center pixel',(){
        verify(mockTranslator.calculatePixelCluster(any)).called(1);
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
      MockCoordinatePixelTranslator mockTranslator;

      setUpAll((){
        GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(0,2,-2,0),DisplaySize(3,3),1);
        mockPixelMap = MockPixelMap();
        graphDisplay.pixelMap = mockPixelMap;

        mockTranslator = MockCoordinatePixelTranslator();
        when(mockTranslator.calculatePixelCluster(Coordinates(0,0))).thenReturn(PixelCluster(0, 2));
        graphDisplay.translator = mockTranslator;

        graphDisplay.displayAxes(Colors.black);
      });

      test('should calculate center pixel',(){
        verify(mockTranslator.calculatePixelCluster(any)).called(1);
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

    group('No visible x axis',(){
      MockPixelMap mockPixelMap;
      MockCoordinatePixelTranslator mockTranslator;

      setUpAll((){
        GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(-1,1,1,3),DisplaySize(3,3),1);
        mockPixelMap = MockPixelMap();
        graphDisplay.pixelMap = mockPixelMap;

        mockTranslator = MockCoordinatePixelTranslator();
        when(mockTranslator.calculatePixelCluster(Coordinates(0,0))).thenReturn(PixelCluster(1, 0));
        graphDisplay.translator = mockTranslator;

        graphDisplay.displayAxes(Colors.black);
      });

      test('should calculate center pixel',(){
        verify(mockTranslator.calculatePixelCluster(any)).called(1);
      });

      test('should display y axis',(){
        var bottom = verify(mockPixelMap.updatePixel(1,0,captureAny));
        var middle = verify(mockPixelMap.updatePixel(1,1,captureAny));
        var top = verify(mockPixelMap.updatePixel(1,2,captureAny));

        expect(bottom.captured[0].value,Colors.black.value);
        expect(middle.captured[0].value,Colors.black.value);
        expect(top.captured[0].value,Colors.black.value);
      });

      test('should not display other points',(){
        verifyNever(mockPixelMap.updatePixel(any,any,any));
      });
    });

    group('No visible y axis',(){
      MockPixelMap mockPixelMap;
      MockCoordinatePixelTranslator mockTranslator;

      setUpAll((){
        GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(1,3,-1,1),DisplaySize(3,3),1);
        mockPixelMap = MockPixelMap();
        graphDisplay.pixelMap = mockPixelMap;

        mockTranslator = MockCoordinatePixelTranslator();
        when(mockTranslator.calculatePixelCluster(Coordinates(0,0))).thenReturn(PixelCluster(0, 1));
        graphDisplay.translator = mockTranslator;

        graphDisplay.displayAxes(Colors.black);
      });

      test('should calculate center pixel',(){
        verify(mockTranslator.calculatePixelCluster(any)).called(1);
      });

      test('should display x axis',(){
        var left = verify(mockPixelMap.updatePixel(0,1,captureAny));
        var middle = verify(mockPixelMap.updatePixel(1,1,captureAny));
        var right = verify(mockPixelMap.updatePixel(2,1,captureAny));

        expect(left.captured[0].value,Colors.black.value);
        expect(middle.captured[0].value,Colors.black.value);
        expect(right.captured[0].value,Colors.black.value);
      });

      test('should not display other points',(){
        verifyNever(mockPixelMap.updatePixel(any,any,any));
      });
    });
  });

  group('Displaying cursor',(){
    group('Centered',(){
      MockPixelMap mockPixelMap;
      MockCoordinatePixelTranslator mockTranslator;

      setUpAll((){
        GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(-1, 1, -1, 1), DisplaySize(3, 3), 1);
        mockPixelMap = MockPixelMap();
        graphDisplay.pixelMap = mockPixelMap;

        mockTranslator = MockCoordinatePixelTranslator();
        when(mockTranslator.calculatePixelCluster(Coordinates(0, 0))).thenReturn(PixelCluster(1, 1));
        graphDisplay.translator = mockTranslator;

        graphDisplay.displayCursor(Coordinates(0, 0));
      });

      test('should calculate center pixel',(){
        verify(mockTranslator.calculatePixelCluster(any)).called(1);
      });

      test('should display correct center pixel',(){
        var center = verify(mockPixelMap.updatePixel(1, 1, captureAny));
        expect(center.captured[0].value, Colors.blue.value);
      });

      test('should display cross pattern',(){
        var left = verify(mockPixelMap.updatePixel(1, 2, captureAny));
        var right = verify(mockPixelMap.updatePixel(1, 0, captureAny));
        var top = verify(mockPixelMap.updatePixel(2, 1, captureAny));
        var bottom = verify(mockPixelMap.updatePixel(0, 1, captureAny));

        expect(left.captured[0].value, Colors.blue.value);
        expect(right.captured[0].value, Colors.blue.value);
        expect(top.captured[0].value, Colors.blue.value);
        expect(bottom.captured[0].value, Colors.blue.value);
      });
    });

    group('Offset',(){
      MockPixelMap mockPixelMap;
      MockCoordinatePixelTranslator mockTranslator;

      setUpAll((){
        GraphDisplay graphDisplay = GraphDisplay.bounds(Bounds(-2, 2, -2, 2), DisplaySize(6, 6), 1);
        mockPixelMap = MockPixelMap();
        graphDisplay.pixelMap = mockPixelMap;

        mockTranslator = MockCoordinatePixelTranslator();
        when(mockTranslator.calculatePixelCluster(Coordinates(1, 1))).thenReturn(PixelCluster(2, 4));
        graphDisplay.translator = mockTranslator;

        graphDisplay.displayCursor(Coordinates(1, 1));
      });

      test('should calculate center pixel',(){
        verify(mockTranslator.calculatePixelCluster(any)).called(1);
      });

      test('should display correct center pixel',(){
        var center = verify(mockPixelMap.updatePixel(2, 4, captureAny));
        expect(center.captured[0].value, Colors.blue.value);
      });

      test('should display cross pattern',(){
        var left = verify(mockPixelMap.updatePixel(2, 5, captureAny));
        var right = verify(mockPixelMap.updatePixel(2, 3, captureAny));
        var top = verify(mockPixelMap.updatePixel(3, 4, captureAny));
        var bottom = verify(mockPixelMap.updatePixel(1, 4, captureAny));

        expect(left.captured[0].value, Colors.blue.value);
        expect(right.captured[0].value,Colors.blue.value);
        expect(top.captured[0].value,Colors.blue.value);
        expect(bottom.captured[0].value,Colors.blue.value);
      });

    });
  });
}