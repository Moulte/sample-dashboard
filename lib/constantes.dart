import 'package:flutter/material.dart';
import 'package:template_dashboard/pages/bar_chart.dart';
import 'package:template_dashboard/pages/home.dart';
import 'package:template_dashboard/pages/line_chart.dart';
import 'package:template_dashboard/pages/pie_chart.dart';
import 'package:template_dashboard/pages/test.dart';

class LocationContainer extends Location {
  final List<Location> subLocations;
  LocationContainer({
    required super.path,
    required super.name,
    required super.unselectedIcon,
    required super.selectedIcon,
    required super.page,
    required this.subLocations,
  }) {
    for (var location in subLocations) {
      assert(location.path.startsWith(path));
    }
  }
}

class Location {
  final String path;
  final String name;
  final bool disabled;
  final Icon unselectedIcon;
  final Icon selectedIcon;
  final EdgeInsets? padding;
  final Widget page;
  final Widget? trailing;

  const Location( {
    required this.path,
    required this.name,
    this.disabled = false,
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.page,
    this.padding,
    this.trailing,
  });
}

final barChart = Location(
  page: MyBarChart(),
  name: "Bar chart",
  path: "/bar-chart",
  selectedIcon: Icon(Icons.stacked_bar_chart, color: Colors.white),
  unselectedIcon: Icon(Icons.stacked_bar_chart_outlined, color: Colors.white.withValues(alpha: 0.6)),
);
final pieChart = Location(
  page: MyPieChart(),
  name: "Pie chart",
  path: "/pie-chart",
  selectedIcon: Icon(Icons.pie_chart, color: Colors.white),
  unselectedIcon: Icon(Icons.pie_chart_outline_outlined, color: Colors.white.withValues(alpha: 0.6)),
);
final lineChart = Location(
  page: MyLineChart(),
  name: "Line chart",
  path: "/line-chart",
  selectedIcon: Icon(Icons.show_chart, color: Colors.white),
  unselectedIcon: Icon(Icons.show_chart_outlined, color: Colors.white.withValues(alpha: 0.6)),
);
final home = Location(
  page: HomePage(),
  name: "Home",
  path: "/",
  selectedIcon: Icon(Icons.home, color: Colors.white),
  unselectedIcon: Icon(Icons.home_outlined, color: Colors.white.withValues(alpha: 0.6)),
);
final test = Location(
  page: TestPage(),
  name: "Test",
  path: "/test",
  selectedIcon: Icon(Icons.build, color: Colors.white),
  unselectedIcon: Icon(Icons.build_outlined, color: Colors.white.withValues(alpha: 0.6)),
);
final stocks = LocationContainer(
  page: TestPage(),
  name: "Stocks",
  path: "/stocks",
  selectedIcon: Icon(Icons.build, color: Colors.white),
  unselectedIcon: Icon(Icons.build_outlined, color: Colors.white.withValues(alpha: 0.6)),
  subLocations: [
    Location(
      page: MyLineChart(),
      name: "SPY",
      path: "/stocks/spy",
      selectedIcon: Icon(Icons.build, color: Colors.white),
      unselectedIcon: Icon(Icons.build_outlined, color: Colors.white.withValues(alpha: 0.6)),
    ),
  ],
);

final routes = <Location>[barChart, pieChart, lineChart, stocks, home];

const headerBackGround = Color.fromARGB(255, 46, 63, 82);
const appBarColor = Color.fromARGB(255, 238, 78, 61);
const backGround = Color.fromARGB(255, 243, 247, 248);
const cardBackGround = Color.fromARGB(255, 254, 253, 245);
