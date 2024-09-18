import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private enum Constants {
        static let loginNavigationControllerIdentifier = "LoginNavigationController"
        static let feedNavigationControllerIdentifier = "FeedNavigationController"
        static let storyboardIdentifier = "Main"
    }

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Initialize the window
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()

        // Add observer for login/logout notifications
        NotificationCenter.default.addObserver(forName: Notification.Name("login"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.login()
        }

        NotificationCenter.default.addObserver(forName: Notification.Name("logout"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.logOut()
        }

        // Check for cached user for persisted login
        if User.current != nil {
            login()
        } else {
            logOut()
        }

        // Set dark mode
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .dark
        }
    }

    private func login() {
        let storyboard = UIStoryboard(name: Constants.storyboardIdentifier, bundle: nil)
        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: Constants.feedNavigationControllerIdentifier)
    }

    private func logOut() {
        User.logout { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: Constants.storyboardIdentifier, bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: Constants.loginNavigationControllerIdentifier)
                    self?.window?.rootViewController = viewController
                }
            case .failure(let error):
                print("❌ Log out error: \(error)")
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
