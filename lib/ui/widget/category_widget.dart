import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'icon': Icons.beach_access,
      'label': 'Beaches',
      'color': 0xFF00A896,
      'description': 'Beautiful beaches in Lombok',
      'route': '/explore?category=beaches',
      'gradient': [0xFF00A896, 0xFF02C39A],
    },
    {
      'icon': Icons.hotel,
      'label': 'Hotels',
      'color': 0xFF008080,
      'description': 'Luxury resorts & villas',
      'route': '/explore?category=hotels',
      'gradient': [0xFF008080, 0xFF00A896],
    },
    {
      'icon': Icons.restaurant,
      'label': 'Culinary',
      'color': 0xFFFF6B35,
      'description': 'Local delicacies',
      'route': '/explore?category=culinary',
      'gradient': [0xFFFF6B35, 0xFFFF8C42],
    },
    {
      'icon': Icons.directions_boat,
      'label': 'Islands',
      'color': 0xFF4299E1,
      'description': 'Gili Islands paradise',
      'route': '/explore?category=islands',
      'gradient': [0xFF4299E1, 0xFF667EEA],
    },
    {
      'icon': Icons.hiking,
      'label': 'Adventure',
      'color': 0xFF48BB78,
      'description': 'Mount Rinjani trek',
      'route': '/explore?category=adventure',
      'gradient': [0xFF48BB78, 0xFF68D391],
    },
    {
      'icon': Icons.museum,
      'label': 'Culture',
      'color': 0xFF9F7AEA,
      'description': 'Sasak tradition',
      'route': '/explore?category=culture',
      'gradient': [0xFF9F7AEA, 0xFFB794F4],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildAnimatedCategoryCard(context, category);
      },
    );
  }

  Widget _buildAnimatedCategoryCard(BuildContext context, Map<String, dynamic> category) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (categories.indexOf(category) * 40)),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          _showCategoryDetail(context, category);
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(category['color']).withOpacity(0.1),
                Color(category['color']).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(category['color']).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon Container
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(category['color']),
                      Color(category['gradient'][1]),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(category['color']).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  category['icon'],
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              // Category Label
              Text(
                category['label'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(category['color']),
                ),
              ),
              const SizedBox(height: 4),
              // Description (small)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  category['description'],
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDetail(BuildContext context, Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Category Icon
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(category['color']),
                    Color(category['gradient'][1]),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color(category['color']).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                category['icon'],
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),  
            // Title
            Text(
              category['label'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(category['color']),
              ),
            ),
            const SizedBox(height: 8), 
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _getFullDescription(category['label']),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            // Featured Items Preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildFeaturedItems(context, category['label']),
            ),
            
            const SizedBox(height: 10),
            
            // Explore Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to explore with category filter
                    context.push('/explore', extra: {'category': category['label'].toLowerCase()});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(category['color']),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Explore ${category['label']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            // const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedItems(BuildContext context, String category) {
    final List<Map<String, dynamic>> items = _getFeaturedItems(category);
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    item['image'],
                    height: 70,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 70,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey.shade400, size: 22),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(height: 70, width: double.infinity, color: Colors.grey.shade100);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item['location'],
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getFullDescription(String category) {
    switch (category) {
      case 'Beaches':
        return 'Discover pristine white sand beaches, crystal clear waters, and stunning coastal views. Perfect for swimming, surfing, and relaxation.';
      case 'Hotels':
        return 'Experience luxury accommodation with world-class amenities. From beachfront resorts to cozy villas with stunning ocean views.';
      case 'Culinary':
        return 'Savor authentic Sasak cuisine and fresh seafood. Taste traditional dishes like Ayam Taliwang and Plecing Kangkung.';
      case 'Islands':
        return 'Explore the famous Gili Islands - Gili Trawangan, Gili Meno, and Gili Air. Snorkeling, diving, and island hopping adventures.';
      case 'Adventure':
        return 'Challenge yourself with Mount Rinjani trekking, waterfall chasing, and exciting outdoor activities in Lombok\'s nature.';
      case 'Culture':
        return 'Immerse in Sasak traditional culture, visit ancient villages, and witness unique ceremonies and handicrafts.';
      default:
        return 'Explore amazing places and experiences in Lombok';
    }
  }

  List<Map<String, dynamic>> _getFeaturedItems(String category) {
    final Map<String, List<Map<String, dynamic>>> featuredData = {
      'Beaches': [
        {'name': 'Kuta Beach', 'location': 'South Lombok', 'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e'},
        {'name': 'Senggigi Beach', 'location': 'West Lombok', 'image': 'https://images.unsplash.com/photo-1512641406448-6574e7773702'},
        {'name': 'Pink Beach', 'location': 'East Lombok', 'image': 'https://images.unsplash.com/photo-1506929562872-bb421503ef21'},
      ],
      'Hotels': [
        {'name': 'Qunci Villas', 'location': 'Mangsit', 'image': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d'},
        {'name': 'Oberoi Resort', 'location': 'Tanjung', 'image': 'https://images.unsplash.com/photo-1540541338287-41700207dee6'},
        {'name': 'Katamaran Resort', 'location': 'Senggigi', 'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4'},
      ],
      'Culinary': [
        {'name': 'Taliwang Khas', 'location': 'Mataram', 'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4'},
        {'name': 'Sate Rembiga', 'location': 'Mataram', 'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836'},
        {'name': 'Warung Sulawesi', 'location': 'Senggigi', 'image': 'https://images.unsplash.com/photo-1551218808-94e220e084d2'},
      ],
      'Islands': [
        {'name': 'Gili Trawangan', 'location': 'Gili Islands', 'image': 'https://images.unsplash.com/photo-1512641406448-6574e7773702'},
        {'name': 'Gili Meno', 'location': 'Gili Islands', 'image': 'https://images.unsplash.com/photo-1537956965359-7573183d1f57'},
        {'name': 'Gili Air', 'location': 'Gili Islands', 'image': 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62'},
      ],
      'Adventure': [
        {'name': 'Mount Rinjani', 'location': 'North Lombok', 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4'},
        {'name': 'Sendang Gile', 'location': 'Senaru', 'image': 'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9'},
        {'name': 'Tiu Kelep', 'location': 'Senaru', 'image': 'https://images.unsplash.com/photo-1533240332313-3db3e3e7e3e3'},
      ],
      'Culture': [
        {'name': 'Sade Village', 'location': 'Central Lombok', 'image': 'https://images.unsplash.com/photo-1528181304801-259f2e4b7a6f'},
        {'name': 'Narmada Park', 'location': 'West Lombok', 'image': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9'},
        {'name': 'Lingsar Temple', 'location': 'West Lombok', 'image': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf'},
      ],
    };
    
    return featuredData[category] ?? featuredData['Beaches']!;
  }
}