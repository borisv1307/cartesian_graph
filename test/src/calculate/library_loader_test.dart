import 'package:cartesian_graph/src/calculate/library_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //static calls are largely unmockable, and Dynamic Library cant even be implemented to mock
  test('Library loader creation can occur',(){
    LibraryLoader loader = LibraryLoader();
    expect(loader, isNotNull);
  });

  test('Filename that is loaded is correct',(){
    expect(LibraryLoader.FILE_NAME, "libcalc.so");
  });
}