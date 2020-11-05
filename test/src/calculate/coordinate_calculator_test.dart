import 'dart:ffi';

import 'package:cartesian_graph/src/calculate/coordinate_calculator.dart';
import 'package:cartesian_graph/src/calculate/library_loader.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class TestableCoordinateCalculator extends CoordinateCalculator{
  LibraryLoader loader;
  TestableCoordinateCalculator(this.loader);

  @override
  LibraryLoader getLibraryLoader(){
    return loader;
  }
}

class MockLibraryLoader extends Mock implements LibraryLoader{}

void main() {
  group('Creates coordinate calculator',(){
    MockLibraryLoader loader;
    TestableCoordinateCalculator calculator;
    setUpAll((){
      loader = MockLibraryLoader();
      calculator = TestableCoordinateCalculator(loader);
    });

    test('is created',(){
      expect(calculator, isNotNull);
    });

    test('loads function upfront',(){
      verify(loader.load()).called(1);
    });
  });

  group('Y value calculated',(){
    Pointer<Utf8> actualEquation;
    double actualX;
    double actualOutput;
    double calculate(Pointer<Utf8> equation, double x){
      actualEquation = equation;
      actualX = x;
      return 52;
    }

    setUpAll((){
      MockLibraryLoader loader = MockLibraryLoader();
      when(loader.load()).thenReturn(calculate);
      TestableCoordinateCalculator calculator = TestableCoordinateCalculator(loader);
      actualOutput = calculator.calculate('2x',6);
    });

    test('equation is utilized',(){
      expect(Utf8.fromUtf8(actualEquation),'2x');
    });

    test('x value is utilized',(){
      expect(actualX,6);
    });

    test('output is received',(){
      expect(actualOutput, 52);
    });
  });
}