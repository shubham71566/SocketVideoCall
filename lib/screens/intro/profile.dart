import 'package:flutter/material.dart';
import 'package:video_call/bloc/bloc.dart';
import 'package:video_call/constants/const.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';

/// A Screen to create a Profile for a new user (Mainly name of the user)
/// Comes right after Intro Screen

class ProfileAdd extends StatefulWidget {
  @override
  _ProfileAddState createState() => _ProfileAddState();
}

class _ProfileAddState extends State<ProfileAdd> with SingleTickerProviderStateMixin{
  String profile;
  final _formKey = GlobalKey<FormState>();
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 2,vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
      preferredSize: Size.fromHeight(140.0),
      child: AppBar(        
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white30,
        title:Container(
          alignment: Alignment.center,
          child: Image.asset(
                'assets/Logo Alternate.png',
                height: 60,
              ),),
          bottom:TabBar(
                isScrollable: true,
                labelColor: Colors.black,
                controller: _tabController,
                // unselectedLabelStyle: TextStyle(color: Colors.black),
                labelStyle: TextStyle(fontSize: 28,fontWeight: FontWeight.w500),
                indicator: BubbleTabIndicator(
                indicatorHeight: 40.0,
                indicatorColor: Colors.white,
                tabBarIndicatorSize: TabBarIndicatorSize.tab,
                indicatorRadius: 18
              ),
                unselectedLabelColor: Colors.white,
                tabs: [
                  new Container(                    
                    margin: EdgeInsets.only(right: 5,left: 5,top: 5,bottom: 5),
                    child:Tab(text: "Login"),
                  ),
                  new Container(
                    margin: EdgeInsets.only(left: 5,right:5,top: 5,bottom: 5),
                    child:Tab(text: "Signup")
                  ),                            
                ],
              )
            ,
      )),
      backgroundColor: backgroundColor,      
      body:SingleChildScrollView(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [                        
            Container(
              height: MediaQuery.of(context).size.height,
              child:
              TabBarView(
              controller: _tabController,
              children: <Widget>[
                Login(),
                Signup()
              ],)),
            
          ],
        )),
      
    );
  }
  
}

class Login extends StatefulWidget {

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  String profile;
  String email;
  String password;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
       child:SingleChildScrollView( 
         child:Form( 
           key: _formKey,       
         child: Column(
           children: <Widget>[
            Padding(padding: EdgeInsets.only(top:30,bottom:30),),

           Container(              
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: true,
                  autofocus: true,
                  cursorColor: Colors.white,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white,fontSize: 20),
                  decoration: InputDecoration(
                    hintText: "Enter Email",
                    filled: true,
                    fillColor: Colors.white24,
                    hintStyle: inputThin,
                    errorStyle: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.red[300]),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                    contentPadding: EdgeInsets.all(20.0),
                    border: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    errorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                  ),
                  textInputAction: TextInputAction.done,
                  // onEditingComplete: () => _submit(context),
                  validator: (data) {
                    if (data.isEmpty) {
                      return 'Please enter your Email';
                    }
                    return null;
                  },
                  onChanged:(text){
                      email = text;
                      },
                ),
              ),
            ),

            Padding(padding: EdgeInsets.only(top:8,bottom:8),),

           Container(              
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  obscureText: true,
                  autocorrect: true,
                  autofocus: true,
                  cursorColor: Colors.white,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white,fontSize: 20),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    filled: true,
                    fillColor: Colors.white24,
                    hintStyle: inputThin,
                    errorStyle: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.red[300]),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                    contentPadding: EdgeInsets.all(20.0),
                    border: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    errorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                  ),
                  textInputAction: TextInputAction.done,

                  validator: (data) {
                    if (data.isEmpty) {
                      return 'Please enter your Password';
                    }
                    return null;
                  },
                  onChanged:(text){
                      password = text;
                      },
                  
                ),
              ),
            ),

            Padding(padding: EdgeInsets.only(top:80),),

            SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: RaisedButton(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15.0),
              child: Text('Done', style: buttonBold),
              shape: themeShape,
              onPressed: () {
                _submit(context);
              },
            ),
          )
           
            ]
         )),
       ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      String basicAuth ='Basic ' + base64Encode(utf8.encode('$email:$password'));
       http.post('http://192.168.43.224:5000/accounts/signin',
                              headers: {"accept": "application/json", "content-type": "application/json",'authorization': basicAuth}, 
                              ).then((response) {
                                if(response.statusCode==200){
                                  var resData=json.decode(response.body);
                                  profile=resData['name'];
                                  
                              Scaffold.of(context)
                                .showSnackBar(
                                  SnackBar(
                                    content: Text('Logged in Successfully.',style: TextStyle(color: Colors.black,fontSize: 20),),
                                    ));  
                                    print("Profile Name Added: Name: $profile");
                              BlocProvider.of<HomeBloc>(context)
                                  .add(HomeEventUpdateProfile(profile: profile));
                              BlocProvider.of<ServerBloc>(context)
                                  .add(ServerEventUpdateHost(host: User(name: profile, ip: '')));
                              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);           
                              
                              }
                              else{
                                Scaffold.of(context)
                                .showSnackBar(
                                  SnackBar(
                                    content: Text('Invalid Credentials.',style: TextStyle(color: Colors.black,fontSize: 20),),
                                    )); 
                              }
                              });
                              
    }
  }
}

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  String profile;
  String email;
  String name;
  String mobile;
  String password;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
       child:SingleChildScrollView(         
         child: Form( 
           key: _formKey,       
         child: Column(
           children: <Widget>[
            Padding(padding: EdgeInsets.only(top:30,bottom:30),),

           Container(              
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  autocorrect: true,
                  autofocus: true,
                  cursorColor: Colors.white,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white,fontSize: 20),
                  decoration: InputDecoration(
                    hintText: "Enter Name",
                    filled: true,
                    fillColor: Colors.white24,
                    hintStyle: inputThin,
                    errorStyle: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.red[300]),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    contentPadding: EdgeInsets.all(20.0),
                    border: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    errorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                  ),
                  textInputAction: TextInputAction.done,
                  // onEditingComplete: () => _submit(context),
                  validator: (data) {
                    if (data.isEmpty) {
                      return 'Please enter your Name';
                    }
                    return null;
                  },
                  onChanged:(text){
                      name = text;
                      },
                ),
              ),
            ),

            Padding(padding: EdgeInsets.only(top:8,bottom:8),),

           Container(              
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: true,
                  autofocus: true,
                  cursorColor: Colors.white,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white,fontSize: 20),
                  decoration: InputDecoration(
                    hintText: "Enter Email",
                    filled: true,
                    fillColor: Colors.white24,
                    hintStyle: inputThin,
                    errorStyle: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.red[300]),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                    contentPadding: EdgeInsets.all(20.0),
                    border: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    errorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                  ),
                  textInputAction: TextInputAction.done,
                  // onEditingComplete: () => _submit(context),
                  validator: (data) {
                    if (data.isEmpty) {
                      return 'Please enter your Email';
                    }
                    return null;
                  },
                  onChanged:(text){
                      email = text;
                      },
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top:8,bottom:8),),

           Container(              
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  autocorrect: true,
                  autofocus: true,
                  cursorColor: Colors.white,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white,fontSize: 20),
                  decoration: InputDecoration(
                    hintText: "Enter Mobile No.",
                    filled: true,
                    fillColor: Colors.white24,
                    hintStyle: inputThin,
                    errorStyle: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.red[300]),
                    prefixIcon: Icon(
                      Icons.phone_android,
                      color: Colors.white,
                    ),
                    contentPadding: EdgeInsets.all(20.0),
                    border: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    errorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                  ),
                  textInputAction: TextInputAction.done,
                  // onEditingComplete: () => _submit(context),
                  validator: (data) {
                    if (data.isEmpty) {
                      return 'Please enter your Mobile No.';
                    }
                    return null;
                  },
                  onChanged:(text){
                      mobile = text;
                      },
                ),
              ),
            ),

            Padding(padding: EdgeInsets.only(top:8,bottom:8),),

           Container(              
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  obscureText: true,
                  autocorrect: true,
                  autofocus: true,
                  cursorColor: Colors.white,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white,fontSize: 20),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    filled: true,
                    fillColor: Colors.white24,
                    hintStyle: inputThin,
                    errorStyle: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.red[300]),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                    contentPadding: EdgeInsets.all(20.0),
                    border: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: themeBorder,
                    ),
                    errorBorder: OutlineInputBorder(
                        borderRadius: themeBorder,
                        borderSide:
                            BorderSide(color: Colors.red[300], width: 2.0)),
                  ),
                  textInputAction: TextInputAction.done,

                  validator: (data) {
                    if (data.isEmpty) {
                      return 'Please enter your Password';
                    }
                    return null;
                  },
                  onChanged:(text){
                      password = text;
                      },
                  
                ),
              ),
            ),

            Padding(padding: EdgeInsets.only(top:80),),

            SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: RaisedButton(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15.0),
              child: Text('Done', style: buttonBold),
              shape: themeShape,
              onPressed: () {
                _submit(context);
              },
            ),
          )
           
            ]
         ))
       ),
    );
  }
  Future<void> _submit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      print(name);
      print(email);
      print(mobile);
      print(password);
      
      var data={
                "email":email,
                "name":name,
                "password":password,
                "mobile":mobile
                };

       http.post('http://192.168.43.224:5000/accounts/signup',
                              headers: {"accept": "application/json", "content-type": "application/json"},
                              body: json.encode(data)
                              ).then((response) {
                                if(response.statusCode==200){                                  
                                profile=name;
                                    
                                Scaffold.of(context)
                                  .showSnackBar(
                                    SnackBar(
                                      content: Text('Account Registered Successfully.',style: TextStyle(color: Colors.black,fontSize: 20),),
                                      ));  
                                      print("Profile Name Added: Name: $profile");
                                BlocProvider.of<HomeBloc>(context)
                                    .add(HomeEventUpdateProfile(profile: profile));
                                BlocProvider.of<ServerBloc>(context)
                                    .add(ServerEventUpdateHost(host: User(name: profile, ip: '')));
                                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);           
                              
                              }
                              else{
                                Scaffold.of(context)
                                .showSnackBar(
                                  SnackBar(
                                    content: Text('Please try again',style: TextStyle(color: Colors.black,fontSize: 20),),
                                    )); 
                              }
                              });
    }
  }
}
