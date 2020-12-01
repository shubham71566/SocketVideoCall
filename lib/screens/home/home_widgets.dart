part of './home.dart';

/// Custom Floating Action Button to display Start Call

class StartCallButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        color: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Start',
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              'Call',
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(fontSize: 24.0, fontWeight: FontWeight.w300),
            ),
            SizedBox(
              width: 20.0,
            ),
            Image.asset(
              'assets/Video Cam White.png',
              height: 18.0,
            )
          ],
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(50.0),
                topLeft: Radius.circular(50.0))),
        onPressed: () {
          showBottomSheet(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              context: context,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0))),
              builder: (_) => UserBottomSheet());
        },
      ),
    );
  }
}

enum TileType { scan, add }

/// A tile widget to display all the available users in a ListView

class TiledButton extends StatelessWidget {
  final User user;
  final TileType type;
  final bool isButton;

  const TiledButton(
      {Key key, this.user, @required this.type, this.isButton = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isButton)
          switch (type) {
            case TileType.scan:

              /// To Scan for new Users
              BlocProvider.of<HomeBloc>(context).add(HomeEventScan());
              break;
            case TileType.add:

              /// Show the Add User Dialog
              showDialog(
                  context: context,
                  child: CustomDialog(
                    child: AddEditViewUser(
                      onSave: (user) => BlocProvider.of<HomeBloc>(context)
                          .add(HomeEventAdd(user: user)),
                    ),
                  ));
              break;
          }
        else {
          /// Pushes the Video Call Screen and also informs the BLoC about it
          BlocProvider.of<CallBloc>(context).add(CallEventConnect(
            peer: user,
            type: CallType.video,
          ));
          BlocProvider.of<CallUIBloc>(context).add(CallUIEventInit(
            peer: user,
            type: CallType.video,
          ));
        }
      },
      onLongPress: () {
        if (!isButton && type != TileType.scan)
          showDialog(
              context: context,
              child: AlertDialog(
                content: AddEditViewUser(
                    editUser: user,
                    onSave: (newUser) {
                      newUser = newUser.copyWith(id: user.id);
                      BlocProvider.of<HomeBloc>(context)
                          .add(HomeEventEdit(newUser: newUser));
                    }),
              ));
      },
      child: Container(
        padding: EdgeInsets.all(24.0),
        height: 100.0,
        width: 150.0,
        decoration: BoxDecoration(
          borderRadius: themeBorder,
          color: (!isButton) ? Color(0xFFCCCCCC) : Colors.black,
        ),
        child: (!isButton)
            ? Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    color: Color(0xFF4D4D4D),
                    size: 25,
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 70.0,
                        child: Text(
                          user.name ?? "UNKNOWN",
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Color(0xFF4D4D4D),
                              ),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      Container(
                        width: 70,
                        child: Text(
                          user.ip ?? "0.0.0.0",
                          style: Theme.of(context).textTheme.caption.copyWith(
                                color: Color(0xFF4D4D4D),
                              ),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Center(
                child: Text(
                  (type == TileType.scan) ? "Scan" : "Add +",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
      ),
    );
  }
}

/// A Corousel grid to display scanned user tiles
class ScannedSlideGrid extends StatelessWidget {
  final List<User> users;

  const ScannedSlideGrid({Key key, @required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      child: ListView.separated(
        separatorBuilder: (_, _s) => SizedBox(
          width: 20.0,
        ),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, count) {
          if (count == 0)
            return TiledButton(isButton: true, type: TileType.scan);
          else
            return TiledButton(user: users[count - 1], type: TileType.scan);
        },
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: users.length + 1,
      ),
    );
  }
}

/// A Corousel grid to display added user tiles
class AddedSlideGrid extends StatelessWidget {
  final List<User> added;

  const AddedSlideGrid({Key key, @required this.added}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      child: ListView.separated(
        separatorBuilder: (_, _s) => SizedBox(
          width: 20.0,
        ),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, count) {
          if (count == added.length)
            return TiledButton(
              isButton: true,
              type: TileType.add,
            );
          else
            return TiledButton(
              user: added[count],
              type: TileType.add,
            );
        },
        padding: const EdgeInsets.symmetric(horizontal: 12.0),

        /// The last one being add a peer button
        itemCount: added.length + 1,
      ),
    );
  }
}

/// A Circular Progress Indicator with "Scanning..." Text above it
class Scanning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Scanning...',
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.white70),
          ),
          SizedBox(
            height: 20.0,
          ),
          CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
        ],
      ),
    );
  }
}

/// A Circular Progress Indicator with "Loading..." Text above it
class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Loading...',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          SizedBox(
            height: 20.0,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  CustomDialog({@required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      // backgroundColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: themeBorder,
      ),
      insetPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 20.0),
      child: child,
    );
  }
}
