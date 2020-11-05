import 'package:equatable/equatable.dart';

class PixelCluster extends Equatable{
  final int x;
  final int y;

  PixelCluster(this.x, this.y);

  @override
  String toString(){
    return 'X:${x.toString()} Y:${y.toString()}';
  }

  @override
  List<Object> get props => [x,y];
}