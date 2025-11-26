import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String currentPage = 'Accueil';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            decoration: const BoxDecoration(color: Colors.teal),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Accueil'),
                  selected: currentPage == 'Accueil',
                  onTap: () => setState(() => currentPage = 'Accueil'),
                ),
                ExpansionTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Paramètres'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Profil'),
                      selected: currentPage == 'Profil',
                      onTap: () => setState(() => currentPage = 'Profil'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Sécurité'),
                      selected: currentPage == 'Sécurité',
                      onTap: () => setState(() => currentPage = 'Sécurité'),
                    ),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('À propos'),
                  selected: currentPage == 'À propos',
                  onTap: () => setState(() => currentPage = 'À propos'),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Center(
              child: Text(
                'Page : $currentPage',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}