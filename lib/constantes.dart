import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_entreprise_web/data_model/article.dart';
import 'package:micro_entreprise_web/data_model/db_client.dart';
import 'package:micro_entreprise_web/data_model/document.dart';
import 'package:micro_entreprise_web/pages/articles.dart';
import 'package:micro_entreprise_web/pages/clients.dart';
import 'package:micro_entreprise_web/pages/documents.dart';

class LocationContainer extends Location {
  final List<Location> subLocations;
  LocationContainer({
    required super.path,
    required super.name,
    required super.unselectedIcon,
    required super.selectedIcon,
    required this.subLocations,
  }) : super(pageBuilder: (context, state) => null) {
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
  final Widget? Function(BuildContext context, GoRouterState state) pageBuilder;
  final Widget? trailing;

  const Location({
    required this.path,
    required this.name,
    this.disabled = false,
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.pageBuilder,
    this.padding,
    this.trailing,
  });
}

final clients = LocationContainer(
  name: "Clients",
  path: "/clients",
  selectedIcon: Icon(Icons.person, color: Colors.white),
  unselectedIcon: Icon(Icons.person_outlined, color: Colors.white.withValues(alpha: 0.6)),
  subLocations: [
    Location(
      pageBuilder: (context, state) => ClientListPage(),
      name: "Clients",
      path: "/clients/all",
      selectedIcon: Icon(Icons.person, color: Colors.white),
      unselectedIcon: Icon(Icons.person_outlined, color: Colors.white.withValues(alpha: 0.6)),
    ),
    Location(
      pageBuilder: (context, state) => AddClientPage(),
      name: "Nouveau Client",
      path: "/clients/new",
      selectedIcon: Icon(Icons.person_add, color: Colors.white),
      unselectedIcon: Icon(Icons.person_add_outlined, color: Colors.white.withValues(alpha: 0.6)),
    ),
    Location(
      disabled: true,
      pageBuilder: (context, state) => AddClientPage(editedClient: state.extra as DBClient),
      name: "Edit Client",
      path: "/clients/edit",
      selectedIcon: Icon(Icons.person_add, color: Colors.white),
      unselectedIcon: Icon(Icons.person_add_outlined, color: Colors.white.withValues(alpha: 0.6)),
    ),
  ],
);
final documents = LocationContainer(
  name: "Docs.",
  path: "/documents",
  selectedIcon: Icon(Icons.file_open, color: Colors.white),
  unselectedIcon: Icon(Icons.file_open_outlined, color: Colors.white.withValues(alpha: 0.6)),
  subLocations: [
    Location(
      pageBuilder: (context, state) => DocumentListPage(),
      name: "Documents",
      path: "/documents/all",
      selectedIcon: Icon(Icons.file_open, color: Colors.white),
      unselectedIcon: Icon(Icons.file_open_outlined, color: Colors.white.withValues(alpha: 0.6)),
    ),
    Location(
      pageBuilder: (context, state) => AddDocumentPage(),
      name: "Nouveau documents",
      path: "/documents/new",
      selectedIcon: Icon(Icons.upload_file, color: Colors.white),
      unselectedIcon: Icon(Icons.upload_file_outlined, color: Colors.white.withValues(alpha: 0.6)),
    ),
    Location(
      pageBuilder: (context, state) => AddDocumentPage(editedDocument: state.extra as Document),
      disabled: true,
      name: "Edit document",
      path: "/documents/edit",
      selectedIcon: Icon(Icons.upload_file, color: Colors.white),
      unselectedIcon: Icon(Icons.upload_file_outlined, color: Colors.white.withValues(alpha: 0.6)),
    ),
  ],
);
final articles = LocationContainer(
  name: "Articles",
  path: "/articles",
  selectedIcon: Icon(Icons.shopping_cart, color: Colors.white),
  unselectedIcon: Icon(Icons.shopping_cart_outlined, color: Colors.white.withValues(alpha: 0.6)),
  subLocations: [
    Location(
      pageBuilder: (context, state) => ArticleListPage(),
      name: "Articles",
      path: "/articles/all",
      selectedIcon: Icon(Icons.shopping_cart, color: Colors.white),
      unselectedIcon: Icon(Icons.shopping_cart_outlined, color: Colors.white.withValues(alpha: 0.6)),
    ),
    Location(
      pageBuilder: (context, state) => AddArticlePage(),
      name: "Nouvel article",
      path: "/articles/new",
      selectedIcon: Icon(Icons.add_shopping_cart, color: Colors.white),
      unselectedIcon: Icon(Icons.add_shopping_cart_outlined, color: Colors.white.withValues(alpha: 0.6)),
    ),
    Location(
      disabled: true,
      pageBuilder: (context, state) => AddArticlePage(editedArticle: state.extra as Article),
      name: "Edit Article",
      path: "/articles/edit",
      selectedIcon: Icon(Icons.shopping_cart, color: Colors.white),
      unselectedIcon: Icon(Icons.shopping_cart_outlined, color: Colors.white.withValues(alpha: 0.6)),
    ),
  ],
);

final routes = <Location>[clients, articles, documents];

const headerBackGround = Color.fromARGB(255, 46, 63, 82);
const appBarColor = Color.fromARGB(255, 238, 78, 61);
const backGround = Color.fromARGB(255, 243, 247, 248);
const cardBackGround = Color.fromARGB(255, 254, 253, 245);
