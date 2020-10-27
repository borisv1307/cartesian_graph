import 'package:cartesian_graph/bounds.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/src/display/coordinate_pixel_translator.dart';
import 'package:cartesian_graph/src/display/display_size.dart';
import 'package:cartesian_graph/src/display/invalid_graph_exception.dart';
import 'package:cartesian_graph/src/display/pixel_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Coordinate pixel creation',(){
    test('creates a translator',(){
      CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(3,3),1);
      expect(translator, isInstanceOf<CoordinatePixelTranslator>());
    });

    test('inputs bounds',(){
      Bounds bounds = Bounds(-1,1,-1,1);
      CoordinatePixelTranslator translator = CoordinatePixelTranslator(bounds,DisplaySize(3,3),1);
      expect(translator.bounds, bounds);
    });

    test('inputs display size',(){
      DisplaySize displaySize = DisplaySize(3,3);
      CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(-1,1,-1,1),displaySize,1);
      expect(translator.displaySize, displaySize);
    });

    test('inputs density',(){
      int density = 1;
      CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(3,3),density);
      expect(translator.lineWeight, 1);
    });
  });

  group('Invalid graphs',(){
    group('Display size of zero',(){
      test('has no width',(){
        expect(()=>CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(0,3),4),throwsA(isA<InvalidGraphException>()));
      });

      test('has no height',(){
        expect(()=>CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(3,0),4),throwsA(isA<InvalidGraphException>()));
      });

      test('has line weight less than 1',(){
        expect(()=>CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(3,0),0),throwsA(isA<InvalidGraphException>()));
      });
    });
  });
  group('Axis location is correct',(){
    group('Centered graph',(){
      CoordinatePixelTranslator translator;
      setUpAll((){
        translator = CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(3,3),1);
      });

      test('center is correct',(){
        PixelLocation pixel = translator.calculatePixelLocation(Coordinates(0,0));
        expect(pixel, PixelLocation(1, 1));
      });

      test('left of y axis is correct',(){
        PixelLocation pixel = translator.calculatePixelLocation(Coordinates(-1,0));
        expect(pixel, PixelLocation(0, 1));
      });

      test('right of y axis is correct',(){
        PixelLocation pixel = translator.calculatePixelLocation(Coordinates(1,0));
        expect(pixel, PixelLocation(2, 1));
      });

      test('above x axis is correct',(){
        PixelLocation pixel = translator.calculatePixelLocation(Coordinates(0,1));
        expect(pixel, PixelLocation(1, 2));
      });

      test('below x axis is correct',(){
        PixelLocation pixel = translator.calculatePixelLocation(Coordinates(0,-1));
        expect(pixel, PixelLocation(1, 0));
      });
    });

    group('Off centered graph',(){
      CoordinatePixelTranslator translator;
      setUpAll((){
        translator = CoordinatePixelTranslator(Bounds(0,2,0,2),DisplaySize(3,3),1);
      });

      test('center is correct',(){
        PixelLocation pixel = translator.calculatePixelLocation(Coordinates(0,0));
        expect(pixel, PixelLocation(0, 0));
      });

      test('above x axis is correct',(){
        PixelLocation pixel = translator.calculatePixelLocation(Coordinates(0,1));
        expect(pixel, PixelLocation(0, 1));
      });

      test('far above x axis is correct',(){
        PixelLocation pixel = translator.calculatePixelLocation(Coordinates(0,2));
        expect(pixel, PixelLocation(0, 2));
      });

      test('right of y axis is correct',(){
        PixelLocation pixel = translator.calculatePixelLocation(Coordinates(1,0));
        expect(pixel, PixelLocation(1, 0));
      });

      test('far right of y axis is correct',(){
        PixelLocation pixel = translator.calculatePixelLocation(Coordinates(2,0));
        expect(pixel, PixelLocation(2,0));
      });
    });

    group('Graph that extends beyond bounds',(){
      CoordinatePixelTranslator translator;
      setUpAll((){
        translator = CoordinatePixelTranslator(Bounds(-2,3,-2,3),DisplaySize(4,4),1);
      });

      test('center is correct',(){
        PixelLocation pixel = translator.calculatePixelLocation(Coordinates(0,0));
        expect(pixel, PixelLocation(1, 1));
      });
    });
  });

  group('X values identified for display',(){
    List<double> xCoordinates;

    void coordinateBuilder(List<double> xCoords){
      xCoordinates = xCoords;
    }

    group('graph with precision of 1',(){
      test('line weight of  1',(){
        CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(3,3),1, builder:coordinateBuilder);
        expect(xCoordinates,[-1,0,1]);
      });

      test('line weight of greater than 1',(){
        CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(6,6),2, builder:coordinateBuilder);
        expect(xCoordinates,[-1,0,1]);
      });
    });

    test('graph with fractional precision',(){
      CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(5,5),1, builder:coordinateBuilder);
      expect(xCoordinates,[-1,-0.5,0,0.5,1]);
    });

    test('off center graph',(){
      CoordinatePixelTranslator(Bounds(0,2,0,2),DisplaySize(3,3),1, builder: coordinateBuilder);
      expect(xCoordinates,[0,1,2]);
    });

    test('graph with precision greater than 1',(){
      CoordinatePixelTranslator(Bounds(-2,2,-2,2),DisplaySize(3,3),1, builder:coordinateBuilder);
      expect(xCoordinates,[-2,0,2]);
    });

    test('graph with bounds resulting in axis not visible',(){
      CoordinatePixelTranslator(Bounds(1,3,1,3),DisplaySize(3,3),1, builder:coordinateBuilder);
      expect(xCoordinates,[1,2,3]);
    });

    group('display must display beyond bounds to ensure precision consistency',(){
      test('scale left of y axis utilized', (){
        CoordinatePixelTranslator(Bounds(-2,3,-2,3),DisplaySize(4,4),1, builder:coordinateBuilder);
        expect(xCoordinates,[-2,0,2,4]);
      });

      test('scale right of y axis utilized', (){
        CoordinatePixelTranslator(Bounds(-3,2,-3,2),DisplaySize(4,4),1, builder:coordinateBuilder);
        expect(xCoordinates,[-4,-2,0,2]);
      });
    });
  });



}