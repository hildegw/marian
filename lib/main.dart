import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './screens/viewer.dart';
import './blocs/tmlu_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marian',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<TmluBloc>(
            create: (BuildContext context) => TmluBloc("_myRepository"),  //TODO is just a dummy string
          ),
        ],
        child: Viewer(title: 'Viewer')
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

