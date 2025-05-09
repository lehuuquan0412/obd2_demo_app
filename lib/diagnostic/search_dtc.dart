// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchDTCPage extends StatefulWidget {
  const SearchDTCPage({super.key});

  @override
  State<SearchDTCPage> createState() {
    return _SearchDTCPageState();
  }
}

class _SearchDTCPageState extends State<SearchDTCPage> {
  DocumentSnapshot? _currentDocument;

  void _searchDTC(String dtcCode) {
    FirebaseFirestore.instance
        .collection('dtc_codes')
        .doc(dtcCode)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          _currentDocument = document;
        });
      } else {
        setState(() {
          _currentDocument = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Không tìm thấy dữ liệu cho mã DTC này')));
      }
    }).catchError((e) {
      print('Lỗi tải tài liệu: $e');
    });
  }

  Future<List<String>> searchDtcCodes(String query) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot snapshot = await firestore
          .collection('dtc_codes')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: query)
          .where(FieldPath.documentId, isLessThan: '${query}z')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Lỗi tải dữ liệu: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tìm kiếm thông tin DTC',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 145, 220, 255),
        leading: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, result) {
            if (didPop) {
              return;
            }
            Navigator.of(context).pop();
          },
          child: BackButton(
            color: Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 2.0,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                } else {
                  return await searchDtcCodes(textEditingValue.text);
                }
              },
              onSelected: (String selection) {
                _searchDTC(selection);
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Hãy nhập mã lỗi',
                    labelStyle:
                        const TextStyle(color: Colors.black, fontSize: 20),
                    suffixIcon: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 30,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(172, 188, 185, 190), width: 5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 165, 145, 185), width: 5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: Container(
                      width: 360,
                      height: 300,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 222, 218, 218),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 177, 172, 172)
                                .withValues(alpha: 0.7),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red)),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                children: _currentDocument != null ? _buildDocumentView() : [],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Lưu ý: Hãy viết hoa chữ cái đầu tiên của mã lỗi",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 100, 100, 100),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDocumentView() {
    List<Widget> list = [
      const SizedBox(height: 20),
    ];
    list.add(_buildSectionContainer(
        "Tên", _getDataField('name', 'Không có dữ liệu')));
    list.add(_buildSectionContainer(
        "Mô tả", _getDataField('description', 'Không có dữ liệu')));
    list.add(_buildSectionContainer(
        "Triệu chứng", _getDataField('symptoms', 'Không có dữ liệu')));
    list.add(_buildSectionContainer(
        "Cách xử lý", _getDataField('repair tips', 'Không có dữ liệu')));
    return list;
  }

  Widget _buildSectionContainer(String title, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 200, 200, 200),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSectionTitle(title), _buildTextItem(text)],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color.fromARGB(255, 50, 20, 200),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextItem(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    );
  }

  String _getDataField(String field, String defaultValue) {
    if (_currentDocument != null &&
        _currentDocument!.data() is Map<String, dynamic>) {
      var data = _currentDocument!.data() as Map<String, dynamic>;
      return data[field] ?? defaultValue;
    }
    return defaultValue;
  }
}
