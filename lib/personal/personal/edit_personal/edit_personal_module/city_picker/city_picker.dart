import 'dart:core';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:yunji/main/global.dart';

import 'province.dart' as meta;
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';

class ScrollPicker extends StatelessWidget {
  final List<String>? itemList;
  final Key? key;
  final String? value;
  final bool isShow;
  final FixedExtentScrollController? controller;
  final ValueChanged<int> changed;
  final ItemWidgetBuilder? itemBuilder;

  // ios选择框的高度. 配合 itemBuilder中的字体使用.
  final double? itemExtent;
  // Constructor. {} here denote that they are optional values i.e you can use as: new MyCard()
  ScrollPicker(
      {this.key,
      this.controller,
      this.isShow = false,
      required this.changed,
      this.itemList,
      this.itemExtent,
      this.itemBuilder,
      this.value});

  @override
  Widget build(BuildContext context) {
    if (!this.isShow) {
      return Container();
    }
    if (this.itemList == null || this.itemList!.isEmpty) {
      return new Expanded(
        child: Container(),
      );
    }
    return new Expanded(
      child: new Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(6.0),
          alignment: Alignment.center,
          child: CupertinoPicker.builder(
              magnification: 1.0,
              itemExtent: this.itemExtent ?? 40.0,
              backgroundColor: AppColors.background,
              scrollController: this.controller,
              onSelectedItemChanged: (index) {
                this.changed(index);
              },
              itemBuilder: (context, index) {
                if (this.itemBuilder != null) {
                  return this.itemBuilder!(
                      this.itemList![index], this.itemList!, index);
                }

                String text = this.itemList![index];

                // TODO 根据字数调整字体大小，不够优雅，可以改为根据函数计算字体大小
                double fontSize = 13;
                if (text != '') {
                  int len = text.length;
                  if (len >= 1 && len <= 3) {
                    fontSize = 20;
                  } else if (len > 3 && len <= 4) {
                    fontSize = 18;
                  } else if (len > 4 && len <= 5) {
                    fontSize = 16;
                  } else if (len > 5 && len <= 6) {
                    fontSize = 12;
                  } else if (len > 6 && len <= 9) {
                    fontSize = 10;
                  } else if (len > 9) {
                    fontSize = 7;
                  }
                }
                return Center(
                  child: Text(
                    '$text',
                    overflow: TextOverflow.ellipsis, // 字数过多时显示省略号
                    maxLines: 1,
                    style: TextStyle(fontSize: fontSize),
                  ),
                );
              },
              childCount: this.itemList!.length)),
      flex: 1,
    );
  }
}

// 显示类型
enum Mods {
  Province,
  Area,
  City,
  Village, // 增加第4级(村/镇)选择
}

abstract class ShowTypeGeometry {
  const ShowTypeGeometry();
}

class ShowType extends ShowTypeGeometry {
  final List<Mods> typesList;

  const ShowType(this.typesList);

  static const ShowType p = ShowType([Mods.Province]);
  static const ShowType c = ShowType([Mods.City]);
  static const ShowType a = ShowType([Mods.Area]);
  static const ShowType v = ShowType([Mods.Village]); // 增加第4级(村/镇)选择
  static const ShowType pc = ShowType([Mods.Province, Mods.City]);
  static const ShowType pca = ShowType([Mods.Province, Mods.City, Mods.Area]);
  static const ShowType pcav = ShowType(
      [Mods.Province, Mods.City, Mods.Area, Mods.Village]); // 增加第4级(村/镇)选择
  static const ShowType ca = ShowType([Mods.Area, Mods.City]);
  static const ShowType cav =
      ShowType([Mods.Area, Mods.City, Mods.Village]); // 增加第4级(村/镇)选择

  ShowType operator +(ShowType others) {
    typesList.addAll(others.typesList);
    return ShowType(typesList);
  }

  bool contain(ShowType other) {
    for (Mods m in other.typesList) {
      if (!typesList.contains(m)) {
        return false;
      }
    }
    return true;
  }
}

class InheritRouteWidget extends InheritedWidget {
  final CityPickerRoute router;

  InheritRouteWidget({Key? key, required this.router, required Widget child})
      : super(key: key, child: child);

  static InheritRouteWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }

  @override
  bool updateShouldNotify(InheritRouteWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return oldWidget.router != router;
  }
}

class CityPickerRoute<T> extends PopupRoute<T> {
  final ThemeData? theme;
  final String? barrierLabel;
  final bool canBarrierDismiss;
  final Widget child;
  final double barrierOpacity;

  CityPickerRoute({
    this.theme,
    required this.child,
    this.canBarrierDismiss = true,
    this.barrierOpacity = 0.5,
    this.barrierLabel,
  });

  @override
  Duration get transitionDuration => Duration(milliseconds: 2000);

  @override
  @override
  Color get barrierColor => Color.fromRGBO(0, 0, 0, barrierOpacity);

  @override
  bool get barrierDismissible => canBarrierDismiss;

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = new MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: InheritRouteWidget(router: this, child: child));
    if (theme != null) {
      bottomSheet = new Theme(data: theme!, child: bottomSheet);
    }
    return bottomSheet;
  }
}

class CityTree {
  /// build cityTrees's meta, it can be changed bu developers
  Map<String, dynamic> metaInfo;

  /// provData user self-defining data
  Map<String, String>? provincesInfo;
  Cache _cache = new Cache();

  /// the tree's modal
  /// data = Point(
  ///   letter,
  ///   name
  ///   code,
  ///   letter,
  ///   child: [
  ///     Point
  ///   ]
  /// )
  /// data = [
  ///   {
  ///     letter: 'Z',
  ///     name: '浙江',
  ///     code: 330000
  ///     child: [
  ///       letter: 'h',
  ///       name: '杭州',
  ///       child
  ///     ]
  ///   }
  /// ]
  late Point tree;

  /// @param metaInfo city and areas meta describe
  CityTree({this.metaInfo = meta.citiesData, this.provincesInfo});

  Map<String, String> get _provincesData =>
      this.provincesInfo ?? meta.provincesData;

  /// build tree by int provinceId,
  /// @param provinceId this is province id
  /// @return tree
  Point initTree(String provinceId) {
    String _cacheKey = provinceId;
//    这里为了避免 https://github.com/hanxu317317/city_pickers/issues/68
//    if (_cache.has(_cacheKey)) {
//      return tree = _cache.get(_cacheKey);
//    }

    String name = this._provincesData[provinceId]!;
    String letter = PinyinHelper.getFirstWordPinyin(name).substring(0, 1);
    var root =
        new Point(code: provinceId, letter: letter, children: [], name: name);
    tree = _buildTree(root, metaInfo[provinceId], metaInfo);
    _cache.set(_cacheKey, tree);
    return tree;
  }

  /// this is a private function, used the return to get a correct tree contain cities and areas
  /// @param code one of province city or area id;
  /// @return provinceId return id which province's child contain code
  String? _getProvinceByCode(String code) {
    String _code = code.toString();
    List<String> keys = metaInfo.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      Map<String, dynamic> child = metaInfo[key];
      if (child.containsKey(_code)) {
        // 当前元素的父key在省份内
        if (this._provincesData.containsKey(key)) {
          return key;
        }
        return _getProvinceByCode(key);
      }
    }
    return null;
  }

  /// build tree by any code provinceId or cityCode or areaCode
  /// @param code build a tree
  /// @return Point a province with its cities and areas tree
  Point initTreeByCode(String code) {
    String _code = code.toString();
    if (this._provincesData[_code] != null) {
      return initTree(code);
    }
    String? provinceId = _getProvinceByCode(code);
    if (provinceId != null) {
      return initTree(provinceId);
    }
    return Point.nullPoint();
//    return Point.nullPoint;
  }

  /// private function
  /// recursion to build tree
  Point _buildTree(Point target, Map<String, dynamic>? citys, Map meta) {
    if (citys == null || citys.isEmpty) {
      return target;
    } else {
      List<String> keys = citys.keys.toList();

      for (int i = 0; i < keys.length; i++) {
        String key = keys[i];
        Map value = citys[key];
        Point _point = new Point(
          code: key,
          letter: value['alpha'],
          children: [],
          name: value['name'],
          isClassificationNode: value['isClassificationNode'] ?? false,
        );

        // for avoid the data  error that such as
        //  "469027": {
        //        "469027": {
        //            "name": "乐东黎族自治县",
        //            "alpha": "l"
        //        }
        //    }
        if (citys.keys.length == 1) {
          if (target.code.toString() == citys.keys.first) {
            continue;
          }
        }

        _point = _buildTree(_point, meta[key], meta);
        target.addChild(_point);
      }
    }
    return target;
  }
}

/// Province Class
class Provinces {
  Map<String, String> metaInfo;

  // 是否将省份排序, 进行排序
  bool sort;

  Provinces({this.metaInfo = meta.provincesData, this.sort = true});

  // 获取省份数据
  get provinces {
    List<Point> provList = [];
    List<String> keys = metaInfo.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      String name = metaInfo[keys[i]]!;
      provList.add(Point(
          code: keys[i],
          children: [],
          letter: PinyinHelper.getFirstWordPinyin(name).substring(0, 1),
          name: name));
    }
    if (this.sort == true) {
      provList.sort((Point a, Point b) {
        if (a.letter == null && b.letter == null) {
          return 0;
        }

        if (a.letter == null) {
          return 1;
        }

        return a.letter!.compareTo(b.letter!);
      });
    }

    return provList;
  }
}

class Point {
  static final _pinyinPlaceholder = new Pinyin._([], '', '');

  final String? code;
  final List<Point> children;
  final int? depth;
  final String? letter;
  final String name;

  /// Just a classification node, not corresponding to the actual region.
  final bool isClassificationNode;

  Point.nullPoint()
      : children = [],
        name = '',
        isClassificationNode = false,
        code = null,
        depth = null,
        letter = null;

  bool get isNull => this.code == null;

  Point({
    this.code = '0',
    required this.children,
    this.depth,
    String? letter,
    this.name = '',
    this.isClassificationNode = false,
  }) : letter = letter?.toUpperCase();

  String? _lowerCaseName;
  String get lowerCaseName => _lowerCaseName ??= name.toLowerCase();

  Pinyin? _pinyin = _pinyinPlaceholder;
  Pinyin? get pinyin {
    if (identical(_pinyin, _pinyinPlaceholder)) {
      _pinyin = Pinyin.tryParse(name);
    }
    return _pinyin;
  }

  /// add node for Point, the node's type must is [Point]
  addChild(Point node) {
    this.children.add(node);
  }

  @override
  String toString() {
    return "Point {code: $code, name: $name, letter: $letter, child: Array & length = ${children.length}";
  }
}

class Pinyin {
  static Pinyin? tryParse(String text) {
    // TODO: 2022/11/8 ipcjs 处理搜索英文首字母...
    if (text.isEmpty || !ChineseHelper.containsChinese(text)) {
      return null;
    }
    final pinyin = PinyinHelper.getPinyinE(text, separator: ' ', defPinyin: '?')
        .split(' ');

    return Pinyin._(
      pinyin,
      pinyin.join(''),
      pinyin.map((e) => e[0]).join(''),
    );
  }

  final List<String> pinyin;
  final String short;
  final String full;
  const Pinyin._(this.pinyin, this.full, this.short);
}

class Location {
  Map<String, dynamic> citiesData;

  Map<String, String>? provincesData;

  /// the target province user selected
  Point? provincePoint;

  /// the target city user selected
  Point? cityPoint;

  /// the target area user selected
  Point? areaPoint;

  // standby
  // Point village;

  // 没有一次性构建整个以国为根的树. 动态的构建以省为根的树, 效率高.
  // List<Point> provinces;

  Location({required this.citiesData, required this.provincesData});

  Result initLocation(String _locationCode) {
//    print("initLocation >>>> $_locationCode");

    CityTree cityTree =
        new CityTree(metaInfo: citiesData, provincesInfo: provincesData);

    String locationCode;
    Result locationInfo = new Result();
    try {
      locationCode = _locationCode;
    } catch (e) {
      print(ArgumentError(
          "The Argument locationCode must be valid like: '100000' but get '$_locationCode' "));
      return locationInfo;
    }
    provincePoint = cityTree.initTreeByCode(locationCode);

    if (provincePoint?.isNull ?? true) {
      return locationInfo;
    }
    locationInfo.provinceName = provincePoint!.name;
    locationInfo.provinceId = provincePoint!.code.toString();

    provincePoint!.children.forEach((Point _city) {
      if (_city.code == locationCode) {
        cityPoint = _city;
      }

      /// 正常不应该在一个循环中, 如此操作, 但是考虑到地区码的唯一性, 可以在一次双层循环中完成操作. 避免第二层的循环查找
      _city.children.forEach((Point _area) {
        if (_area.code == locationCode) {
          cityPoint = _city;
          areaPoint = _area;
        }
      });
    });

    if (cityPoint != null && !cityPoint!.isNull) {
      locationInfo.cityName = cityPoint!.name;
      locationInfo.cityId = cityPoint!.code.toString();
    }

    if (areaPoint != null && !areaPoint!.isNull) {
      locationInfo.areaName = areaPoint!.name;
      locationInfo.areaId = areaPoint!.code.toString();
    }

    return locationInfo;
  }
}

class CityPickerUtil {
  Map<String, dynamic> citiesData;
  Map<String, String> provincesData;

  CityPickerUtil({required this.citiesData, required this.provincesData});

  Result getAreaResultByCode(String code) {
    Location location =
        new Location(citiesData: citiesData, provincesData: provincesData);
    return location.initLocation(code);
  }
}

/// it's a cache class, aim to reduce calculations;
class Cache {
  Map<String, dynamic> _cache = {};

  // factory
  factory Cache() {
    return _getInstance();
  }

  static Cache get instance => _getInstance();
  static Cache? _instance;

  Cache._();

  void set(String key, dynamic value) {
    _cache[key] = value;
  }

  bool has(String key) {
    return _cache.containsKey(key);
  }

  dynamic get(String key) {
    if (has(key)) {
      return _cache[key];
    }
    return null;
  }

  dynamic remove(String key) {
    if (has(key)) {
      _cache.remove(key);
    }
    return null;
  }

  static Cache _getInstance() {
    if (_instance == null) {
      _instance = new Cache._();
    }
    return _instance!;
  }
}

void setTimeout({required int milliseconds, callback = VoidCallback}) {
  new Timer(Duration(milliseconds: milliseconds), () {
    callback();
  });
}

typedef ItemWidgetBuilder = Widget Function(
    dynamic item, List<dynamic> list, int index);

/// 自定义 城市选择器的头
typedef AppBarBuilder = AppBar Function(String title);

/// CityPicker 返回的 **Result** 结果函数
class Result {
  /// provinceId
  String? provinceId;

  /// cityId
  String? cityId;

  /// areaId
  String? areaId;

  String? villageId; // 增加第4级(村/镇)选择

  /// provinceName
  String? provinceName;

  /// cityName
  String? cityName;

  /// areaName
  String? areaName;

  String? villageName; // 增加第4级(村/镇)选择

  Result({
    this.provinceId,
    this.cityId,
    this.areaId,
    // 增加第4级(村/镇)选择
    this.villageId,
    this.provinceName,
    this.cityName,
    this.areaName,
    // 增加第4级(村/镇)选择
    this.villageName,
  });

  /// string json
  @override
  String toString() {
    //TODO: implement toString
    Map<String, dynamic> obj = {
      'provinceName': provinceName,
      'provinceId': provinceId,
      'cityName': cityName,
      'villageName': villageName, // 增加第4级(村/镇)选择
      'cityId': cityId,
      'areaName': areaName,
      'areaId': areaId,
      'villageId': villageId // 增加第4级(村/镇)选择
    };
    obj.removeWhere((key, value) => value == null || value == 'null');

    return json.encode(obj);
  }
}

class CityPickers {
  /// 插件的静态原始城市数据
  static Map<String, dynamic> metaCities = meta.citiesData;

  /// 插件的静态原始省份数据
  static Map<String, String> metaProvinces = meta.provincesData;

  /// 工具方法，用于获取城市选择器工具类
  static utils(
      {Map<String, String>? provinceData, Map<String, dynamic>? citiesData}) {
    print("CityPickers.metaProvinces::: ${CityPickers.metaCities}");
    return CityPickerUtil(
      provincesData: provinceData ?? CityPickers.metaProvinces,
      citiesData: citiesData ?? CityPickers.metaCities,
    );
  }

  /// 显示城市选择器
  /// @param context 用于导航的BuildContext
  /// @param locationCode 初始选择的代码，可以是省、市或地区的ID
  /// @param height 容器的高度
  /// @param theme 使用的主题，其主色调
  /// @param barrierDismissible 用户是否可以通过点击背景关闭模态框
  /// @param cancelWidget 自定义取消按钮的组件
  /// @param confirmWidget 自定义确认按钮的组件
  /// @param itemBuilder 自定义项目构建器
  /// @param borderRadius 容器的左上和右上圆角，默认为0
  /// @return Result 参见[Result]
  static Future<Result?> showCityPicker(
      {required BuildContext context,
      showType = ShowType.pca,
      double height = 400.0,
      String locationCode = '110000',
      ThemeData? theme,
      Map<String, dynamic>? citiesData,
      Map<String, String>? provincesData,
      bool barrierDismissible = true,
      double barrierOpacity = 0.5,
      ItemWidgetBuilder? itemBuilder,
      double? itemExtent,
      Widget? cancelWidget,
      Widget? confirmWidget,
      double borderRadius = 0,
      bool isSort = false}) {
    return Navigator.of(context, rootNavigator: true).push(
      new CityPickerRoute(
        canBarrierDismiss: barrierDismissible,
        barrierOpacity: barrierOpacity,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        child: BaseView(
          isSort: isSort,
          showType: showType,
          height: height,
          itemExtent: itemExtent,
          itemBuilder: itemBuilder,
          cancelWidget: cancelWidget,
          confirmWidget: confirmWidget,
          citiesData: citiesData ?? meta.citiesData,
          provincesData: provincesData ?? meta.provincesData,
          locationCode: locationCode,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class BaseView extends StatefulWidget {
  final double? progress;
  final String locationCode;
  final ShowType showType;
  final Map<String, String> provincesData;
  final Map<String, dynamic> citiesData;
  final ItemWidgetBuilder? itemBuilder;

  /// 是否对数据进行排序
  final bool isSort;

  /// ios选择框的高度. 配合 itemBuilder中的字体使用.
  final double? itemExtent;

  /// 容器高度
  final double height;

  /// 取消按钮的Widget
  /// 当用户设置该属性. 会优先使用用户设置的widget, 否则使用代码中默认的文本, 使用primary主题色
  final Widget? cancelWidget;

  /// 确认按钮的widget
  /// 当用户设置该属性. 会优先使用用户设置的widget, 否则使用代码中默认的文本, 使用primary主题色
  final Widget? confirmWidget;

  final double borderRadius;

  /// 是否开启全球化数据
  final bool? global;

  const BaseView({
    super.key,
    this.progress,
    required this.showType,
    required this.height,
    required this.locationCode,
    required this.citiesData,
    required this.provincesData,
    this.itemBuilder,
    this.itemExtent,
    this.cancelWidget,
    this.confirmWidget,
    this.isSort = false,
    this.borderRadius = 0,
    this.global = false,
  }) : assert(!(itemBuilder != null && itemExtent == null),
            "\ritemExtent could't be null if itemBuilder exits");

  @override
  _BaseView createState() => _BaseView();
}

class _BaseView extends State<BaseView> {
  Timer? _changeTimer;
  bool _resetControllerOnce = false;

  FixedExtentScrollController provinceController =
      FixedExtentScrollController();
  FixedExtentScrollController cityController = FixedExtentScrollController();
  FixedExtentScrollController areaController = FixedExtentScrollController();
  FixedExtentScrollController villageController =
      FixedExtentScrollController(); // 增加第4级(村/镇)选择

  // 所有省的列表. 因为性能等综合原因,
  // 没有一次性构建整个以国为根的树. 动态的构建以省为根的树, 效率高.
  late List<Point> provinces;
  late CityTree cityTree;

  late Point targetProvince;
  Point? targetCity;
  Point? targetArea;
  Point? targetVillage; // 增加第4级(村/镇)选择

  @override
  void initState() {
    super.initState();

    provinces = Provinces(metaInfo: widget.provincesData, sort: widget.isSort)
        .provinces;

    cityTree = CityTree(
        metaInfo: widget.citiesData, provincesInfo: widget.provincesData);

    try {
      _initLocation(widget.locationCode);
      _initController();
    } catch (e) {
      print('Exception details:\n 初始化地理位置信息失败, 请检查省分城市数据 \n $e');
    }
  }

  @override
  void dispose() {
    provinceController.dispose();
    cityController.dispose();
    areaController.dispose();
    villageController.dispose();

    // 增加第4级(村/镇)选择
    if (_changeTimer?.isActive ?? false) {
      _changeTimer!.cancel();
    }
    super.dispose();
  }

  // 初始化controller, 为了使给定的默认值, 在选框的中心位置
  void _initController() {
    ShowType showType = widget.showType;
    if (showType.contain(ShowType.p)) {
      provinceController = FixedExtentScrollController(
          initialItem:
              provinces.indexWhere((Point p) => p.code == targetProvince.code));
    }
    if (showType.contain(ShowType.c)) {
      cityController = FixedExtentScrollController(
          initialItem: targetProvince.children
              .indexWhere((Point p) => p.code == targetCity!.code));
    }
    if (showType.contain(ShowType.a)) {
      areaController = FixedExtentScrollController(
          initialItem: targetCity!.children
              .indexWhere((Point p) => p.code == targetArea!.code));
    }
    // 增加第4级(村/镇)选择
    if (showType.contain(ShowType.v)) {
      villageController = FixedExtentScrollController(
          initialItem: targetArea!.children
              .indexWhere((Point p) => p.code == targetVillage!.code));
    }
  }

  // 重置Controller的原因在于, 无法手动去更改initialItem, 也无法通过
  // jumpTo or animateTo去更改, 强行更改, 会触发 _onProvinceChange  _onCityChange 与 _onAreacChange
  // 只为覆盖初始化化的参数initialItem
  void _resetController() {
    if (_resetControllerOnce) return;
    provinceController = FixedExtentScrollController(initialItem: 0);

    cityController = FixedExtentScrollController(initialItem: 0);
    areaController = FixedExtentScrollController(initialItem: 0);
    villageController =
        FixedExtentScrollController(initialItem: 0); // 增加第4级(村/镇)选择
    _resetControllerOnce = true;
  }

  // initialize tree by locationCode
  void _initLocation(String? locationCode) {
    String locationCode0;
    if (locationCode != null) {
      try {
        locationCode0 = locationCode;
      } catch (e) {
        print(ArgumentError(
            "The Argument locationCode must be valid like: '100000' but get '$locationCode' "));
        return;
      }

      targetProvince = cityTree.initTreeByCode(locationCode0);

      /// 为用户给出的locationCode不正确做一个容错
      if (targetProvince.isNull) {
        targetProvince = cityTree.initTreeByCode(provinces.first.code!);
      }
      for (var _city in targetProvince.children) {
        if (_city.code == locationCode0) {
          targetCity = _city;
          targetArea = _getTargetChildFirst(_city);
          // 增加第4级(村/镇)选择
          targetVillage = _getTargetChildFirst(targetArea!);
        }
        for (var _area in _city.children) {
          if (_area.code == locationCode0) {
            targetCity = _city;
            targetArea = _area;
            // 增加第4级(村/镇)选择
            targetVillage = _getTargetChildFirst(_area);
          }
          for (var _village in _area.children) {
            if (_village.code == locationCode0) {
              targetCity = _city;
              targetArea = _area;
              // 增加第4级(村/镇)选择
              targetVillage = _village;
            }
          }
        }
      }
    } else {
      /// 本来默认想定在北京, 但是由于有可能出现用户的省份数据为不包含北京, 所以采用第一个省份做为初始
      targetProvince = cityTree.initTreeByCode(widget.provincesData.keys.first);
    }
    // 尝试试图匹配到下一个级别的第一个,
    targetCity ??= _getTargetChildFirst(targetProvince);
    // 尝试试图匹配到下一个级别的第一个,
    targetArea ??= _getTargetChildFirst(targetCity!);
    // 增加第4级(村/镇)选择
    // 尝试试图匹配到下一个级别的第一个,
    targetVillage ??= _getTargetChildFirst(targetArea!);
  }

  Point? _getTargetChildFirst(Point target) {
    if (target == Point.nullPoint()) {
      return Point.nullPoint();
    }
    if (target.children.isNotEmpty && target.children.isNotEmpty) {
      return target.children.first;
    }
    return Point.nullPoint();
  }

  // 通过选中的省份, 构建以省份为根节点的树型结构
  List<String> getCityItemList() {
    List<String> result = [];
    result.addAll(targetProvince.children.toList().map((p) => p.name).toList());
    return result;
  }

  List<String> getAreaItemList() {
    List<String> result = [];

    if (targetCity != null) {
      result.addAll(targetCity!.children.toList().map((p) => p.name).toList());
    }
    return result;
  }

  // 增加第4级(村/镇)选择
  List<String> getVillageItemList() {
    List<String> result = [];

    if (targetArea != null) {
      result.addAll(targetArea!.children.toList().map((p) => p.name).toList());
    }
    return result;
  }

  // province change handle
  // 加入延时处理, 减少构建树的消耗
  _onProvinceChange(Point province) {
    if (_changeTimer != null && _changeTimer!.isActive) {
      _changeTimer!.cancel();
    }
    _changeTimer = Timer(const Duration(milliseconds: 100), () {
      Point provinceTree = cityTree.initTree(province.code.toString());
      setState(() {
        targetProvince = provinceTree;
        targetCity = _getTargetChildFirst(provinceTree);
        if (!targetCity!.isNull) {
          targetArea = _getTargetChildFirst(targetCity!);
          targetVillage = _getTargetChildFirst(targetArea!); // 增加第4级(村/镇)选择
        } else {
          targetArea = Point.nullPoint();
          targetVillage = Point.nullPoint();
        }
        _resetController();
      });
    });
  }

  _onCityChange(Point targetCity) {
    print('_onCityChange');
    if (_changeTimer != null && _changeTimer!.isActive) {
      _changeTimer!.cancel();
    }
    _changeTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        targetCity = targetCity;
        targetArea = _getTargetChildFirst(targetCity);
        if (!targetArea!.isNull) {
          targetVillage = _getTargetChildFirst(targetArea!); // 增加第4级(村/镇)选择
        } else {
          targetVillage = Point.nullPoint();
        }
      });
    });
    _resetController();
  }

  _onAreaChange(Point targetArea) {
    if (_changeTimer != null && _changeTimer!.isActive) {
      _changeTimer!.cancel();
    }
    _changeTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        targetArea = targetArea;
        targetVillage = _getTargetChildFirst(targetArea);
      });
    });
  }

  // 增加第4级(村/镇)选择
  _onVillageChange(Point targetVillage) {
    if (_changeTimer != null && _changeTimer!.isActive) {
      _changeTimer!.cancel();
    }
    _changeTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        targetVillage = targetVillage;
      });
    });
  }

  Result _nullResult() {
    Result result = Result();
    result.provinceId = 'null';
    return result;
  }

  Result _buildResult() {
    Result result = Result();
    ShowType showType = widget.showType;
    if (showType.contain(ShowType.p)) {
      result.provinceId = targetProvince.code.toString();
      result.provinceName = targetProvince.name;
    }
    if (showType.contain(ShowType.c)) {
      result.provinceId = targetProvince.code.toString();
      result.provinceName = targetProvince.name;
      result.cityId = targetCity?.code.toString();
      result.cityName = targetCity?.name;
    }
    if (showType.contain(ShowType.a)) {
      result.provinceId = targetProvince.code.toString();
      result.provinceName = targetProvince.name;
      result.cityId = targetCity?.code.toString();
      result.cityName = targetCity?.name;
      result.areaId = targetArea?.code.toString();
      result.areaName = targetArea?.name;
    }

    // 增加第4级(村/镇)选择
    if (showType.contain(ShowType.v)) {
      result.provinceId = targetProvince.code.toString();
      result.provinceName = targetProvince.name;
      result.cityId = targetCity!.code.toString();
      result.cityName = targetCity?.name;
      result.areaId = targetArea?.code.toString();
      result.areaName = targetArea?.name;
      result.villageId = targetVillage?.code.toString();
      result.villageName = targetVillage?.name;
    }
    // 台湾异常数据. 需要过滤
    // if (result.provinceId == "710000") {
    //   result.cityId = null;
    //   result.cityName = null;
    //   result.areaId = null;
    //   result.areaName = null;
    //   result.villageId = null;
    //   result.villageName = null;
    // }

    return result;
  }

  Widget _bottomBuild() {
    List<Widget> pickerRows = [];
    if (widget.showType.contain(ShowType.p)) {
      pickerRows.add(ScrollPicker(
        key: const Key('province'),
        isShow: widget.showType.contain(ShowType.p),
        controller: provinceController,
        itemBuilder: widget.itemBuilder,
        itemExtent: widget.itemExtent,
        value: targetProvince.name,
        itemList: provinces.toList().map((v) => v.name).toList(),
        changed: (index) {
          _onProvinceChange(provinces[index]);
        },
      ));
    }
    if (widget.showType.contain(ShowType.c)) {
      pickerRows.add(ScrollPicker(
        key: const Key('citys'),
        // 这个属性是为了强制刷新
        isShow: widget.showType.contain(ShowType.c),
        controller: cityController,
        itemBuilder: widget.itemBuilder,
        itemExtent: widget.itemExtent,
        value: targetCity?.name,
        itemList: getCityItemList(),
        changed: (index) {
          _onCityChange(targetProvince.children[index]);
        },
      ));
    }
    if (widget.showType.contain(ShowType.a)) {
      pickerRows.add(ScrollPicker(
        key: const Key('towns'),
        isShow: widget.showType.contain(ShowType.a),
        controller: areaController,
        itemBuilder: widget.itemBuilder,
        itemExtent: widget.itemExtent,
        value: targetArea?.name,
        itemList: getAreaItemList(),
        changed: (index) {
          _onAreaChange(targetCity!.children[index]);
        },
      ));
    }
    if (widget.showType.contain(ShowType.v)) {
      pickerRows.add(ScrollPicker(
        // 增加第4级(村/镇)选择
        // key: Key('villages'),
        isShow: widget.showType.contain(ShowType.v),
        controller: villageController,
        itemBuilder: widget.itemBuilder,
        itemExtent: widget.itemExtent,
        value: targetVillage?.name,
        itemList: getVillageItemList(),
        changed: (index) {
          _onVillageChange(targetArea!.children[index]);
        },
      ));
    }
    return SizedBox(
      height: 300,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: pickerRows,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '取消',
                        style: AppTextStyle.textStyle,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, _nullResult()),
                      child: Text(
                        '移除',
                        style: AppTextStyle.redTextStyle,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _buildResult()),
                  child: Text(
                    '确定',
                    style: AppTextStyle.textStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: AppColors.background,
      child: _bottomBuild(),
    );
  }
}

class _WrapLayout extends SingleChildLayoutDelegate {
  _WrapLayout({
    required this.progress,
    required this.height,
  });

  final double progress;
  final double height;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = height;

    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_WrapLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
