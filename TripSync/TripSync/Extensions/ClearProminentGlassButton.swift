//
//  ClearProminentGlassButton.swift
//  TripSync
//
//  Created by Arpit Garg on 05/12/25.
//

import UIKit

class ClearProminentGlassButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        if #available(iOS 26.0, *) {
            // Preserve existing configuration properties from storyboard
            let existingTitle = self.configuration?.title
            let existingAttributedTitle = self.configuration?.attributedTitle
            let existingImage = self.configuration?.image
            let existingTitleFont = self.configuration?.titleTextAttributesTransformer
            let existingBaseForegroundColor = self.configuration?.baseForegroundColor
            let existingBaseBackgroundColor = self.configuration?.baseBackgroundColor
            
            // Apply clear glass configuration
            var config = UIButton.Configuration.prominentClearGlass()
            
            // Restore storyboard properties
            if let title = existingTitle {
                config.title = title
            }
            if let attributedTitle = existingAttributedTitle {
                config.attributedTitle = attributedTitle
            }
            if let image = existingImage {
                config.image = image
            }
            if let font = existingTitleFont {
                config.titleTextAttributesTransformer = font
            }
            if let fgColor = existingBaseForegroundColor {
                config.baseForegroundColor = fgColor
            }
            if let bgColor = existingBaseBackgroundColor {
                config.baseBackgroundColor = bgColor
            }
            
            self.configuration = config
        } else {
            // Fallback for iOS < 26.0: use plain style with clear background
            if self.configuration == nil {
                var config = UIButton.Configuration.plain()
                config.background.backgroundColor = .clear
                self.configuration = config
            }
        }
    }
}
