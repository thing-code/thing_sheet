import 'package:material_ui/material_ui.dart';
import 'package:thing_sheet/thing_sheet.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          spacing: 12,
          children: [
            FilledButton(
              onPressed: () {
                ThingSheet.showPopUp(
                  context: context,
                  builder: (context) => _PopUpBody(),
                );
              },
              child: Text("Show Pop Up"),
            ),
            OutlinedButton(
              onPressed: () {
                ThingSheet.showSheet(
                  context: context,
                  builder: (context, scrollController) =>
                      _SheetBody(controller: scrollController),
                );
              },
              child: Text("Show Sheet"),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopUpBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      spacing: 16,
      children: [
        const Text(
          'Pop Up Example',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          height: 100,
          width: 100,
          alignment: .center,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }
}

class _SheetBody extends StatelessWidget {
  final ScrollController controller;

  const new({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverAppBar.large(
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Sheet Example'),
            centerTitle: true,
          ),
        ),
        SliverPadding(
          padding: .all(16),
          sliver: SliverList.separated(
            itemCount: 50,
            itemBuilder: (context, index) =>
                ListTile(title: Text('Data $index')),
            separatorBuilder: (context, index) => SizedBox(height: 8),
          ),
        ),
        SliverPadding(
          padding: .symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              label: Text('Close'),
              icon: Icon(Icons.logout),
            ),
          ),
        ),
      ],
    );
  }
}
