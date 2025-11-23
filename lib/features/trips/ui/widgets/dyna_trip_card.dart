import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/theme/colors.dart';
import '../../data/model/dyna_trips_list_models.dart';

class DynaTripCard extends StatelessWidget {
  final DynaTripItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool busy;

  const DynaTripCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final dep = item.departureDate != null ? df.format(item.departureDate!) : '-';
    final arr = item.arrivalDate != null ? df.format(item.arrivalDate!) : '-';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اتجاه الرحلة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${item.fromCityNameAr} → ${item.toCityNameAr}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'السعة ${item.dynaCapacity}',
                  style: TextStyle(
                    color: ColorsManager.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),
          Row(
            children: [
              _iconText(Icons.event, dep),
              SizedBox(width: 10.w),
              _iconText(Icons.schedule, arr),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: Colors.grey[200], thickness: 1),
          SizedBox(height: 8.h),

          // أزرار التحكم
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.mode_edit_outline_rounded, size: 16, color: Colors.white),
                  label: const Text('تعديل', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: ColorsManager.primaryColor,
                    side:  BorderSide(color: ColorsManager.primaryColor),
                    minimumSize: Size(80.w, 36.h),
                  ),
                  onPressed: busy ? null : onEdit,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                  label: const Text('حذف', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: ColorsManager.redButton,
                    side:  BorderSide(color: ColorsManager.redButton),
                    minimumSize: Size(80.w, 36.h),
                  ),
                  onPressed: busy ? null : onDelete,
                ),
              ),
              if (busy) ...[
                SizedBox(width: 10.w),
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}