import 'package:flutter/material.dart';

import 'app/theme/portal_theme.dart';

void main() {
  runApp(const PortalApp());
}

class PortalApp extends StatelessWidget {
  const PortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal App',
      debugShowCheckedModeBanner: false,
      theme: PortalTheme.light,
      home: const PortalThemePreviewPage(),
    );
  }
}

class PortalThemePreviewPage extends StatelessWidget {
  const PortalThemePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portal App')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Design system preview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This temporary screen verifies the application theme.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: const Text('Primary action')),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Secondary action'),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () {}, child: const Text('Text action')),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Employee name',
              hintText: 'Enter employee name',
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'This card inherits its appearance from PortalTheme.',
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: null, child: const Text('Disabled action')),
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
