import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/data/repo/hotel_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/viewmodel/wishlist/wishlist_cubit.dart';

/// View: WishlistScreen
/// Menampilkan hotel yang disimpan user (WishlistCubit, disimpan lokal).
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _repo = HotelRepository();
  List<HotelModel> _hotels = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    final ids = context.read<WishlistCubit>().state;
    setState(() => _loading = true);
    final results = await Future.wait(ids.map((id) => _repo.getHotelById(id)));
    setState(() {
      _hotels = results.whereType<HotelModel>().toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WishlistCubit, Set<String>>(
      listener: (context, _) => _loadHotels(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Wishlist'), centerTitle: true),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _hotels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 72, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('Belum ada hotel tersimpan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('Ketuk ikon hati pada hotel untuk menyimpannya',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _hotels.length,
                    itemBuilder: (context, index) {
                      final hotel = _hotels[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(hotel.image,
                                width: 64, height: 64, fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    Container(width: 64, height: 64, color: Colors.grey.shade200)),
                          ),
                          title: Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${hotel.location} · \$${hotel.price.toStringAsFixed(0)}/malam'),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.redAccent),
                            onPressed: () => context.read<WishlistCubit>().toggle(hotel.id),
                          ),
                          onTap: () => context
                              .push(AppRouter.hotelDetail.replaceFirst(':id', hotel.id)),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
