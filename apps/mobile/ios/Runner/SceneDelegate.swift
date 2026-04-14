import Flutter
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }

    let flutterViewController: FlutterViewController
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      print("LR iOS SceneDelegate using shared FlutterEngine")
      flutterViewController = FlutterViewController(
        engine: appDelegate.flutterEngine,
        nibName: nil,
        bundle: nil
      )
    } else {
      print("LR iOS SceneDelegate fallback FlutterViewController")
      flutterViewController = FlutterViewController()
    }

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = flutterViewController
    window.makeKeyAndVisible()
    self.window = window
  }
}
