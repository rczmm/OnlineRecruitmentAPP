import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final String avatarUrl;
  final bool isFile;
  final String? fileName;
  final String? fileUrl;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isMe,
    required this.avatarUrl,
    this.isFile = false,
    this.fileName,
    this.fileUrl,
  });

  factory ChatMessageModel.fromJson(
      Map<String, dynamic> json,
      String currentUserId,
      String peerName,
      String myAvatar,
      String peerAvatar) {
    final senderId = json['senderId']?.toString() ?? 'unknown';
    final isMe = senderId == currentUserId;
    DateTime timestamp;
    if (json['timestamp'] != null) {
      try {
        // Use DateFormat to parse the specific string format
        timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").parse(
            json['timestamp'].toString(),
            true); // Use true for UTC if applicable, false otherwise
        debugPrint(
            "Parsed timestamp ${json['timestamp']} successfully: $timestamp"); // Add log
      } catch (e) {
        debugPrint(
            "!!! ERROR parsing timestamp '${json['timestamp']}': $e"); // Log error
        timestamp = DateTime.now(); // Fallback
      }
    } else {
      timestamp = DateTime.now(); // Fallback if timestamp is missing
    }

    return ChatMessageModel(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      senderId: senderId,
      senderName: isMe ? '我' : peerName,
      text: json['text']?.toString() ?? '',
      timestamp: timestamp,
      isMe: isMe,
      avatarUrl: isMe ? myAvatar : peerAvatar,
      isFile: json['type'] == 'file',
      fileName: json['fileName']?.toString(),
      fileUrl: json['fileUrl']?.toString(),
    );
  }
}

class UserFile {
  final String? id;
  final String fileName;
  final String fileUrl;

  UserFile({this.id, required this.fileName, required this.fileUrl});

  factory UserFile.fromJson(Map<String, dynamic> json) {
    return UserFile(
      id: json['id']?.toString(),
      fileName: json['fileName'].toString(),
      fileUrl: json['fileUrl'].toString(),
    );
  }
}

class CommonPhrase {
  final String? id;
  final String text;
  final String? userId;

  CommonPhrase({this.id, required this.text, this.userId});

  factory CommonPhrase.fromJson(Map<String, dynamic> json) {
    return CommonPhrase(
      id: json['id']?.toString(),
      text: json['text'] ?? '',
      userId: json['userId']?.toString(),
    );
  }
}
