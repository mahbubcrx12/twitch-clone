import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/provider/user_provider.dart';
import 'package:twitch_clone/resources/firestore_methods.dart';
import 'package:twitch_clone/widgets/custom_text_field.dart';
import 'package:twitch_clone/widgets/loading_indicator.dart';
class Chat extends StatefulWidget {
  final String channelId;
  const Chat({Key? key,required this.channelId}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController _chatController =TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;
    return SizedBox(
        width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: StreamBuilder<dynamic>(
              stream: FirebaseFirestore.instance
              .collection('livestream')
              .doc(widget.channelId)
              .collection('comments')
              .orderBy('createdAt',descending: true)
              .snapshots(),
              builder: (context,snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const LoadingIndicator();
                }
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount:snapshot.data.docs.length,
                    itemBuilder: (context,index)=> ListTile(
                      title: Text(snapshot.data.docs[index]['úsername'],style: TextStyle(
                        color: snapshot.data.docs[index]['uid'] ==
                          userProvider.user.uid
                            ? Colors.blue
                            : Colors.black,
                      ),),
                      subtitle: Text(snapshot.data.docs[index]['messege']),
                    ),
                );
              },
            ),
          ),
          CustomTextField(
            controller: _chatController,
          onTap: (val){
              FireStoreMethods().chat(_chatController.text, widget.channelId, context);
              setState(() {
                _chatController.text = "";
              });
          },
          )
        ],
      ),
    );
  }
}
