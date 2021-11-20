import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'dart:ui';

class Visualizer extends StatefulWidget {
  Visualizer({
    required this.recorderSubscription,
    required this.isRecorderStreamInitialized,
    Key? key,
  }) : super(key: key);
  StreamSubscription<RecordingDisposition>? recorderSubscription;
  bool isRecorderStreamInitialized;
  @override
  _VisualizerState createState() => _VisualizerState();
}

class _VisualizerState extends State<Visualizer> {
  List<double> dbLevels = [0];
  bool _isRemoveModeEnable = false;

  void enableRemoveMode() {
    _isRemoveModeEnable = true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRecorderStreamInitialized) {
      widget.recorderSubscription?.onData(
        (data) {
          setState(() {
            dbLevels.add(data.decibels ?? 0);
            if (_isRemoveModeEnable) {
              dbLevels.removeAt(0);
            }
          });
        },
      );
    }
    return CustomPaint(
      size: const Size(400, double.infinity),
      painter: Painter(dbLevels, enableRemoveMode, _isRemoveModeEnable),
    );
  }
}

class Painter extends CustomPainter {
  Painter(this._dbLevels, this.enableRemoveMode, this._isRemoveModeEnable);
  List<double> _dbLevels;
  Function enableRemoveMode;
  bool _isRemoveModeEnable;

  final double _spaceBetwenLines = 2;
  double _halfHeight = 0;
  late double preventX;

  final paintSettings = Paint()
    ..color = Colors.black
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;

  void drawColumn(Canvas canvas, double dbLevel) {
    drawIndentLine(canvas);
    canvas.drawLine(
      Offset(preventX, _halfHeight - dbLevel / 1.2),
      Offset(preventX, _halfHeight + dbLevel / 1.2),
      paintSettings,
    );
    preventX = preventX + 2;
  }

  void drawIndentLine(Canvas canvas) {
    canvas.drawLine(
      Offset(preventX, _halfHeight),
      Offset(preventX + _spaceBetwenLines, _halfHeight),
      paintSettings,
    );
    preventX = preventX + _spaceBetwenLines;
  }

  void drawDeficientIndentLine(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, _halfHeight),
      Offset(size.width, _halfHeight),
      paintSettings,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    preventX = 0;
    _halfHeight = size.height / 2;
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    print(_dbLevels.length);

    if (_isRemoveModeEnable) {
      drawDeficientIndentLine(canvas, size);
    }

    _dbLevels.forEach((level) {
      if (level - 25 >= 0) {
        drawColumn(canvas, level);
      } else {
        drawIndentLine(canvas);
      }
      if (preventX >= size.width && _isRemoveModeEnable == false) {
        enableRemoveMode();
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
