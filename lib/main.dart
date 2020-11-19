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
        dividerColor: Color(0xDD222222),
        primaryColorLight: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,

        textTheme: TextTheme(
          //Verification code
          headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white,),
          //code input text
          headline2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white),
          //share header
          headline3: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, color: Colors.white,
            height: 1.5 ),
          //house overview headline
          subtitle1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.white,
            height:  1.5),
          //login text input, button text, house overview info
          subtitle2: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.white,),
          //icon bar text
          bodyText1: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: Colors.white),
          //login input hint text
          bodyText2: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Color(0xFFB7A3DC)),
          //error text form fields
          overline: TextStyle(fontSize: 12.0, color: Color(0xFFFD6F8D)),

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

