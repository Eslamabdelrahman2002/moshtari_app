import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A class to create an image from a Flutter widget.
class CreateImageFromWidget {
  /// Converts a given widget into an image.
  ///
  /// This static method uses the rendering library to create a snapshot of the widget after
  /// a specified delay, allowing animations or renders to complete.
  ///
  /// - `widget`: The widget to render as an image.
  /// - `logicalSize`: The logical size of the widget in the render view. If not provided,
  ///    it defaults to the size of the physical screen scaled by the device's pixel ratio.
  /// - `waitToRender`: Duration to wait before capturing the widget image. This delay allows
  ///    the widget's view to complete any necessary rendering.
  /// - `imageSize`: The size of the image to output. Defaults to the physical size of the screen.
  ///
  /// Returns a `Future<Uint8List>` which is the PNG-encoded image data of the rendered widget.
  static Future<Uint8List> createImageFromWidget(Widget widget,
      {Size? logicalSize,
      required Duration waitToRender,
      Size? imageSize}) async {
    // Create a new repaint boundary used to capture the widget.
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    // Access the first available view, usually the main app window.
    final view = ui.PlatformDispatcher.instance.views.first;

    // Default logical size to current view size adjusted by the device pixel ratio if not provided.
    logicalSize ??= view.physicalSize / view.devicePixelRatio;

    // Default image size to the physical size of the view if not provided.
    imageSize ??= view.physicalSize;

    // Setup the render view with appropriate configuration and children.
    final RenderView renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(logicalSize),
        devicePixelRatio: 1.0,
      ),
    );

    // Create a pipeline owner and a build owner to manage rendering.
    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    // Setup the rendering tree and initial frame.
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    // Attach the widget to the repaint boundary within the rendering tree.
    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: widget,
    ).attachToRenderTree(buildOwner);

    // Build the widget in the current scope.
    buildOwner.buildScope(rootElement);

    // Wait for the specified duration to allow the widget to render.
    await Future.delayed(waitToRender);

    // Rebuild and finalize the tree after the delay.
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    // Execute the layout, paint, and compositing stages.
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    // Capture the image from the repaint boundary.
    final ui.Image image = await repaintBoundary.toImage(
        pixelRatio: imageSize.width / logicalSize.width);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    // Return the image data as a Uint8List.
    return byteData!.buffer.asUint8List();
  }
}
