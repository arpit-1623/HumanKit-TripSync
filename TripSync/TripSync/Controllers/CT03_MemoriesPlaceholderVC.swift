//
//  CT03_MemoriesPlaceholderVC.swift
//  TripSync
//
//  Created on 26/11/2025.
//

import UIKit

class CT03_MemoriesPlaceholderVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation title
        self.title = "Memories"
        
        // Configure appearance
        setupUI()
    }
    
    private func setupUI() {
        // Background color matching app theme
        view.backgroundColor = UIColor(named: "BgColor") ?? .systemBackground
    }
}
