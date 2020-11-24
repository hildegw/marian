
import "package:flutter/material.dart";

import '../utils/responsive.dart';
import '../utils/validations.dart';

class MenuSearch extends StatefulWidget {
  @override
  _MenuSearchState createState() => _MenuSearchState();
}

class _MenuSearchState extends State<MenuSearch> {
  bool addLine = false;
  final searchC = TextEditingController();
  bool showSpinner = false;
  final validate = FormValidations();
  final searchFormKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
  }

    @override
  void dispose() {
    searchC.dispose();   
    super.dispose();
  }

  void searchGithub(String value) {
    print('submit search? ${searchFormKey.currentState.validate()} with $value');
    if (searchFormKey.currentState.validate()) {
      print("searching");
      setState(() { showSpinner = true; });
    };
  }


  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return Container(
      //color: Theme.of(context).dividerColor, 
      //height: 50, 
      width: resp.wp(100),
      child: Stack(

        children: [
          Form(
            key: searchFormKey,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                textAlign: TextAlign.center,
                maxLength: 300,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.none,
                style: Theme.of(context).textTheme.subtitle1,                
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 30, color: Theme.of(context).primaryColor,),
                    onPressed: () => searchGithub(searchC.text), //setState(() => addLine = !addLine ),
                  ),
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
              ),
              controller: searchC,
              validator: (value) { return validate.checkSearch(value);},
              onFieldSubmitted: (value) => searchGithub(value),
            ),
        ),
          ),

        showSpinner 
          ? Positioned(
            top: 20,
            left: resp.wp(48),
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColorLight,)
              ),
          ) 
          : Container(),

        ],
      )
    );

  }
}