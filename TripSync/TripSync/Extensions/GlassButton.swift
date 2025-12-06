//
//  GlassButton.swift
//  TripSync
//
//  Created by Arpit Garg on 05/12/25.
//

import UIKit

class GlassButton: UIButton {
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
            let existingImagePadding = self.configuration?.imagePadding
            let existingTitleFont = self.configuration?.titleTextAttributesTransformer
            let existingBaseForegroundColor = self.configuration?.baseForegroundColor
            let existingBaseBackgroundColor = self.configuration?.baseBackgroundColor
            
            // Apply glass configuration
            var config = UIButton.Configuration.glass()
            
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
            if let imagePadding = existingImagePadding {
                config.imagePadding = imagePadding
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
            // Fallback for iOS < 26.0: keep storyboard configuration as-is
            // The plain/filled style from storyboard will be used
            // Just ensure text color is set properly
            if self.configuration?.baseForegroundColor == nil {
                var config = self.configuration ?? UIButton.Configuration.plain()
                config.baseForegroundColor = .label
                self.configuration = config
            }
        }
    }
}
