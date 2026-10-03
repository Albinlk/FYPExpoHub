{{flutter_js}}
{{flutter_build_config}}

// Anti-clickjacking for the signed-in areas. GitHub Pages can't send an
// X-Frame-Options / frame-ancestors header, so refuse to run those routes
// inside someone else's frame. Public pages stay embeddable.
(function () {
  // The admin subdomain redirects "/" to the sign-in page client-side, after
  // this check has run, so the whole host counts as protected.
  var protectedArea =
    /^\/(admin|lecturer|fypms)(\/|$)/.test(location.pathname) ||
    /^admin\./.test(location.hostname);
  if (protectedArea && window.top !== window.self) {
    document.documentElement.style.display = 'none';
    try {
      window.top.location = window.self.location.href;
    } catch (e) {
      // Cross-origin top we can't navigate: stay hidden.
    }
    throw new Error('Refusing to load a protected page inside a frame.');
  }
})();

_flutter.loader.load({
  // No `renderer` key: the loader auto-selects the best compatible build
  // (dart2wasm/skwasm on WasmGC browsers, dart2js/canvaskit fallback).
  // NOTE: renderer:"auto" is NOT a valid value — it rejects every build
  // and leaves the splash hanging forever.
  onEntrypointLoaded: async function (engineInitializer) {
    // Register the caching service worker (stamped with the deploy version
    // at build time — see the deploy workflow). Non-blocking: the app
    // boots immediately whether or not the SW finishes installing.
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('sw.js?v={{BUILD_VERSION}}', {
        scope: './',
      }).catch((e) =>
        console.warn('Service worker registration failed:', e),
      );
    }

    // Display the HTML splash (defined in index.html) until the first
    // Flutter frame is ready, then fade it out.
    try {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
    } catch (e) {
      console.error('App failed to start:', e);
      showStartupError();
      return;
    }
    const splash = document.querySelector('#splash');
    if (splash) {
      splash.classList.add('splash-fade');
      window.setTimeout(() => splash.remove(), 400);
    }
  },
});

// If the engine never starts (offline, blocked script, unsupported browser)
// the splash would spin forever; say what happened and offer a reload.
function showStartupError() {
  var splash = document.querySelector('#splash');
  if (!splash) return;
  var loading = splash.querySelector('.splash-loading');
  if (loading) {
    loading.textContent = 'Could not start the app. Check your connection and try again.';
    loading.style.fontSize = '14px';
    loading.style.letterSpacing = 'normal';
    loading.style.maxWidth = '24em';
    loading.style.textAlign = 'center';
  }
  var spinner = splash.querySelector('.splash-spinner');
  if (spinner) spinner.style.display = 'none';
  if (!splash.querySelector('.splash-retry')) {
    var button = document.createElement('button');
    button.className = 'splash-retry';
    button.textContent = 'Reload';
    button.style.cssText =
      'margin-top:16px;padding:10px 24px;font-size:16px;border:0;border-radius:8px;cursor:pointer;';
    button.onclick = function () { location.reload(); };
    (loading ? loading.parentNode : splash).appendChild(button);
  }
}

window.setTimeout(function () {
  if (document.querySelector('#splash') && !document.querySelector('flt-glass-pane')) {
    var loading = document.querySelector('#splash .splash-loading');
    if (loading) loading.textContent = 'Still loading… this is taking longer than usual.';
  }
}, 15000);
