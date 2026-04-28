import 'package:flutter/material.dart';
import '../../data/repository/auth_repository.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final user = authRepository.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text(
          'Trang chủ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Nút logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Đăng xuất',
            onPressed: () => _showLogoutConfirm(context, authRepository),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.indigo.shade200,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 54,
                  color: Colors.indigo.shade400,
                ),
              ),
              const SizedBox(height: 24),

              // Welcome text
              const Text(
                'Xin chào!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text('Nguyễn Bình Minh - 6451071047'),
              const SizedBox(height: 10),

              // Email hiển thị
              _UserEmailCard(email: user?.email ?? 'Không rõ'),
              const SizedBox(height: 32),

              // Thông tin đăng nhập
              _InfoCard(
                icon: Icons.verified_user_outlined,
                label: 'Trạng thái',
                value: 'Đã xác thực',
                valueColor: Colors.green,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.calendar_today_outlined,
                label: 'Tạo lúc',
                value: _formatDate(user?.metadata.creationTime),
                valueColor: Colors.indigo,
              ),
              const SizedBox(height: 40),

              // Logout button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutConfirm(context, authRepository),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, AuthRepository authRepository) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authRepository.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không rõ';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Widget hiển thị email người dùng
class _UserEmailCard extends StatelessWidget {
  final String email;
  const _UserEmailCard({required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.email_outlined, color: Colors.indigo.shade400, size: 20),
          const SizedBox(width: 8),
          Text(
            email,
            style: TextStyle(
              fontSize: 15,
              color: Colors.indigo.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget hiển thị thông tin dạng card
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[500], size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}