import 'package:hive/hive.dart';

import '../database/save_model.dart';

class Boxes{
  static Box<SaveModel> getData() => Hive.box<SaveModel>("savedB");
}