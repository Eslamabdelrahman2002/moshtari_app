import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_body.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../logic/cubit/real_estate_cubit.dart'; // Assuming your body is here

class RealEstateScreen extends StatelessWidget {
  const RealEstateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RealEstateCubit>(),
      child: const Scaffold(
        body: RealEstateBody(),
      ),
    );
  }
}