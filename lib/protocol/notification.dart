import 'package:flutter/foundation.dart';
import 'package:lime/protocol/enums/event.enum.dart';
import 'package:lime/protocol/envelope.dart';
import 'package:lime/protocol/node.dart';
import 'package:lime/protocol/reason.dart';

class Notification extends Envelope {
  static const String eventKey = "event";
  static const String reasonKey = "reason";

  Notification(
      {final String? id,
      final Node? from,
      final Node? to,
      final Node? pp,
      this.event,
      this.reason})
      : super(id: id, from: from, to: to, pp: pp);

  /// Related event to the notification
  Event? event;

  /// In the case of a failed event, brings more details about the problem.
  Reason? reason;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> notification = {};

    if (id != null) {
      notification['id'] = id;
    }

    if (from != null) {
      notification['from'] = from.toString();
    }

    if (to != null) {
      notification['to'] = to.toString();
    }

    if (event != null) {
      notification[eventKey] = describeEnum(event!);
    }

    if (reason != null) {
      notification[reasonKey] = describeEnum(reasonKey);
    }

    return notification;
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    final notification = Notification(
      id: json.containsKey('id') ? json['id'] : null,
      from: json.containsKey('from') ? Node.parse(json['from']) : null,
      to: json.containsKey('to') ? Node.parse(json['to']) : null,
      pp: json.containsKey('pp') ? Node.parse(json['pp']) : null,
    );

    if (json.containsKey(reasonKey)) {
      notification.reason = Reason.fromJson(json[reasonKey]);
    }
    if (json.containsKey(eventKey)) {
      notification.event =
          Event.values.firstWhere((e) => describeEnum(e) == json[eventKey]);
    }

    return notification;
  }
}
