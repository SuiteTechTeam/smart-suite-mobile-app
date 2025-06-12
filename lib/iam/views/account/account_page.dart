import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../utils/auth_utils.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map<String, dynamic>? userInfo;
  bool isLoading = true;
  final UserService _userService = UserService(); // baseUrl ya está fija en el servicio

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    setState(() { isLoading = true; });
    final info = await _userService.getUserInfoFromApi();
    setState(() {
      userInfo = info;
      isLoading = false;
    });
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: userInfo?['name'] ?? '');
    final emailController = TextEditingController(text: userInfo?['email'] ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = {
                  ...?userInfo,
                  'name': nameController.text,
                  'email': emailController.text,
                };
                final success = await _userService.updateUserInfo(updated);
                if (success) {
                  Navigator.of(context).pop();
                  _fetchUserInfo();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(labelText: 'Old Password'),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await _userService.changePassword(
                  oldPasswordController.text,
                  newPasswordController.text,
                );
                if (success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed!')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password change failed')));
                }
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUserInfo,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userInfo == null
              ? const Center(child: Text('No user info available'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(userInfo?['name'] ?? 'No name'),
                      subtitle: Text(userInfo?['email'] ?? 'No email'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showEditDialog,
                      child: const Text('Edit Profile'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _showChangePasswordDialog,
                      child: const Text('Change Password'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        AuthUtils.signOut(context);
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
    );
  }
}
