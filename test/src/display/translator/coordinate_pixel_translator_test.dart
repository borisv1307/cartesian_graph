import 'package:cartesian_graph/bounds.dart';
import 'package:cartesian_graph/coordinates.dart';
import 'file:///C:/Users/Greg/IdeaProjects/se-calc/cartesian_graph/lib/src/display/translator/coordinate_pixel_translator.dart';
import 'package:cartesian_graph/src/display/display_size.dart';
import 'file:///C:/Users/Greg/IdeaProjects/se-calc/cartesian_graph/lib/src/display/translator/invalid_graph_exception.dart';
import 'package:cartesian_graph/src/display/pixel_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Coordinate pixel creation',(){
    test('creates a translator',(){
      CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(3,3),1);
      expect(translator, isInstanceOf<CoordinatePixelTranslator>());
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
        PixelPoint pixel = translator.calculatePixelPoint(Coordinates(0,0));
        expect(pixel, PixelPoint(1, 1));
      });

      test('left of y axis is correct',(){
        PixelPoint pixel = translator.calculatePixelPoint(Coordinates(-1,0));
        expect(pixel, PixelPoint(0, 1));
      });

      test('right of y axis is correct',(){
        PixelPoint pixel = translator.calculatePixelPoint(Coordinates(1,0));
        expect(pixel, PixelPoint(2, 1));
      });

      test('above x axis is correct',(){
        PixelPoint pixel = translator.calculatePixelPoint(Coordinates(0,1));
        expect(pixel, PixelPoint(1, 2));
      });

      test('below x axis is correct',(){
        PixelPoint pixel = translator.calculatePixelPoint(Coordinates(0,-1));
        expect(pixel, PixelPoint(1, 0));
      });
    });

    group('Off centered graph',(){
      CoordinatePixelTranslator translator;
      setUpAll((){
        translator = CoordinatePixelTranslator(Bounds(0,2,0,2),DisplaySize(3,3),1);
      });

      test('center is correct',(){
        PixelPoint pixel = translator.calculatePixelPoint(Coordinates(0,0));
        expect(pixel, PixelPoint(0, 0));
      });

      test('above x axis is correct',(){
        PixelPoint pixel = translator.calculatePixelPoint(Coordinates(0,1));
        expect(pixel, PixelPoint(0, 1));
      });

      test('far above x axis is correct',(){
        PixelPoint pixel = translator.calculatePixelPoint(Coordinates(0,2));
        expect(pixel, PixelPoint(0, 2));
      });

      test('right of y axis is correct',(){
        PixelPoint pixel = translator.calculatePixelPoint(Coordinates(1,0));
        expect(pixel, PixelPoint(1, 0));
      });

      test('far right of y axis is correct',(){
        PixelPoint pixel = translator.calculatePixelPoint(Coordinates(2,0));
        expect(pixel, PixelPoint(2,0));
      });
    });

    group('Graph that extends beyond bounds',(){
      CoordinatePixelTranslator translator;
      setUpAll((){
        translator = CoordinatePixelTranslator(Bounds(-2,3,-2,3),DisplaySize(4,4),1);
      });

      test('center is correct',(){
        PixelPoint pixel = translator.calculatePixelPoint(Coordinates(0,0));
        expect(pixel, PixelPoint(1, 1));
      });
    });
  });

  group('X values identified for display',(){
    group('graph with precision of 1',(){
      test('line weight of  1',(){
        CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(3,3),1);
        expect(translator.xCoordinates,[-1,0,1]);
      });

      test('line weight of greater than 1',(){
        CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(6,6),2);
        expect(translator.xCoordinates,[-1,0,1]);
      });
    });

    test('graph with fractional precision',(){
      CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(-1,1,-1,1),DisplaySize(5,5),1);
      expect(translator.xCoordinates,[-1,-0.5,0,0.5,1]);
    });

    test('off center graph',(){
      CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(0,2,0,2),DisplaySize(3,3),1);
      expect(translator.xCoordinates,[0,1,2]);
    });

    test('graph with precision greater than 1',(){
      CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(-2,2,-2,2),DisplaySize(3,3),1);
      expect(translator.xCoordinates,[-2,0,2]);
    });

    test('graph with bounds resulting in axis not visible',(){
      CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(1,3,1,3),DisplaySize(3,3),1);
      expect(translator.xCoordinates,[1,2,3]);
    });

    group('display must display beyond bounds to ensure precision consistency',(){
      test('scale left of y axis utilized', (){
        CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(-2,3,-2,3),DisplaySize(4,4),1);
        expect(translator.xCoordinates,[-2,0,2,4]);
      });

      test('scale right of y axis utilized', (){
        CoordinatePixelTranslator translator = CoordinatePixelTranslator(Bounds(-3,2,-3,2),DisplaySize(4,4),1);
        expect(translator.xCoordinates,[-4,-2,0,2]);
      });
    });
  });



}