import 'package:aqs/Colors.dart';
import 'package:aqs/views/FrameOne_view.dart';
import 'package:aqs/views/FrameTwo_view.dart';
import 'package:aqs/views/Home_view.dart';
import 'package:aqs/views/Humidity_view.dart';
import 'package:aqs/views/Temperature_view.dart';
import 'package:aqs/views/Co2_view.dart';
import 'package:aqs/views/Hcho_view.dart';
import 'package:aqs/views/Tvoc_view.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _Material3BottomNavState();
}

class _Material3BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const FrameOnePage(),
    const FrameTwoPage(),
    //StatisticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_navBarItems[_selectedIndex].label ?? 'Home'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(seconds: 1),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _navBarItems,
      ),
    );
  }
}

const _navBarItems = [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded, color: AppColors.actiaGreen),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.tab_rounded),
    selectedIcon: Icon(Icons.tab_rounded, color: AppColors.actiaGreen),
    label: 'Frame One',
  ),
  NavigationDestination(
    icon: Icon(Icons.tab_rounded),
    selectedIcon: Icon(Icons.tab_rounded, color: AppColors.actiaGreen),
    label: 'Frame Two',
  ),
  NavigationDestination(
    icon: Icon(Icons.query_stats_rounded),
    selectedIcon: Icon(
      Icons.query_stats_rounded,
      color: AppColors.actiaGreen,
    ),
    label: 'Statistics',
  ),
];

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg, // Grey background for the home page
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(20.0), // Adjust padding as needed
          child: Column(
            //  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore the latest values',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.actiaGreen,
                ),
              ),
              SizedBox(
                  height:
                      20), // Add spacing between the title and the container
              Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the container
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bg, // Shadow color
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3), // Changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    HumidityView(),
                    SizedBox(
                        height: 10), // Adjust spacing between widgets as needed
                    TemperatureView(),
                    SizedBox(height: 10),
                    Co2View(),
                    SizedBox(height: 10),
                    HCHOView(),
                    SizedBox(height: 10),
                    TVOCView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
