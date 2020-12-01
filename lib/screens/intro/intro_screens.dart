import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call/constants/const.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({
    Key key,
  }) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _showFAB = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Spacer(),
          Hero(
            tag: 'icon',
            child: Image.asset(
              'assets/Logo Alternate.png',
              height: 60,
            ),
          ),
          Spacer(flex: 1),
          Expanded(
            flex: 20,
            child: Swiper(
              itemCount: 3,
              itemBuilder: (_, index) => IntroSwipables(index: index),
              loop: false,
              pagination: SwiperPagination(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                builder: DotSwiperPaginationBuilder(
                  activeColor: bottomIndSelected,
                  activeSize: 14.0,
                  color: bottomIndNormal,
                  space: 8.0,
                ),
              ),
              outer: true,
              onIndexChanged: (value) {
                if (value == 2)
                  setState(() {
                    _showFAB = true;
                  });
                else if (_showFAB)
                  setState(() {
                    _showFAB = false;
                  });
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: (_showFAB) ? GetStarted() : null,
    );
  }
}

/// Custom Floating Action Button to display Get Started

class GetStarted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 50.0),
      width: MediaQuery.of(context).size.width * 0.8,
      child: RaisedButton(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Get', style: buttonThin),
            Text(' Started', style: buttonBold),
          ],
        ),
        shape: themeShape,
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool _seen = prefs.getString('name') != null;
          if (!_seen)
            Navigator.of(context).pushNamed('/profile');
          else
            Navigator.of(context).pop();
        },
      ),
    );
  }
}

class IntroSwipables extends StatelessWidget {
  const IntroSwipables({Key key, @required this.index}) : super(key: key);

  final int index;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntroText(
          index: index,
        ),
        Expanded(
          child: Padding(
            padding: (index == 2)
                ? const EdgeInsets.only(bottom: 80.0)
                : const EdgeInsets.all(32.0),
            child: Image.asset('assets/Illustrations/$index.png'),
          ),
        ),
      ],
    );
  }
}

class IntroText extends StatelessWidget {
  IntroText({@required this.index});

  /// Can only have values of : [0, 1, 2]
  final int index;

  final List<Widget> introText1 = [
    Text("Call", style: bold),
    Text("without", style: thin),
    Text("Internet!", style: bold),
  ];
  final List<Widget> introText2 = [
    Text("Connect", style: bold),
    Text("to the same", style: thin),
    Text("Wi-Fi", style: bold),
  ];
  final List<Widget> introText3 = [
    Text("Scan", style: bold),
    Text("and start", style: thin),
    Text("calling!", style: bold),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
            (index == 0) ? introText1 : (index == 1) ? introText2 : introText3,
      ),
    );
  }
}
