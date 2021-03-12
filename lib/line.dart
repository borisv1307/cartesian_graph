import 'package:cartesian_graph/segment_bounds.dart';
import 'package:flutter/material.dart';

class Line{
  final Color color;
  final String equation;
  final SegmentBounds segmentBounds;
  Line(this.equation,{this.color = Colors.black, SegmentBounds segmentBounds}):
    this.segmentBounds = segmentBounds ?? SegmentBounds();
}