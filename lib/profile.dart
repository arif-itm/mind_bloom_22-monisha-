// profile.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- Form + controllers ---
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Jordan Rivera');
  final _emailCtrl = TextEditingController(text: 'jordan@example.com');

  // Password fields (in Change Password sheet)
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  // Avatar
  File? _avatarFile;
  final _picker = ImagePicker();

  // Toggles (Settings / Privacy)
  bool _pushNotifs = true;
  bool _emailUpdates = false;
  bool _privateAccount = false;
  bool _shareAnalytics = false;
  bool _allowTagging = true;
  bool _twoFAEnabled = false;

  bool _saving = false;

  // --- Validators ---
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your name';
    if (v.trim().length < 2) return 'Name is too short';
    return null;
  }
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  double _passwordStrength(String v) {
    int score = 0;
    if (v.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(v)) score++;
    if (RegExp(r'[a-z]').hasMatch(v)) score++;
    if (RegExp(r'[0-9]').hasMatch(v)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v)) score++;
    return (score / 5).clamp(0, 1).toDouble();
  }

  String? _validateNewPassword(String? v) {
    if ((v ?? '').isEmpty) return 'Enter a new password';
    final s = _passwordStrength(v!);
    if (s < 0.6) {
      return 'Use 8+ chars with upper/lower, number & symbol';
    }
    return null;
  }

  // --- Image pickers (with safe fallbacks) ---
  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final x = await _picker.pickImage(source: source, imageQuality: 85);
      if (x == null) return;
      setState(() => _avatarFile = File(x.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not access camera/photos.')),
      );
    }
  }

  // --- Save profile (mock secure update) ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    // TODO: Re-authenticate user before sensitive updates (email changes, etc)
    // Example hook: await AuthRepository.instance.reauthenticate();

    // Simulate a secure backend call
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated securely ✅')),
    );
  }

  // --- Change Password flow ---
  Future<void> _openChangePassword() async {
    _currentPwCtrl.clear();
    _newPwCtrl.clear();
    _confirmPwCtrl.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 12,
          ),
          child: StatefulBuilder(builder: (context, setBtm) {
            final strength = _passwordStrength(_newPwCtrl.text);
            String strengthLbl;
            if (strength < 0.34) {
              strengthLbl = 'Weak';
            } else if (strength < 0.67) {
              strengthLbl = 'Medium';
            } else {
              strengthLbl = 'Strong';
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42, height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const Text('Change Password',
                    style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 12),
                TextField(
                  controller: _currentPwCtrl,
                  obscureText: !_showCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current password',
                    suffixIcon: IconButton(
                      icon: Icon(
                          _showCurrent ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setBtm(() => _showCurrent = !_showCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newPwCtrl,
                  obscureText: !_showNew,
                  onChanged: (_) => setBtm(() {}),
                  decoration: InputDecoration(
                    labelText: 'New password',
                    helperText:
                    'Use 8+ chars with upper/lowercase, number & symbol',
                    suffixIcon: IconButton(
                      icon: Icon(_showNew
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setBtm(() => _showNew = !_showNew),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: strength, minHeight: 6),
                const SizedBox(height: 4),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Strength: $strengthLbl',
                        style: const TextStyle(fontSize: 12))),
                const SizedBox(height: 10),
                TextField(
                  controller: _confirmPwCtrl,
                  obscureText: !_showConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm new password',
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirm
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setBtm(() => _showConfirm = !_showConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                        ),
                        onPressed: () async {
                          // Validate here
                          if (_currentPwCtrl.text.isEmpty) {
                            _snack('Enter your current password');
                            return;
                          }
                          final v = _validateNewPassword(_newPwCtrl.text);
                          if (v != null) {
                            _snack(v);
                            return;
                          }
                          if (_newPwCtrl.text != _confirmPwCtrl.text) {
                            _snack('Passwords do not match');
                            return;
                          }

                          // TODO: Secure backend call:
                          // await AuthRepository.instance.changePassword(
                          //   current: _currentPwCtrl.text,
                          //   newPassword: _newPwCtrl.text,
                          // );

                          await Future.delayed(const Duration(milliseconds: 900));
                          if (!mounted) return;
                          Navigator.pop(context);
                          _snack('Password updated securely ✅');
                        },
                        child: const Text('Update'),
                      ),
                    ),
                  ],
                )
              ],
            );
          }),
        );
      },
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- Export data (demo JSON) ---
  Future<void> _exportData() async {
    final json = jsonEncode({
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'settings': {
        'pushNotifications': _pushNotifs,
        'emailUpdates': _emailUpdates,
        'twoFAEnabled': _twoFAEnabled,
      },
      'privacy': {
        'privateAccount': _privateAccount,
        'shareAnalytics': _shareAnalytics,
        'allowTagging': _allowTagging,
      },
      'exportedAt': DateTime.now().toIso8601String(),
    });
    // In a real app, save to device/share securely.
    _snack('Your data (JSON) is ready for export');
    debugPrint(json);
  }

  // --- Delete account (confirm) ---
  Future<void> _confirmDelete() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action is permanent. Type DELETE to confirm.',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(hintText: 'Type: DELETE'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, ctrl.text.trim() == 'DELETE'),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      // TODO: Call secure deletion on backend.
      _snack('Account deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0.6,
        foregroundColor: Colors.black87,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _saving ? null : _saveProfile,
              icon: _saving
                  ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: const Text('Save'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal.shade700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // --- Header / Avatar ---
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : const AssetImage('assets/avatar_placeholder.png')
                        as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _showAvatarSheet,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 2))
                              ],
                            ),
                            child: Icon(Icons.edit, color: Colors.teal.shade700, size: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Keep your info private. You control what’s shared.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Editable Profile Form ---
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Display name',
                    child: TextFormField(
                      controller: _nameCtrl,
                      validator: _validateName,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Your name',
                      ),
                    ),
                  ),
                  _LabeledField(
                    label: 'Email',
                    child: TextFormField(
                      controller: _emailCtrl,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'your@email.com',
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _openChangePassword,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Change password'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            const Divider(height: 28),

            // --- Settings ---
            const _SectionTitle('Settings'),
            SwitchListTile(
              title: const Text('Push notifications'),
              value: _pushNotifs,
              onChanged: (v) => setState(() => _pushNotifs = v),
            ),
            SwitchListTile(
              title: const Text('Email updates'),
              value: _emailUpdates,
              onChanged: (v) => setState(() => _emailUpdates = v),
            ),
            ListTile(
              title: const Text('Two-factor authentication'),
              subtitle: Text(_twoFAEnabled ? 'Enabled' : 'Disabled'),
              trailing: Switch(
                value: _twoFAEnabled,
                onChanged: (v) async {
                  // In real app: route to 2FA setup (TOTP/SMS) and verify first.
                  setState(() => _twoFAEnabled = v);
                  _snack(v ? '2FA enabled (demo)' : '2FA disabled');
                },
              ),
            ),

            const Divider(height: 28),

            // --- Privacy ---
            const _SectionTitle('Privacy'),
            SwitchListTile(
              title: const Text('Private account'),
              subtitle: const Text('Only approved followers can see your content'),
              value: _privateAccount,
              onChanged: (v) => setState(() => _privateAccount = v),
            ),
            SwitchListTile(
              title: const Text('Allow tagging'),
              value: _allowTagging,
              onChanged: (v) => setState(() => _allowTagging = v),
            ),
            SwitchListTile(
              title: const Text('Share anonymous analytics'),
              subtitle: const Text('Help improve the app (no personal data)'),
              value: _shareAnalytics,
              onChanged: (v) => setState(() => _shareAnalytics = v),
            ),

            const Divider(height: 28),

            // --- Data & Security ---
            const _SectionTitle('Data & Security'),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Export my data'),
              subtitle: const Text('Get a copy of your profile settings'),
              onTap: _exportData,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out of all devices'),
              onTap: () {
                // TODO: Invalidate all refresh tokens server-side.
                _snack('Logged out on all devices (demo)');
              },
            ),

            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
                title: Text('Delete account', style: TextStyle(color: Colors.red.shade700)),
                onTap: _confirmDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.gallery);
              },
            ),
            if (_avatarFile != null)
              ListTile(
                leading: const Icon(Icons.remove_circle_outline),
                title: const Text('Remove photo'),
                onTap: () {
                  setState(() => _avatarFile = null);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }
}

// --- UI helpers ---
class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormFieldTheme(child: child),
        ],
      ),
    );
  }
}

class TextFormFieldTheme extends StatelessWidget {
  final Widget child;
  const TextFormFieldTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF6F7F9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }
}
