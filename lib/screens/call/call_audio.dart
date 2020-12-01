import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_call/bloc/bloc.dart';
import 'package:video_call/model/user.dart';

class ScreenCallAudio extends StatefulWidget {
  final User user;
  const ScreenCallAudio({@required this.user});
  @override
  _ScreenCallAudioState createState() => _ScreenCallAudioState();
}

class _ScreenCallAudioState extends State<ScreenCallAudio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              BlocProvider.of<CallUIBloc>(context).add(CallUIEventEnd());
              Navigator.of(context).maybePop();
            }),
        centerTitle: true,
        title: Text('Socket Audio Call'),
      ),
      body: BlocConsumer(
        cubit: BlocProvider.of<CallUIBloc>(context),
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Icon(
                    Icons.phone,
                    size: 200.0,
                  ),
                ),
                ScreenCallOverlay(
                  status: _status(state),
                  name: widget.user.name,
                  ip: widget.user.ip,
                  leftButton: FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    child: Icon(
                      Icons.mic_off,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  rightButton: FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    child: Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          );
        },
        listener: (BuildContext context, state) {
          if (state is CallUIStateDeclined) {
            Future.delayed(Duration(seconds: 2)).then((value) {
              if (mounted) {
                print('Executed Maybe Pop!');
                Navigator.of(context).maybePop();
              }
            });
          }
        },
      ),
    );
  }

  String _status(CallUIState state) {
    if (state is CallUIStateInitialise)
      return 'Initialising...';
    else if (state is CallUIStateConnecting ||
        state is CallUIStateInitRenderers)
      return 'Calling...';
    else if (state is CallUIStateConnected)
      return 'Connected';
    else {
      var status = (state as CallUIStateDeclined).status;
      print('Call Video: ' + '${status.toString()} ${status.index} ');
      switch (status) {
        case Status.BUSY:
          return 'BUSY';
          break;
        case Status.REJECT:
          return 'Call Rejected';
          break;
        case Status.END:
          return 'Call Ended';
          break;
        default:
          return 'ERROR';
          break;
      }
    }
  }
}

class ScreenCallOverlay extends StatelessWidget {
  const ScreenCallOverlay({
    Key key,
    @required this.status,
    @required this.name,
    @required this.ip,
    @required this.leftButton,
    @required this.rightButton,
  }) : super(key: key);

  final String status;
  final String name;
  final String ip;
  final Widget leftButton;
  final Widget rightButton;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        _topOverlay(context, height, width),
        _bottomOverlay(context, height, width),
      ],
    );
  }

  Widget _topOverlay(context, height, width) {
    return Stack(
      children: [
        Positioned(
          child: Container(
            color: Color(0x99000000),
            height: height * 0.25,
            width: width,
          ),
        ),
        Positioned(
          top: 0.0,
          child: Container(
            width: width,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6.apply(
                        color: Colors.white,
                      ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headline3.apply(
                        color: Colors.white,
                      ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  "IP Address: " + ip,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomOverlay(context, height, width) {
    return Container(
      height: height,
      width: width,
      child: Stack(
        children: [
          Positioned(
            bottom: 0.0,
            child: Container(
              color: Color(0x99000000),
              height: height * 0.2,
              width: width,
            ),
          ),
          Positioned(
            bottom: 0.0,
            child: Container(
              width: width,
              height: height * 0.2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  leftButton,
                  FloatingActionButton(
                    heroTag: null,
                    child: Icon(
                      Icons.call_end,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.red,
                    onPressed: () {
                      BlocProvider.of<CallUIBloc>(context)
                          .add(CallUIEventEnd());
                      BlocProvider.of<HomeBloc>(context)
                          .add(HomeEventInitialise());
                      Navigator.of(context).pop();
                    },
                  ),
                  rightButton,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String status(Status status) {
  switch (status) {
    case Status.BUSY:
      return "User Busy";
      break;
    case Status.REJECT:
      return "User Rejected";
      break;
    default:
      return "An Error Occured";
      break;
  }
}
