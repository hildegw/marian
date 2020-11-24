
import "package:flutter/material.dart";

import '../utils/responsive.dart';


class MenuSearch extends StatefulWidget {
  @override
  _MenuSearchState createState() => _MenuSearchState();
}

class _MenuSearchState extends State<MenuSearch> {
  bool addLine = false;
  final searchC = TextEditingController();
  bool showSpinner = false;
  bool showCodeError = false;


  @override
  void initState() {
    super.initState();
  }

    @override
  void dispose() {
    searchC.dispose();   
    super.dispose();
  }

//if (_firstNameC.text.length > 0) userData.firstName = _firstNameC.text;  



  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return Container(
      //color: Theme.of(context).dividerColor, 
      //height: 50, 
      width: resp.wp(100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: resp.wp(80),
            //height: 50,
            child: TextFormField(
              textAlign: TextAlign.center,
              maxLength: 300,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              style: Theme.of(context).textTheme.subtitle1,                
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    borderSide: BorderSide(color: Theme.of(context).backgroundColor)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    borderSide: BorderSide(color: Theme.of(context).backgroundColor)
                ),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    borderSide: BorderSide(color: Theme.of(context).errorColor)
                ),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    borderSide: BorderSide(color: Theme.of(context).errorColor)
                ),
                filled: true,
                fillColor: Theme.of(context).primaryColorDark,
                hintText: "Search Github",
                hintStyle: Theme.of(context).textTheme.bodyText1,
                errorStyle: Theme.of(context).textTheme.overline,
                //counterText: '', //counting characters
            ),
            controller: searchC,
            //validator: (value) { return _validate.checkFirstName(value);},
            //onFieldSubmitted: (value) => _lastNameFn.requestFocus(),
        ),
          ),


        IconButton(
          icon: Icon(Icons.add_circle_outline, size: 35, color: Theme.of(context).primaryColor,),
          onPressed: () => setState(() => addLine = !addLine ),
        ),

        showSpinner 
          ? Padding(
            padding: EdgeInsets.only(
              top: resp.hp(40),
              left: resp.wp(45),
            ),
            child: CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColorLight,)) 
          : Container(),

        ],
      )
    );

  }
}