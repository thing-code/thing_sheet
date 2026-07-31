import 'package:flutter/material.dart';
import 'package:thing_sheet/thing_sheet.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () {
                  ThingExpressiveSheet.show(
                    context,
                    showIndicator: false,
                    builder: (context) {
                      return Column(
                        mainAxisSize: .min,
                        children: [
                          const Text(
                            'Judul Bottom Sheet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // ConstrainedBox(
                          //   constraints: BoxConstraints(
                          //     maxHeight: MediaQuery.heightOf(context) * .76,
                          //   ),
                          //   child: ListView(
                          //     children: List.generate(
                          //       20,
                          //       (index) => ListTile(title: Text('Item $index')),
                          //     ),
                          //   ),
                          // ),
                          Container(
                            height: 100,
                            width: 100,
                            alignment: .center,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Tutup'),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text("Show Bottomsheet"),
              ),
            ),
          );
        },
      ),
    );
  }
}
