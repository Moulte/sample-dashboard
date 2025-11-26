import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:template_dashboard/constantes.dart';
import 'package:template_dashboard/dialog_notif.dart';
import 'package:template_dashboard/model.dart';
import 'package:template_dashboard/navigation_bar.dart';
import 'package:template_dashboard/state.dart';

void main() async {
  final pref = await SharedPreferences.getInstance();
  runApp(ProviderScope(overrides: [prefsProvider.overrideWith((ref) => pref), secureStorageProvider.overrideWith((ref) => kIsWeb?null: FlutterSecureStorage())], child: const DccsApp()));
}

Location? getLocationByPath(String path) {
  for (var location in routes) {
    if (location is LocationContainer) {
      for (var subLocation in location.subLocations) {
        if (subLocation.path == path) return subLocation;
      }
    } else {
      if (location.path == path) return location;
    }
  }
  return null;
}

List<RouteBase> _createRoutes() {
  final createdRoutes = <RouteBase>[];
  for (var location in routes) {
    if (location is LocationContainer) {
      createdRoutes.addAll(
        location.subLocations
            .map(
              (subLocation) => GoRoute(
                pageBuilder: (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  name: subLocation.path,
                  child: subLocation.page,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                ),
                path: subLocation.path,
              ),
            )
            .toList(),
      );
    } else {
      createdRoutes.add(
        GoRoute(
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            name: location.path,
            child: location.page,
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          ),
          path: location.path,
        ),
      );
    }
  }
  return createdRoutes;
}

final routerProvider = Provider((ref) {
  String lastLocation = ref.read(prefsProvider).getString("lastLocation") ?? "/";
  final GoRouter router = GoRouter(
    initialLocation: lastLocation,
    routes: [
      ShellRoute(
        routes: _createRoutes(),
        pageBuilder: (context, state, child) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: ShellPage(currentState: state, child: child),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) {
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: ShellPage(
          currentState: state,
          child: Center(
            child: Text('Page not found : ${state.uri.toString()}', style: const TextStyle(fontSize: 18, color: Colors.red)),
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      );
    },
  );
  return router;
});

class DccsApp extends ConsumerWidget {
  const DccsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Dccs App",
      theme: ThemeData(
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 13),
          titleMedium: TextStyle(fontSize: 12),
          titleSmall: TextStyle(fontSize: 10),
          headlineLarge: TextStyle(fontSize: 13),
          headlineMedium: TextStyle(fontSize: 12),
          headlineSmall: TextStyle(fontSize: 10),
          bodyLarge: TextStyle(fontSize: 13),
          bodyMedium: TextStyle(fontSize: 12),
          bodySmall: TextStyle(fontSize: 10),
          labelLarge: TextStyle(fontSize: 12),
          labelMedium: TextStyle(fontSize: 12),
          labelSmall: TextStyle(fontSize: 10),
        ),
      ),
      routerConfig: router,
    );
  }
}

class ShellPage extends ConsumerWidget {
  const ShellPage({super.key, required this.child, required this.currentState});
  final Widget child;
  final GoRouterState currentState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routePath = currentState.uri.toString();
    final location = getLocationByPath(routePath);
    ref.listen<String?>(notifProvider, (prev, next) {
      if (next != null) {
        displayNotif(context, next);
        ref.read(notifProvider.notifier).displayNotif(null);
      }
    });
    ref.listen<DialogNotif?>(dialogProvider, (prev, next) async {
      if (next != null) {
        await displayDialog(context, next);
      }
    });
    ref.listen<TextFieldNotif?>(textFieldProvider, (prev, next) async {
      if (next != null) {
        await displayTextField(context, next);
      }
    });
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MediaQuery.of(context).size.width > 480 ? AppNavigationRail(currentState: currentState, routes: routes) : Container(),
              Expanded(
                child: Scaffold(
                  appBar: AppBar(
                    leadingWidth: MediaQuery.of(context).size.width < 480 ? 40 : 0,
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (MediaQuery.of(context).size.width < 480)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              child: const Icon(Icons.menu, color: Colors.white),
                              onTap: () async {
                                Scaffold.of(context).openDrawer();
                              },
                            ),
                          ),
                      ],
                    ),
                    centerTitle: true,
                    title: SelectableText((location?.name) ?? "Page not found", style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.teal.shade700,
                    flexibleSpace: FlexibleSpaceBar(),
                  ),
                  body: Center(child: child),
                ),
              ),
            ],
          );
        },
      ),
      drawer: MediaQuery.of(context).size.width < 480 ? Drawer(width: 220, child: AppNavigationRail(currentState: currentState, routes: routes)) : null,
    );
  }
}
