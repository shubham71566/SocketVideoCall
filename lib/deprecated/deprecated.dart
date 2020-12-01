// class OverlayPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     var gradient = LinearGradient(
//       colors: [
//         Color(0xCC000000),
//         Color(0x88000000),
//         Color(0x55000000),
//         Color(0x20000000),
//         Color(0x55000000),
//         Color(0x88000000),
//         Color(0xCC000000),
//       ],
//       end: Alignment.topCenter,
//       begin: Alignment.bottomCenter,
//     );
//     var paint = Paint()
//       ..shader = gradient.createShader(
//         Rect.fromLTWH(0, 0, size.width, size.height),
//       );

//     var path = Path();
//     path.lineTo(0, size.height);
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width, 0);
//     path.close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }

// class Overlay extends StatefulWidget {
//   Overlay({
//     Key key,
//     // @required this.makeCall,
//     // @required this.hangUp,
//   }) : super(key: key);

//   // final Function makeCall;
//   // final Function hangUp;
//   @override
//   _OverlayState createState() => _OverlayState();
// }

// class _OverlayState extends State<Overlay> {
//   bool showOverlay = false;
//   bool _inCalling = false;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           showOverlay = !showOverlay;
//         });
//       },
//       child: (!showOverlay)
//           ? Container(
//               color: Color(0x00000000),
//             )
//           : Stack(
//               children: [
//                 CustomPaint(
//                   painter: OverlayPainter(),
//                   child: Container(
//                     color: Color(0x00000000),
//                   ),
//                 ),
//                 FloatingActionButton(
//                   onPressed: (){},//_inCalling ? widget.hangUp,
//                   tooltip: 'Hangup',
//                   child: Icon(Icons.call_end),
//                 ),
//               ],
//             ),
//     );
//   }
// }
