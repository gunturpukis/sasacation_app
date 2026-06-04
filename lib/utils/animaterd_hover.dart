// // Untuk efek hover yang lebih menarik, tambahkan StatefulWidget
// import 'package:flutter/material.dart';

// class _AnimatedCategoryCard extends StatefulWidget {
//   final Map<String, dynamic> category;
  
//   const _AnimatedCategoryCard({required this.category});

//   @override
//   State<_AnimatedCategoryCard> createState() => _AnimatedCategoryCardState();
// }

// class _AnimatedCategoryCardState extends State<_AnimatedCategoryCard> {
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
//         child: GestureDetector(
//           onTap: () => _showCategoryDetail(context, widget.category),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(widget.category['color']).withOpacity(0.1),
//                   Color(widget.category['color']).withOpacity(0.05),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: Color(widget.category['color']).withOpacity(0.2),
//                 width: 1,
//               ),
//               boxShadow: _isHovered
//                   ? [
//                       BoxShadow(
//                         color: Color(widget.category['color']).withOpacity(0.2),
//                         blurRadius: 15,
//                         offset: const Offset(0, 5),
//                       )
//                     ]
//                   : null,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   height: 60,
//                   width: 60,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Color(widget.category['color']),
//                         Color(widget.category['gradient'][1]),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Color(widget.category['color']).withOpacity(0.3),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     widget.category['icon'],
//                     color: Colors.white,
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   widget.category['label'],
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Color(widget.category['color']),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Text(
//                     widget.category['description'],
//                     style: TextStyle(
//                       fontSize: 9,
//                       color: Colors.grey.shade500,
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }