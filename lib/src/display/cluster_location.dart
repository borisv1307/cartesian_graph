import 'package:equatable/equatable.dart';

class ClusterLocation extends Equatable{
  final int x;
  final int y;

  ClusterLocation(this.x, this.y);

  @override
  String toString(){
    return 'X:${x.toString()} Y:${y.toString()}';
  }

  @override
  List<Object> get props => [x,y];
}