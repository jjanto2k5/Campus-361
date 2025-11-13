// import 'package:flutter/material.dart';
// import 'dart:ui' show Canvas, Paint, PathMetrics, Tangent;
// import 'dart:math' as math;

// class CampusMapScreen extends StatefulWidget {
//   final String destinationRoom;

//   const CampusMapScreen({Key? key, required this.destinationRoom})
//       : super(key: key);

//   @override
//   State<CampusMapScreen> createState() => _CampusMapScreenState();
// }

// class _CampusMapScreenState extends State<CampusMapScreen>
//     with SingleTickerProviderStateMixin {
//   String? selectedStartRoom;
//   late AnimationController _controller;

//   final Map<String, Offset> roomPositions = {
//     'S101': const Offset(0.35, 0.85),
//     'S102': const Offset(0.65, 0.85),
//     'S103': const Offset(0.25, 0.55),
//     'S104': const Offset(0.75, 0.55),
//     'S105': const Offset(0.25, 0.25),
//     'S106': const Offset(0.75, 0.25),
//   };

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );
//     WidgetsBinding.instance.addPostFrameCallback((_) => _askCurrentLocation());
//   }

//   void _askCurrentLocation() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Select your current location"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: roomPositions.keys.map((room) {
//             return ListTile(
//               title: Text(room),
//               onTap: () {
//                 setState(() => selectedStartRoom = room);
//                 Navigator.pop(context);
//                 _controller.forward(from: 0);
//               },
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final start = selectedStartRoom;
//     final end = widget.destinationRoom;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Path from ${start ?? "?"} → $end"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 2,
//         shadowColor: Colors.black12,
//       ),
//       backgroundColor: const Color(0xFFF3F4F6),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return AnimatedBuilder(
//             animation: _controller,
//             builder: (context, _) {
//               return CustomPaint(
//                 painter: _MapPainter(
//                   roomPositions: roomPositions,
//                   start: start,
//                   end: end,
//                   progress: _controller.value,
//                   width: constraints.maxWidth,
//                   height: constraints.maxHeight,
//                 ),
//                 size: Size(constraints.maxWidth, constraints.maxHeight),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class _MapPainter extends CustomPainter {
//   final Map<String, Offset> roomPositions;
//   final String? start;
//   final String end;
//   final double progress;
//   final double width;
//   final double height;

//   _MapPainter({
//     required this.roomPositions,
//     required this.start,
//     required this.end,
//     required this.progress,
//     required this.width,
//     required this.height,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // --- Hallway base ---
//     final Paint hallwayPaint = Paint()
//       ..color = const Color(0xFFDCE1E6)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 40
//       ..strokeCap = StrokeCap.round;

//     final Paint hallwayShadow = Paint()
//       ..color = Colors.black.withOpacity(0.08)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 46
//       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

//     // --- Path (blue line) ---
//     final Paint pathPaint = Paint()
//       ..color = Colors.blueAccent
//       ..strokeWidth = 6
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;

//     // --- Rooms ---
//     final Paint roomFill = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;

//     final Paint roomBorder = Paint()
//       ..color = Colors.grey.shade400
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     final textPainter = TextPainter(
//       textAlign: TextAlign.center,
//       textDirection: TextDirection.ltr,
//     );

//     // ====== Draw Hallways ======
//     final Path hallway = Path();
//     hallway.moveTo(width * 0.5, height * 0.1);
//     hallway.lineTo(width * 0.5, height * 0.9);
//     hallway.moveTo(width * 0.2, height * 0.55);
//     hallway.lineTo(width * 0.8, height * 0.55);

//     // Add soft hallway shadow
//     canvas.drawPath(hallway, hallwayShadow);
//     canvas.drawPath(hallway, hallwayPaint);

//     // ====== Draw Rooms ======
//     roomPositions.forEach((room, offset) {
//       final Offset center = Offset(offset.dx * width, offset.dy * height);
//       final Rect rect = Rect.fromCenter(
//         center: center,
//         width: width * 0.16,
//         height: height * 0.1,
//       );

//       // Room box shadow (3D depth)
//       final RRect shadowRect =
//           RRect.fromRectAndRadius(rect, const Radius.circular(12));
//       canvas.drawShadow(Path()..addRRect(shadowRect), Colors.black54, 3, false);

//       // Room fill & border
//       canvas.drawRRect(shadowRect, roomFill);
//       canvas.drawRRect(shadowRect, roomBorder);

//       // Label
//       textPainter.text = TextSpan(
//         text: room,
//         style: const TextStyle(
//           fontSize: 15,
//           color: Colors.black,
//           fontWeight: FontWeight.w600,
//         ),
//       );
//       textPainter.layout(maxWidth: rect.width);
//       textPainter.paint(
//         canvas,
//         Offset(
//           rect.center.dx - textPainter.width / 2,
//           rect.center.dy - textPainter.height / 2,
//         ),
//       );
//     });

//     // ====== Draw Path ======
//     if (start != null &&
//         roomPositions[start] != null &&
//         roomPositions[end] != null) {
//       // Build a small graph representing walkable connections.
//       // Nodes: rooms + central junction `VC` at (midX, 0.55).
//       final midX = width * 0.5;
//       final vcKey = '__VC__';

//       // Helper to convert normalized offsets to absolute positions
//       Offset toAbs(Offset o) => Offset(o.dx * width, o.dy * height);

//       // Build positions map including VC
//       final Map<String, Offset> positions = {}..addAll(roomPositions);
//       positions[vcKey] = Offset(midX / width, 0.55); // normalized

//       // Build adjacency: Map<node, Map<neighbor, weight>>
//       Map<String, Map<String, double>> adj = {};
//       for (final a in positions.keys) {
//         adj[a] = {};
//       }

//       // Connect rooms that lie on the same horizontal hallway (y roughly equal)
//       const double sameRowEps = 0.02;
//       final keys = positions.keys.toList();
//       for (int i = 0; i < keys.length; i++) {
//         for (int j = i + 1; j < keys.length; j++) {
//           final ka = keys[i];
//           final kb = keys[j];
//           final pa = toAbs(positions[ka]!);
//           final pb = toAbs(positions[kb]!);
//           final dy = (pa.dy - pb.dy).abs() / height;
//           final dist = (pa - pb).distance;

//           // If both are rooms and on same visual row, allow direct edge
//           if (ka != vcKey && kb != vcKey && dy < sameRowEps) {
//             adj[ka]![kb] = dist;
//             adj[kb]![ka] = dist;
//           }
//         }
//       }

//       // Connect every room to VC (vertical hub) with weight = euclidean distance
//       for (final k in roomPositions.keys) {
//         final pa = toAbs(roomPositions[k]!);
//         final pvc = Offset(midX, pa.dy);
//         final distToVc = (pa - pvc).distance;
//         // connect room to virtual projection node (VC at same Y)
//         adj[k]![vcKey] = distToVc;
//         adj[vcKey]![k] = distToVc;
//       }

//       // Run Dijkstra on this small graph
//       List<String>? shortest = _dijkstra(adj, start!, end);

//       if (shortest != null && shortest.length >= 2) {
//         final path = Path();
//         for (int i = 0; i < shortest.length; i++) {
//           final node = shortest[i];
//           final pos = node == vcKey
//               ? Offset(midX, 0.55 * height)
//               : toAbs(roomPositions[node]!);
//           if (i == 0) path.moveTo(pos.dx, pos.dy);
//           else path.lineTo(pos.dx, pos.dy);
//         }

//         // Animate path reveal
//         final PathMetrics metrics = path.computeMetrics();
//         for (final metric in metrics) {
//           final extractPath = metric.extractPath(0, metric.length * progress);
//           canvas.drawPath(extractPath, pathPaint);
//         }

//         // Markers
//         final startPos = toAbs(roomPositions[start]!);
//         final endPos = toAbs(roomPositions[end]!);
//         canvas.drawCircle(startPos, 8, Paint()..color = Colors.green);
//         canvas.drawCircle(endPos, 8, Paint()..color = Colors.red);
//       }
//     }
//   }

//   // Simple Dijkstra implementation for small graphs
//   List<String>? _dijkstra(Map<String, Map<String, double>> adj, String src, String dst) {
//     final nodes = adj.keys.toList();
//     final dist = <String, double>{};
//     final prev = <String, String?>{};
//     final unvisited = <String>{}..addAll(nodes);

//     for (final n in nodes) {
//       dist[n] = double.infinity;
//       prev[n] = null;
//     }
//     dist[src] = 0;

//     while (unvisited.isNotEmpty) {
//       // pick node with smallest dist
//       String? u;
//       double best = double.infinity;
//       for (final n in unvisited) {
//         final d = dist[n]!;
//         if (d < best) {
//           best = d;
//           u = n;
//         }
//       }
//       if (u == null) break;
//       if (u == dst) break;
//       unvisited.remove(u);

//       final neighbors = adj[u]!;
//       for (final v in neighbors.keys) {
//         if (!unvisited.contains(v)) continue;
//         final alt = dist[u]! + neighbors[v]!;
//         if (alt < dist[v]!) {
//           dist[v] = alt;
//           prev[v] = u;
//         }
//       }
//     }

//     if (dist[dst] == double.infinity) return null;

//     // reconstruct path
//     final path = <String>[];
//     String? cur = dst;
//     while (cur != null) {
//       path.insert(0, cur);
//       cur = prev[cur];
//     }
//     return path;
//   }

//   @override
//   bool shouldRepaint(covariant _MapPainter oldDelegate) => true;
// }