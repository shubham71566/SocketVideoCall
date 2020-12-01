part of './home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeStateIdle extends HomeState {
  final List<User> users;
  final List<User> added;
  final User profile;
  final localVideo;

  const HomeStateIdle({this.users, this.added, this.profile, this.localVideo});

  @override
  List<Object> get props => [added, users, profile, localVideo];
}

class HomeStateLoading extends HomeState {
  const HomeStateLoading();

  @override
  List<Object> get props => [];
}
