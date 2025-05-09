import 'package:app_chan_doan/connection_manage.dart';
import 'package:app_chan_doan/data_chart/radar_chart.dart';
import 'package:app_chan_doan/diagnostic/diagnostic_page.dart';
import 'package:app_chan_doan/diagnostic/search_dtc.dart';
import 'package:app_chan_doan/gps_tracker/map.dart';
import 'package:app_chan_doan/login_page.dart';
import 'package:app_chan_doan/mode_1/mode_1_first_page.dart';
import 'package:app_chan_doan/mode_4/mode_4_first_page.dart';
import 'package:app_chan_doan/mode_6/mode_6_page.dart';
import 'package:app_chan_doan/mode_9/module_information_page.dart';
import 'package:app_chan_doan/mqtt.dart';
import 'package:app_chan_doan/training_code/steering_wheel.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 145, 220, 255),
          title: const Text('Danh mục'),
          titleTextStyle: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.white,
        body: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          padding: const EdgeInsets.all(4.0),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          children: <Widget>[
            _buildButton(
                context,
                "Đọc số VIN",
                'assets/images/Module_Information.png',
                const ModuleInformationPage()),
            _buildButton(context, "OBD Test", 'assets/images/OBD_Test.png',
                const Mode6Page()),
            _buildButton(context, "Đọc dữ liệu của xe",
                'assets/images/Read_Stream_Data.png', const Mode1FirstPage()),
            _buildButton(context, "Đồ thị radar",
                'assets/images/Radar_Chart.png', const RadarChartPage()),
            _buildButton(context, "Kiểm tra cơ cấu chấp hành",
                'assets/images/Actuators_Test.png', const Mode4FirstPage()),
            _buildButton(context, "Đọc lỗi DTC", 'assets/images/Diagnostic.png',
                const DiagnosticPage()),
            _buildButton(context, "Tìm kiếm thông tin DTC",
                'assets/images/Search_DTC.png', const SearchDTCPage()),
            _buildButton(context, "Góc quay vô lăng",
                'assets/images/logoGT.png', const SteeringWheel()),
            _buildButton(context, "Theo dõi GPS",
                'assets/images/GPS_Tracker.png', const GPSPage()),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
                mqtt.publish('{"disconnect":$id}');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(
                      color: Color.fromARGB(255, 0, 0, 0), width: 3),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shadowColor: Colors.black.withValues(alpha: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 183, 183, 183)
                              .withValues(alpha: 0),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/logout.png',
                        width: 80, height: 80),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Đăng xuất",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, String iconPath, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 3),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 183, 183, 183)
                      .withValues(alpha: 0),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Image.asset(iconPath, width: 80, height: 80),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
