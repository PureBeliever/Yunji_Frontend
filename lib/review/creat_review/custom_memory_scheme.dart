import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_module/default_cupertion.dart';

class CustomMemoryScheme extends StatefulWidget {
  const CustomMemoryScheme({super.key});

  @override
  State<CustomMemoryScheme> createState() => _CustomMemoryScheme();
}

class Item {
  Item({
    required this.dateByDays,
    required this.dateByMinute,
    required this.numberOfReviews,
  });

  String dateByDays;
  String dateByMinute;
  String numberOfReviews;
}

class _CustomMemoryScheme extends State<CustomMemoryScheme> {
  List<Item> _itemList = [];

  late DateTime now;
  late String dateByDays;
  late String dateByMinute;
  late String dateByDaysSelect;
  late String dateByMinuteSelect;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    dateByDays = DateFormat('yyyy年MM月dd日').format(now);
    dateByMinute = DateFormat('HH:mm').format(now);

    _itemList.add(Item(
        dateByDays: dateByDays,
        dateByMinute: dateByMinute,
        numberOfReviews: '进行第1次复习'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          '自定义记忆方案',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.check,
              size: 30,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              '本次学习后',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _itemList.length + 1,
              itemBuilder: (context, index) {
                if (index == _itemList.length) {
                  return Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 100, right: 100),
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                            color: Color.fromRGBO(84, 87, 105, 1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _itemList.add(Item(
                              dateByDays: dateByDays,
                              dateByMinute: dateByMinute,
                              numberOfReviews:
                                  '进行第${_itemList.length + 1}次复习'));
                        });
                      },
                      child: const Icon(
                        Icons.add,
                        color: Color.fromRGBO(84, 87, 105, 1),
                      ),
                    ),
                  );
                } else {
                  return ListTile(
                    title: _buildItem(_itemList[index]),
                    trailing: GestureDetector(
                      onTap: () {
                        setState(() {
                          _itemList.removeAt(index);
                          _itemList.forEach((element) {
                            element.numberOfReviews =
                                '进行第${_itemList.indexOf(element) + 1}次复习';
                          });
                        });
                      },
                      child: const Icon(
                        color: Colors.black,
                        Icons.remove,
                        size: 26,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future _buildDatePickerDialog(BuildContext context, Item item) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: SizedBox(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    child: Localizations.override(
                      context: context,
                      locale: const Locale('en'),
                      delegates: const [
                        MyDefaultCupertinoLocalizations.delegate
                      ],
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        minimumDate: now,
                        maximumDate: DateTime(now.year + 10, 12, 31),
                        initialDateTime: now,
                        dateOrder: DatePickerDateOrder.ymd,
                        onDateTimeChanged: (date) {
                          dateByDaysSelect =
                              DateFormat('yyyy年MM月dd日').format(date);
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            item.dateByDays = dateByDaysSelect;
                          });
                        },
                        child: const Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future _buildDatePickerDialogMinute(BuildContext context, Item item) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: SizedBox(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    child: Localizations.override(
                      context: context,
                      locale: const Locale('en'),
                      delegates: const [
                        MyDefaultCupertinoLocalizations.delegate
                      ],
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                        onDateTimeChanged: (date) {
                          dateByMinuteSelect = DateFormat('HH:mm').format(date);
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            item.dateByMinute = dateByMinuteSelect;
                          });
                        },
                        child: const Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildItem(Item item) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            _buildDatePickerDialog(context, item);
          },
          child: Text(item.dateByDays,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(84, 87, 105, 1),
              )),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(left: 10, right: 10),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color.fromRGBO(84, 87, 105, 1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0, // 消除阴影
          ),
        ),
        const SizedBox(width: 5),
        ElevatedButton(
          onPressed: () {
            _buildDatePickerDialogMinute(context, item);
          },
          child: Text(item.dateByMinute,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(84, 87, 105, 1),
              )),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(left: 10, right: 10),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color.fromRGBO(84, 87, 105, 1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0, // 消除阴影
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            item.numberOfReviews,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
