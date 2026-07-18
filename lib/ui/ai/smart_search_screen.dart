// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sasacation/core/apptheme.dart';
// import 'package:sasacation/ui/hotels/detail_hotels_page.dart';
// import 'package:sasacation/viewmodel/ai/ai_bloc.dart';

// class SmartSearchScreen extends StatefulWidget {
//   const SmartSearchScreen({super.key});

//   @override
//   State<SmartSearchScreen> createState() => _SmartSearchScreenState();
// }

// class _SmartSearchScreenState extends State<SmartSearchScreen> {
//   final _controller = TextEditingController();

//   final List<String> _examples = [
//     'Hotel mewah di tepi pantai dengan kolam renang',
//     'Tempat makan seafood yang enak di Senggigi',
//     'Destinasi petualangan untuk backpacker',
//     'Resort murah di bawah 200 dollar per malam',
//     'Tempat wisata budaya Sasak',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Smart Search'), centerTitle: true),
//       body: Column(
//         children: [
//           // Search bar
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     onSubmitted: _doSearch,
//                     decoration: InputDecoration(
//                       hintText: 'Cari dengan bahasa natural...',
//                       prefixIcon: const Icon(
//                         Icons.auto_awesome,
//                         color: AppTheme.primaryColor,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       suffixIcon: _controller.text.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.clear),
//                               onPressed: () {
//                                 _controller.clear();
//                                 setState(() {});
//                               },
//                             )
//                           : null,
//                     ),
//                     onChanged: (_) => setState(() {}),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () => _doSearch(_controller.text),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.all(16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Icon(Icons.search),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             child: BlocBuilder<AiBloc, AiState>(
//               builder: (context, state) {
//                 if (state is AiInitial) return _buildExamples();
//                 if (state is AiSearchLoading) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const CircularProgressIndicator(),
//                         const SizedBox(height: 16),
//                         Text(
//                           '🤖 Menganalisis "${state.query}"...',
//                           style: TextStyle(color: Colors.grey.shade600),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//                 if (state is AiSearchLoaded) return _buildResults(state);
//                 if (state is AiError) {
//                   return Center(
//                     child: Text(
//                       state.message,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   );
//                 }
//                 return _buildExamples();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExamples() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.lightbulb_outline,
//                 color: AppTheme.primaryColor,
//                 size: 18,
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Contoh pencarian cerdas:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ..._examples.map(
//             (e) => InkWell(
//               onTap: () {
//                 _controller.text = e;
//                 _doSearch(e);
//               },
//               borderRadius: BorderRadius.circular(10),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Row(
//                   children: [
//                     Icon(Icons.search, size: 16, color: Colors.grey.shade400),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         e,
//                         style: TextStyle(color: Colors.grey.shade700),
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_forward_ios,
//                       size: 12,
//                       color: Colors.grey.shade400,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResults(AiSearchLoaded state) {
//     final result = state.result;
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // AI interpretation
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppTheme.primaryColor.withOpacity(0.06),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.auto_awesome,
//                   size: 16,
//                   color: AppTheme.primaryColor,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     result.interpretation,
//                     style: TextStyle(
//                       color: AppTheme.primaryColor,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Result count
//           Text(
//             '${result.totalResults} tempat ditemukan',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           const SizedBox(height: 12),

//           // Results grid
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 0.75,
//             ),
//             itemCount: result.results.length,
//             itemBuilder: (context, index) {
//               final item = result.results[index];
//               return _ResultCard(item: item);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _doSearch(String query) {
//     if (query.trim().isEmpty) return;
//     FocusScope.of(context).unfocus();
//     context.read<AiBloc>().add(AiSmartSearchRequested(query: query.trim()));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }

// class _ResultCard extends StatelessWidget {
//   final Map<String, dynamic> item;
//   const _ResultCard({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     final isHotel = item['type'] == 'hotel';
//     return GestureDetector(
//       onTap: () {
//         if (isHotel) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => HotelDetailScreen(hotelId: item['id']),
//             ),
//           );
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(16),
//               ),
//               child: Image.network(
//                 item['image'] ?? '',
//                 height: 120,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => Container(
//                   height: 120,
//                   color: Colors.grey.shade200,
//                   child: const Icon(Icons.image, color: Colors.grey),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item['name'] ?? '',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13,
//                     ),
//                   ),
//                   Text(
//                     item['location'] ?? '',
//                     style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       const Icon(Icons.star, color: Colors.amber, size: 12),
//                       Text(
//                         ' $item.rating',
//                         style: const TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Spacer(),
//                       if (item['price'] != null && item['price'] > 0)
//                         Text(
//                           '\$$item.price',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: AppTheme.primaryColor,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/ui/hotels/detail_hotels_page.dart';
import 'package:sasacation/utils/json_helper.dart';
import 'package:sasacation/viewmodel/ai/ai_bloc.dart';

class SmartSearchScreen extends StatefulWidget {
  const SmartSearchScreen({super.key});

  @override
  State<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends State<SmartSearchScreen> {
  final _controller = TextEditingController();

  final List<String> _examples = [
    'Hotel mewah di tepi pantai dengan kolam renang',
    'Tempat makan seafood yang enak di Senggigi',
    'Destinasi petualangan untuk backpacker',
    'Resort murah di bawah 200 dollar per malam',
    'Tempat wisata budaya Sasak',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _doSearch,
                    decoration: InputDecoration(
                      hintText: 'Cari dengan bahasa natural...',
                      prefixIcon: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _doSearch(_controller.text),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<AiBloc, AiState>(
              builder: (context, state) {
                if (state is AiInitial) return _buildExamples();
                if (state is AiSearchLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text('🤖 Menganalisis "${state.query}"...',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }
                if (state is AiSearchLoaded) return _buildResults(state);
                if (state is AiError) {
                  return Center(
                      child: Text(state.message, style: const TextStyle(color: Colors.red)));
                }
                return _buildExamples();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamples() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.primaryColor, size: 18),
              const SizedBox(width: 8),
              const Text('Contoh pencarian cerdas:', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ..._examples.map((e) => InkWell(
                onTap: () {
                  _controller.text = e;
                  _doSearch(e);
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 16, color: Colors.grey.shade400),
                      const SizedBox(width: 12),
                      Expanded(child: Text(e, style: TextStyle(color: Colors.grey.shade700))),
                      Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildResults(AiSearchLoaded state) {
    final result = state.result;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(result.interpretation,
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('${result.totalResults} tempat ditemukan',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: result.results.length,
            itemBuilder: (context, index) => _ResultCard(item: result.results[index]),
          ),
        ],
      ),
    );
  }

  void _doSearch(String query) {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<AiBloc>().add(AiSmartSearchRequested(query: query.trim()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isHotel = item['type'] == 'hotel';

    // FIX: hasil search AI adalah Map<String, dynamic> mentah dari backend,
    // BUKAN lewat model class dengan fromJson(). Field price/rating di sini
    // bisa berupa String ("25") kalau berasal dari kolom NUMERIC PostgreSQL,
    // jadi WAJIB di-parse dengan parseDouble() sebelum dibandingkan atau
    // dipakai sebagai num — perbandingan langsung seperti `item['price'] > 0`
    // akan crash kalau nilainya masih String.
    final price = parseDouble(item['price']);
    final rating = parseDouble(item['rating']);

    return GestureDetector(
      onTap: () {
        if (isHotel) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => HotelDetailScreen(hotelId: item['id'].toString())));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                item['image'] ?? '',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 120,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(item['location'] ?? '',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      // FIX: gunakan variabel `rating` (sudah double) untuk format,
                      // bukan item['rating'] langsung yang mungkin masih String.
                      Text(' ${rating.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      // FIX: bandingkan `price` (double hasil parseDouble),
                      // bukan `item['price']` mentah — ini akar penyebab crash.
                      if (price > 0)
                        Text('\$${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
