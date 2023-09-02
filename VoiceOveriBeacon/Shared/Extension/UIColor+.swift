//
//  UIColor+.swift
//  TactileMap
//
//  Created by 陳邦亢 on 2023/8/31.
//

import Foundation
import UIKit

extension UIColor {
    func complementaryColor() -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let complementaryRed = 1.0 - red
        let complementaryGreen = 1.0 - green
        let complementaryBlue = 1.0 - blue
        
        return UIColor(red: complementaryRed, green: complementaryGreen, blue: complementaryBlue, alpha: alpha)
    }
    
    func complementaryColorWithBrightnessDifference(brightnessDifference: CGFloat) -> UIColor {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            let complementaryRed = 1.0 - red
            let complementaryGreen = 1.0 - green
            let complementaryBlue = 1.0 - blue
            
            let adjustedRed = red + (complementaryRed - red) * brightnessDifference
            let adjustedGreen = green + (complementaryGreen - green) * brightnessDifference
            let adjustedBlue = blue + (complementaryBlue - blue) * brightnessDifference
            
            return UIColor(red: adjustedRed, green: adjustedGreen, blue: adjustedBlue, alpha: alpha)
        }
}
