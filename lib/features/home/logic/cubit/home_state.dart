import 'package:flutter/material.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeSuccess extends HomeState {
  final HomeDataModel homeData;
  HomeSuccess(this.homeData);
}
class HomeFailure extends HomeState {
  final String error;
  HomeFailure(this.error);
}