import 'package:kakikenyang/utils/colors.dart';
import 'package:kakikenyang/view/account/account_screen.dart';
import 'package:kakikenyang/view/home/home_screen.dart';
import 'package:kakikenyang/view/map/map_screen.dart';
import 'package:kakikenyang/view/navigationBar/nav_controller.dart';
import 'package:kakikenyang/view/search/browse_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class BottomNavigationBarKK extends StatefulWidget {
  const BottomNavigationBarKK({super.key});

  @override
  State<BottomNavigationBarKK> createState() => _BottomNavigationBarKKState();
}

class _BottomNavigationBarKKState extends State<BottomNavigationBarKK> {
  final PersistentTabController _controller = globalNavController;
  final NavBarStyle _navBarStyle = NavBarStyle.style1;

  List<Widget> _buildScreens() {
    return [
      HomeScreen(onFeatureTap: (index) => _controller.jumpToTab(index)),
      const SearchScreen(),
      const MapScreen(),
      const AccountScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(Color active, Color inactive) {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.house),
        title: ("Home"),
        activeColorPrimary: active,
        inactiveColorPrimary: inactive,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.search),
        title: ("Cari"),
        activeColorPrimary: active,
        inactiveColorPrimary: inactive,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.map),
        title: ("Map"),
        activeColorPrimary: active,
        inactiveColorPrimary: inactive,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.person),
        title: ("Akun"),
        activeColorPrimary: active,
        inactiveColorPrimary: inactive,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final navBg = Theme.of(context).colorScheme.surface; // untuk NavBar
    final iconActive = buttonColor;
    final iconInactive = grey;

    return PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(iconActive, iconInactive),
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardAppears: true,
        popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
        padding: const EdgeInsets.only(top: 8),
        backgroundColor: navBg,
        isVisible: true,
        animationSettings: const NavBarAnimationSettings(
            navBarItemAnimation: ItemAnimationSettings( // Navigation Bar's items animation properties.
                duration: Duration(milliseconds: 400),
                curve: Curves.ease,
            ),
            screenTransitionAnimation: ScreenTransitionAnimationSettings( // Screen transition animation on change of selected tab.
                animateTabTransition: true,
                duration: Duration(milliseconds: 200),
                screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
            ),
        ),
        confineToSafeArea: true,
        navBarHeight: kBottomNavigationBarHeight,
        navBarStyle: _navBarStyle, // Choose the nav bar style with this property
      );
  }
}
