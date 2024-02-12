import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/pages/line.dart';
import 'package:todo_app/pages/points.dart';
import 'drawing_painter.dart';

class DrawingArea extends ConsumerWidget {
  const DrawingArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(pointsProvider);
    final lines = ref.watch(linesProvider);

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              final Offset localPosition =
                  renderBox.globalToLocal(details.globalPosition);
              if (localPosition.dx >= 0 && localPosition.dy >= 0) {
                ref.read(pointsProvider.notifier).addPoint(localPosition);
              }
            },
            onPanEnd: (details) {
              if (points.isNotEmpty) {
                final lastPoint = points.last;
                if (lines.isNotEmpty) {
                  final firstPoint = points.first;
                  final lastLine = lines.last;
                  if (lastPoint != firstPoint &&
                      !ref.read(linesProvider.notifier).linesIntersect(
                          lastLine.start,
                          lastLine.end,
                          firstPoint,
                          lastPoint)) {
                    ref
                        .read(linesProvider.notifier)
                        .addLine(Line(firstPoint, lastPoint));
                  }
                } else {
                  ref.read(linesProvider.notifier).addLine(Line(points.first,
                      lastPoint)); // Используем первую точку в качестве начальной для первой линии
                }
                ref.read(pointsProvider.notifier).clearPoints();
              }
            },
            child: CustomPaint(
              painter: DrawingPainter(points: points, lines: lines),
              size: Size.infinite,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => ref.read(linesProvider.notifier).undo(),
              child: const Text('Назад'),
            ),
            ElevatedButton(
              onPressed: () => ref.read(linesProvider.notifier).redo(),
              child: const Text('Вперед'),
            ),
          ],
        ),
      ],
    );
  }
}
