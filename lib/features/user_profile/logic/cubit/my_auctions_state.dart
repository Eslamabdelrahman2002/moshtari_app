import 'package:equatable/equatable.dart';
import '../../data/model/my_auctions_model.dart';

abstract class MyAuctionsState extends Equatable {
  const MyAuctionsState();
  @override
  List<Object?> get props => [];
}

class MyAuctionsInitial extends MyAuctionsState {}

class MyAuctionsLoading extends MyAuctionsState {}

class MyAuctionsFailure extends MyAuctionsState {
  final String error;
  const MyAuctionsFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class MyAuctionsSuccess extends MyAuctionsState {
  final List<MyAuctionModel> auctions;
  final int currentPage;
  final int totalPages;
  final Set<String> actionLoadingKeys; // car-9, real_estate-3 ...

  const MyAuctionsSuccess({
    required this.auctions,
    required this.currentPage,
    required this.totalPages,
    this.actionLoadingKeys = const {},
  });

  MyAuctionsSuccess copyWith({
    List<MyAuctionModel>? auctions,
    int? currentPage,
    int? totalPages,
    Set<String>? actionLoadingKeys,
  }) {
    return MyAuctionsSuccess(
      auctions: auctions ?? this.auctions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      actionLoadingKeys: actionLoadingKeys ?? this.actionLoadingKeys,
    );
  }

  @override
  List<Object?> get props => [auctions, currentPage, totalPages, actionLoadingKeys];
}