import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:video_call/bloc/bloc.dart';
import 'package:video_call/bloc/home_bloc/home_bloc.dart';
import 'package:video_call/bloc/server_bloc/server_bloc.dart';
import 'package:video_call/constants/const.dart';
import 'package:video_call/model/user.dart';
import 'package:video_call/screens/about.dart';
import 'package:video_call/screens/add_user.dart';
import 'package:video_call/screens/call/call_video.dart';

part './home_widgets.dart';

class ScreenHome extends StatefulWidget {
  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final RTCVideoRenderer _localView = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  @override
  void dispose() {
    _localView.dispose();
    super.dispose();
  }

  initRenderers() async {
    await _localView.initialize();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('Executed Did Update Widget');
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<HomeBloc>(context).add(HomeEventInitialise());
    BlocProvider.of<ServerBloc>(context).listen((state) {
      if (state is ServerStateIncomingCall) {
        BlocProvider.of<HomeBloc>(context).add(HomeEventLoading());
        Navigator.of(context).pushNamed('/incoming', arguments: state.peer);
      }
    });
    BlocProvider.of<CallUIBloc>(context).listen((state) {
      if (state is CallUIStateInitialise) {
        BlocProvider.of<HomeBloc>(context).add(HomeEventLoading());
        Navigator.of(context).pushNamed(
            (state.type == CallType.audio) ? '/audio_call' : '/video_call',
            arguments: state.user);
      }
    });
    return BlocBuilder(
        cubit: BlocProvider.of<HomeBloc>(context),
        buildWhen: (_, current) => current is HomeStateIdle,
        builder: (_, state) {
          if (state is HomeStateIdle) _localView.srcObject = state.localVideo;
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              alignment: Alignment.topCenter,
              fit: StackFit.expand,
              children: [
                RemoteVideo(renderer: _localView),
                Positioned(
                    top: 30.0,
                    right: MediaQuery.of(context).size.width * 0.25,
                    child: Image.asset(
                      'assets/Logo.png',
                      height: 80.0,
                    )),
                Positioned(
                  top: 55.0,
                  left: 15.0,
                  child: Builder(
                    builder: (context) {
                      return FloatingActionButton(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          heroTag: null,
                          child: Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer());
                    },
                  ),
                ),
                Positioned(bottom: 0.0, child: StartCallButton())
              ],
            ),
            drawer: Drawer(
              child: AboutDrawer(),
            ),
          );
        });
  }
}

class UserBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(50.0), topLeft: Radius.circular(50.0)),
          color: Color(0x66000000),
        ),
        child: BlocBuilder(
            cubit: BlocProvider.of<HomeBloc>(context),
            builder: (context, state) {
              print("Rebuilt the BottomSheet UI!   State: " + state.toString());
              if (state is HomeStateIdle) {
                var users = state.users;
                var added = state.added;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: Container(
                        height: 8.0,
                        width: 70.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Available',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                ' Users  ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w300),
                              ),
                              Text(
                                '( ' + (users?.length ?? 0).toString() + ' )',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ],
                          ),
                          IconButton(icon: Icon(Icons.info), onPressed: () {}),
                        ],
                      ),
                    ),
                    (users == null)
                        ? Scanning()
                        : (users.length > 0)
                            ? ScannedSlideGrid(
                                users: users,
                              )
                            : Center(
                                child: TiledButton(
                                  type: TileType.scan,
                                  isButton: true,
                                ),
                              ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Added',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                ' Users  ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w300),
                              ),
                              Text(
                                '( ' + (added?.length ?? 0).toString() + ' )',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ],
                          ),
                          IconButton(icon: Icon(Icons.info), onPressed: () {}),
                        ],
                      ),
                    ),
                    (added == null)
                        ? Loading()
                        : (added.length > 0)
                            ? AddedSlideGrid(
                                added: added,
                              )
                            : Center(
                                child: TiledButton(
                                  type: TileType.add,
                                  isButton: true,
                                ),
                              ),
                    SizedBox(
                      height: 30.0,
                    ),
                  ],
                );
              } else
                return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
