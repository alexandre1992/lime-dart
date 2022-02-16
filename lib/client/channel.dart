import 'package:lime/network/transport.dart';
import 'package:lime/protocol/command.dart';
import 'package:lime/protocol/enums/command_method.enum.dart';
import 'package:lime/protocol/enums/command_status.enum.dart';
import 'package:lime/protocol/enums/session_state.enum.dart';
import 'package:lime/protocol/envelope.dart';
import 'package:lime/protocol/message.dart';
import 'package:lime/protocol/notification.dart';
import 'package:lime/protocol/session.dart';

abstract class Channel {
  final Transport transport;
  final bool autoReplyPings;
  final bool autoNotifyReceipt;

  String? remoteNode;
  String? localNode;
  String? sessionId;
  SessionState? state;

  Channel({
    required this.transport,
    this.autoReplyPings = true,
    this.autoNotifyReceipt = false,
  }) {
    state = SessionState.isNew;

    transport.onEvelope?.stream.listen(
      (event) {
        print('event received on channel: $event\n');

        if (event.containsKey('state')) {
          print('envelope is session');
          final session = Session.fromJson(event);
          onSession(session);
        } else if (event.containsKey('method')) {
          print('envelope is command');
          final command = Command.fromJson(event);

          if ( //_isForMe(command) &&
              autoReplyPings &&
                  command.id != null &&
                  command.uri == '/ping' &&
                  command.method == CommandMethod.get) {
            print('auto reply ping');

            final commandSend = Command(
                id: command.id,
                to: command.from,
                method: CommandMethod.get,
                status: CommandStatus.success,
                type: 'application/vnd.lime.ping+json',
                resource: {});

            sendCommand(commandSend);
          }

          onCommand(command);
        } else if (event.containsKey('content')) {
          print('envelope is message');
          final message = Message.fromJson(event);
          onMessage(message);
        } else if (event.containsKey('event')) {
          print('envelope is notification');
          final notification = Notification.fromJson(event);
          onNotification(notification);
        }

        print('\n-------------------------------------------------------\n');
      },
      onError: (e) => print('stream error: $e'),
      onDone: () => print('stream done'),
    );
  }

  Future<void> open() async {
    await transport.open();
  }

  Future<void> sendSession(Session session) {
    if (state == SessionState.finished || state == SessionState.failed) {
      throw Exception('Cannot send in the $state state');
    }
    return send(session);
  }

  Future<void> sendCommand(Command command) {
    if (state != SessionState.established) {
      throw Exception('Cannot send in the $state state');
    }
    return send(command);
  }

  Future<void> sendNotification(Notification notification) {
    if (state != SessionState.established) {
      throw Exception('Cannot send in the $state state');
    }
    return send(notification);
  }

  Future<void> sendMessage(Message message) {
    if (state != SessionState.established) {
      throw Exception('Cannot send in the $state state');
    }
    return send(message);
  }

  send(Envelope envelope) async {
    await transport.send(envelope);
  }

  bool _isForMe(Envelope envelope) {
    bool isforme = envelope.to == null ||
        envelope.to.toString() == localNode ||
        localNode!.substring(0, envelope.to.toString().length) ==
            envelope.to.toString();
    return isforme;
  }

  void onMessage(Message message) {}
  void onSession(Session session) {}
  void onNotification(Notification notification) {}
  void onCommand(Command command) {}
}
