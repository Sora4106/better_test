{{flutter_js}}
{{flutter_build_config}}

// The deployment script replaces this marker for every release. Keeping the
// app bundle URL versioned prevents an old PWA cache from serving main.dart.js
// after index.html has already discovered a newer deployment.
const pwaCacheVersion = '__PWA_CACHE_VERSION__';
for (const build of window._flutter?.buildConfig?.builds ?? []) {
  if (!build.mainJsPath) continue;
  const separator = build.mainJsPath.includes('?') ? '&' : '?';
  build.mainJsPath = `${build.mainJsPath}${separator}v=${encodeURIComponent(pwaCacheVersion)}`;
}

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
