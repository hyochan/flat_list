import 'package:flat_list_example/screens/flat_list_ex1.dart';
import 'package:flat_list_example/screens/flat_list_ex2.dart';
import 'package:flat_list_example/screens/flat_list_ex3.dart';
import 'package:flat_list_example/screens/home.dart';
import 'package:flutter/foundation.dart';

enum AppRoute {
  home,
  flatListEx1,
  flatListEx2,
  flatListEx3,
}

extension RouteName on AppRoute {
  String get name => describeEnum(this);

  bool get isRoot => this == AppRoute.home;

  /// Convert to `lower-snake-case` format.
  String get path {
    if (isRoot) return '';

    RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    String result = name
        .replaceAllMapped(exp, (Match m) => ('-${m.group(0)}'))
        .toLowerCase();
    return result;
  }

  /// Convert to `lower-snake-case` format with `/`.
  String get fullPath {
    if (isRoot) return '/';

    RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    String result = name
        .replaceAllMapped(exp, (Match m) => ('-${m.group(0)}'))
        .toLowerCase();
    return '/$result';
  }
}

final routes = {
  AppRoute.home.fullPath: (context) => const Home(),
  AppRoute.flatListEx1.fullPath: (context) => const FlatListEx1(),
  AppRoute.flatListEx2.fullPath: (context) => const FlatListEx2(),
  AppRoute.flatListEx3.fullPath: (context) => const FlatListEx3(),
};
