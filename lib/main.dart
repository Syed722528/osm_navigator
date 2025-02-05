import 'package:flutter/material.dart';
import 'package:osm_navigator/provider/map_providers.dart';
import 'package:provider/provider.dart';

import 'pages/map_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedLocationsProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => MarkerProvider()),
        ChangeNotifierProvider(create: (_) => SelectedRouteProvider()),
        ChangeNotifierProvider(create: (_) => FloatingActionButtonMenuProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MapPage(),
      ),
    );
  }
}
