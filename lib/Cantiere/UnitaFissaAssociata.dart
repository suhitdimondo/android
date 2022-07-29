import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hr_app/TimbPages/timbratureListWinit.dart';

import '../Model/Cantieri.dart';
import '../Model/Internet.dart';
import 'CantiereWinit.dart';

class DescrizioneCantiere extends StatefulWidget {
  final List<Cantiere> items;
  final bool internet;
  final String code;

  const DescrizioneCantiere({this.items, this.code, this.internet});

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

String string = "";

class _MultiSelectState extends State<DescrizioneCantiere> {
  Checkinternet objectinternet = Checkinternet();
  List _journals = [];
  List<String> data = [];
  List unitafissa = [];
  bool internet;

  _refreshJournals() async {
    internet = await checkinternet();
    if (internet == true) {
      List data = await dbHelper.getCantiereList();
      setState(() {
        _journals = data;
      });
    } else {
      List res = await dbHelper.select_cantieri();
      setState(() {
        for (int i = 0; i < res.length; i++) {
          _journals.add(res[i]["DescrizioneCantiere"]);
        }
      });
    }
  }

  checkinternet() async {
    return await objectinternet.checkConnectivityState();
  }

  List _selectedItems = [];

  @override
  void initState() {
    _refreshJournals();
    checkinternet();
    super.initState();
  }

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  void _reset() {
    _selectedItems.clear();
    Navigator.pop(context);
  }

  String selectedValue = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Descrizione Cantiere'),
        content: SingleChildScrollView(
            child: Container(
          child: Row(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton2(
                  isExpanded: true,
                  hint: Row(
                    children: const [
                      Icon(
                        Icons.list,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Text(
                          'CODICE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  items: _journals
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  value: selectedValue.isNotEmpty ? selectedValue : null,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value.toString();
                      _itemChange(selectedValue, true);
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios_outlined,
                  ),
                  iconSize: 14,
                  iconEnabledColor: Colors.white,
                  iconDisabledColor: Colors.grey,
                  buttonHeight: 50,
                  buttonWidth: MediaQuery.of(context).size.width * 0.60,
                  buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                  buttonDecoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                    color: Colors.blue,
                  ),
                  buttonElevation: 2,
                  itemHeight: 40,
                  dropdownMaxHeight: 200,
                  dropdownWidth: MediaQuery.of(context).size.width * 0.60,
                  dropdownPadding: null,
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.black,
                  ),
                  dropdownElevation: 8,
                  scrollbarRadius: const Radius.circular(40),
                  scrollbarThickness: 6,
                  scrollbarAlwaysShow: true,
                  offset: const Offset(0, 0),
                ),
              ),
            ],
          ),
        )),
        actions: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.67,
              child: Container(
                  child: Row(children: [
                ElevatedButton(
                  child: const Text('INVIA'),
                  onPressed: () async {
                    unitafissa = await dbHelper
                        .select_decrizione_cantieri(selectedValue);
                    for (int i = 0; i < unitafissa.length; i++) {
                      selectedValue = unitafissa[i]["UnitaFissaAssociata"];
                    }
                    print(selectedValue);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Cantieri(
                          fissa: this.selectedValue,
                          internet: widget.internet,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  child: Row(
                    children: [],
                  ),
                  margin: EdgeInsets.all(27.0),
                ),
                ElevatedButton(
                  child: const Text('ANNULLA'),
                  onPressed: _reset,
                ),
              ])))
        ]);
  }
}
