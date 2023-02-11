import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:twitch_clone/resources/firestore_methods.dart';
import 'package:twitch_clone/screen/broadcast.dart';
import 'package:twitch_clone/utils/colors.dart';
import 'package:twitch_clone/utils/utils.dart';
import 'package:twitch_clone/widgets/custom_button.dart';
import 'package:twitch_clone/widgets/custom_text_field.dart';
class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({Key? key}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();
 Uint8List? image;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  goLiveStream()async{
    String channelId = await FireStoreMethods().startLiveStream(
        context, _titleController.text, image);
    if(channelId.isNotEmpty){
      showSnackBar(context, 'Livestream has started successfully!');
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>BroadcastScreen(
        isBroadcaster: true,
        channelId: channelId,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child:Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0,vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap:()async{
                        Uint8List? pickedImage = await pickImage();
                        if(pickedImage != null){
                          setState(() {
                            image = pickedImage;
                          });
                        }
                      },
                      child:image != null
                          ? Center(
                            child: SizedBox(
                            height: 200,
                            width: 250,
                            child:Image.memory(image!)),
                          )
                          :DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10),
                          dashPattern: const [10,4],
                          strokeCap: StrokeCap.round,
                          color: buttonColor,
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: buttonColor.withOpacity(.05),
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.folder_open,
                                  color: buttonColor,
                                  size: 40,
                                ),
                                const SizedBox(height: 15,),
                                Text("Select your thumbnail",style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade400
                                ),)
                              ],
                            ),
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Text("Title",style: TextStyle(
                fontWeight: FontWeight.bold
              ),),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomTextField(
                    controller: _titleController,

                ),
              ),
              Spacer(),
              Padding(padding: EdgeInsets.only(bottom: 10),
              child: CustomButton(
                  text: "Go Live",
                  onTap: goLiveStream,
              ),
              )
            ],
          ),
        )
    );
  }
}
