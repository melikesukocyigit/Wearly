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

        // Combinations (DI: gardırop sağlayıcısını enjekte et)
        let combosVC = CombinationsViewController()
        combosVC.title = "Combinations"
        combosVC.wardrobeProvider = { wardrobeVM.allItems }
        let combosNav = UINavigationController(rootViewController: combosVC)
        combosNav.tabBarItem = UITabBarItem(
            title: "Combinations",
            image: UIImage(systemName: "sparkles"),
            selectedImage: UIImage(systemName: "sparkles")
        )

        // Profile (placeholder)
        let profile = UIViewController()
        profile.view.backgroundColor = .systemBackground
        profile.title = "Profile"
        let profileNav = UINavigationController(rootViewController: profile)
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle")
        )

        viewControllers = [wardrobeNav, combosNav, profileNav]
    }
}

