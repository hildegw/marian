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
        primaryColorDark: Colors.black,
        backgroundColor: Color(0xDD222222), //transparent
        dividerColor: Colors.amber,
        primaryColorLight: Colors.white,
        errorColor: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,

        textTheme: TextTheme(
          //Verification code
          headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white,),
          //code input text
          headline2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white),
          //share header
          headline3: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, color: Colors.white,
            height: 1.5 ),
          //search input text
          subtitle1: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.white,),
          //search hint text
          bodyText1: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: Colors.amber),
          overline: TextStyle(fontSize: 12.0, color: Colors.amber),

        ),

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

