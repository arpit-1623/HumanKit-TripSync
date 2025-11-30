//
//  CS01_ChatContainerVC.swift
//  TripSync
//
//  Created by GitHub Copilot on 26/11/25.
//

import UIKit

class ChatContainerViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Properties
    var trip: Trip?
    
    private var generalChatVC: GeneralChatViewController?
    private var subgroupsListVC: SubgroupsListViewController?
    private var alertsVC: AlertsViewController?
    
    private var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        setupChildViewControllers()
        showViewController(at: 0)
    }
    
    // MARK: - Setup
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "General", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Subgroups", at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: "Alerts", at: 2, animated: false)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    private func setupChildViewControllers() {
        // Load all child VCs from storyboard
        let chatStoryboard = UIStoryboard(name: "SA07_ChatGeneral", bundle: nil)
        
        if let generalVC = chatStoryboard.instantiateViewController(withIdentifier: "GeneralChatViewController") as? GeneralChatViewController {
            generalVC.trip = self.trip
            generalChatVC = generalVC
        }
        
        if let subgroupsVC = chatStoryboard.instantiateViewController(withIdentifier: "SubgroupsListViewController") as? SubgroupsListViewController {
            subgroupsVC.trip = self.trip
            subgroupsListVC = subgroupsVC
        }
        
        if let alertVC = chatStoryboard.instantiateViewController(withIdentifier: "AlertsViewController") as? AlertsViewController {
            alertVC.trip = self.trip
            alertsVC = alertVC
        }
    }
    
    private func showViewController(at index: Int) {
        // Remove current view controller
        if let current = currentViewController {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        // Determine which view controller to show
        var viewControllerToShow: UIViewController?
        
        switch index {
        case 0:
            viewControllerToShow = generalChatVC
        case 1:
            viewControllerToShow = subgroupsListVC
        case 2:
            viewControllerToShow = alertsVC
        default:
            break
        }
        
        // Add new view controller
        if let vcToShow = viewControllerToShow {
            addChild(vcToShow)
            vcToShow.view.frame = containerView.bounds
            vcToShow.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(vcToShow.view)
            vcToShow.didMove(toParent: self)
            currentViewController = vcToShow
        }
    }
    
    // MARK: - Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        showViewController(at: sender.selectedSegmentIndex)
    }
    
}
