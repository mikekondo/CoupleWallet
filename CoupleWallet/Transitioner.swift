import UIKit

@MainActor public protocol Transitioner {
    func push(viewController: UIViewController, animated: Bool)
    func push(viewController: UIViewController, stacks: [UIViewController], animated: Bool)
    func popViewControllerSelf(animated: Bool)
    func popTo<T: UIViewController>(_ vcType: T.Type, animated: Bool)
    func contains<T: UIViewController>(_ vcType: T.Type) -> Bool
    func popToRootViewController(animated: Bool)
    func present(viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismissSelf(animated: Bool, completion: (() -> Void)?)
    func stack(viewController: UIViewController)
}

public extension Transitioner where Self: UIViewController {
    private var nav: UINavigationController? {
        let nav: UINavigationController?
        if let navigationController = self as? UINavigationController {
            nav = navigationController
        } else {
            nav = navigationController
        }

        return getNav(nav)
    }

    private func getNav(_ nav: UINavigationController?) -> UINavigationController? {
        if let presentedVC = (nav?.presentedViewController as? UINavigationController)?.viewControllers.last {
            if let presentedNavVC = presentedVC as? UINavigationController {
                return getNav(presentedNavVC)
            } else {
                return getNav(presentedVC.navigationController)
            }
        } else {
            return nav
        }
    }

    func push(viewController: UIViewController, animated: Bool) {
        nav?.pushViewController(viewController, animated: animated)
    }

    func push(viewController: UIViewController, stacks: [UIViewController], animated: Bool) {
        let currentViewControllers = nav?.viewControllers ?? []
        nav?.viewControllers = currentViewControllers + stacks
        nav?.pushViewController(viewController, animated: animated)
    }

    func stack(viewController: UIViewController) {
        let currentViewControllers = nav?.viewControllers ?? []
        nav?.viewControllers = currentViewControllers + [viewController]
    }

    func popViewControllerSelf(animated: Bool) {
        nav?.popViewController(animated: animated)
    }

    func popTo(_ vcType: (some UIViewController).Type, animated: Bool) {
        guard let childs = nav?.viewControllers, let offset = childs
            .enumerated()
            .compactMap({ type(of: $0.element) == vcType ? $0.offset : nil })
            .max() else {
            return
        }
        nav?.popToViewController(childs[offset], animated: true)
    }

    func contains(_ vcType: (some UIViewController).Type) -> Bool {
        guard let navigation = nav else { return false }
        return navigation.viewControllers.contains { vc -> Bool in return type(of: vc) == vcType }
    }

    func popToRootViewController(animated: Bool) {
        nav?.popToRootViewController(animated: animated)
    }

    func present(viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let nav {
            if let tab = nav.tabBarController {
                tab.present(viewController, animated: animated, completion: completion)
            } else {
                nav.present(viewController, animated: animated, completion: completion)
            }
        } else {
            present(viewController, animated: animated, completion: completion)
        }
    }

    func dismissSelf(animated: Bool, completion: (() -> Void)?) {
        if let nav {
            nav.dismiss(animated: animated, completion: completion)
        } else {
            dismiss(animated: animated, completion: completion)
        }
    }
}

extension UIViewController: Transitioner {}
