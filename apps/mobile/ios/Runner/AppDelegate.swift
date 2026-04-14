import Flutter
import UIKit
#if canImport(image_picker_ios)
import image_picker_ios
#endif
#if canImport(path_provider_foundation)
import path_provider_foundation
#endif
#if canImport(share_plus)
import share_plus
#endif
#if canImport(shared_preferences_foundation)
import shared_preferences_foundation
#endif
#if canImport(url_launcher_ios)
import url_launcher_ios
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  lazy var flutterEngine = FlutterEngine(name: "lo_renaciente_engine")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("LR iOS AppDelegate didFinishLaunching start")
    flutterEngine.run()
    registerSafePlugins(on: flutterEngine)
    print("LR iOS AppDelegate plugins registered")

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    print("LR iOS AppDelegate didFinishLaunching end \(result)")
    return result
  }

  private func registerSafePlugins(on engine: FlutterEngine) {
    // gallery_saver_plus estaba provocando un crash nativo en iPhone al
    // registrarse durante el arranque. Lo omitimos en iOS para priorizar
    // apertura estable de la app; la exportacion usa fallback en Dart.
#if canImport(image_picker_ios)
    if let registrar = engine.registrar(forPlugin: "FLTImagePickerPlugin") {
      FLTImagePickerPlugin.register(with: registrar)
    }
#endif
#if canImport(path_provider_foundation)
    if let registrar = engine.registrar(forPlugin: "PathProviderPlugin") {
      PathProviderPlugin.register(with: registrar)
    }
#endif
#if canImport(share_plus)
    if let registrar = engine.registrar(forPlugin: "FPPSharePlusPlugin") {
      FPPSharePlusPlugin.register(with: registrar)
    }
#endif
#if canImport(shared_preferences_foundation)
    if let registrar = engine.registrar(forPlugin: "SharedPreferencesPlugin") {
      SharedPreferencesPlugin.register(with: registrar)
    }
#endif
#if canImport(url_launcher_ios)
    if let registrar = engine.registrar(forPlugin: "URLLauncherPlugin") {
      URLLauncherPlugin.register(with: registrar)
    }
#endif
  }
}
