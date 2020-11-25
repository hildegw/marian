
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../models/model_git_search_response.dart';
import '../blocs/tmlu_files_bloc.dart';



class GitSearchApi {
  
  ModelGitSearchResponse searchResp;
  List<ModelGitFile> files;

  getListOfFiles(String user, String searchString, BuildContext context) async {

      final url = searchString != null 
        ? Uri.parse('https://api.github.com/search/code?q=user:$user+extension:tmlu+${searchString.trim()}')
        : Uri.parse('https://api.github.com/search/code?q=user:$user+extension:tmlu');
      print(url);

      try {
        final request = await HttpClient().getUrl(url);
        final HttpClientResponse response = await request.close();
        String reply = await utf8.decoder.bind(response).join();
        searchResp = ModelGitSearchResponse.fromJson(jsonDecode(reply));
        files = searchResp.createFiles(searchResp.items);
        files.forEach((fil) => print(fil));
            //add data to bloc
        final filesBloc = BlocProvider.of<TmluFilesBloc>(context); //files
        filesBloc.add(LoadData(files: files));
  
      } catch (err) {
        print('error searching github for tmlu data in utils: $err');
      }
  }

} //class



