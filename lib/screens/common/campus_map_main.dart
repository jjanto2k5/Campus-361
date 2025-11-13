import 'package:flutter/material.dart';
import 'dart:ui' show Canvas, Paint, PathMetrics;
import 'dart:collection';
import 'dart:math';
import '../welcome_screen.dart';


class CampusMapMainScreen extends StatefulWidget {
  final String? startRoom;
  final String? destinationRoom;
  final bool fromGuest;
  final VoidCallback? onBackToHome;


  const CampusMapMainScreen({
    Key? key,
    this.startRoom,
    this.destinationRoom,
    this.fromGuest = false,
    this.onBackToHome,
  }) : super(key: key);

  @override
  State<CampusMapMainScreen> createState() => _CampusMapMainScreenState();
}

class _CampusMapMainScreenState extends State<CampusMapMainScreen>
    with SingleTickerProviderStateMixin {
  String? startRoom;
  String? endRoom;
  bool isPanelExpanded = true;
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

    startRoom = widget.startRoom;
    endRoom = widget.destinationRoom;

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

        //Back Button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (widget.fromGuest) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              );
            } else {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              }
              Navigator.pop(context);
            }
          },
        ),
      ),

      // === Map Body ===
      body: Stack(
        children: [
          // Map layout and animations 
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

          // === Bottom Sliding Panel ===
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

                    // Collapsed view
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

                    // Expanded view
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

// === Graph & Dijkstra Implementation ===
class GraphNode {
  final String id;
  final Offset position;
  final Map<String, double> neighbors; // neighborId -> distance

  GraphNode(this.id, this.position) : neighbors = {};
}

class CampusGraph {
  final Map<String, GraphNode> nodes = {};

  void addNode(String id, Offset position) {
    nodes[id] = GraphNode(id, position);
  }

  void addEdge(String from, String to) {
    if (nodes.containsKey(from) && nodes.containsKey(to)) {
      final distance = _calculateDistance(nodes[from]!.position, nodes[to]!.position);
      nodes[from]!.neighbors[to] = distance;
      nodes[to]!.neighbors[from] = distance; // bidirectional
    }
  }

  double _calculateDistance(Offset a, Offset b) {
    return sqrt(pow(a.dx - b.dx, 2) + pow(a.dy - b.dy, 2));
  }

  List<String> dijkstra(String start, String end) {
    if (!nodes.containsKey(start) || !nodes.containsKey(end)) {
      return [];
    }

    final distances = <String, double>{};
    final previous = <String, String?>{};
    final unvisited = <String>{};

    // Initialize
    for (final nodeId in nodes.keys) {
      distances[nodeId] = double.infinity;
      previous[nodeId] = null;
      unvisited.add(nodeId);
    }
    distances[start] = 0;

    while (unvisited.isNotEmpty) {
      // Find node with minimum distance
      String? current;
      double minDist = double.infinity;
      for (final nodeId in unvisited) {
        if (distances[nodeId]! < minDist) {
          minDist = distances[nodeId]!;
          current = nodeId;
        }
      }

      if (current == null || current == end) break;
      unvisited.remove(current);

      // Update distances to neighbors
      for (final neighbor in nodes[current]!.neighbors.keys) {
        if (!unvisited.contains(neighbor)) continue;
        
        final alt = distances[current]! + nodes[current]!.neighbors[neighbor]!;
        if (alt < distances[neighbor]!) {
          distances[neighbor] = alt;
          previous[neighbor] = current;
        }
      }
    }

    // Reconstruct path
    final path = <String>[];
    String? current = end;
    while (current != null) {
      path.insert(0, current);
      current = previous[current];
    }

    return path.isEmpty || path.first != start ? [] : path;
  }

  List<Offset> getPathPositions(List<String> nodeIds) {
    return nodeIds.map((id) => nodes[id]!.position).toList();
  }
}

CampusGraph buildCampusGraph() {
  final graph = CampusGraph();

  // Define hallway nodes
  graph.addNode('top', const Offset(0.5, 0.1));
  graph.addNode('upper', const Offset(0.5, 0.25));
  graph.addNode('center', const Offset(0.5, 0.55));
  graph.addNode('lower', const Offset(0.5, 0.85));
  graph.addNode('left', const Offset(0.2, 0.55));
  graph.addNode('right', const Offset(0.8, 0.55));

  // Define room entrance nodes
  graph.addNode('S101_entrance', const Offset(0.5, 0.85));
  graph.addNode('S102_entrance', const Offset(0.5, 0.85));
  graph.addNode('S103_entrance', const Offset(0.2, 0.55));
  graph.addNode('S104_entrance', const Offset(0.8, 0.55));
  graph.addNode('S105_entrance', const Offset(0.5, 0.25));
  graph.addNode('S106_entrance', const Offset(0.5, 0.25));

  // Define room nodes
  graph.addNode('S101', const Offset(0.35, 0.85));
  graph.addNode('S102', const Offset(0.65, 0.85));
  graph.addNode('S103', const Offset(0.25, 0.55));
  graph.addNode('S104', const Offset(0.75, 0.55));
  graph.addNode('S105', const Offset(0.25, 0.25));
  graph.addNode('S106', const Offset(0.75, 0.25));

  // Connect hallway nodes (main corridors)
  graph.addEdge('top', 'upper');
  graph.addEdge('upper', 'center');
  graph.addEdge('center', 'lower');
  graph.addEdge('left', 'center');
  graph.addEdge('center', 'right');

  // Connect rooms to their entrance nodes
  graph.addEdge('S101', 'S101_entrance');
  graph.addEdge('S102', 'S102_entrance');
  graph.addEdge('S103', 'S103_entrance');
  graph.addEdge('S104', 'S104_entrance');
  graph.addEdge('S105', 'S105_entrance');
  graph.addEdge('S106', 'S106_entrance');

  // Connect entrance nodes to hallway nodes
  graph.addEdge('S101_entrance', 'lower');
  graph.addEdge('S102_entrance', 'lower');
  graph.addEdge('S103_entrance', 'left');
  graph.addEdge('S104_entrance', 'right');
  graph.addEdge('S105_entrance', 'upper');
  graph.addEdge('S106_entrance', 'upper');

  return graph;
}

// === Map Painter (unchanged) ===
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

    // Rooms
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

    // Path animation using Dijkstra's algorithm
    if (start != null && end != null) {
      final graph = buildCampusGraph();
      final pathNodes = graph.dijkstra(start!, end!);
      
      if (pathNodes.isNotEmpty) {
        final pathPositions = graph.getPathPositions(pathNodes);
        
        // Build path from positions
        final path = Path();
        path.moveTo(pathPositions[0].dx * width, pathPositions[0].dy * height);
        for (int i = 1; i < pathPositions.length; i++) {
          path.lineTo(pathPositions[i].dx * width, pathPositions[i].dy * height);
        }

        final PathMetrics metrics = path.computeMetrics();
        for (final metric in metrics) {
          final segment = metric.extractPath(0, metric.length * progress);
          canvas.drawPath(segment, pathPaint);
        }

        // Start (green) and End (red) markers
        final s = pathPositions.first;
        final e = pathPositions.last;
        canvas.drawCircle(
            Offset(s.dx * width, s.dy * height), 8, Paint()..color = Colors.green);
        canvas.drawCircle(
            Offset(e.dx * width, e.dy * height), 8, Paint()..color = Colors.red);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => true;
}
