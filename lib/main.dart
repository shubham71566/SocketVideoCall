import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_call/screens/call/call_audio.dart';
import 'package:video_call/screens/call/call_video.dart';
import 'package:video_call/screens/home/home.dart';
import 'package:video_call/bloc/bloc.dart';
import 'package:video_call/screens/incoming.dart';
import 'package:video_call/screens/intro/intro_screens.dart';
import 'package:video_call/screens/intro/profile.dart';
import 'package:video_call/screens/intro/splash.dart';
import 'package:video_call/socket/repository.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  CallBloc callBloc;
  ServerBloc serverBloc;
  CallUIBloc callUIBloc;
  HomeBloc homeBloc;
  Repository repository;

  @override
  void initState() {
    super.initState();
    repository = Repository();
    callUIBloc = CallUIBloc();
    callBloc = CallBloc(callUIBloc, repository);
    serverBloc = ServerBloc(callUIBloc, repository)..add(ServerEventInit());
    homeBloc = HomeBloc(repository);
  }

  @override
  void dispose() {
    callBloc.close();
    serverBloc.close();
    callUIBloc.close();
    homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<ServerBloc>.value(value: serverBloc),
          BlocProvider<CallBloc>.value(value: callBloc),
          BlocProvider<CallUIBloc>.value(value: callUIBloc),
          BlocProvider<HomeBloc>.value(value: homeBloc),
        ],
        child: MaterialApp(
            title: 'Video Call',
            theme: ThemeData.dark(),
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case '/intro':
                  return CustomRoute(
                    widget: IntroScreen(),
                  );
                  break;
                case '/profile':
                  return CustomRoute(
                    widget: ProfileAdd(),
                  );
                  break;
                case '/home':
                  return CustomRoute(
                    widget: ScreenHome(),
                  );
                  break;
                case '/audio_call':
                  return CustomRoute(
                    widget: ScreenCallAudio(
                      user: settings.arguments,
                    ),
                  );
                  break;
                case '/video_call':
                  return CustomRoute(
                    widget: ScreenCallVideo(
                      user: settings.arguments,
                    ),
                  );
                  break;
                case '/incoming':
                  return CustomRoute(
                    widget: ScreenIncoming(
                      user: settings.arguments,
                    ),
                  );
                  break;
                default:
                  return CustomRoute(
                    widget: SplashScreen(),
                  );
              }
            }));
  }
}

class CustomRoute extends PageRouteBuilder {
  Widget widget;
  CustomRoute({
    this.widget,
  }) : super(
            pageBuilder: (context, animation, secondaryAnimation) => widget,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var tween, curve, animationWithCurve;
              tween = Tween(
                begin: Offset(1.0, 0.0),
                end: Offset.zero,
              );
              curve = Curves.easeOut;
              animationWithCurve = CurvedAnimation(
                parent: animation,
                curve: curve,
              );
              return SlideTransition(
                position: tween.animate(animationWithCurve),
                child: child,
              );
            });
}
