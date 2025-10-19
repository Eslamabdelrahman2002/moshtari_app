import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mushtary/core/utils/helpers/create_image_from_widget.dart';

/// Extension on [Widget] to convert it into a [BitmapDescriptor].
extension ToBitDescription on Widget {
  /// Converts the widget into a [BitmapDescriptor] which can be used for custom marker icons in Google Maps.
  ///
  /// - `logicalSize`: The logical size of the widget in the render view. If not provided,
  ///   it defaults based on the screen dimensions and device pixel ratio.
  /// - `imageSize`: The size of the output image. If not provided, it defaults to the physical
  ///   size of the screen.
  /// - `waitToRender`: The time to wait before rendering the widget. Defaults to 300 milliseconds.
  ///   This delay can be adjusted depending on the complexity of the widget.
  /// - `textDirection`: The text direction to use for the widget rendering. Defaults to left-to-right.
  ///
  /// Returns a `Future<BitmapDescriptor>` which can be used as a custom marker icon in Google Maps.
  Future<BitmapDescriptor> toBitmapDescriptor(
      {Size? logicalSize,
      Size? imageSize,
      Duration waitToRender = const Duration(milliseconds: 300),
      TextDirection textDirection = TextDirection.ltr}) async {
    // Wrap the widget in a RepaintBoundary and set MediaQuery and Directionality
    // to ensure it renders correctly in isolation.
    final widget = RepaintBoundary(
      child: MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(textDirection: textDirection, child: this)),
    );

    // Use the previously documented method to create an image from the widget.
    final pngBytes = await CreateImageFromWidget.createImageFromWidget(widget,
        waitToRender: waitToRender,
        logicalSize: logicalSize,
        imageSize: imageSize);

    // Convert the PNG bytes into a BitmapDescriptor to be used as a marker icon.
    return BitmapDescriptor.bytes(pngBytes);
  }
}
