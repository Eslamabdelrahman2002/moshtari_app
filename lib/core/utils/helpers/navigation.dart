import 'package:flutter/material.dart';

import '../../router/app_router.dart';

extension Navigation on BuildContext {
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this)
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(String routeName,
      {Object? arguments, required RoutePredicate predicate}) {
    return Navigator.of(this)
        .pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  void pop({dynamic result}) => Navigator.of(this).pop(result);
}


extension NavX on BuildContext {
  NavigatorState get _root => navigatorKey.currentState!;
  Future<T?> pushNamed<T extends Object?>(String name, {Object? arguments}) =>
      _root.pushNamed<T>(name, arguments: arguments);

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      String name, {TO? result, Object? arguments}) =>
      _root.pushReplacementNamed<T, TO>(name, result: result, arguments: arguments);

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
      String name, bool Function(Route<dynamic>) predicate, {Object? arguments}) =>
      _root.pushNamedAndRemoveUntil<T>(name, predicate, arguments: arguments);
}