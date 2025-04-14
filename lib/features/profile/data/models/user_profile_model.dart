import 'package:flutter/foundation.dart';

import 'dart:convert';

class UserProfile {
  final String? id;
  final String? userId;
  final String? exJob;
  final String? exSalary;
  final String? exMinSalary;
  final String? exMaxSalary;
  final String? personIntroduction;
  final String? workExperience;
  final String? name;
  final List<String>? specialty;
  final String? city;
  final String? avatarUrl;
  final String? email;

  UserProfile({
    this.id,
    this.userId,
    this.exJob,
    this.exSalary,
    this.exMinSalary,
    this.exMaxSalary,
    this.personIntroduction,
    this.workExperience,
    this.name,
    this.specialty,
    this.city,
    this.avatarUrl,
    this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    json = json['data'];

    List<String> specialtyList = [];
    if (json['specialty'] != null) {
      for (var item in json['specialty']) {
        specialtyList.add(item.toString());
      }
    }
    return UserProfile(
      id: json['id'],
      userId: json['userId'],
      exJob: json['exJob'],
      exSalary: json['exSalary'],
      exMinSalary: json['exMinSalary'],
      exMaxSalary: json['exMaxSalary'],
      personIntroduction: json['personIntroduction'],
      workExperience: json['workExperience'],
      name: json['name'],
      specialty: specialtyList,
      city: json['city'],
      avatarUrl: json['avatarUrl'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exJob': exJob,
      'exSalary': exSalary,
      'exMinSalary': exMinSalary,
      'exMaxSalary': exMaxSalary,
      'personIntroduction': personIntroduction,
      'workExperience': workExperience,
      'name': name,
      'specialty': specialty,
      'city': city,
      'avatarUrl': avatarUrl,
      'email': email,
    };
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    String? exJob,
    String? exSalary,
    String? exMinSalary,
    String? exMaxSalary,
    String? personIntroduction,
    String? workExperience,
    String? name,
    List<String>? specialty,
    String? city,
    String? avatarUrl,
    String? email,
  }) {
    return UserProfile(
      id: id?? this.id,
      userId: userId ?? this.userId,
      exJob: exJob ?? this.exJob,
      exSalary: exSalary ?? this.exSalary,
      exMinSalary: exMinSalary ?? this.exMinSalary,
      exMaxSalary: exMaxSalary ?? this.exMaxSalary,
      personIntroduction: personIntroduction ?? this.personIntroduction,
      workExperience: workExperience ?? this.workExperience,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'UserProfile{id: $id,userId: $userId, name: $name, email: $email, city: $city, specialty: $specialty}';
  }
}