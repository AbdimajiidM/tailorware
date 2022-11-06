import 'package:tailorware/models/size_model.dart';

class Service {
  Service({
    required this.name,
    required this.style,
    required this.imageName,
    required this.sizes,
    required this.quantity,
    required this.menu,
  });
  String name;
  String style;
  String imageName;
  List<SizeModel> sizes;
  final int quantity;
  final String menu;
}
