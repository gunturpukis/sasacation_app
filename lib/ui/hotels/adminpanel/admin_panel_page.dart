import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminCard(
            context,
            icon: Icons.hotel,
            title: 'Manage Hotels',
            description: 'Add, edit, or remove hotels',
            color: AppTheme.primaryColor,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            icon: Icons.place,
            title: 'Manage Destinations',
            description: 'Add, edit, or remove tourist destinations',
            color: Colors.orange,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            icon: Icons.restaurant,
            title: 'Manage Culinary',
            description: 'Add, edit, or remove restaurants',
            color: Colors.green,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            icon: Icons.directions_car,
            title: 'Manage Transport',
            description: 'Add, edit, or remove transport options',
            color: Colors.purple,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            icon: Icons.upload_file,
            title: 'Bulk Upload',
            description: 'Upload multiple items at once',
            color: Colors.teal,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            icon: Icons.analytics,
            title: 'Analytics',
            description: 'View booking statistics and reports',
            color: Colors.indigo,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}