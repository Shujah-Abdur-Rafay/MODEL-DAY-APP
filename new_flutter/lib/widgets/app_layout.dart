import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/sidebar.dart';
import 'package:new_flutter/widgets/swipe_navigation.dart';
import 'package:new_flutter/theme/app_theme.dart';

class AppLayout extends StatefulWidget {
  final String currentPage;
  final Widget child;
  final String? title;
  final List<Widget>? actions;

  const AppLayout({
    super.key,
    required this.currentPage,
    required this.child,
    this.title,
    this.actions,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool isSidebarOpen = false;
  bool _userHasCollapsedSidebar = false; // Track if user manually collapsed
  int selectedIndex = 0;
  bool _initialSidebarSet = false;

  void _handleItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    // Additional navigation logic can be added here
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800; // Further lowered to 800 for better browser support
    final isTablet = screenWidth > 600 && screenWidth <= 800;
    final isMobile = screenWidth <= 600;



    // Set initial sidebar state for desktop (only once and if user hasn't manually collapsed it)
    if (!isSidebarOpen && isDesktop && !_userHasCollapsedSidebar && !_initialSidebarSet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            isSidebarOpen = true;
            _initialSidebarSet = true;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      // Show app bar on mobile and tablet
      appBar: (isMobile || isTablet)
          ? AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => setState(() => isSidebarOpen = true),
              ),
              title: Text(
                widget.title ?? 'ModelLog',
                style: const TextStyle(
                  color: AppTheme.goldColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: widget.actions,
              elevation: 0,
            )
          : null,
      body: Stack(
        children: [
          // Main content
          Row(
            children: [
              // Desktop sidebar (always visible)
              if (isDesktop && isSidebarOpen)
                SizedBox(
                  width: isTablet ? 250 : 280,
                  child: Sidebar(
                    currentPage: widget.currentPage,
                    onCloseSidebar: () => setState(() {
                      isSidebarOpen = false;
                      _userHasCollapsedSidebar = true; // Mark as manually collapsed
                    }),
                    selectedIndex: selectedIndex,
                    onItemSelected: _handleItemSelected,
                    isDesktop: true, // Add this flag
                  ),
                ),

              // Toggle button for desktop when sidebar is closed
              if (isDesktop && !isSidebarOpen)
                Container(
                  width: 60,
                  color: const Color(0xFF1A1A1A), // Use dark gray instead of pure black
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => setState(() {
                          isSidebarOpen = true;
                          _userHasCollapsedSidebar = false; // Reset the flag when manually opened
                        }),
                      ),
                    ],
                  ),
                ),
              // Main content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: isDesktop
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          )
                        : null,
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Desktop header with title and actions (hide for welcome page)
                        if (isDesktop && widget.currentPage != '/welcome')
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.title ?? 'ModelLog',
                                  style: const TextStyle(
                                    color: AppTheme.goldColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.actions != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: widget.actions!,
                                  ),
                              ],
                            ),
                          ),
                        // Main content with swipe navigation
                        Expanded(
                          child: SwipeNavigation(
                            currentRoute: widget.currentPage,
                            child: Padding(
                              padding: EdgeInsets.all(
                                isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0),
                              ),
                              child: widget.child,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Mobile/Tablet sidebar (overlay)
          if ((isMobile || isTablet) && isSidebarOpen)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Row(
                  children: [
                    SizedBox(
                      width: isMobile ? 280 : 320,
                      child: Sidebar(
                        currentPage: widget.currentPage,
                        onCloseSidebar: () =>
                            setState(() => isSidebarOpen = false),
                        selectedIndex: selectedIndex,
                        onItemSelected: (index) {
                          _handleItemSelected(index);
                          setState(() => isSidebarOpen = false);
                        },
                        isDesktop: false, // Mobile/tablet sidebar
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isSidebarOpen = false),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
