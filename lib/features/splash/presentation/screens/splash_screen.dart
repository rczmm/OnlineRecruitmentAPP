import 'package:flutter/material.dart';
import 'package:zhaopingapp/core/navigation/route_names.dart';
import 'package:zhaopingapp/core/services/storage_service.dart';

final storageService = StorageService();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    _controller.forward();

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      String? token = await storageService.getAuthToken(); // Use your service
      final route = (token != null && token.isNotEmpty)
          ? RouteNames.home
          : RouteNames.auth;
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or theme background
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary, // Use theme color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
