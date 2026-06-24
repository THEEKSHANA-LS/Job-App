// lib/screens/shared/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Profile tab
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  // Skills tab
  final _skillCtrl     = TextEditingController();
  List<String> _skills = [];

  // CV tab
  String? _pickedFilePath;
  String? _pickedFileName;
  bool    _uploadingCv = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    final user      = context.read<AuthProvider>().user;
    _nameCtrl.text  = user?.name  ?? '';
    _phoneCtrl.text = user?.phone ?? '';
    _skills         = List.from(user?.skills ?? []);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  // ─── Save profile ─────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final auth    = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final success = await profile.updateProfile(
      authProvider: auth,
      name:         _nameCtrl.text.trim(),
      phone:        _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    _showSnack(
      success,
      success
          ? (profile.successMessage ?? 'Profile updated')
          : (profile.errorMessage   ?? 'Update failed'),
    );
  }

  // ─── Save skills ──────────────────────────────────────────────────────
  Future<void> _saveSkills() async {
    final auth    = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final success = await profile.updateSkills(
      authProvider: auth,
      skills:       _skills,
    );
    if (!mounted) return;
    _showSnack(
      success,
      success
          ? (profile.successMessage ?? 'Skills updated')
          : (profile.errorMessage   ?? 'Update failed'),
    );
  }

  void _addSkill() {
    final skill = _skillCtrl.text.trim();
    if (skill.isEmpty) return;
    if (_skills.contains(skill)) { _skillCtrl.clear(); return; }
    setState(() { _skills.add(skill); _skillCtrl.clear(); });
  }

  void _removeSkill(String s) => setState(() => _skills.remove(s));

  // ─── Pick & upload CV ─────────────────────────────────────────────────
  Future<void> _pickAndUploadCV() async {
    final result = await FilePicker.platform.pickFiles(
      type:              FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _pickedFilePath = result.files.single.path;
      _pickedFileName = result.files.single.name;
      _uploadingCv    = true;
    });

    final auth    = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final success = await profile.uploadCV(
      authProvider: auth,
      filePath:     _pickedFilePath!,
    );

    setState(() => _uploadingCv = false);
    if (!mounted) return;
    _showSnack(
      success,
      success
          ? (profile.successMessage ?? 'CV uploaded')
          : (profile.errorMessage   ?? 'Upload failed'),
    );
  }

  Future<void> _openCv(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  void _showSnack(bool success, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(msg),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller:           _tabCtrl,
          labelColor:           AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor:       AppColors.primary,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Skills'),
            Tab(text: 'CV'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildProfileTab(profile),
          _buildSkillsTab(profile),
          _buildCvTab(),
        ],
      ),
    );
  }

  // ── Tab 1 ─ Profile ────────────────────────────────────────────────────
  Widget _buildProfileTab(ProfileProvider profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: CircleAvatar(
                radius:          52,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize:   36,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            CustomTextField(
              label:      'Full Name',
              controller: _nameCtrl,
              prefixIcon: Icons.person_outlined,
              validator:  (v) => v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label:        'Phone Number',
              controller:   _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon:   Icons.phone_outlined,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text:      'Save Changes',
              isLoading: profile.isLoading,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 2 ─ Skills ─────────────────────────────────────────────────────
  Widget _buildSkillsTab(ProfileProvider profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Skills', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'Add skills to get AI-powered job recommendations',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:         _skillCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText:   'e.g. Flutter, Python, Marketing',
                    prefixIcon: Icon(Icons.add_rounded),
                  ),
                  onSubmitted: (_) => _addSkill(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addSkill,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (_skills.isEmpty)
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:        AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('No skills added yet', style: TextStyle(color: AppColors.textHint)),
              ),
            )
          else
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _skills.map((s) => Chip(
                label:           Text(s, style: const TextStyle(fontSize: 13, color: AppColors.primary)),
                backgroundColor: AppColors.primaryLight,
                side:            const BorderSide(color: AppColors.primary, width: 0.5),
                deleteIcon:      const Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
                onDeleted:       () => _removeSkill(s),
                shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              )).toList(),
            ),

          const SizedBox(height: 32),
          PrimaryButton(
            text:      'Save Skills',
            isLoading: profile.isLoading,
            onPressed: _skills.isEmpty ? null : _saveSkills,
          ),
        ],
      ),
    );
  }

  // ── Tab 3 ─ CV ─────────────────────────────────────────────────────────
  Widget _buildCvTab() {
    // Read fresh user from auth provider so cvUrl updates after upload
    final cvUrl = context.watch<AuthProvider>().user?.cvUrl;
    final hasCv = cvUrl != null && cvUrl.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your CV / Resume', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Upload a PDF or Word document. Employers will be able to view your CV.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Current CV card
          if (hasCv) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        AppColors.success.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_rounded, color: AppColors.success, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CV Uploaded ✓',
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.success)),
                        SizedBox(height: 2),
                        Text('Tap the icon to view',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:      const Icon(Icons.open_in_new_rounded, color: AppColors.primary),
                    onPressed: () => _openCv(cvUrl!),
                    tooltip:   'View CV',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Picked file preview
          if (_pickedFileName != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:        AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _pickedFileName!,
                      style: const TextStyle(
                        color:      AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize:   13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Upload button
          SizedBox(
            width:  double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _uploadingCv ? null : _pickAndUploadCV,
              icon: _uploadingCv
                  ? const SizedBox(
                      width:  16, height: 16,
                      child:  CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.upload_file_rounded),
              label: Text(_uploadingCv
                  ? 'Uploading...'
                  : hasCv ? 'Replace CV' : 'Upload CV'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side:  const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Supported formats: PDF, DOC, DOCX',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ),
        ],
      ),
    );
  }
}