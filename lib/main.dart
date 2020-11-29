import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './screens/viewer.dart';
import './blocs/tmlu_bloc.dart';
import 'blocs/tmlu_files_bloc.dart';

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
        backgroundColor: Color(0xEE222222), //transparent
        dividerColor: Colors.amber[100],
        primaryColorLight: Colors.white,
        errorColor: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        //splash
        //highlightColor: Color(0xAA222222),
        splashColor: Color(0xAA555555),

        textTheme: TextTheme(
          //search input text
          subtitle1: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white,),
          //search input hint text
          bodyText1: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: Colors.amber[100]),
          //list of search results
          bodyText2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.white,),
          //button
          button: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: Colors.black,),
          //search input error text
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

