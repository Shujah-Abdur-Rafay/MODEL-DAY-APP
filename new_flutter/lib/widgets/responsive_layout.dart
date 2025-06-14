import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget child;
  final String currentPage;
  final int selectedIndex;
  final Function(int)? onItemSelected;
  final String? title;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.currentPage,
    required this.selectedIndex,
    this.onItemSelected,
    this.title,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  bool _isSidebarOpen = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 800;
        final isMediumScreen = constraints.maxWidth < 1200;

        return Scaffold(
          key: _scaffoldKey,
          appBar: isSmallScreen
              ? AppBar(
                  backgroundColor: Colors.black,
                  title: Text(
                    widget.title ?? 'Model Day',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                )
              : null,
          drawer: isSmallScreen
              ? Drawer(
                  backgroundColor: Colors.black,
                  child: Sidebar(
                    currentPage: widget.currentPage,
                    onCloseSidebar: () => Navigator.pop(context),
                    selectedIndex: widget.selectedIndex,
                    onItemSelected: (index) {
                      Navigator.pop(context);
                      widget.onItemSelected?.call(index);
                    },
                    isDesktop: false, // Mobile drawer
                  ),
                )
              : null,
          body: Row(
            children: [
              // Sidebar for desktop/tablet
              if (_isSidebarOpen && !isSmallScreen)
                SizedBox(
                  width: isMediumScreen ? 250 : 280,
                  child: Sidebar(
                    currentPage: widget.currentPage,
                    onCloseSidebar: () =>
                        setState(() => _isSidebarOpen = false),
                    selectedIndex: widget.selectedIndex,
                    onItemSelected: widget.onItemSelected ?? (index) {},
                    isDesktop: !isSmallScreen, // Desktop/tablet sidebar
                  ),
                ),

              // Toggle button for desktop when sidebar is closed
              if (!_isSidebarOpen && !isSmallScreen)
                Container(
                  width: 60,
                  color: Colors.black,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => setState(() => _isSidebarOpen = true),
                      ),
                    ],
                  ),
                ),

              // Main Content
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Responsive breakpoints helper
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 800;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }
}

// Responsive grid helper
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = desktopColumns;

        if (ResponsiveBreakpoints.isMobile(context)) {
          columns = mobileColumns;
        } else if (ResponsiveBreakpoints.isTablet(context)) {
          columns = tabletColumns;
        }

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: runSpacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
          children: children,
        );
      },
    );
  }
}

// Responsive text helper
class ResponsiveText extends StatelessWidget {
  final String text;
  final double mobileSize;
  final double tabletSize;
  final double desktopSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileSize = 14,
    this.tabletSize = 16,
    this.desktopSize = 18,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize = desktopSize;

    if (ResponsiveBreakpoints.isMobile(context)) {
      fontSize = mobileSize;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      fontSize = tabletSize;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}

// Responsive spacing helper
class ResponsiveSpacing {
  static double small(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) return 8;
    if (ResponsiveBreakpoints.isTablet(context)) return 12;
    return 16;
  }

  static double medium(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) return 16;
    if (ResponsiveBreakpoints.isTablet(context)) return 20;
    return 24;
  }

  static double large(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) return 24;
    if (ResponsiveBreakpoints.isTablet(context)) return 32;
    return 40;
  }
}
