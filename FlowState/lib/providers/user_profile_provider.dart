import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String? profileImagePath;

  UserProfile({required this.name, this.profileImagePath});

  Map<String, dynamic> toJson() => {
        'name': name,
        'profileImagePath': profileImagePath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'],
        profileImagePath: json['profileImagePath'],
      );
}

class UserProfileProvider with ChangeNotifier {
  UserProfile _userProfile = UserProfile(name: 'Guest');

  UserProfile get userProfile => _userProfile;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'Guest';
    final imagePath = prefs.getString('profile_image_path');
    _userProfile = UserProfile(name: name, profileImagePath: imagePath);
    notifyListeners();
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'userProfile',
      json.encode(_userProfile.toJson()),
    );
  }

  Future<void> updateProfile({String? name, String? profileImagePath}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) {
      await prefs.setString('user_name', name);
      _userProfile = UserProfile(name: name, profileImagePath: profileImagePath ?? _userProfile.profileImagePath);
    }
    if (profileImagePath != null) {
      await prefs.setString('profile_image_path', profileImagePath);
      _userProfile = UserProfile(name: _userProfile.name, profileImagePath: profileImagePath);
    }
    saveProfile();
    notifyListeners();
  }
}
