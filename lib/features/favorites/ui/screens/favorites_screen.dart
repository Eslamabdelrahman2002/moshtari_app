import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/home/ui/widgets/grid_view_item.dart';

import '../logic/cubit/favorites_cubit.dart';
import '../logic/cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FavoritesCubit>()..getFavoritesScreenItems(),
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
        title: const Text('قائمة المفضلة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading || state is FavoritesInitial) {
            return const Center(child: CircularProgressIndicator());
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
                final favoriteItem = state.favoriteItems[index];
                final adModel = HomeAdModel.fromFavorite(favoriteItem);

                return GridViewItem(
                  adModel: adModel,
                  isFavorited: true,
                  onFavoriteTap: () {
                    context.read<FavoritesCubit>().removeFavorite(
                      favoriteRecordId: favoriteItem.id,
                    );
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