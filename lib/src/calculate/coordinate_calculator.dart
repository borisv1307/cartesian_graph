
import 'package:ffi/ffi.dart';

import 'library_loader.dart';

class CoordinateCalculator {
  CalculateFunction calculateFunction;

  CoordinateCalculator(){
    calculateFunction = getLibraryLoader().load();
  }

  LibraryLoader getLibraryLoader(){
    return LibraryLoader();
  }

  double calculate(String equation, double xValue){
    double result = calculateFunction(Utf8.toUtf8(equation), xValue);
    return result;
  }
}