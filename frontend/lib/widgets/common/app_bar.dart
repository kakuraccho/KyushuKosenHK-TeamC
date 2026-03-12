import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_colors.dart';
import '../../screens/friends_screen.dart';
import '../../screens/settings_screen.dart';

class FocusAppBar extends StatelessWidget {
  final String title;

  const FocusAppBar({super.key, required this.title});

  void _showHamburgerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.settings_outlined,
                  color: AppColors.onSurface),
              title: const Text('User Settings',
                  style: TextStyle(color: AppColors.onSurface)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline,
                  color: AppColors.onSurface),
              title: const Text('Friends',
                  style: TextStyle(color: AppColors.onSurface)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FriendsScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.bg,
        padding: const EdgeInsets.fromLTRB(14, 5, 14, 0),
        child: Container(
          height: 72,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(36),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 4,
                child: IconButton(
                  icon: const Icon(Icons.menu,
                      color: AppColors.onSurface, size: 24),
                  onPressed: () => _showHamburgerMenu(context),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurface,
                ),
              ),
              Positioned(
                right: 4,
                child: IconButton(
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: AppColors.onSurface,
                    size: 24,
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surfaceContainer,
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: AppColors.onSurface),
                        ),
                        content: const Text(
                          'Are you sure you want to log out?',
                          style:
                              TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await Supabase.instance.client.auth.signOut();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
