import 'package:equatable/equatable.dart';

class SegmentBounds extends Equatable{
  final int xMin;
  final int xMax;
  final int yMin;
  final int yMax;

  SegmentBounds({this.xMin,this.xMax,this.yMin,this.yMax});

  @override
  List<Object> get props => [xMin,xMax,yMin,yMax];
}