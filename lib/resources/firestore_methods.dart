import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/model/live_stream.dart';
import 'package:twitch_clone/provider/user_provider.dart';
import 'package:twitch_clone/resources/storage_methods.dart';
import 'package:twitch_clone/utils/utils.dart';

class FireStoreMethods{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods _storageMethods = StorageMethods();
  Future<String> startLiveStream(BuildContext context,String title,Uint8List? image)async{
    final user = Provider.of<UserProvider>(context,listen: false);
    String channelId ='';
    try{
      if(title.isNotEmpty && image != null){
        if(!((await _firestore
            .collection('livestream')
            .doc('${user.user.uid}${user.user.username}')
            .get())
            .exists)){
          String thumbnailUrl = await _storageMethods.uploadImageToStorage(
            "livestream-thumbnails",
            image,
            user.user.uid,
          );
          channelId = '${user.user.uid}${user.user.username}';

          LiveStream liveStream = LiveStream(
              title: title,
              image: thumbnailUrl,
              uid: user.user.uid,
              username: user.user.username,
              startedAt: DateTime.now(),
              viewers: 0,
              channelId: channelId);
          _firestore.collection('livestream').doc(channelId).set(liveStream.toMap());
        }else{
          showSnackBar(context, "Two live streaming is not possible");
        }
      }else{
        showSnackBar(context, 'Please enter all the fields');
      }
    } on FirebaseException catch(e){
      showSnackBar(context,e.message!);
    }
    return channelId;
  }
}