import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaper_app/data/data.dart';
import 'package:wallpaper_app/model/wallpaper_model.dart';
import 'package:wallpaper_app/widgets/widget.dart';


class Categorie extends StatefulWidget {

  final String CategoryName;
  Categorie({this.CategoryName});

  @override
  _CategorieState createState() => _CategorieState();
}

class _CategorieState extends State<Categorie> {

  List<WallpaperModel> wallpapers=new  List();


  getSearchWallpapers(String query) async {

    var response = await http.get(Uri.parse("https://api.pexels.com/v1/search?query=$query&per_page=30&page=1"),
        headers: {
          "Authorization":apiKey});

    // print(response.body.toString());

    Map<String,dynamic> jsonData = jsonDecode(response.body);

    jsonData["photos"].forEach((element){
      //print(element);
      WallpaperModel wallpaperModel=new WallpaperModel();
      wallpaperModel= WallpaperModel.fromMap(element);
      wallpapers.add(wallpaperModel);
    });

    setState(() {

    });

  }

  @override
  void initState() {
   getSearchWallpapers(widget.CategoryName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: brandName(),
        elevation: 0.0,
      ),

      body: SingleChildScrollView(
        child: Container(
          child:Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Color(0xfff5f8fd),
                    borderRadius: BorderRadius.circular(30)
                ),
                padding:EdgeInsets.symmetric(horizontal: 24) ,
                margin:EdgeInsets.symmetric(horizontal: 24) ,

              ),

              SizedBox(height: 16,),

              wallpapersList(wallpapers:wallpapers,context:context),

            ],) ,),
      ),
    );
  }
}
