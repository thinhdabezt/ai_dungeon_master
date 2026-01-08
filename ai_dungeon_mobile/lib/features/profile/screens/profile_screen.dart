import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Adventurer Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.username[0].toUpperCase(),
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : null,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showAvatarPicker(context, authProvider),
                    tooltip: 'Change Avatar',
                  ),
                ),
              ],
            ).animate().scale(),

            const SizedBox(height: 16),
            Text(
              user.username,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
            ),
            
            const SizedBox(height: 32),
            
            // Stats Board
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildStatRow(context, Icons.bolt, 'Streak', '${user.currentStreak} Days', Colors.orange),
                  const Divider(height: 32, indent: 16, endIndent: 16),
                  _buildStatRow(context, Icons.auto_awesome, 'Experience', '${user.learningXP} XP', Colors.purple),
                  const SizedBox(height: 16),
                  
                  // XP Progress Bar (Simple Level logic: Level = XP / 1000 + 1)
                  Builder(
                    builder: (context) {
                      final level = (user.learningXP / 1000).floor() + 1;
                      final progress = (user.learningXP % 1000) / 1000;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Level $level', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('${(progress * 100).toInt()}% to Level ${level + 1}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                            minHeight: 8,
                            color: Colors.purpleAccent,
                          ),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 40),

            // Actions
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout?'),
                    content: const Text('Are you sure you want to end your session?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );

                if (confirm == true) {
                  await authProvider.logout();
                  if (context.mounted) context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  void _showAvatarPicker(BuildContext context, AuthProvider authProvider) {
    final List<String> seeds = [
      'Felix', 'Aneka', 'Zack', 'Midnight', 'Shadow', 'Luna', 'Grim', 'Sky', 'Ember'
    ];
    final TextEditingController customController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose your Guise'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: seeds.length,
                  itemBuilder: (context, index) {
                    final seed = seeds[index];
                    final url = 'https://api.dicebear.com/7.x/adventurer/png?seed=$seed';
                    return GestureDetector(
                      onTap: () {
                         Navigator.pop(ctx);
                         authProvider.updateAvatar(url);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade800,
                        backgroundImage: NetworkImage(url),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text('Or Enter Custom URL:', style: TextStyle(fontSize: 12, color: Colors.white54)),
                const SizedBox(height: 8),
                TextField(
                  controller: customController,
                  decoration: InputDecoration(
                    hintText: 'https://example.com/image.png',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        if (customController.text.isNotEmpty) {
                          Navigator.pop(ctx);
                          authProvider.updateAvatar(customController.text);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }
}
