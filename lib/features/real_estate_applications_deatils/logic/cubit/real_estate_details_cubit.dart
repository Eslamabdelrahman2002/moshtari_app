// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'package:mushtary/features/real_estate_applications_deatils/logic/cubit/real_estate_details_state.dart';
// import '../../../real_estate/data/repo/real_estate_repo.dart';
//
// class RealEstateDetailsCubit extends Cubit<RealEstateDetailsState> {
//   final RealEstateRepo _realEstateRepo;
//
//   RealEstateDetailsCubit(this._realEstateRepo) : super(RealEstateDetailsInitial());
//
//   void fetchAdDetails(int id) async {
//     emit(RealEstateDetailsLoading());
//     try {
//       final ad = await _realEstateRepo.getRealEstateAdById(id);
//       emit(RealEstateDetailsSuccess(ad));
//     } catch (e) {
//       emit(RealEstateDetailsFailure(e.toString()));
//     }
//   }
// }