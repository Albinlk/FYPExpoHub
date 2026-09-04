{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Renderer auto-selection: modern browsers get the smaller/faster
    // engine (skwasm); older browsers fall back to CanvasKit.
    renderer: "auto",
  },
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
