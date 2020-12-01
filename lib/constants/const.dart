import 'package:flutter/material.dart';

const Color backgroundColor = Color(0xFF121212);

const Color bottomIndNormal = Color(0xFFC4C4C4);
const Color bottomIndSelected = Colors.white;

const TextStyle bold =
    TextStyle(fontSize: 48, fontWeight: FontWeight.w400, color: Colors.white);

const TextStyle thin =
    TextStyle(fontSize: 48, fontWeight: FontWeight.w200, color: Colors.white);

const TextStyle buttonThin =
    TextStyle(fontSize: 32, fontWeight: FontWeight.w200, color: Colors.black);

const TextStyle buttonBold =
    TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black);

const TextStyle inputThin =
    TextStyle(fontSize: 24, fontWeight: FontWeight.w200, color: Colors.white70);

const ShapeBorder themeShape =
    RoundedRectangleBorder(borderRadius: themeBorder);

const BorderRadius themeBorder = BorderRadius.only(
  topLeft: Radius.circular(50.0),
  bottomRight: Radius.circular(50.0),
  topRight: Radius.circular(25.0),
  bottomLeft: Radius.circular(25.0),
);
