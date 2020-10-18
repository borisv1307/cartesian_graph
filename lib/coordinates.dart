import 'package:equatable/equatable.dart';

class Coordinates extends Equatable{
  final double x;
  final double y;

  Coordinates(this.x,this.y);

  @override
  String toString(){
    return 'X:${x.toString()} Y:${y.toString()}';
  }

  @override
  List<Object> get props => [x,y];



}