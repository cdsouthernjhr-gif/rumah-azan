import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Shown instead of the app when start-up fails, so the problem is visible
/// and reportable instead of a frozen splash screen.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error, this.stack});
  final Object error;
  final StackTrace? stack;

  String get details => 'Rumah Azan startup error\n$error\n\n${stack ?? ''}';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF0E7A5A)),
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Rumah Azan')),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            const Text(
              'Aplikasi tidak dapat dimulakan.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sila ambil tangkapan skrin halaman ini atau tekan "Salin butiran" '
              'dan hantarkan kepada pembangun.\n\n'
              'The app could not start. Please send a screenshot or the copied details.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Salin butiran / Copy details'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: details));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disalin')));
                }
              },
            ),
            const SizedBox(height: 16),
            SelectableText(details, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}
