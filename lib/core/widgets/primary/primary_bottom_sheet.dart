import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

import '../../theme/colors.dart';

Future<T?> showPrimaryBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool? hasNoPadding = false,
  bool isDismissible = true,
  Function? onDismiss,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: isDismissible,
    // useRootNavigator: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.r),
        topRight: Radius.circular(24.r),
      ),
    ),
    builder: (context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                verticalSpace(10),
                Container(
                  width: 102.w,
                  height: 4.h,
                  margin: EdgeInsets.only(
                    top: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsManager.black,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: hasNoPadding == true ? 0 : 16.w,
                  ),
                  child: child,
                ),
                verticalSpace(12),
              ],
            ),
          ),
        ),
      );
    },
  ).then((value) {
    onDismiss?.call();
    return value;
  });
}
