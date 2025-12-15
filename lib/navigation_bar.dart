import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_entreprise_web/constantes.dart';
import 'package:micro_entreprise_web/main.dart';

class AppNavigationRail extends ConsumerStatefulWidget {
  final GoRouterState currentState;
  final List<Location> routes;
  const AppNavigationRail({required this.routes, required this.currentState, super.key});

  @override
  ConsumerState<AppNavigationRail> createState() => _AppNavigationRailState();
}

class _AppNavigationRailState extends ConsumerState<AppNavigationRail> {
  String currentPagePath = "/home";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routePath = widget.currentState.uri.toString();
    setState(() {
      final location = getLocationByPath(routePath);
      currentPagePath = location?.path ?? "/home";
    });
  }

  List<Widget> createNavigationItems() {
    final navItems = <Widget>[];

    for (var location in widget.routes) {
      if (location is LocationContainer) {
        final isParentSelected = "/${currentPagePath.split("/")[1]}" == location.path;

        navItems.add(
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              collapsedIconColor: Colors.white.withValues(alpha: 0.7),
              iconColor: Colors.white,
              childrenPadding: const EdgeInsets.only(left: 16),
              leading: _AnimatedRailIcon(
                icon: isParentSelected ? location.selectedIcon : location.unselectedIcon,
                isSelected: isParentSelected,
              ),
              title: Text(
                location.name,
                style: TextStyle(
                  color: isParentSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                  fontWeight: isParentSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              children: location.subLocations.where((location) => !location.disabled).map((sublocation) {
                final isSelected = currentPagePath == sublocation.path;
                return _AnimatedRailTile(
                  icon: isSelected ? sublocation.selectedIcon : sublocation.unselectedIcon,
                  label: sublocation.name,
                  isSelected: isSelected,
                  trailing: sublocation.trailing,
                  onTap: () {
                    setState(() {
                      currentPagePath = sublocation.path;
                    });
                    context.go(sublocation.path);
                    Scaffold.of(context).closeDrawer();
                  },
                );
              }).toList(),
            ),
          ),
        );
      } else {
        if(location.disabled) continue;
        final isSelected = currentPagePath == location.path;
        navItems.add(
          _AnimatedRailTile(
            icon: isSelected ? location.selectedIcon : location.unselectedIcon,
            label: location.name,
            isSelected: isSelected,
            trailing: location.trailing,
            onTap: () {
              setState(() {
                currentPagePath = location.path;
              });
              context.go(location.path);
              Scaffold.of(context).closeDrawer();
            },
          ),
        );
      }
    }

    return navItems;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.teal.shade700,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(1, 0))],
      ),
      child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: createNavigationItems()),
    );
  }
}

class _AnimatedRailTile extends StatefulWidget {
  final Widget icon;
  final Widget? trailing;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedRailTile({required this.icon, required this.label, required this.isSelected, required this.onTap, this.trailing});

  @override
  State<_AnimatedRailTile> createState() => _AnimatedRailTileState();
}

class _AnimatedRailTileState extends State<_AnimatedRailTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (v) => setState(() => hovered = v),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: 46,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Colors.white.withValues(alpha: 0.15)
              : hovered
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            // Pastille de sélection animée (comme le rail Flutter)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 4,
              height: 28,
              margin: const EdgeInsets.only(left: 4, right: 8),
              decoration: BoxDecoration(
                color: widget.isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: IconTheme(
                data: IconThemeData(size: widget.isSelected ? 22 : 20, color: Colors.white),
                child: widget.icon,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: widget.isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(widget.label),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.trailing
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedRailIcon extends StatelessWidget {
  final Widget icon;
  final bool isSelected;

  const _AnimatedRailIcon({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent),
      child: IconTheme(
        data: IconThemeData(size: isSelected ? 22 : 20, color: Colors.white),
        child: icon,
      ),
    );
  }
}
