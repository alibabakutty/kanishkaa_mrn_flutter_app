import 'package:flutter/material.dart';
import 'package:mobile_app/features/provider/auth_provider.dart';
import 'package:mobile_app/features/provider/mrn_provider.dart';
import 'package:mobile_app/features/provider/site_provider.dart';
import 'package:mobile_app/features/provider/stock_provider.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider to pull user details dynamically
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.username ?? 'No Name';
    final email = authProvider.email ?? 'Not available';
    final mobileNumber = authProvider.mobileNumber ?? 'Not available';

    return Scaffold(
      backgroundColor:  Colors.white, // Matching your dark theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C685B),
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. Profile Header / Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: CircleAvatar(
                      radius: 60,
                      child: const Icon(
                        Icons.person_outline,
                        size: 60,
                        color: Color(0xFF005447),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. User Info Display
            Text(
              username,
              style: const TextStyle(
                color: Color(0xFF005447),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Site Engineer',
              style: TextStyle(
                color: Color(0xFF349083),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // 3. Information Cards / Options

            const SizedBox(height: 12),
            _buildProfileTile(
              icon: Icons.mail,
              title: 'Email',
              trailingText: email,
            ),
            const SizedBox(height: 12),
            _buildProfileTile(
              icon: Icons.call,
              title: 'Mobile Number',
              trailingText: mobileNumber,

            ),
            
            const SizedBox(height: 40),

            // 4. Log Out Button tied to AuthProvider state
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C685B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'LOG OUT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _showLogoutConfirmation(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom helper widget for profile settings rows
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon,  color: const Color(0xFF0C685B)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color:  Color(0xFF0C685B),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  color: Color(0xFF005447),
                  fontSize: 15,
                ),
              )
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }

  // Prompt safe log out modal
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Log Out', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to end your current session?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                // 1. Close the dialog window first
                Navigator.pop(dialogContext);

                // 2. Clear token/auth storage state synchronously
                context.read<MrnProvider>().clear();
                context.read<SiteProvider>().clear();
                context.read<StockProvider>().clear();
                await context.read<AuthProvider>().logout();

                if (!context.mounted) return;

                // 3. WIPE the navigation stack entirely and send them to Login
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(), // Ensure LoginScreen is imported
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, -0.04), // Subtle downward slide out
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                      (route) => false, // This condition 'false' drops ALL existing screens from history
                );
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}