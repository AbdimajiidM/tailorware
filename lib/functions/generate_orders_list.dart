import 'package:tailorware/models/order_model.dart';
import 'package:tailorware/models/service_model.dart';
import 'package:tailorware/models/size_model.dart';

import 'package:intl/intl.dart';

List<Order> generateOrdersList(orders) {
  List<Order> ordersList = [];
  for (var order in orders) {
    var orderServices = order['services']!;
    List<Service> services = [];

    for (var service in orderServices) {
      var styles = '';
      List<SizeModel> sizes = [];

      for (var index = 0; index < service['styles'].length; index++) {
        var style = service['styles'][index];
        if (index == 0) {
          styles += style;
        } else {
          styles += " - $style";
        }
      }

      for (var index = 0; index < service['sizes'].length; index++) {
        var title = service['sizes'][index]['title'];
        var value = service['sizes'][index]['value'];

        SizeModel size = SizeModel(
          title: '$title',
          value: '$value',
        );

        sizes.add(size);
      }

      services.add(
        Service(
          name: service['type']!,
          style: styles,
          imageName: service['imageUrl']!,
          sizes: sizes,
          quantity: service['quantity'],
          menu: service['menu'] != null ? service['menu']['name']! : "",
        ),
      );
    }
    var customer = order['customer'];
    var date = DateTime.parse(order['deadline']);
    var deadline = DateFormat.yMMMMd().format(date);

    ordersList.add(
      Order(
        orderId: order['_id'],
        orderNumber: order['orderNumber']!,
        name: order['name']!,
        customerName: customer != null ? customer['name']! : "No Customer",
        phone: customer != null ? customer['phone']! : "No Contact",
        deadline: deadline,
        ref: order['Ref'],
        services: services,
      ),
    );
  }

  return ordersList;
}
