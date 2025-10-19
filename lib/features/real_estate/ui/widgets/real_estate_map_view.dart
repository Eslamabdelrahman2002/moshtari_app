import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/widget_to_bit_extension.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_map_item_detail.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_triangle_painter.dart';

class RealEstateMapView extends StatefulWidget {
  const RealEstateMapView({super.key});

  static const CameraPosition _mecca = CameraPosition(
    target: LatLng(24.714648, 46.667786),
    zoom: 12,
  );

  @override
  State<RealEstateMapView> createState() => _RealEstateMapViewState();
}

class _RealEstateMapViewState extends State<RealEstateMapView> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final StreamController<double> _zoomLevelStreamController =
      StreamController<double>();
  double _currentZoomLevel = 12;

  List<Marker> markerList = [];

  updateMarkers({Iterable<Marker>? markers}) async {
    try {
      markerList.addAll([
        Marker(
          markerId: const MarkerId("MarkerId2"),
          position: const LatLng(24.714648, 46.667786),
          icon: await getCustomIcon(),
        ),
        Marker(
          markerId: const MarkerId("MarkerId1"),
          position: const LatLng(24.724559, 46.674784),
          icon: await getCustomIcon(),
        ),
        Marker(
          markerId: const MarkerId("MarkerId3"),
          position: const LatLng(24.694601, 46.675439),
          icon: await getCustomIcon(),
        ),
        Marker(
          markerId: const MarkerId("MarkerId4"),
          position: const LatLng(24.689670, 46.673160),
          icon: await getCustomIcon(),
        ),
        Marker(
          markerId: const MarkerId("MarkerId5"),
          position: const LatLng(24.729771, 46.690392),
          icon: await getCustomIcon(),
        ),
        Marker(
            markerId: const MarkerId("MarkerId6"),
            position: const LatLng(24.715888, 46.653222),
            icon: await getCustomIcon(),
            anchor: const Offset(0.5, 1.0),
            onTap: () {}),
      ]);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _zoomLevelStreamController.stream.listen((double zoomLevel) {
      if (mounted) {
        updateMarkers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: GoogleMap(
            onCameraIdle: () {
              if (mounted) {
                updateMarkers();
              }
            },
            minMaxZoomPreference: const MinMaxZoomPreference(8, 17),
            mapType: MapType.terrain,
            initialCameraPosition: RealEstateMapView._mecca,
            buildingsEnabled: false,
            markers: markerList.toSet(),
            liteModeEnabled: false,
            onCameraMove: (CameraPosition position) {
              if (_currentZoomLevel != position.zoom) {
                _currentZoomLevel = position.zoom;
                _zoomLevelStreamController.add(_currentZoomLevel);
              }
            },
            indoorViewEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            compassEnabled: false,
            rotateGesturesEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              if (mounted) {
                updateMarkers();
              }
            },
          ),
        ),
        Positioned(
          left: 16.w,
          bottom: 120.h,
          child: FloatingActionButton(
            onPressed: () {
              navigateToLocation(RealEstateMapView._mecca.target);
            },
            backgroundColor: ColorsManager.primary400,
            child: Text(
              'أطلب\nعقارك',
              style: TextStyles.font12White400Weight,
            ),
          ),
        ),
        Positioned(
          right: 16.w,
          left: 16.w,
          bottom: 10,
          child: InkWell(
              onTap: () {
                context.pushNamed(Routes.realEstateDetailsScreen);
              },
              child: const RealEstateMapItemDetails()),
        ),
      ],
    );
  }

  Future<void> navigateToLocation(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: latLng,
      zoom: 12,
    )));
  }

  Future getCustomIcon() async {
    final controller = await _controller.future;
    final double zoomLevel = await controller.getZoomLevel();
    final double responsiveSize = getResponsiveSize(zoomLevel);

    return SizedBox(
      width: responsiveSize * 3,
      height: responsiveSize * 2.5,
      child: Column(children: [
        Container(
            padding: EdgeInsets.all(responsiveSize * 0.1),
            width: responsiveSize * 3,
            height: responsiveSize,
            decoration: BoxDecoration(
              color: ColorsManager.secondary500,
              borderRadius: BorderRadius.circular(100),
            ),
            child: FittedBox(
                child: Text(
              '١ ~ ٢ مليون',
              overflow: TextOverflow.ellipsis,
              style: TextStyles.font12Dark500500Weight,
            ))),
        SizedBox(
          width: responsiveSize / 3,
          height: responsiveSize / 6,
          child: Transform.flip(
            flipY: true,
            child: CustomPaint(
              painter: RealEstateTrianglePainter(),
            ),
          ),
        ),
        SizedBox(height: responsiveSize / 5),
        Container(
            width: responsiveSize / 1.2,
            height: responsiveSize / 1.2,
            padding: EdgeInsets.all(responsiveSize * 0.1),
            decoration: const BoxDecoration(
              color: ColorsManager.secondary500,
              shape: BoxShape.circle,
            ),
            child: FittedBox(
              child: Text(
                '3',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyles.font12Dark500500Weight,
              ),
            )),
      ]),
    ).toBitmapDescriptor();
  }

  /// This method is used to get the responsive size of the icon based on the zoom level
  double getResponsiveSize(double width) {
    return width - 7;
  }

  @override
  void dispose() {
    _controller.future.then((controller) => controller.dispose());
    _zoomLevelStreamController.close();
    super.dispose();
  }
}
