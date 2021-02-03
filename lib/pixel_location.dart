import 'package:equatable/equatable.dart';

class PixelLocation extends Equatable{
  final int x;
  final int y;

  PixelLocation(this.x, this.y);

  @override
  String toString(){
    return 'X:${x.toString()} Y:${y.toString()}';
  }

  @override
  List<Object> get props => [x,y];
}