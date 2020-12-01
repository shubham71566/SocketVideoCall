import 'package:flutter/material.dart';
import 'package:video_call/bloc/bloc.dart';
import 'package:video_call/model/user.dart';

class ScreenIncoming extends StatelessWidget {
  final User user;
  const ScreenIncoming({this.user});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener(
        cubit: BlocProvider.of<ServerBloc>(context),
        listenWhen: (_, current) => current is ServerStateInitial,
        listener: (context, _) => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Positioned(
              top: 50.0,
              child: Container(
                width: width,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      "Incoming Call",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5.apply(
                            color: Colors.white,
                          ),
                    ),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.headline3.apply(
                            color: Colors.white,
                          ),
                    ),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    Text(
                      "IP Address: " + user.ip,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.1,
              child: Container(
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: null,
                          child: Icon(
                            Icons.call,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.green,
                          onPressed: () {
                            BlocProvider.of<ServerBloc>(context)
                                .add(ServerEventCallAccept());
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          "Accept",
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: null,
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.red,
                          onPressed: () {
                            BlocProvider.of<ServerBloc>(context)
                                .add(ServerEventCallReject());
                            BlocProvider.of<HomeBloc>(context)
                                .add(HomeEventInitialise());
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          "Reject",
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
