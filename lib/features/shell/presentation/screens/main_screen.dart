import 'package:flutter/material.dart';
import 'package:zhaopingapp/features/home/presentation/screens/home_screen.dart';
import 'package:zhaopingapp/features/chat/presentation/screens/chat_screen.dart';
import 'package:zhaopingapp/features/profile/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screenOptions = <Widget>[
    HomeScreen(),
    ChatScreenContent(),
    ProfileScreen(),
  ];

  // (Optional) Titles corresponding to each screen
  static const List<String> _screenTitles = <String>[
    '首页',
    '聊天',
    '我的',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme data

    return Scaffold(
      appBar: AppBar(
        // title: Text(_screenTitles[_selectedIndex]), // Dynamic title
        title: Text(_screenTitles[_selectedIndex],
            style: theme.appBarTheme.titleTextStyle), // Use theme style
        centerTitle: true,
        // backgroundColor: theme.colorScheme.primary, // Use theme color
        // elevation: theme.appBarTheme.elevation ?? 2, // Use theme elevation
        // No need to set foregroundColor if using theme's appBarTheme correctly
      ),
      // Use IndexedStack to preserve state of tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _screenOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Use theme colors
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.unselectedWidgetColor,
        // Or Colors.grey
        // backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ?? Colors.white,
        // elevation: theme.bottomNavigationBarTheme.elevation ?? 10,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        // Keep fixed if you always want labels visible
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            // Consider outlined icons for unselected
            activeIcon: Icon(Icons.home),
            // Filled icon for selected
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '聊天',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
