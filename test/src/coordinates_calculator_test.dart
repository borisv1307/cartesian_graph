import 'package:advanced_calculation/advanced_calculator.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/segment_bounds.dart';
import 'package:cartesian_graph/src/coordinates_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAdvancedCalculator extends Mock implements AdvancedCalculator{}

main(){
  test('Coordinates calculated',(){
    MockAdvancedCalculator mockAdvancedCalculator = MockAdvancedCalculator();
    when(mockAdvancedCalculator.calculateEquation('x', 1)).thenReturn(2);

    CoordinatesCalculator coordinatesCalculator = CoordinatesCalculator(calculator: mockAdvancedCalculator);
    List<Coordinates> calculatedCoordinates = coordinatesCalculator.calculate('x', [1], SegmentBounds());

    expect(calculatedCoordinates.length,1);
    expect(calculatedCoordinates[0],Coordinates(1, 2));
  });

  test('Multiple coordinates calculated',(){
    MockAdvancedCalculator mockAdvancedCalculator = MockAdvancedCalculator();
    when(mockAdvancedCalculator.calculateEquation('x', 1)).thenReturn(2);
    when(mockAdvancedCalculator.calculateEquation('x', 3)).thenReturn(4);

    CoordinatesCalculator coordinatesCalculator = CoordinatesCalculator(calculator: mockAdvancedCalculator);
    List<Coordinates> calculatedCoordinates = coordinatesCalculator.calculate('x', [1,3], SegmentBounds());

    expect(calculatedCoordinates.length,2);
    expect(calculatedCoordinates[0],Coordinates(1, 2));
    expect(calculatedCoordinates[1],Coordinates(3, 4));
  });

  group('Segment bounds',(){
    group('min x',(){
      test('removes coordinates',(){
        MockAdvancedCalculator mockAdvancedCalculator = MockAdvancedCalculator();
        when(mockAdvancedCalculator.calculateEquation('x', 1)).thenReturn(2);

        CoordinatesCalculator coordinatesCalculator = CoordinatesCalculator(calculator: mockAdvancedCalculator);
        List<Coordinates> calculatedCoordinates = coordinatesCalculator.calculate('x', [1], SegmentBounds(xMin: 2));

        expect(calculatedCoordinates,isEmpty);
      });

      test('is inclusive',(){
        MockAdvancedCalculator mockAdvancedCalculator = MockAdvancedCalculator();
        when(mockAdvancedCalculator.calculateEquation('x', 1)).thenReturn(2);

        CoordinatesCalculator coordinatesCalculator = CoordinatesCalculator(calculator: mockAdvancedCalculator);
        List<Coordinates> calculatedCoordinates = coordinatesCalculator.calculate('x', [1], SegmentBounds(xMin: 1));

        expect(calculatedCoordinates.length,1);
      });
    });

    group('max x',(){
      test('removes coordinates',(){
        MockAdvancedCalculator mockAdvancedCalculator = MockAdvancedCalculator();
        when(mockAdvancedCalculator.calculateEquation('x', 1)).thenReturn(2);

        CoordinatesCalculator coordinatesCalculator = CoordinatesCalculator(calculator: mockAdvancedCalculator);
        List<Coordinates> calculatedCoordinates = coordinatesCalculator.calculate('x', [1], SegmentBounds(xMax: 0));

        expect(calculatedCoordinates,isEmpty);
      });

      test('is inclusive',(){
        MockAdvancedCalculator mockAdvancedCalculator = MockAdvancedCalculator();
        when(mockAdvancedCalculator.calculateEquation('x', 1)).thenReturn(2);

        CoordinatesCalculator coordinatesCalculator = CoordinatesCalculator(calculator: mockAdvancedCalculator);
        List<Coordinates> calculatedCoordinates = coordinatesCalculator.calculate('x', [1], SegmentBounds(xMax: 1));

        expect(calculatedCoordinates.length,1);
      });
    });

    group('min y',(){
      test('removes coordinates',(){
        MockAdvancedCalculator mockAdvancedCalculator = MockAdvancedCalculator();
        when(mockAdvancedCalculator.calculateEquation('x', 1)).thenReturn(2);

        CoordinatesCalculator coordinatesCalculator = CoordinatesCalculator(calculator: mockAdvancedCalculator);
        List<Coordinates> calculatedCoordinates = coordinatesCalculator.calculate('x', [1], SegmentBounds(yMin: 3));

        expect(calculatedCoordinates,isEmpty);
      });

      test('is inclusive',(){
        MockAdvancedCalculator mockAdvancedCalculator = MockAdvancedCalculator();
        when(mockAdvancedCalculator.calculateEquation('x', 1)).thenReturn(2);

        CoordinatesCalculator coordinatesCalculator = CoordinatesCalculator(calculator: mockAdvancedCalculator);
        List<Coordinates> calculatedCoordinates = coordinatesCalculator.calculate('x', [1], SegmentBounds(yMin: 2));

        expect(calculatedCoordinates.length,1);
      });
    });

    group('max x',(){
      test('removes coordinates',(){
        MockAdvancedCalculator mockAdvancedCalculator = MockAdvancedCalculator();
        when(mockAdvancedCalculator.calculateEquation('x', 1)).thenReturn(2);

        CoordinatesCalculator coordinatesCalculator = CoordinatesCalculator(calculator: mockAdvancedCalculator);
        List<Coordinates> calculatedCoordinates = coordinatesCalculator.calculate('x', [1], SegmentBounds(yMax: 1));

        expect(calculatedCoordinates,isEmpty);
      });

      test('is inclusive',(){
        MockAdvancedCalculator mockAdvancedCalculator = MockAdvancedCalculator();
        when(mockAdvancedCalculator.calculateEquation('x', 1)).thenReturn(2);

        CoordinatesCalculator coordinatesCalculator = CoordinatesCalculator(calculator: mockAdvancedCalculator);
        List<Coordinates> calculatedCoordinates = coordinatesCalculator.calculate('x', [1], SegmentBounds(yMax: 2));

        expect(calculatedCoordinates.length,1);
      });
    });
  });
}