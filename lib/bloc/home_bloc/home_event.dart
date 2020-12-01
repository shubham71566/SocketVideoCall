part of './home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class HomeEventInitialise extends HomeEvent {
  const HomeEventInitialise();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event Home Page';
}

class HomeEventScan extends HomeEvent {
  const HomeEventScan();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event Home Scan';
}

class HomeEventNewScanned extends HomeEvent {
  final List<User> users;
  HomeEventNewScanned({this.users});

  @override
  List<Object> get props => [users];

  @override
  String toString() => 'Event Recieved New Scanned Users';
}

class HomeEventAdd extends HomeEvent {
  final User user;
  HomeEventAdd({this.user});

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'Event Add';
}

class HomeEventEdit extends HomeEvent {
  final User newUser;
  HomeEventEdit({this.newUser});

  @override
  List<Object> get props => [newUser];

  @override
  String toString() => 'Event Edit';
}

class HomeEventUpdateProfile extends HomeEvent {
  final String profile;
  HomeEventUpdateProfile({this.profile});

  @override
  List<Object> get props => [profile];

  @override
  String toString() => 'Event Update Profile Name';
}

class HomeEventLoading extends HomeEvent {
  const HomeEventLoading();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event Home Loading';
}