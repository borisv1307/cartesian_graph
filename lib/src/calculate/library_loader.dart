import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef RawCalculateFunction = Double Function(Pointer<Utf8>, Double x);
typedef CalculateFunction = double Function(Pointer<Utf8>, double x);

class LibraryLoader{
  static const FILE_NAME = "libcalc.so";

  CalculateFunction load(){
     final DynamicLibrary library = Platform.isAndroid
         ?  DynamicLibrary.open(FILE_NAME)
         : DynamicLibrary.process();

     CalculateFunction calculateFunction =  library
         .lookup<NativeFunction<RawCalculateFunction>>("calculate_for_graph")
         .asFunction();

     return calculateFunction;
  }
}