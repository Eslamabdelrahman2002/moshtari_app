import 'package:flutter/material.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/features/create_ad/ui/screens/create_ad_screen.dart'; // لو بتستخدمه بالرُزم
import 'package:mushtary/features/home/ui/screens/home_screen.dart';
import 'package:mushtary/features/home/ui/widgets/bottom_nav_bar_item.dart';
import 'package:mushtary/features/messages/ui/screens/messages_screen.dart';
import 'package:mushtary/features/real_estate/ui/screens/real_estate_screen.dart';
import 'package:mushtary/features/services/ui/screens/service_screen.dart';
import 'package:mushtary/features/services/ui/widgets/service_bottom_sheet_content.dart';
import 'package:mushtary/features/services/ui/screens/dinat_application_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../../create_ad/ui/screens/publish_entry_screen.dart';

class MushtaryBottomNavigationBar extends StatefulWidget {
  const MushtaryBottomNavigationBar({super.key});
  @override
  State<MushtaryBottomNavigationBar> createState() => _MushtaryBottomNavigationBarState();
}

class _MushtaryBottomNavigationBarState extends State<MushtaryBottomNavigationBar>
    with AutomaticKeepAliveClientMixin {
  int _bottomNavIndex = 0; // ابدأ بالخيار الأول
  int serviceIndex = 0;

  List<Widget> getScreens(int serviceIndex) {
    return [
      const HomeScreen(),
      const RealEstateScreen(),
      const PublishEntryScreen(), // جديد: أضفته هنا عشان يكون جزء من الـ tabs
      const MessagesScreen(),
      ServiceScreen(index: serviceIndex),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: getScreens(serviceIndex)[_bottomNavIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              spreadRadius: 1,
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SalomonBottomBar(
          currentIndex: _bottomNavIndex,
          items: [
            BottomNavBarItem.salamonBottomBarItem(
              _bottomNavIndex == 0 ? 'home_active' : 'home',
              'الرئيسية',
            ),
            BottomNavBarItem.salamonBottomBarItem(
              _bottomNavIndex == 1 ? 'building_active' : 'building',
              'العقارات',
            ),
            BottomNavBarItem.salamonBottomBarItem(
              _bottomNavIndex == 2 ? 'add_active' : 'add',
              'اضافة',
            ),
            BottomNavBarItem.salamonBottomBarItem(
              _bottomNavIndex == 3 ? 'message_active' : 'message',
              'الرسائل',
            ),
            BottomNavBarItem.salamonBottomBarItem(
              _bottomNavIndex == 4 ? 'service_active' : 'service',
              'الخدمات',
            ),
          ],
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 300),
          backgroundColor: Colors.white,
          selectedColorOpacity: 1,
          onTap: (index) async {
            if (index == 4) {
              final result = await showModalBottomSheet<ServiceSheetResult>(
                context: context,
                backgroundColor: Colors.white,
                showDragHandle: true,
                isScrollControlled: true,
                isDismissible: true,
                builder: (context) => const ServiceBottomSheetContent(),
              );

              if (result == null) return;

              if (result.openDinatApplication) {
                if (!mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DinatApplicationScreen()),
                );
              } else if (result.serviceIndex != null) {
                setState(() {
                  serviceIndex = result.serviceIndex!;
                  _bottomNavIndex = 4;
                });
              }
            } else {
              setState(() => _bottomNavIndex = index); // تحديث الـ index لكل tabs, بما فيها index==2 (PublishEntryScreen)
            }
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => false;
}