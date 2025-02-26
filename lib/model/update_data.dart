import 'package:survey_app/model/street.dart';

class UpdateData {
  int truk;
  int pickup;
  int roda3;
  Metadata? metadata;

  UpdateData(
      {required this.truk,
      required this.pickup,
      required this.roda3,
      this.metadata});
}


class UpdateStreetPerColumn {
  String columnName;
  int value;
  UpdateStreetPerColumn({required this.columnName, required this.value});
}