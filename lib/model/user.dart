import 'package:video_call/bloc/bloc.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String ip;

  User({
    this.id,
    this.name,
    this.ip,
  });

  User copyWith({id, name, ip}) {
    return User(id: id ?? this.id, name: name ?? this.name, ip: ip ?? this.ip);
  }

  @override
  List<Object> get props => [id, name, ip];
}

enum CallType { audio, video }
