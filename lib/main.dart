import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './screens/viewer.dart';
import './blocs/tmlu_bloc.dart';
import './blocs/tmlu_files_bloc copy.dart';

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
        primaryColor: Colors.amber[300],
        primaryColorDark: Colors.black,
        backgroundColor: Color(0xDD222222), //transparent
        dividerColor: Colors.amber[100],
        primaryColorLight: Colors.white,
        errorColor: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,

        textTheme: TextTheme(
          //tbd
          headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white,),
          //code input text
          headline2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.amber[100]),
          //search input text
          subtitle1: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.white,),
          //search hint text
          bodyText1: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: Colors.amber[100]),
          overline: TextStyle(fontSize: 12.0, color: Colors.amber),
        ),

      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<TmluBloc>(
            create: (BuildContext context) => TmluBloc("_myRepository"),  //TODO is just a dummy string
          ),
          BlocProvider<TmluFilesBloc>(
            create: (BuildContext context) => TmluFilesBloc(),  //TODO is just a dummy string
          ),
        ],
        child: Viewer(title: 'Viewer')
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

