{{flutter_js}}
{{flutter_build_config}}

// Flutter's generated service worker now unregisters itself. The application
// uses pwa_cache_worker.js instead so repeat visits can reuse the app shell.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    const loading = document.getElementById('app-loading');
    if (loading) loading.remove();
    await appRunner.runApp();
  }
});
