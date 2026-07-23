{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Force CanvasKit renderer: uses GPU-accelerated Skia for crisp,
    // anti-aliased text — eliminates jagged fonts on Flutter web.
    renderer: "canvaskit",
  },
});
