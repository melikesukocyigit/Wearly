import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Wardrobe
        let wardrobeVM = WardrobeViewModel()
        let wardrobeVC = WardrobeViewController(viewModel: wardrobeVM)
        let wardrobeNav = UINavigationController(rootViewController: wardrobeVC)
        wardrobeNav.tabBarItem = UITabBarItem(
            title: "Wardrobe",
            image: UIImage(systemName: "hanger"),
            selectedImage: UIImage(systemName: "hanger")
        )

        let combos = UIViewController()
        combos.view.backgroundColor = .systemBackground
        combos.title = "Combinations"
        combos.tabBarItem = UITabBarItem(title: "Combos", image: UIImage(systemName: "sparkles"), selectedImage: nil)

        let profile = UIViewController()
        profile.view.backgroundColor = .systemBackground
        profile.title = "Profile"
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), selectedImage: nil)

        viewControllers = [wardrobeNav, combos, profile]
    }
}

