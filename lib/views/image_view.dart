
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';



class ImageView extends StatefulWidget {

  final String imgUrl;
  ImageView({@required this.imgUrl});

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {

  var filePath;
  var imageId;
  var path=null; //use for get saved image local path

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: Stack(
            children: [
              Hero(
                tag: widget.imgUrl,
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(widget.imgUrl,fit: BoxFit.cover,)),
              ),

              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                       GestureDetector(
                         onTap: ()  async {
                             if(Platform.isIOS) //IOS can Only download the image
                               {
                                 _downloadImage();
                                 _showSnacBarToOpenImage();
                               }
                             else
                               {

                                 try{

                                   showDialog(context: context,
                                       builder: (context)=>_selectWallpaperTypeDialog() );

                                 }
                                 catch(ex){
                                   Fluttertoast.showToast(
                                       msg: ex.message,
                                       toastLength: Toast.LENGTH_SHORT,
                                       gravity: ToastGravity.CENTER,
                                       timeInSecForIosWeb: 1,
                                       backgroundColor: Colors.red,
                                       textColor: Colors.white,
                                       fontSize: 16.0
                                   );
                                 }
                               }
                         },
                         child: Stack(children: [
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xff1c1B1B).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            width: MediaQuery.of(context).size.width/2,

                          ),
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width/2,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white54,width: 1),
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                    colors: [
                                      Color(0x36FFFFFF),
                                      Color(0x0FFFFFFF)
                                    ]
                                )
                            ),
                            child:Column(children: [
                              Text("Set Wallpaper",style: TextStyle(
                                  fontSize: 16,color: Colors.white70
                              ),),
                              Text("Image will be saved in gallery",style: TextStyle(
                                  fontSize: 10,color: Colors.white70
                              ),)
                            ],) ,
                          ),
                      ],),
                       )
                    ,
                    SizedBox(height: 16,),
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                      child: Text("Cancel",style: TextStyle(color: Colors.white),)),
                    SizedBox(height: 50,)
                ],),
              ),

              //DOWNLOAD AND FAVORITE BUTTONS=================

              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: Container(
                  //color: Colors.black26,
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.topRight,
                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      IconButton(icon: Icon(Icons.download_sharp,color: Colors.white,), onPressed: () async {
                       await _downloadImage();
                       _showSnacBarToOpenImage();
                      }),

                      //This is BtnS for add to favorite AND SHARE.===========EDIT THE ON PRESSED ==========================================
                      IconButton(icon: Icon(Icons.favorite,color: Colors.white), onPressed: (){}),
                      IconButton(icon: Icon(Icons.share,color: Colors.white), onPressed: (){}),


                      //===========================================END OF TOP RIGHT BUTTONS===============================================
                    ]
                )
                ),
              ),

              //==============================================

            ],
          ),
    );
  }



  _askPermission() async {
    if (Platform.isIOS) {
      /*Map<PermissionGroup, PermissionStatus> permissions =
          */await PermissionHandler()
          .requestPermissions([PermissionGroup.photos]);
    } else {
      /* PermissionStatus permission = */await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
    }
  }

  _selectWallpaperTypeDialog ()
  {
    return AlertDialog(
      title: Container(child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Text('Set wallpaper',style: TextStyle(color: Colors.black),),
      ),color: Colors.white,),
      content: setupAlertDialoadContainer(context),
    );
  }

  Widget setupAlertDialoadContainer(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          height: 155.0, // Change as per your requirement
          width: 280.0, // Change as per your requirement
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.home,color: Colors.blue,),
                title: Text("Home Screen"),
                onTap: (){
                  _setToHomeScreen();
                },
              ),

              ListTile(
                leading: Icon(Icons.lock,color: Colors.blue,),
                title: Text("Lock Screen"),
                onTap: (){
                  _setToLockScreen();
                },
              ),

              ListTile(
                leading: Icon(Icons.phone_android,color: Colors.blue,),
                title: Text("Both"),
                onTap: (){
                  _setToBothScreen();
                },
              ),
            ],
          )
        ),


        Align(
          alignment: Alignment.bottomRight,
          child: FlatButton(

            onPressed: (){
              Navigator.pop(context);
            },child: Text("Cancel"),),
        )
      ],
    );
  }

  _setToHomeScreen()
  async {
    try
    {
      Navigator.pop(context);

      await _downloadImage();

      int location = WallpaperManager.HOME_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;
      final String result = await WallpaperManager.setWallpaperFromFile(path, location);

      //show toast as done
      Fluttertoast.showToast(
          msg: "Image sets to home screen",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    catch(e)
    {
      Fluttertoast.showToast(
          msg:e.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

  }

  _setToLockScreen()
  async {

    try
    {
      Navigator.pop(context);

      await _downloadImage();

      int location = WallpaperManager.LOCK_SCREEN; // or location = WallpaperManager.HOME_SCREEN;
      final String result = await WallpaperManager.setWallpaperFromFile(path, location);

      //show toast as done
      Fluttertoast.showToast(
          msg: "Image sets to lock screen",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    catch(e)
    {
      Fluttertoast.showToast(
          msg:e.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  _setToBothScreen()
  async {

    try
    {
      Navigator.pop(context);
      await _downloadImage();

      int location = WallpaperManager.BOTH_SCREENS; // or location = WallpaperManager.LOCK_SCREEN;
      final String result = await WallpaperManager.setWallpaperFromFile(path, location);

      //show toast as done
      Fluttertoast.showToast(
          msg: "Image sets to both screen",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    catch(e)
    {
      Fluttertoast.showToast(
          msg:e.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  _downloadImage() async
  {
    if(path==null) {

      if (Platform.isAndroid) {
        await _askPermission();
      }

      try {
        var imageId = await ImageDownloader.downloadImage(
          widget.imgUrl,
          destination: AndroidDestinationType
              .directoryPictures, //images save to pictures folder
        );
        path = await ImageDownloader.findPath(imageId);
      }
      catch (e) {
        Fluttertoast.showToast(
            msg: e.message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
  }

  _showSnacBarToOpenImage(){
    //show SnackBar
    final snackBar = SnackBar(
      content: Text('Image Saved in Gallery'),
      action: SnackBarAction(
        label: 'Open',
        onPressed: () async {
          await ImageDownloader.open(path);
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    //END OF SHOW SNACK BAR
  }


}
