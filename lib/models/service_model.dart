import 'package:tailorware/models/size_model.dart';

class Service {
  Service({
    required this.name,
    required this.style,
    required this.imageName,
    required this.sizes,
  });
  String name;
  String style;
  String imageName;
  List<SizeModel> sizes;
}
