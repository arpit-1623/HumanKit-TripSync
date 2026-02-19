//
//  HidesTabBarNavigationController.swift
//  TripSync
//
//  Created by TripSync on 18/02/26.
//

import UIKit

/// A UINavigationController subclass that automatically hides the tab bar
/// when any view controller is pushed onto the stack (i.e., any screen
/// beyond the root). The tab bar reappears when returning to the root.
class HidesTabBarNavigationController: UINavigationController {

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = true
        super.pushViewController(viewController, animated: animated)
    }
}
