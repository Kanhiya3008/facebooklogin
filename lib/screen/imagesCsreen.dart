import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
class ImagesScreen extends StatefulWidget {
  @override
  _ImagesScreenState createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  List<dynamic> imageslist = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImages();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
            itemCount: imageslist.length,
            itemBuilder: (context,index){
              return
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(

            width: MediaQuery.of(context).size.width,

            child: GridView.count(crossAxisCount: 4,
              childAspectRatio: 0.8,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(imageslist[index].length, (i){
                return Card(
                child: Image.network(imageslist[index][i],fit: BoxFit.cover,)
                );

              }
            )

            ),
            ) );

        }),
      )





        //
        // StreamBuilder(
        //     stream: FirebaseFirestore.instance
        //         .collection('Images')
        //         .snapshots(),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) return const Text('loading....');
        //       return ListView.builder(
        //           reverse: true,
        //           shrinkWrap: true,
        //           itemCount: snapshot.data.documents.length,
        //           itemBuilder: (context, index) {
        //             return _buildListItem(
        //                 context, snapshot.data.documents[index]);
        //           });
        //     }),

    );
  }

  // Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
  //   return Padding(
  //       padding: EdgeInsets.all(0),
  //       child: optionList(document["image"]));
  // }
  //
  //
  // Widget optionList(List data,) {
  //   return Container(
  //       height: MediaQuery.of(context).size.height,
  //       width: MediaQuery.of(context).size.width / 1.2,
  //       child: GridView.count(
  //           crossAxisCount: 4,
  //           childAspectRatio: 0.7,
  //           shrinkWrap: true,
  //           physics: NeverScrollableScrollPhysics(),
  //           children: List.generate(data.length, (index) {
  //             return Container(
  //                 decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(20),
  //                     border: Border.all(color: Colors.black)),
  //                 height: 70,
  //                 width: 70,
  //                 child: Padding(padding: EdgeInsets.all(5),
  //                     child: Image.network( data[index],fit: BoxFit.cover,)
  //                 )
  //             );
  //           }))
  //   );
  // }


  getImages(){
    FirebaseFirestore.instance.collection("Images").get().then((value){
      value.docs.forEach((element) {
        print(element['image'].length);
        // print(element['image']);

        List<dynamic> imageeli = [];
       setState(() {
         imageslist.add(element['image']);
         print(imageslist[0][0]);

       });


      });
    });
  }
}
