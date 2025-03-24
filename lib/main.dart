import 'dart:math';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

// Constants
const String identifier = "za.co.discovery.vitality.crf.pilot";
const String taskName = "periodicTask";
const String appGroupId = "group.homeScreenApp";
const String iosWidgetName = "WidgetExtension";
const String androidWidgetName = "TestGlanceWidgetReceiver";
const String dataKey = "text_from_flutter_app";

// Main entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize work manager
  await _initializeWorkManager();

  runApp(const MyApp());
}

// Initialize work manager for periodic tasks
Future<void> _initializeWorkManager() async {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(identifier, taskName);
}

// Callback dispatcher for background tasks
@pragma('vm:entry-point') // Required if app is obfuscated or using Flutter 3.1+
void callbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    if (task == taskName) {
      final randomNum = Random().nextInt(100);
      await _updateWidgetWithData(randomNum);
      return Future.value(true);
    }
    return Future.value(false);
  });
}

// Update widget with generated random number
Future<void> _updateWidgetWithData(int randomNum) async {
  final data = "Random = $randomNum";
  await HomeWidget.saveWidgetData(dataKey, data);
  await HomeWidget.updateWidget(
    iOSName: iosWidgetName,
    androidName: androidWidgetName,
  );
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// Home page with stateful logic for widget interaction
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId(appGroupId);
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });

    await _updateWidgetWithData(_counter);
  }

  // Request to pin widget if supported
  Future<void> _requestToPinWidget() async {
    await HomeWidget.requestPinWidget(androidName: androidWidgetName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildPinWidgetButton(),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  // FutureBuilder to display widget pinning status
  Widget _buildPinWidgetButton() {
    return FutureBuilder<bool?>(
      future: HomeWidget.isRequestPinWidgetSupported(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData && snapshot.data == true) {
          return TextButton(
            onPressed: _requestToPinWidget,
            child: const Text("Add Widget"),
          );
        }

        return const Text("Not supported");
      },
    );
  }
}
