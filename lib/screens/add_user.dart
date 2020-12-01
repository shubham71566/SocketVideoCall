import 'package:flutter/material.dart';
import 'package:video_call/model/user.dart';

/// An Alert Dialog to add a USER
class AddEditViewUser extends StatefulWidget {
  final Function(User) onSave;
  final User editUser;
  final User profile;

  AddEditViewUser({this.onSave, this.editUser, this.profile});

  @override
  _AddEditViewUserState createState() => _AddEditViewUserState();
}

class _AddEditViewUserState extends State<AddEditViewUser> {
  User user = User();
  bool edit = false;
  bool profile = false;

  final _formKey = GlobalKey<FormState>();

  FocusNode ipNode = FocusNode();
  @override
  void initState() {
    super.initState();
    if (widget.editUser != null) {
      user = widget.editUser.copyWith();
      edit = true;
    } else if (widget.profile != null) {
      user = widget.profile;
      profile = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (edit) ? "Edit User" : (profile) ? "Profile" : "Add User",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.black,
                      ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  autocorrect: true,
                  autofocus: true,
                  initialValue: (edit || profile) ? user.name : null,
                  cursorColor: Colors.black,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.black87),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: "Name",
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Color(0xFF888888)),
                    prefixIcon: Icon(
                      Icons.account_circle,
                      color: Colors.black,
                    ),
                    contentPadding: EdgeInsets.all(20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        bottomRight: Radius.circular(50.0),
                        topRight: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        bottomRight: Radius.circular(50.0),
                        topRight: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0),
                      ),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        bottomRight: Radius.circular(50.0),
                        topRight: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0),
                      ),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(ipNode),
                  validator: (data) {
                    if (data.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (name) {
                    user = user.copyWith(name: name);
                  },
                  keyboardType: TextInputType.name,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  focusNode: ipNode,
                  cursorColor: Colors.white,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: "IP",
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.white70),
                    prefixIcon: Icon(
                      Icons.router,
                      color: Colors.white,
                    ),
                    contentPadding: EdgeInsets.all(20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        bottomRight: Radius.circular(50.0),
                        topRight: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        bottomRight: Radius.circular(50.0),
                        topRight: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0),
                      ),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        bottomRight: Radius.circular(50.0),
                        topRight: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0),
                      ),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (data) {
                    if (profile)
                      return null;
                    else if (data.isEmpty) {
                      return 'Please enter an ip address';
                    } else if (data.contains(new RegExp(r'[A-Z]')))
                      return 'IP address cannot have letters';
                    return null;
                  },
                  initialValue: (edit || profile) ? user.ip : "192.168.0.",
                  enabled: (profile) ? false : true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () => _onDone(context),
                  onSaved: (ip) {
                    user = user.copyWith(ip: ip);
                  },
                  keyboardType: TextInputType.phone,
                ),
                ButtonBar(
                  children: [
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        /// Exit the Alert Dialog
                        Navigator.of(context).pop();
                      },
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          bottomRight: Radius.circular(50.0),
                          topRight: Radius.circular(25.0),
                          bottomLeft: Radius.circular(25.0),
                        ),
                      ),
                      child: Text((edit) ? "Save" : (profile) ? "OK" : "Add"),
                      onPressed: () => _onDone(context),
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onDone(BuildContext context) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print("Saved new user: \n Name: ${user.name} \n IP: ${user.ip}");
      widget.onSave(user);

      /// Exit the Alert Dialog
      Navigator.of(context).pop();
    }
  }
}
