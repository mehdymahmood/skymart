import 'cart_item_model.dart';
import 'user_model.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final List<CartItemModel> items;
  final AddressModel deliveryAddress;
  final String paymentMethod;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final String status;
  final DateTime placedAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? trackingNumber;
  final String? promoCode;
  final String? notes;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.subtotal,
    this.shippingFee = 0,
    this.discount = 0,
    required this.total,
    required this.status,
    required this.placedAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.trackingNumber,
    this.promoCode,
    this.notes,
  });

  bool get isActive => status != 'Delivered' && status != 'Cancelled';
  bool get isCompleted => status == 'Delivered';
  bool get isCancelled => status == 'Cancelled';

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  List<OrderTimelineEvent> get timeline {
    final events = <OrderTimelineEvent>[];
    events.add(OrderTimelineEvent(
      title: 'Order Placed',
      subtitle: 'Your order has been placed successfully',
      dateTime: placedAt,
      isCompleted: true,
      icon: 'check_circle',
    ));
    if (confirmedAt != null) {
      events.add(OrderTimelineEvent(
        title: 'Order Confirmed',
        subtitle: 'Seller has confirmed your order',
        dateTime: confirmedAt,
        isCompleted: true,
        icon: 'store',
      ));
    } else {
      events.add(OrderTimelineEvent(
        title: 'Order Confirmed',
        subtitle: 'Waiting for seller confirmation',
        dateTime: null,
        isCompleted: false,
        icon: 'store',
      ));
    }
    if (shippedAt != null) {
      events.add(OrderTimelineEvent(
        title: 'Order Shipped',
        subtitle: 'Your order is on the way',
        dateTime: shippedAt,
        isCompleted: true,
        icon: 'local_shipping',
      ));
    } else {
      events.add(OrderTimelineEvent(
        title: 'Order Shipped',
        subtitle: 'Preparing for shipment',
        dateTime: null,
        isCompleted: false,
        icon: 'local_shipping',
      ));
    }
    if (deliveredAt != null) {
      events.add(OrderTimelineEvent(
        title: 'Delivered',
        subtitle: 'Your order has been delivered',
        dateTime: deliveredAt,
        isCompleted: true,
        icon: 'home',
      ));
    } else {
      events.add(OrderTimelineEvent(
        title: 'Delivered',
        subtitle: 'Awaiting delivery',
        dateTime: null,
        isCompleted: false,
        icon: 'home',
      ));
    }
    return events;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'items': items.map((i) => i.toJson()).toList(),
        'deliveryAddress': deliveryAddress.toJson(),
        'paymentMethod': paymentMethod,
        'subtotal': subtotal,
        'shippingFee': shippingFee,
        'discount': discount,
        'total': total,
        'status': status,
        'placedAt': placedAt.toIso8601String(),
        'confirmedAt': confirmedAt?.toIso8601String(),
        'shippedAt': shippedAt?.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'cancelledAt': cancelledAt?.toIso8601String(),
        'trackingNumber': trackingNumber,
        'promoCode': promoCode,
        'notes': notes,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] ?? '',
        orderNumber: json['orderNumber'] ?? '',
        items: (json['items'] as List? ?? [])
            .map((i) => CartItemModel.fromJson(i))
            .toList(),
        deliveryAddress: AddressModel.fromJson(json['deliveryAddress'] ?? {}),
        paymentMethod: json['paymentMethod'] ?? '',
        subtotal: (json['subtotal'] ?? 0).toDouble(),
        shippingFee: (json['shippingFee'] ?? 0).toDouble(),
        discount: (json['discount'] ?? 0).toDouble(),
        total: (json['total'] ?? 0).toDouble(),
        status: json['status'] ?? '',
        placedAt: DateTime.parse(json['placedAt'] ?? DateTime.now().toIso8601String()),
        confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt']) : null,
        shippedAt: json['shippedAt'] != null ? DateTime.parse(json['shippedAt']) : null,
        deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
        cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
        trackingNumber: json['trackingNumber'],
        promoCode: json['promoCode'],
        notes: json['notes'],
      );
}

class OrderTimelineEvent {
  final String title;
  final String subtitle;
  final DateTime? dateTime;
  final bool isCompleted;
  final String icon;

  OrderTimelineEvent({
    required this.title,
    required this.subtitle,
    this.dateTime,
    required this.isCompleted,
    required this.icon,
  });
}
