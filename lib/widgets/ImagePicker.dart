// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraClass extends StatefulWidget{


  @override
  _CameraState createState()=> _CameraState();


}

class _CameraState  extends State<CameraClass>{


  File _imageFile;
  _openGallery(BuildContext context) async{
    File pickFromGallery= (await ImagePicker.pickImage(source: ImageSource.gallery));
    setState(() {
      _imageFile=pickFromGallery;
    });
    Navigator.of(context).pop();

  }
  _openCamera(BuildContext context) async{
    File pickFromGallery= (await ImagePicker.pickImage(source: ImageSource.camera));
    setState(() {
      _imageFile=pickFromGallery;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showDialog(BuildContext context){
    return showDialog(context:context,builder: (BuildContext context){

      return AlertDialog(
        title: Text("Make A choice"),
        content: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListBody(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  child: Text("Gallery"),
                  onTap: (){
                    _openGallery(context);
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  child: Text("Camera"),
                  onTap: (){
                    _openCamera(context);
                  },
                ),
              ),
            ],
          ),
        ),
        ),
      );
    });
  }

  Widget _decideImageView(){
    if(_imageFile == null){
      return Text("No image selected ");
    }
    else{
      return Image.file(_imageFile,width: 400,height: 400,);
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _decideImageView(),
          RaisedButton(
            onPressed: (){_showDialog(context);},
            child: Text("Select Image"),
          ),
        ],
      ),
    );
  }
}
