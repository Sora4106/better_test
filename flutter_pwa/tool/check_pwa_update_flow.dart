import 'dart:io';

void main() {
  final root = Directory.current;
  final index = File('${root.path}/web/index.html').readAsStringSync();
  final bootstrap =
      File('${root.path}/web/flutter_bootstrap.js').readAsStringSync();
  final worker =
      File('${root.path}/web/pwa_cache_worker.js').readAsStringSync();
  final deployScript =
      File('${root.parent.path}/tools/update-pwa-cache.ps1').readAsStringSync();
  final problems = <String>[];

  if (!index.contains("updateViaCache: 'none'")) {
    problems.add('Service worker registration must bypass HTTP cache.');
  }
  if (!index.contains("addEventListener('controllerchange'")) {
    problems.add('Service worker updates must reload the active page once.');
  }
  if (!index.contains('flutter_bootstrap.js?v=__PWA_CACHE_VERSION__')) {
    problems.add('Flutter bootstrap must use a release-versioned URL.');
  }
  if (!bootstrap.contains("const pwaCacheVersion = '__PWA_CACHE_VERSION__';")) {
    problems.add('Flutter bootstrap is missing its release cache marker.');
  }
  if (!bootstrap.contains('build.mainJsPath =')) {
    problems.add('Flutter bootstrap must version main.dart.js.');
  }
  if (!worker.contains("url.pathname.endsWith('/main.dart.js')")) {
    problems.add('Main Flutter bundle must use network-first updates.');
  }
  if (!worker.contains('caches.match(request, {ignoreSearch: true})')) {
    problems.add('Offline fallback must support versioned app URLs.');
  }
  if (!deployScript.contains(r'$bootstrapPath') ||
      !deployScript.contains(r'@($indexPath, $bootstrapPath, $workerPath)')) {
    problems.add('Deployment script must stamp the bootstrap cache version.');
  }

  if (problems.isNotEmpty) throw StateError(problems.join('\n'));
  print(
      'PWA update flow OK: versioned bootstrap and main bundle are enforced.');
}
