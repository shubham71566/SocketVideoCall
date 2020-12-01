import 'dart:async';

import 'package:get_ip/get_ip.dart';
import 'package:video_call/bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call/socket/repository.dart';
import 'package:video_call/socket/socket_scan.dart';
part './home_event.dart';
part './home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  List<User> addedUsers = List();
  List<User> scannedUsers = List();
  SocketScan scanner = SocketScan();

  final Repository repository;

  var localStream;
  var _host;

  HomeBloc(this.repository) : super(HomeStateLoading()) {
    init();

    /// For testing only:
    // scannedUsers.add(User(name: "Ranger", ip: "192.168.0.1"));
    // scannedUsers.add(User(name: "Hobbit", ip: "192.168.0.2"));

    // addedUsers.add(User(name: "Ranger", ip: "192.168.0.1"));
    // addedUsers.add(User(name: "Hobbit", ip: "192.168.0.2"));
  }

  Future<User> getHost() async {
    var profile = await getProfile();
    String ip;
    try {
      ip = await GetIp.ipAddress;
    } catch (e) {
      print('Home Bloc: ' + e);
      ip = 'Error retrieving IP address';
    }
    return User(name: profile, ip: ip);
  }

  Future<void> init() async {
    _host = await getHost();
    scanner.init(
        host: _host.copyWith(),
        updateUsers: (users) {
          add(HomeEventNewScanned(users: users));
        });
  }

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is HomeEventInitialise)
      yield* _mapHomeToState(event);
    else if (event is HomeEventScan)
      yield* _mapScanToState(event);
    else if (event is HomeEventNewScanned)
      yield* _mapNewScanToState(event);
    else if (event is HomeEventAdd)
      yield* _mapAddToState(event);
    else if (event is HomeEventEdit)
      yield* _mapEditToState(event);
    else if (event is HomeEventUpdateProfile)
      yield* _mapUpdateProfileToState(event);
    else if (event is HomeEventLoading)
      yield HomeStateLoading();
    else
      throw Exception("EventNotFound");
  }

  Stream<HomeState> _mapScanToState(HomeEventScan event) async* {
    yield HomeStateIdle(
        added: addedUsers, profile: _host.copyWith(), localVideo: localStream);
    _host = await getHost();
    scanner.updateHost(_host);
    await scanner.scan();

    /// If the Scanner doesn't return any Users within 500 ms, yield the normal
    /// state. (To stop the "Scanning..." C. Progress Indicator)
    await Future.delayed(Duration(milliseconds: 500));
    yield HomeStateIdle(
      added: addedUsers,
      users: scannedUsers,
      profile: _host.copyWith(),
      localVideo: localStream,
    );
  }

  Stream<HomeState> _mapNewScanToState(HomeEventNewScanned event) async* {
    scannedUsers = event.users;
    yield HomeStateIdle(
      added: addedUsers,
      users: scannedUsers,
      profile: _host.copyWith(),
      localVideo: localStream,
    );
  }

  Stream<HomeState> _mapHomeToState(HomeEventInitialise event) async* {
    localStream = await repository.getLocalVideo();
    _host = await getHost();
    yield HomeStateIdle(
      added: addedUsers,
      users: scannedUsers,
      profile: _host.copyWith(),
      localVideo: localStream,
    );
  }

  Stream<HomeState> _mapAddToState(HomeEventAdd event) async* {
    yield HomeStateIdle(
      users: scannedUsers,
      profile: _host.copyWith(),
      localVideo: localStream,
    );

    /// Allocating user a sequential ID
    var user = event.user.copyWith(id: addedUsers.length);
    addedUsers.add(user);
    print("Home Bloc: Added the users to list: $addedUsers");
    yield HomeStateIdle(
      added: addedUsers,
      users: scannedUsers,
      profile: _host.copyWith(),
      localVideo: localStream,
    );
  }

  Stream<HomeState> _mapEditToState(HomeEventEdit event) async* {
    yield HomeStateIdle(
      users: scannedUsers,
      profile: _host.copyWith(),
      localVideo: localStream,
    );
    if (event.newUser.id >= 0) {
      addedUsers[event.newUser.id] = event.newUser;
      print("Home Bloc: Editted the user at ${event.newUser.id} to list");
    }
    yield HomeStateIdle(
      added: addedUsers,
      users: scannedUsers,
      profile: _host.copyWith(),
      localVideo: localStream,
    );
  }

  Stream<HomeState> _mapUpdateProfileToState(
      HomeEventUpdateProfile event) async* {
    print("Home Bloc: Editted the profile name at ${event.profile}");
    yield HomeStateLoading();
    await updateProfile(event.profile);
    init();
    add(HomeEventInitialise());
  }

  updateProfile(name) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
  }

  getProfile() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }
}
