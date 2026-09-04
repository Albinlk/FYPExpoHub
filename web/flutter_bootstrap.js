{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  // No `renderer` key: the loader auto-selects the best compatible build
  // (dart2wasm/skwasm on WasmGC browsers, dart2js/canvaskit fallback).
  // NOTE: renderer:"auto" is NOT a valid value — it rejects every build
  // and leaves the splash hanging forever.
  onEntrypointLoaded: async function (engineInitializer) {
    // Display the HTML splash (defined in index.html) until the first
    // Flutter frame is ready, then fade it out.
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    const splash = document.querySelector('#splash');
    if (splash) {
      splash.classList.add('splash-fade');
      window.setTimeout(() => splash.remove(), 400);
    }
  },
});
