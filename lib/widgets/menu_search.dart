
import "package:flutter/material.dart";

import '../utils/responsive.dart';
import '../utils/validations.dart';
import '../utils/git_search_api.dart';


class MenuSearch extends StatefulWidget {
  @override
  _MenuSearchState createState() => _MenuSearchState();
}

class _MenuSearchState extends State<MenuSearch> {
  bool addLine = false;
  final userC = TextEditingController();
  final searchC = TextEditingController();
  bool showSpinner = false;
  final validate = FormValidations();
  final searchFormKey = GlobalKey<FormState>();
  FocusNode addSearchFn;

  @override
  void initState() {
    addSearchFn = FocusNode(); //focus for text input fields
    userC.text = "arosl";
    super.initState();
  }

  @override
  void dispose() {
    userC.dispose();
    searchC.dispose(); 
    addSearchFn.dispose();  
    super.dispose();
  }

  void searchGithub(BuildContext context) async {
    print('submit search? ${searchFormKey.currentState.validate()} with ${userC.text} and ${searchC.text}');
    if (searchFormKey.currentState.validate()) {
      await GitSearchApi().getListOfFiles(userC.text, searchC.text, context);
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
              padding: const EdgeInsets.only(top: 12.0, bottom: 12, left: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: resp.wp(40),
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      maxLength: 50,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.none,
                      style: Theme.of(context).textTheme.subtitle1,                
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(color: Theme.of(context).dividerColor)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(color: Theme.of(context).dividerColor)
                        ),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(color: Theme.of(context).errorColor)
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(color: Theme.of(context).errorColor)
                        ),
                        filled: true,
                        fillColor: Theme.of(context).primaryColorDark,
                        labelText: "git user",
                        labelStyle: Theme.of(context).textTheme.bodyText1,
                        errorStyle: Theme.of(context).textTheme.overline,
                        counterText: "", //counting characters
                      ),
                      controller: userC,
                      validator: (value) { return validate.checkGitUser(value);},
                      onFieldSubmitted: (value) => addSearchFn.requestFocus(),
                      
                    ),
                  ),

                  SizedBox(
                    width: resp.wp(40),
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      maxLength: 50,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.none,
                      style: Theme.of(context).textTheme.subtitle1,                
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(color: Theme.of(context).dividerColor)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(color: Theme.of(context).dividerColor)
                        ),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(color: Theme.of(context).errorColor)
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(color: Theme.of(context).errorColor)
                        ),
                        filled: true,
                        fillColor: Theme.of(context).primaryColorDark,
                        labelText: "optional search term",
                        labelStyle: Theme.of(context).textTheme.bodyText1,
                        errorStyle: Theme.of(context).textTheme.overline,
                        counterText: "", //counting characters
                      ),
                      focusNode: addSearchFn,
                      controller: searchC,
                      validator: (value) { return null ;}, //optional search string
                      onFieldSubmitted: (value) => searchGithub(context),
                    ),
                  ),
                  
                  IconButton(
                    icon: Icon(Icons.search, size: 25, color: Theme.of(context).dividerColor,),
                    onPressed: () => searchGithub(context), //setState(() => addLine = !addLine ),
                  ),

                ],
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