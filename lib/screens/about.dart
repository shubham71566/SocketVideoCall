import 'package:flutter/material.dart';
import 'package:video_call/bloc/bloc.dart';
import 'package:video_call/screens/home/home.dart';
import 'add_user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard_manager/clipboard_manager.dart';

const String _devEmail = "r4ngerofgondor@gmail.com";
const String _profileURL = "https://ranger.gitlab.io";
const String _sourceURL = "https://gitlab.com/rangerofgondor/video-call";
const String _telegramURL = "https://t.me/RangerOfGondor";
const String _gitLabURL = "https://gitlab.com/rangerofgondor";
const String _licenceURL =
    "https://gitlab.com/rangerofgondor/video-call/LICENCE";

final Uri _emailURL =
    Uri(scheme: 'mailto', path: 'r4ngerofgondor@gmail.com', queryParameters: {
  'subject': 'Query<Socket>:',
});

class AboutDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Spacer(),
          Image.asset(
            'assets/Logo Alternate.png',
            height: 65,
          ),
          Spacer(),
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) => current is HomeStateIdle,
            builder: (context, state) {
              assert(state is HomeStateIdle);
              return ListTile(
                leading: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 50,
                ),
                title: Text((state as HomeStateIdle).profile.name,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    )),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // var state = BlocProvider.of<HomeBloc>(context).state;
                    if (state is HomeStateIdle)
                      showDialog(
                          context: context,
                          child: CustomDialog(
                              child: AddEditViewUser(
                            onSave: (user) {
                              BlocProvider.of<HomeBloc>(context).add(
                                  HomeEventUpdateProfile(profile: user.name));
                            },
                            profile: state.profile.copyWith(),
                          )));
                  },
                ),
              );
            },
          ),
          SizedBox(height: 16.0),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/intro');
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 28.0),
            leading: Icon(
              Icons.slideshow,
              color: Colors.white,
              size: 35,
            ),
            title: Text(
              "View Intro",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w300),
            ),
          ),
          Spacer(flex: 2),
          Expanded(flex: 10, child: AboutSection()),
        ],
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(50.0)),
        color: Colors.white,
      ),
      child: Theme(
        data: ThemeData.light(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Spacer(flex: 2),
            Text(
              "    About",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            Spacer(),
            ListTile(
              onTap: () {
                _launchURL(_profileURL, context);
              },
              leading: Image.asset(
                "assets/Icons/dev.png",
              ),
              title: Text(
                "Shrivathsa Prakash",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                "View Profile",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Row(
              children: [
                FlatButton.icon(
                  onPressed: () {
                    _launchURL(_sourceURL, context);
                  },
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 32.0),
                  icon: Icon(
                    Icons.code,
                    size: 35,
                  ),
                  label: Text(
                    "  View Source Code",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Spacer(),
              ],
            ),
            Spacer(flex: 2),
            Text(
              "    Reach out",
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            Spacer(flex: 2),
            Row(
              children: [
                FlatButton.icon(
                  onPressed: () {
                    _launchEmail(context);
                  },
                  onLongPress: () =>
                      _copyToClip(text: _devEmail, context: context),
                  padding: const EdgeInsets.only(left: 32.0),
                  icon: Icon(Icons.email),
                  label: Text(
                    "   " + _devEmail,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Spacer(),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: .0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ImageButton(
                    asset: "assets/Icons/telegram.png",
                    title: "Telegram",
                    onPressed: () => _launchURL(_telegramURL, context),
                  ),
                  ImageButton(
                    asset: "assets/Icons/gitlab.png",
                    title: "GitLab",
                    onPressed: () => _launchURL(_gitLabURL, context),
                  ),
                ],
              ),
            ),
            Spacer(flex: 2),
            Container(
              height: 1.0,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    onPressed: () => _launchURL(_licenceURL, context),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/Icons/licence.png",
                          height: 20,
                          color: Colors.white30,
                          colorBlendMode: BlendMode.lighten,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "View Licence",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.copyright,
                        size: 20.0,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "Copyright 2020",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      /// Show a snackbar that couldn't launch URL
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Couldn't launch URL!"),
      ));
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    if (await canLaunch(_emailURL.toString())) {
      await launch(_emailURL.toString());
    } else {
      /// Show a snackbar that it is copied to clip board
      _copyToClip(text: _devEmail, context: context);
    }
  }

  void _copyToClip({@required String text, @required BuildContext context}) {
    ClipboardManager.copyToClipBoard(text).then((result) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.copy,
              color: Colors.white,
            ),
            Text('Copied to Clipboard!',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Colors.white,
                    )),
          ],
        ),
        backgroundColor: Colors.black,
      ));
    });
  }
}

class ImageButton extends StatelessWidget {
  ImageButton(
      {@required this.asset, @required this.title, @required this.onPressed});

  final String title, asset;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Image.asset(
            asset,
            height: 25,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            title,
            style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
