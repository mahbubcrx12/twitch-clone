import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/provider/user_provider.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:twitch_clone/resources/firestore_methods.dart';
import 'package:twitch_clone/screen/chat_screen.dart';
import 'package:twitch_clone/screen/home_screen.dart';
import '../config/appid.dart';
class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;
  const BroadcastScreen({Key? key,required this.isBroadcaster,required this.channelId}) : super(key: key);

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine;
  List<int> remoteUid = [];
  bool switchCamera = true;
  bool isMuted = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initEngine();
  }
  void _initEngine()async{
      _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
      _addListeners();

      await _engine.enableVideo();
      await _engine.startPreview();
      await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
      if(widget.isBroadcaster){
        _engine.setClientRole(ClientRole.Broadcaster);
      }else{
        _engine.setClientRole(ClientRole.Audience);
      }
      _joinChannel();
  }
  void _addListeners(){
    _engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {
        debugPrint('userJoined $uid $elapsed');
      },
      userJoined: (uid, reason) {
        debugPrint('userOffline $uid $reason');
        setState(() {
          remoteUid.removeWhere((element) => element == false);
        });
      },
      leaveChannel: (stats){
        debugPrint('leaveChannel $stats');
        setState(() {
          remoteUid.clear();
        });
      }
    ));
  }

  void _joinChannel()async{
    if(defaultTargetPlatform == TargetPlatform.android){
      await [Permission.microphone,Permission.camera].request();
    }
    await _engine.joinChannelWithUserAccount(
        tempToken,
        'test123',
        Provider.of<UserProvider>(context,listen: false).user.uid,
    );
  }

  void _switchCamera(){
    _engine.switchCamera().then((value){
     setState(() {
       switchCamera = !switchCamera;
     });
    }).catchError((err){
      debugPrint('switchCamera $err');
    });
  }

  void onToggleMute() async{
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

  _leaveChannel() async{
    await _engine.leaveChannel();
    if('${Provider.of<UserProvider>(context,listen: false).user.uid}${Provider.of<UserProvider>(context,listen: false).user.username}' == widget.channelId){
      await FireStoreMethods().endLiveStream(widget.channelId);
    }else{
      await FireStoreMethods().updateViewCount(widget.channelId,false);
    }
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async{
          await _leaveChannel();
          return Future.value(true);
        },
        child: Scaffold(
          body: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _renderVideo(user),
                  if("${user.uid}${user.username}" == widget.channelId)
                    Row(
                     // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: _switchCamera,
                          child: Column(
                            children: [
                              const Icon(Icons.switch_camera_outlined,color: Colors.red,size: 40,),
                              const Text("Switch Camera"),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: onToggleMute,
                          child: Column(
                            children: [
                              Icon(isMuted ? Icons.volume_off :Icons.volume_mute_sharp,color: Colors.red,size: 40),
                              Text(isMuted ? 'Unmute' : 'Mute'),
                            ],
                          ),
                        )
                      ],
                    ),
                  Expanded(
                      child: Chat(
                          channelId: widget.channelId
                      )
                  )

                ],
          ),
          ),
        ),
      ),
    );
  }
  _renderVideo(user){
    return AspectRatio(aspectRatio: 16/12,
      child: "${user.uid}${user.username}" == widget.channelId ? RtcLocalView.SurfaceView(
        zOrderMediaOverlay: true,
        zOrderOnTop: true,
      ): remoteUid.isNotEmpty ? kIsWeb ? RtcRemoteView.SurfaceView(
        uid: remoteUid[0],channelId: widget.channelId,)
          : RtcRemoteView.TextureView(
          uid: remoteUid[0],
          channelId: widget.channelId)
          :Container()

    );
  }
}
