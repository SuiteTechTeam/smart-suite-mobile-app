import 'package:flutter/material.dart';
import '../views/home_page.dart';
import '../../hotels/views/hotel_management_screen.dart';
import '../../reservations/views/reservation_management_screen.dart';
import '../views/account/account_page.dart';

class HomeTabNavigation extends StatefulWidget {
  const HomeTabNavigation({super.key});

  @override
  State<HomeTabNavigation> createState() => _HomeTabNavigationState();
}

class _HomeTabNavigationState extends State<HomeTabNavigation>
    with TickerProviderStateMixin {  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  static const List<TabInfo> _tabs = <TabInfo>[
    TabInfo(
      title: 'Inicio',
      icon: Icons.home_rounded,
      activeIcon: Icons.home,
      gradient: LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
      ),
    ),
    TabInfo(
      title: 'Hoteles',
      icon: Icons.hotel_rounded,
      activeIcon: Icons.hotel,
      gradient: LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
      ),
    ),
    TabInfo(
      title: 'Reservas',
      icon: Icons.book_online_rounded,
      activeIcon: Icons.book_online,
      gradient: LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
      ),
    ),
    TabInfo(
      title: 'Cuenta',
      icon: Icons.person_rounded,
      activeIcon: Icons.person,
      gradient: LinearGradient(
        colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate bottom navigation bar height with margin
    // We use 16 for top and bottom margins, plus around 56-60 for the nav bar itself
    // Add extra padding (19px + safety margin) to prevent overflow
    final bottomNavHeight = MediaQuery.of(context).padding.bottom + 16 + 16 + 60 + 20;
    
    return Scaffold(
      extendBody: true,
      appBar: _buildModernAppBar(context, isDark),
      body: SafeArea(
        bottom: false, // We'll handle bottom padding manually
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomNavHeight),
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _buildScrollablePages(),
          ),
        ),
      ),
      bottomNavigationBar: _buildModernBottomNavBar(context, isDark),
      floatingActionButton: _selectedIndex == 2 ? _buildFAB(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context, bool isDark) {
    return AppBar(
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          _tabs[_selectedIndex].title,
          key: ValueKey(_selectedIndex),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: isDark ? null : Colors.white,
      foregroundColor: isDark ? null : Colors.black87,
      elevation: 0,
      scrolledUnderElevation: 1,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: _tabs[_selectedIndex].gradient,
        ),
      ),
      actions: [
        IconButton(
          icon: AnimatedRotation(
            turns: _selectedIndex * 0.1,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.notifications_rounded),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.white),
                    SizedBox(width: 8),
                    Text('No hay notificaciones nuevas'),
                  ],
                ),
                backgroundColor: Colors.grey.shade800,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }  Widget _buildModernBottomNavBar(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          selectedItemColor: _tabs[_selectedIndex].gradient.colors.first,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          elevation: 0,
          items: _tabs.map((tab) {
            final index = _tabs.indexOf(tab);
            final isSelected = index == _selectedIndex;
            
            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(isSelected ? 8 : 4),
                decoration: BoxDecoration(
                  gradient: isSelected ? tab.gradient : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: tab.gradient.colors.first.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isSelected ? tab.activeIcon : tab.icon,
                  color: isSelected ? Colors.white : null,
                  size: isSelected ? 24 : 20,
                ),
              ),
              label: tab.title,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget? _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/add-reservation');
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Nueva Reserva'),
      backgroundColor: const Color(0xFFFF9800),
      foregroundColor: Colors.white,
      elevation: 4,
      extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }  // Build scrollable versions of each page
  List<Widget> _buildScrollablePages() {
    return const [
      HomePage(),
      HotelManagementScreen(),
      ReservationManagementScreen(),
      AccountPage(),
    ];
  }
}

class TabInfo {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final LinearGradient gradient;

  const TabInfo({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.gradient,
  });
}
