import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/src/display/pixel_location.dart';
import 'package:cartesian_graph/src/display/translator/coordinate_pixel_location_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  group('Coordinate pixel location map creation',(){
    test('creates a map',(){
      CoordinatePixelLocationMap locationMap = CoordinatePixelLocationMap();
      expect(locationMap, isInstanceOf<CoordinatePixelLocationMap>());
    });
  });

  test('No matching item',(){
    CoordinatePixelLocationMap locationMap = CoordinatePixelLocationMap();
    expect(locationMap[Coordinates(1,1)], null);
  });

  test('Stores pixel locations by coordinates',(){
    Coordinates coordinates = Coordinates(2, 3);
    PixelLocation location = PixelLocation(5, 7);

    CoordinatePixelLocationMap locationMap = CoordinatePixelLocationMap();
    locationMap[coordinates] = location;

    expect(locationMap[coordinates], location);
  });

  group('Retrieves closest match', (){

    test('with closest x',(){
      CoordinatePixelLocationMap locationMap = CoordinatePixelLocationMap();
      locationMap[Coordinates(1,1)] = PixelLocation(1, 1);
      expect(locationMap[Coordinates(1.2,1)], PixelLocation(1,1));
    });

    test('with closest y',(){
      CoordinatePixelLocationMap locationMap = CoordinatePixelLocationMap();
      locationMap[Coordinates(1,1)] = PixelLocation(1, 1);
      expect(locationMap[Coordinates(1.2,1.3)], PixelLocation(1,1));
    });

    test('with closest x & y',(){
      CoordinatePixelLocationMap locationMap = CoordinatePixelLocationMap();
      locationMap[Coordinates(1,1)] = PixelLocation(1, 1);
      locationMap[Coordinates(2,2)] = PixelLocation(2, 2);
      expect(locationMap[Coordinates(1.4,1.7)], PixelLocation(2,2));
    });
  });
}