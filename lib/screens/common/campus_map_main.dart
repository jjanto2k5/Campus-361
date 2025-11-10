import 'package:flutter/material.dart';
import 'dart:ui' show Canvas, Paint, PathMetrics;

class CampusMapMainScreen extends StatefulWidget {
  final String? startRoom; // 👈 optional when coming from Map tab
  final String? destinationRoom; // 👈 required when coming from timetable

  const CampusMapMainScreen({
    Key? key,
    this.startRoom,
    this.destinationRoom,
  }) : super(key: key);

  @override
  State<CampusMapMainScreen> createState() => _CampusMapMainScreenState();
}

class _CampusMapMainScreenState extends State<CampusMapMainScreen>
    with SingleTickerProviderStateMixin {
  String? startRoom;
  String? endRoom;
  bool isPanelExpanded = true; // for the dropdown panel
  late AnimationController _controller;

  final Map<String, Offset> roomPositions = {
    'S101': const Offset(0.35, 0.85),
    'S102': const Offset(0.65, 0.85),
    'S103': const Offset(0.25, 0.55),
    'S104': const Offset(0.75, 0.55),
    'S105': const Offset(0.25, 0.25),
    'S106': const Offset(0.75, 0.25),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Auto-assign rooms when navigated from timetable
    startRoom = widget.startRoom;
    endRoom = widget.destinationRoom;

    // If both are provided, start path animation
    if (startRoom != null && endRoom != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.forward(from: 0);
        setState(() => isPanelExpanded = false);
      });
    }
  }

  void _showPath() {
    if (startRoom != null && endRoom != null) {
      _controller.forward(from: 0);
      FocusScope.of(context).unfocus();
      setState(() => isPanelExpanded = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both locations')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Campus Map'),
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: Stack(
        children: [
          // === Map Background ===
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _MapPainter(
                      roomPositions: roomPositions,
                      start: startRoom,
                      end: endRoom,
                      progress: _controller.value,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  );
                },
              );
            },
          ),

          // === Sliding Search Panel ===
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            bottom: isPanelExpanded ? 0 : -screenHeight * 0.25,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => setState(() => isPanelExpanded = true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Collapsed view (when panel is hidden)
                    if (!isPanelExpanded)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Path: ${startRoom ?? "?"} → ${endRoom ?? "?"}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_arrow_up),
                        ],
                      ),

                    // Expanded panel for manual selection
                    if (isPanelExpanded) ...[
                      Row(
                        children: [
                          const Icon(Icons.my_location,
                              color: Colors.blueAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: startRoom,
                              hint: const Text('From'),
                              decoration: _dropdownDecoration(),
                              items: roomPositions.keys
                                  .map((room) => DropdownMenuItem(
                                        value: room,
                                        child: Text(room),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => startRoom = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.redAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: endRoom,
                              hint: const Text('To'),
                              decoration: _dropdownDecoration(),
                              items: roomPositions.keys
                                  .map((room) => DropdownMenuItem(
                                        value: room,
                                        child: Text(room),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => endRoom = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        onPressed: _showPath,
                        icon: const Icon(Icons.navigation,
                            color: Colors.white, size: 18),
                        label: const Text(
                          "Show Path",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

// === MAP PAINTER ===
class _MapPainter extends CustomPainter {
  final Map<String, Offset> roomPositions;
  final String? start;
  final String? end;
  final double progress;
  final double width;
  final double height;

  _MapPainter({
    required this.roomPositions,
    required this.start,
    required this.end,
    required this.progress,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint hallPaint = Paint()
      ..color = const Color(0xFFE3E8EF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round;

    final Paint pathPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint roomFill = Paint()..color = Colors.white;
    final Paint border = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Hallway layout
    final Path layout = Path();
    layout.moveTo(width * 0.5, height * 0.1);
    layout.lineTo(width * 0.5, height * 0.9);
    layout.moveTo(width * 0.2, height * 0.55);
    layout.lineTo(width * 0.8, height * 0.55);
    canvas.drawPath(layout, hallPaint);

    // Draw rooms
    roomPositions.forEach((room, offset) {
      final rect = Rect.fromCenter(
        center: Offset(offset.dx * width, offset.dy * height),
        width: width * 0.16,
        height: height * 0.1,
      );
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
      canvas.drawShadow(Path()..addRRect(rrect), Colors.black54, 2, false);
      canvas.drawRRect(rrect, roomFill);
      canvas.drawRRect(rrect, border);

      textPainter.text = TextSpan(
        text: room,
        style: const TextStyle(fontSize: 15, color: Colors.black),
      );
      textPainter.layout(maxWidth: rect.width);
      textPainter.paint(
        canvas,
        Offset(rect.center.dx - textPainter.width / 2,
            rect.center.dy - textPainter.height / 2),
      );
    });

    // Path drawing
    if (start != null && end != null) {
      final s = roomPositions[start]!;
      final e = roomPositions[end]!;

      final path = Path()
        ..moveTo(s.dx * width, s.dy * height)
        ..lineTo(width * 0.5, s.dy * height)
        ..lineTo(width * 0.5, e.dy * height)
        ..lineTo(e.dx * width, e.dy * height);

      final PathMetrics metrics = path.computeMetrics();
      for (final metric in metrics) {
        final segment = metric.extractPath(0, metric.length * progress);
        canvas.drawPath(segment, pathPaint);
      }

      // Draw start (green) and end (red)
      canvas.drawCircle(Offset(s.dx * width, s.dy * height), 8,
          Paint()..color = Colors.green);
      canvas.drawCircle(Offset(e.dx * width, e.dy * height), 8,
          Paint()..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => true;
}
