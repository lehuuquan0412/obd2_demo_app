// ignore_for_file: use_build_context_synchronously

import 'package:app_chan_doan/connection_manage.dart';
import 'package:app_chan_doan/menu_page.dart';
import 'package:app_chan_doan/mqtt.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class SeriPage extends StatefulWidget {
  const SeriPage({super.key});

  @override
  State<SeriPage> createState() {
    return _SeriPageState();
  }
}

class _SeriPageState extends State<SeriPage> {
  final _seriController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _databaseRef = FirebaseDatabase.instance.ref();
  late StreamSubscription _subscription;
  String? initialStatus;
  bool _isNavigated = false;

  void _startListening() {
    _subscription = _databaseRef
        .child('${_seriController.text}/status')
        .onValue
        .listen((event) {
      var status = event.snapshot.value.toString();
      setState(() {
        initialStatus ??= status;
      });
      _handleFirebaseStatus(status);
    });
  }

  Future<void> _handleFirebaseStatus(String status) async {
    if (_isNavigated) return;

    if (status == 'connected' && initialStatus == 'connected') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Dialog(
            insetPadding: EdgeInsets.fromLTRB(50, 250, 50, 300),
            child: Center(
              child: Text('Thiết bị đã được kết nối với một tài khoản khác.',
                  style: TextStyle(fontSize: 18)),
            ),
          );
        },
      );
      await Future.delayed(const Duration(seconds: 3));
      _goBackToButtonScreen();
    } else if (status == 'disconnect') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Dialog(
            insetPadding: EdgeInsets.fromLTRB(50, 250, 50, 300),
            child: Center(
              child:
                  Text('Thiết bị ngoại tuyến.', style: TextStyle(fontSize: 18)),
            ),
          );
        },
      );
      await Future.delayed(const Duration(seconds: 3));
      _goBackToButtonScreen();
    } else if (status == 'free') {
      initialStatus = 'free';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Dialog(
            insetPadding: EdgeInsets.fromLTRB(50, 250, 50, 300),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
      await Future.delayed(const Duration(seconds: 10));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      String latestStatus =
          (await _databaseRef.child('${_seriController.text}/status').once())
              .snapshot
              .value
              .toString();

      if (latestStatus == 'connected' && initialStatus == 'free') {
        verifyId = _seriController.text;
        _navigateToNextPage();
      } else {
        _goBackToButtonScreen();
      }
    } else if (status != 'connected') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            insetPadding: EdgeInsets.fromLTRB(50, 250, 50, 300),
            child: Center(
              child: Text('Không có dữ liệu.', style: TextStyle(fontSize: 18)),
            ),
          );
        },
      );
      await Future.delayed(const Duration(seconds: 2));
      _goBackToButtonScreen();
    }
  }

  void _goBackToButtonScreen() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _navigateToNextPage() {
    _subscription.cancel();
    _isNavigated = true;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MenuPage()),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 190, 235, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                const Text(
                  'Vui lòng nhập mã thiết bị để kết nối',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 50),
                TextFormField(
                  controller: _seriController,
                  decoration: const InputDecoration(labelText: 'Mã thiết bị'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 9, 9, 9),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child:
                      const Text('OK', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _startListening();
                    mqtt.publish('{"connect":$id}');
                  },
                ),
                Center(
                  child: Image.asset(
                    'assets/images/Xpander.png',
                    width: 600,
                    height: 400,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
