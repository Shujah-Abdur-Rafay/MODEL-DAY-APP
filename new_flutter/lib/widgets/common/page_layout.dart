import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../responsive_layout.dart';

class PageLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry? padding;
  final bool isScrollable;

  const PageLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = false,
    this.onBackPressed,
    this.padding,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveBreakpoints.isSmallScreen(context);
    
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Header
        _buildPageHeader(context, isSmallScreen),
        
        SizedBox(height: ResponsiveSpacing.medium(context)),
        
        // Page Content
        Expanded(child: child),
      ],
    );

    if (isScrollable) {
      content = SingleChildScrollView(
        padding: padding ?? EdgeInsets.all(ResponsiveSpacing.medium(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(context, isSmallScreen),
            SizedBox(height: ResponsiveSpacing.medium(context)),
            child,
          ],
        ),
      );
    } else {
      content = Padding(
        padding: padding ?? EdgeInsets.all(ResponsiveSpacing.medium(context)),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }

  Widget _buildPageHeader(BuildContext context, bool isSmallScreen) {
    return Row(
      children: [
        if (showBackButton) ...[
          IconButton(
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
          ),
          SizedBox(width: ResponsiveSpacing.small(context)),
        ],
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                title,
                mobileSize: 20,
                tabletSize: 24,
                desktopSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppTheme.spacingXs),
                ResponsiveText(
                  subtitle!,
                  mobileSize: 12,
                  tabletSize: 14,
                  desktopSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ],
            ],
          ),
        ),
        
        if (actions != null) ...[
          SizedBox(width: ResponsiveSpacing.small(context)),
          ...actions!,
        ],
      ],
    );
  }
}

class PageSection extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const PageSection({
    super.key,
    this.title,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            ResponsiveText(
              title!,
              mobileSize: 16,
              tabletSize: 18,
              desktopSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
          Container(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppTheme.backgroundColor.withValues(alpha: 0.8),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
                    ),
                  ),
                  if (loadingText != null) ...[
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      loadingText!,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveBreakpoints.isSmallScreen(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSpacing.large(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 64 : 80,
              color: AppTheme.textMuted,
            ),
            SizedBox(height: ResponsiveSpacing.medium(context)),
            ResponsiveText(
              title,
              mobileSize: 16,
              tabletSize: 18,
              desktopSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: ResponsiveSpacing.small(context)),
              ResponsiveText(
                description!,
                mobileSize: 12,
                tabletSize: 14,
                desktopSize: 16,
                color: AppTheme.textMuted,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: ResponsiveSpacing.large(context)),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
