import 'dart:convert';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_demo/models/push_notification.dart';
import 'package:overlay_support/overlay_support.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  var notificationSettings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${notificationSettings.authorizationStatus}');

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  print(message.data);
  // print(message.);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Flutter X Firebase Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

// end main

// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String token) {
  _messageCount++;
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = "Hello World";

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getToken().then((token) {

      print(token);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        // Navigator.pushNamed(context, '/message',
        //     arguments: MessageArguments(message, true));
        print("\nMessage :\n");
        print(message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        print("\nnotification.hashCode :\n");
        print(notification.hashCode);
        print("\nnotification.title :\n");
        print(notification.title);
        print("\nnotification.body :\n");
        print(notification.body);
        setState(() {
          text = notification.body;
          print(text);
          print("\nHello :\n");

        });
        print("\nworld :\n");
        // flutterLocalNotificationsPlugin.show(
        //     notification.hashCode,
        //     notification.title,
        //     notification.body,
        //     NotificationDetails(
        //       android: AndroidNotificationDetails(
        //         channel.id,
        //         channel.name,
        //         channel.description,
        //         // TODO add a proper drawable resource to android, for now using
        //         //      one that already exists in example app.
        //         icon: 'launch_background',
        //       ),
        //     ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('\nA new onMessageOpenedApp event was published!');
      print(message);
      // Navigator.pushNamed(context, '/message',
      //     arguments: MessageArguments(message, true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Cloud Messaging'),
      //   actions: <Widget>[
      //     PopupMenuButton(
      //       onSelected: (item){},
      //       itemBuilder: (BuildContext context) {
      //         return [
      //           const PopupMenuItem(
      //             value: 'subscribe',
      //             child: Text('Subscribe to topic'),
      //           ),
      //           const PopupMenuItem(
      //             value: 'unsubscribe',
      //             child: Text('Unsubscribe to topic'),
      //           ),
      //           const PopupMenuItem(
      //             value: 'get_apns_token',
      //             child: Text('Get APNs token (Apple only)'),
      //           ),
      //         ];
      //       },
      //     ),
      //   ],
      // ),
      // floatingActionButton: Builder(
      //   builder: (context) => FloatingActionButton(
      //     // onPressed: sendPushMessage,
      //     onPressed: (){},
      //     backgroundColor: Colors.white,
      //     child: const Icon(Icons.send),
      //   ),
      // ),
      body: Center(child: Text(text)),
      // body: SingleChildScrollView(
      //   child: Column(children: [
      //     MetaCard('Permissions', Permissions()),
      //     MetaCard('FCM Token', TokenMonitor((token) {
      //       _token = token;
      //       return token == null
      //           ? const CircularProgressIndicator()
      //           : Text(token, style: const TextStyle(fontSize: 12));
      //     })),
      //     MetaCard('Message Stream', MessageList()),
      //   ]),
      // ),
    );
  }
}



/// UI Widget for displaying metadata.
class MetaCard extends StatelessWidget {
  final String _title;
  final Widget _children;

  // ignore: public_member_api_docs
  MetaCard(this._title, this._children);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child:
                      Text(_title, style: const TextStyle(fontSize: 18))),
                  _children,
                ]))));
  }
}