import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/utils/json/area_model.dart';
import 'package:mushtary/core/utils/json/areas_sa.dart';
import 'package:mushtary/core/utils/json/cites_sa.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_drop_down.dart';

class RealEstateActionBar extends StatefulWidget {
  final VoidCallback onListViewTap;
  final VoidCallback onGridViewTap;
  final VoidCallback onMapViewTap;
  final bool isListView;
  final bool isGridView;
  final bool isMapView;
  final bool isApplications;

  const RealEstateActionBar({
    super.key,
    required this.onListViewTap,
    required this.onGridViewTap,
    required this.isListView,
    required this.onMapViewTap,
    required this.isGridView,
    required this.isMapView,
    required this.isApplications,
  });

  @override
  State<RealEstateActionBar> createState() => _RealEstateActionBarState();
}

class _RealEstateActionBarState extends State<RealEstateActionBar> {
  int cityIndex = 0;
  int countryIndex = 0;
  int currentCityId = 0;
  List<Area> currentAreas = [];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Visibility(
              visible: !widget.isApplications,
              child: Row(
                children: [
                  InkWell(
                    onTap: widget.onGridViewTap,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: widget.isGridView
                            ? ColorsManager.secondary500
                            : ColorsManager.lightYellow,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: widget.isGridView
                          ? MySvg(
                              image: 'gridView_active',
                              width: 20.w,
                              height: 20.w)
                          : MySvg(image: 'gridView', width: 20.w, height: 20.w),
                    ),
                  ),
                  horizontalSpace(8),
                  InkWell(
                    onTap: widget.onListViewTap,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: widget.isListView
                            ? ColorsManager.secondary500
                            : ColorsManager.lightYellow,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: widget.isListView
                          ? MySvg(
                              image: 'listView_active',
                              width: 20.w,
                              height: 20.w)
                          : MySvg(image: 'listView', width: 20.w, height: 20.w),
                    ),
                  ),
                  horizontalSpace(8),
                  InkWell(
                    onTap: widget.onMapViewTap,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: widget.isMapView
                            ? ColorsManager.secondary500
                            : ColorsManager.lightYellow,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: widget.isMapView
                          ? MySvg(
                              image: 'mapView_active',
                              width: 20.w,
                              height: 20.w)
                          : MySvg(image: 'mapView', width: 20.w, height: 20.w),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            if (!widget.isMapView)
              Visibility(
                visible: !widget.isMapView,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        backgroundColor: Colors.white,
                        builder: (context) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.w),
                                  topRight: Radius.circular(8.w)),
                              color: Colors.white,
                            ),
                            height: 500.h,
                            width: double.infinity,
                            child: ListView.builder(
                                itemCount: currentAreas.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 16.w),
                                    decoration: BoxDecoration(
                                      color: countryIndex == index
                                          ? ColorsManager.secondary500
                                              .withOpacity(0.1)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          countryIndex = index;
                                          context.pop();
                                        });
                                      },
                                      title: Text(
                                        '${(currentAreas[index].areaNameAr)}',
                                        style: countryIndex == index
                                            ? TextStyles.font16Black500Weight
                                            : TextStyles.font16Dark400Weight,
                                      ),
                                      leading: Icon(
                                        Icons.check,
                                        color: countryIndex == index
                                            ? ColorsManager.secondary500
                                            : Colors.white,
                                      ),
                                    ),
                                  );
                                }),
                          );
                        });
                  },
                  child: RealEstateDropDown(
                    title: currentAreas.isEmpty
                        ? 'أختر'
                        : '${(currentAreas[countryIndex].areaNameAr)}',
                  ),
                ),
              ),
            horizontalSpace(8),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    backgroundColor: Colors.white,
                    builder: (context) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.w),
                              topRight: Radius.circular(8.w)),
                          color: Colors.white,
                        ),
                        height: 500.h,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: ColorsManager.secondary500,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              child: ListTile(
                                title: Text(
                                  (Cites.cites[cityIndex].cityNameAr),
                                  style: TextStyles.font16Black500Weight,
                                ),
                                leading: Icon(
                                  Icons.check,
                                  color: ColorsManager.black,
                                ),
                              ),
                            ),
                            verticalSpace(8.w),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: Cites.cites.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      decoration: BoxDecoration(
                                        color: cityIndex == index
                                            ? ColorsManager.secondary500
                                                .withOpacity(0.1)
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Visibility(
                                        visible: (cityIndex != index),
                                        child: ListTile(
                                          onTap: () {
                                            setState(() {
                                              cityIndex = index;
                                              currentCityId =
                                                  Cites.cites[index].id;
                                              countryIndex = 0;
                                              _getAreasForCurrentCity();
                                              context.pop();
                                            });
                                          },
                                          title: Text(
                                            (Cites.cites[index].cityNameAr),
                                            style: cityIndex == index
                                                ? TextStyles
                                                    .font16Black500Weight
                                                : TextStyles
                                                    .font16Dark400Weight,
                                          ),
                                          leading: Icon(
                                            Icons.check,
                                            color: cityIndex == index
                                                ? ColorsManager.secondary500
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      );
                    });
              },
              child: RealEstateDropDown(
                title: (Cites.cites[cityIndex].cityNameAr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getAreasForCurrentCity() {
    currentAreas = Areas.areas.where((area) {
      return area.cityId == currentCityId;
    }).toList();
  }
}
