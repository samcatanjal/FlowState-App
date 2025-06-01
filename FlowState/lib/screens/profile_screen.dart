import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  File? _profileImage;
  bool _useBiometric = false;
  UserProfile? _currentProfile; // Track current profile

  @override
  void initState() {
    super.initState();
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    _currentProfile = profileProvider.userProfile;
    _nameController = TextEditingController(text: _currentProfile!.name);
    
    // Add listener to update UI when profile changes
    profileProvider.addListener(_updateFromProvider);
    // Load biometric preference for toggle
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _useBiometric = prefs.getBool('use_biometric') ?? false;
      });
    });
  }

  @override
  void dispose() {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    profileProvider.removeListener(_updateFromProvider);
    _nameController.dispose();
    super.dispose();
  }

  void _updateFromProvider() {
    final profile = Provider.of<UserProfileProvider>(context, listen: false).userProfile;
    if (_nameController.text != profile.name) {
      setState(() {
        _nameController.text = profile.name;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_biometric', value);
    setState(() {
      _useBiometric = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
            ? 'Biometric authentication enabled. It will be required next time you log in.'
            : 'Biometric authentication disabled. You will use PIN only next time.'
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // Save the image path to the provider
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      profileProvider.updateProfile(profileImagePath: pickedFile.path);
    }
  }

  void _changePin() {
    Navigator.pushNamed(context, '/verify_pin');
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      
      // If a new image was picked, save it
      if (_profileImage != null) {
        profileProvider.updateProfile(
          name: _nameController.text,
          profileImagePath: _profileImage!.path,
        );
      } else {
        profileProvider.updateProfile(name: _nameController.text);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the latest profile data
    final profile = Provider.of<UserProfileProvider>(context).userProfile;
    
    // Update controller if profile changed
    if (profile.name != _currentProfile?.name) {
      _currentProfile = profile;
      _nameController.text = profile.name;
    }
    
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (profile.profileImagePath != null
                          ? FileImage(File(profile.profileImagePath!))
                          : null),
                  child: _profileImage == null && profile.profileImagePath == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tap to change profile picture',
                style: GoogleFonts.poppins(
                  color: theme.hintColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Change PIN',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Use Biometric Authentication'),
                value: _useBiometric,
                onChanged: _toggleBiometric,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
