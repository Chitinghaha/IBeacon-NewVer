//
//  UIView+Nib.swift
//  HiQ
//
//  Created by 陳邦亢 on 2023/7/19.
//

import Foundation
import UIKit

extension UIView {
    /// Load custom view from xib
    /// - Parameter nibName: (Optional) xib name
    /// - Returns: Custom view
    ///
    /// Example:
    ///
    ///     let theView = SomeCustomView.loadFromNib()
    class func loadFromNib(nibName: String? = nil) -> Self {
        let nibName = nibName ?? String(describing: Self.self)
        guard let nib = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil) else {
            fatalError("missing expected nib named: \(nibName)")
        }
        guard let view = nib.first as? Self else {
            fatalError("view of type \(Self.self) not found in \(nib)")
        }
        return view
    }
    
    @discardableResult
    func addViewFromNib<T : UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
            return nil
        }
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        return contentView
    }
}
