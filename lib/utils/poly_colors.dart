import 'package:flutter/material.dart';

import '../model/street.dart';

Color polyColorByRoad(Street st) {
  var color = Colors.red;
  if (st.pickup == 1 && st.truk == 1 && st.roda3 == 1) {
    return Colors.greenAccent;
  }
  if (st.pickup == 1 && st.truk == 1 && st.roda3 == 0) {
    return Colors.lightBlueAccent;
  }
  if (st.pickup == 1 && st.truk == 0 && st.roda3 == 1) {
    return Colors.deepOrangeAccent;
  }
  if (st.pickup == 1 && st.truk == 0 && st.roda3 == 0) {
    return Colors.yellowAccent;
  }
  if (st.pickup == 0 && st.truk == 1 && st.roda3 == 1) {
    return Colors.blueGrey;
  }
  if (st.pickup == 0 && st.truk == 1 && st.roda3 == 0) {
    return Colors.purpleAccent;
  }
  if (st.pickup == 0 && st.truk == 0 && st.roda3 == 1) {
    return Colors.blue;
  }
  return color;
}
