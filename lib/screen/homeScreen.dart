import 'dart:async';
import 'dart:io';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart'  as firebase_storage;

import '../authBloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'imagesCsreen.dart';
import 'loginScreen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Asset> images = <Asset>[];
  List <File> fileImageArray = [];
  String _error = 'No Error Dectected';
  StreamSubscription<User> homeStateSubscription;

  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context,listen: false);
    homeStateSubscription = authBloc.currentUser.listen((fbUser) {
      if (fbUser == null){
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Login())
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    homeStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    String _error = 'No Error Dectected';
    var authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: InkWell(
                onTap: (){
Navigator.push(context, MaterialPageRoute(builder: (context) => ImagesScreen()));
                },
                child: Text("View Images")),
          )],
      ),
        body: Column(
          children: [
            Center(
              child: StreamBuilder<User>(
                  stream: authBloc.currentUser,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(snapshot.data.displayName,style:TextStyle(fontSize: 35.0)),
                        SizedBox(height: 20.0,),
                        CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data.photoURL + '?width=500&height500'),
                          radius: 60.0,
                        ),
                        SizedBox(height: 30.0,),
                        SignInButton(
                            Buttons.Facebook,
                            text: 'Sign out of Facebook',
                            onPressed: () => authBloc.logout()
                        )
                      ],);
                  }
              ),
            ),
            ElevatedButton( onPressed: loadAssets, child: Text("SelectImage")),
            Divider(color: Colors.blue,),
            buildGridView(),
            SizedBox(height: 20,),
         images.length != 0 ?   ElevatedButton( onPressed: (){
              uploadFiles(fileImageArray).then(onGoBack); 
            }, child: Text("UploadImage")):Container(),
          ],
        )

    );
  }

  Widget buildGridView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width/6,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: images.length,
          itemBuilder: (context,index){

            return Stack(
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ClipRRect(
                      borderRadius:BorderRadius.circular(5),
                      child: AssetThumb(
                        asset: images[index],
                        width: 300,
                        height: 300,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        print(index);
                        images.removeAt(index);
                        // images.remove(index);
                        // print(images.length);
                      });
                    },
                    child: CircleAvatar(maxRadius: 8,
                      child: Icon(Icons.clear,color: Colors.white,size: 15,),
                      backgroundColor: Colors.red[700],),
                  ),
                )
              ],
            );
          }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }




    if (!mounted) return;
    setState(() {
      images = resultList;
      _error = error;
      print(_error);
      print(images);
      print("assest");

      images.forEach((imageAsset) async {
        final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
        File tempFile = File(filePath);
        if (tempFile.existsSync()) {
          fileImageArray.add(tempFile);

        }
      });
    });


  }

  List<String> imagesUrls=[];
  Future<List<String>> uploadFiles(List _images) async {


    if(_images != null){
    _images.forEach((_image) async{
      String fileName = "images" + '/${DateTime.now()}.png';
      firebase_storage.Reference  reference = firebase_storage.FirebaseStorage.instance.ref().child(fileName);
      firebase_storage.UploadTask  uploadTask = reference.putFile(_image);
      // String imagePath = await (await uploadTask).ref.getDownloadURL();
      // print(imagePath);
      imagesUrls.add(await (await uploadTask).ref.getDownloadURL());
    });

    }


    // return imagesUrls;
  }

  FutureOr onGoBack(dynamic value) {
    print("On call back");
    saveImage();

    setState(() {});
  }


  saveImage  (){
    if (imagesUrls != null){
      print('image list');

        FirebaseFirestore.instance.collection("Images").doc().set({
          "image":imagesUrls.toList()
        });
      setState(() {
        images.clear();
        imagesUrls.clear();
        fileImageArray.clear();
      });

    }
  }



}