class Bounds{
  final int xMin;
  final int xMax;
  final int yMin;
  final int yMax;

  Bounds(this.xMin,this.xMax,this.yMin,this.yMax):
        assert(xMax > xMin, 'Maximum x must be greater than minimum x'),
        assert(yMax > yMin, 'Maximum y must be greater than minimum y');
}