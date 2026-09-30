// In-Class Activity 06 — Smiley Face
// Student: Brian Smith
// Date: September 30, 2026

import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

enum FaceType {
  classic('Classic'),
  sleepy('Sleepy'),
  surprised('Surprised');

  const FaceType(this.label);
  final String label;
}

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  // Drawing "state" — changing these + setState() triggers shouldRepaint
  double mood = 0.8; // 0.0 sad → 1.0 happy
  FaceType faceType = FaceType.classic;
  Color? faceColor; // null = use the mood color bands
  final _random = Random();

  static final _palette = <String, Color>{
    'pink': Colors.pink.shade200,
    'green': Colors.lightGreen.shade400,
    'purple': Colors.purple.shade200,
    'teal': Colors.teal.shade200,
    'yellow': Colors.yellow.shade600,
  };

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _cycleFace() {
    final next = FaceType.values[(faceType.index + 1) % FaceType.values.length];
    setState(() => faceType = next);
    _showMessage('Face changed to ${next.label}');
  }

  void _randomize() {
    final colorName = _palette.keys.elementAt(_random.nextInt(_palette.length));
    final newMood = _random.nextDouble();
    setState(() {
      mood = newMood;
      faceColor = _palette[colorName];
    });
    _showMessage(
      'Random mood ${newMood.toStringAsFixed(2)} with a $colorName face',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _cycleFace,
                onLongPress: _randomize,
                child: CustomPaint(
                  key: const Key('smiley'),
                  size: const Size(300, 300),
                  painter: SmileyPainter(
                    mood: mood,
                    faceType: faceType,
                    faceColor: faceColor,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SegmentedButton<FaceType>(
                  segments: [
                    for (final type in FaceType.values)
                      ButtonSegment(value: type, label: Text(type.label)),
                  ],
                  selected: {faceType},
                  onSelectionChanged: (selection) =>
                      setState(() => faceType = selection.first),
                ),
                const SizedBox(height: 8),
                Text('Mood: ${mood.toStringAsFixed(2)}'),
                Slider(
                  value: mood,
                  onChanged: (double v) => setState(() {
                    mood = v;
                    faceColor = null;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({required this.mood, required this.faceType, this.faceColor});
  final double mood;
  final FaceType faceType;
  final Color? faceColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Modules 2–3: add eyes and mouth here. Base every position on size, center, or radius.
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.35;

    final facePaint = Paint()
      ..color =
          faceColor ??
          (mood < 0.35
              ? Colors.lightBlue.shade300
              : mood <= 0.7
              ? Colors.yellow.shade600
              : Colors.orange.shade400)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    final border = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, border);

    final eyePaint = Paint()..color = Colors.black87;
    final eyeY = center.dy - radius * 0.2;
    final eyeDx = radius * 0.35;
    final leftEye = Offset(center.dx - eyeDx, eyeY);
    final rightEye = Offset(center.dx + eyeDx, eyeY);

    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    if (faceType == FaceType.sleepy) {
      // Closed eyes: the bottom half of a small circle.
      for (final eye in [leftEye, rightEye]) {
        final eyeRect = Rect.fromCircle(center: eye, radius: radius * 0.13);
        canvas.drawArc(eyeRect, 0, pi, false, mouthPaint);
      }
      final sleepyMouth = Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.4),
        width: radius * 0.5,
        height: radius * 0.2,
      );
      canvas.drawArc(sleepyMouth, 0.15 * pi, 0.70 * pi, false, mouthPaint);
      return;
    }

    if (faceType == FaceType.surprised) {
      canvas.drawCircle(leftEye, radius * 0.17, eyePaint);
      canvas.drawCircle(rightEye, radius * 0.17, eyePaint);
      final openMouth = Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.45),
        width: radius * 0.3,
        height: radius * 0.4,
      );
      canvas.drawOval(openMouth, mouthPaint);
      return;
    }

    canvas.drawCircle(leftEye, radius * 0.11, eyePaint);
    canvas.drawCircle(rightEye, radius * 0.11, eyePaint);

    if (mood < 0.35) {
      final frownRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.55),
        width: radius * 0.9,
        height: radius * 0.6,
      );
      canvas.drawArc(frownRect, 1.15 * pi, 0.70 * pi, false, mouthPaint);
    } else {
      final smileHeight = mood <= 0.7 ? radius * 0.4 : radius * 0.9;
      final smileRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.15),
        width: radius * 1.0,
        height: smileHeight,
      );
      canvas.drawArc(smileRect, 0.15 * pi, 0.70 * pi, false, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.faceType != faceType ||
        oldDelegate.faceColor != faceColor;
  }
}
