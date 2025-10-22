import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/my_auctions_model.dart';
import '../../data/repo/my_auctions_repo.dart';
import 'my_auctions_state.dart';

class MyAuctionsCubit extends Cubit<MyAuctionsState> {
  final MyAuctionsRepo _repo;

  MyAuctionsCubit(this._repo) : super(MyAuctionsInitial());

  List<MyAuctionModel> _auctions = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isFetching = false;

  // مفاتيح تحميل القبول/الرفض لكل كارد
  final Set<String> _actionLoadingKeys = {};

  String _key(int auctionId, String auctionType) => '$auctionType-$auctionId';

  Future<void> loadInitialAuctions() async {
    if (_isFetching) return;
    _isFetching = true;
    _currentPage = 1;
    _auctions.clear();
    emit(MyAuctionsLoading());

    try {
      final response = await _repo.fetchMyAuctions(page: 1);
      _auctions = response.data;
      _currentPage = response.page;
      _totalPages = response.totalPages;

      _emitSuccess();
    } catch (e) {
      emit(MyAuctionsFailure(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  // ربط زر القبول/الرفض
  Future<String?> approveOrReject({
    required int auctionId,
    required String auctionType, // 'car' | 'real_estate'
    required int itemId,
    required bool accept,
  }) async {
    final k = _key(auctionId, auctionType);
    if (_actionLoadingKeys.contains(k)) return null;

    _actionLoadingKeys.add(k);
    _emitSuccess();

    try {
      final res = await _repo.approveAuction(
        auctionId: auctionId,
        auctionType: auctionType,
        itemId: itemId,
        action: accept ? 'accept' : 'reject',
      );

      // TODO: ممكن تحدث الحالة المحلية للعنصر (حذفه/تغيير status) إن لزم
      final msg = (res.message.isNotEmpty)
          ? res.message
          : (accept ? 'تم قبول المزاد' : 'تم رفض المزاد');

      return msg;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _actionLoadingKeys.remove(k);
      _emitSuccess();
    }
  }

  void _emitSuccess() {
    emit(MyAuctionsSuccess(
      auctions: _auctions,
      currentPage: _currentPage,
      totalPages: _totalPages,
      actionLoadingKeys: Set.unmodifiable(_actionLoadingKeys),
    ));
  }
}