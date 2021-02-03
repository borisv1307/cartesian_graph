import 'package:cartesian_graph/coordinates.dart';
import 'package:cartesian_graph/src/display/cluster_location.dart';
import 'package:cartesian_graph/src/display/translator/coordinate_pixel_location_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  group('Coordinate pixel location map creation',(){
    test('creates a map',(){
      CoordinatePixelPointLocationMap locationMap = CoordinatePixelPointLocationMap();
      expect(locationMap, isInstanceOf<CoordinatePixelPointLocationMap>());
    });
  });

  test('No matching item',(){
    CoordinatePixelPointLocationMap locationMap = CoordinatePixelPointLocationMap();
    expect(locationMap[Coordinates(1,1)], null);
  });

  test('Stores pixel locations by coordinates',(){
    Coordinates coordinates = Coordinates(2, 3);
    ClusterLocation location = ClusterLocation(5, 7);

    CoordinatePixelPointLocationMap locationMap = CoordinatePixelPointLocationMap();
    locationMap[coordinates] = location;

    expect(locationMap[coordinates], location);
  });

  group('Retrieves closest pixel location match', (){

    test('with closest x',(){
      CoordinatePixelPointLocationMap locationMap = CoordinatePixelPointLocationMap();
      locationMap[Coordinates(1,1)] = ClusterLocation(1, 1);
      expect(locationMap[Coordinates(1.2,1)], ClusterLocation(1,1));
    });

    test('with closest y',(){
      CoordinatePixelPointLocationMap locationMap = CoordinatePixelPointLocationMap();
      locationMap[Coordinates(1,1)] = ClusterLocation(1, 1);
      expect(locationMap[Coordinates(1.2,1.3)], ClusterLocation(1,1));
    });

    test('with closest x & y',(){
      CoordinatePixelPointLocationMap locationMap = CoordinatePixelPointLocationMap();
      locationMap[Coordinates(1,1)] = ClusterLocation(1, 1);
      locationMap[Coordinates(2,2)] = ClusterLocation(2, 2);
      expect(locationMap[Coordinates(1.4,1.7)], ClusterLocation(2,2));
    });
  });
}