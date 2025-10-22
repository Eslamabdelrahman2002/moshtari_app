import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/home/ui/widgets/grid_view_item.dart';

import '../../../../core/theme/text_styles.dart';
import '../logic/cubit/favorites_cubit.dart';
import '../logic/cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FavoritesCubit>()..getFavoritesScreenItems(),
      child: const FavoritesView(),
    );
  }
}

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('قائمة المفضلة',style: TextStyles.font20Black500Weight,),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios,color: ColorsManager.darkGray300,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<FavoritesCubit, FavoritesState>(
        listenWhen: (_, s) => s is AddFavoriteFailure,
        listener: (context, state) {
          if (state is AddFavoriteFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        buildWhen: (_, s) => s is! FavoritesLoaded, // تجاهل IDs فقط
        builder: (context, state) {
          if (state is FavoritesLoading || state is FavoritesInitial) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state is FavoritesError) {
            return Center(child: Text(state.error));
          }
          if (state is FavoritesSuccess) {
            if (state.favoriteItems.isEmpty) {
              return const Center(child: Text('لا يوجد عناصر في المفضلة'));
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.75,
              ),
              padding: EdgeInsets.all(16.w),
              itemCount: state.favoriteItems.length,
              itemBuilder: (context, index) {
                final f = state.favoriteItems[index];
                final adModel = HomeAdModel.fromFavorite(f);
                return GridViewItem(
                  adModel: adModel,
                  isFavorited: true,
                  onFavoriteTap: () {
                    context.read<FavoritesCubit>().removeFavorite(favoriteRecordId: f.id);
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}