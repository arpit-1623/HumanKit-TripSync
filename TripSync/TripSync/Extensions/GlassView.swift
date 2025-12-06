//
//  GlassView.swift
//  TripSync
//
//  Created by Arpit Garg on 05/12/25.
//

import UIKit

class GlassView: UIVisualEffectView {
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        setupView()
    }
    
    convenience init() {
        self.init(effect: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        if #available(iOS 26.0, *) {
            let glassEffect = UIGlassEffect()
            self.effect = glassEffect
        } else {
            self.effect = UIBlurEffect(style: .systemThinMaterial)
        }
        
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
    }
}
