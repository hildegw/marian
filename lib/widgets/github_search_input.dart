
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/responsive.dart';
import '../utils/validations.dart';
import '../utils/local_storage.dart';
import '../utils/git_search_api.dart';
import '../blocs/tmlu_files_bloc.dart';


class GithubSearchInput extends StatefulWidget {
  @override
  _GithubSearchInputState createState() => _GithubSearchInputState();
}

class _GithubSearchInputState extends State<GithubSearchInput> {
  final localStorage = LocalStorage();
  final validate = FormValidations();
  final searchFormKey = GlobalKey<FormState>();
  final userC = TextEditingController();
  final searchC = TextEditingController();
  bool showSpinner = false;
  bool addLine = false;
  FocusNode addSearchFn;
  String gitUser;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async { await getGitUser();});
    addSearchFn = FocusNode(); //focus for text input fields
    print("gitUser init github search input $gitUser");
    //userC.text = gitUser; 
    super.initState();
  }

  Future<void> getGitUser() async {
    String localGitUser = await localStorage.getGitUser();
    setState(() => userC.text = localGitUser);
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
      localStorage.saveGitUser(userC.text);
    };
  }


  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return BlocBuilder<TmluFilesBloc, TmluFilesState>(builder: (context, state) {   
    
    if (state.status == TmluFilesStatus.hasTmluFiles && (state.files == null || state.files.length < 1)) {
          //TODO add error message if 
    }

      return Container(
        //color: Theme.of(context).dividerColor, 
        //height: 50, 
        width: resp.wp(100),
        child: Stack(

          children: [
            Form(
              key: searchFormKey,
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 12, left: 12, right: 12),
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
                    
                    Container(
                      width: 25,
                      child: FlatButton(
                        padding: EdgeInsets.all(0.0),
                        onPressed: () => searchGithub(context), //setState(() => addLine = !addLine ),
                        child: Icon(Icons.search, size: 25, color: Theme.of(context).dividerColor),
                      ),
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
    });
  }
}