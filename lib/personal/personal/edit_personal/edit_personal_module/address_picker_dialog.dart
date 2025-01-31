import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChineseAddressPickerDialog extends StatefulWidget {
  @override
  _ChineseAddressPickerDialogState createState() =>
      _ChineseAddressPickerDialogState();
}

class _ChineseAddressPickerDialogState
    extends State<ChineseAddressPickerDialog> {
  final List<String> provinces = ['北京', '上海', '广东', '浙江', '江苏'];
  final List<String> cities = ['广州', '深圳', '珠海', '佛山', '东莞'];
  final List<String> areas = ['天河区', '越秀区', '海珠区', '荔湾区', '白云区'];

  int selectedProvinceIndex = 0;
  int selectedCityIndex = 0;
  int selectedAreaIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        height: 300.0,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedProvinceIndex = index;
                  });
                },
                children: provinces.map((String province) {
                  return Center(child: Text(province));
                }).toList(),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedCityIndex = index;
                  });
                },
                children: cities.map((String city) {
                  return Center(child: Text(city));
                }).toList(),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedAreaIndex = index;
                  });
                },
                children: areas.map((String area) {
                  return Center(child: Text(area));
                }).toList(),
              ),
            ),
            CupertinoButton(
              child: Text('确定'),
              onPressed: () {
                String selectedAddress =
                    '${provinces[selectedProvinceIndex]} ${cities[selectedCityIndex]} ${areas[selectedAreaIndex]}';
                print('选择的地址: $selectedAddress');
                Navigator.of(context).pop(selectedAddress);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 使用弹窗
void showChineseAddressPickerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ChineseAddressPickerDialog();
    },
  ).then((selectedAddress) {
    if (selectedAddress != null) {
      // 处理选择的地址
      print('用户选择的地址: $selectedAddress');
    }
  });
}
