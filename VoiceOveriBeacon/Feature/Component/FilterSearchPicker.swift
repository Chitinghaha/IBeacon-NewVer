//
//  FilterSearchPicker.swift
//  FilterSearchPicker
//
//  Created by 陳邦亢 on 2023/7/4.
//

import Foundation
import UIKit
import Combine

class FilterSearchPicker {
    
    //MARK: - properties for outer setting
    var contentStrings: [String]?
    var searchTitle: String?
    var searchPlaceHolder: String?
    var receiveResultString: ((_ result: String) -> Void)?
    var isSearchViewHidden: Bool?
    var isCancelButtonHidden: Bool?
    var config: FilterSearchPickerConfiguration = LightSearchFilterPickerConfiguration()
    
    func show(on vc: UIViewController) {
        guard let contents = contentStrings
        else { return }
        
        let vm = FilterSearchPickerViewModel(contentsString: contents, config: self.config)
        
        if let searchTitle = searchTitle {
            vm.title = searchTitle
        }
        
        if let searchPlaceHolder = searchPlaceHolder {
            vm.placeHolder = searchPlaceHolder
        }
        
        if let receiveResultString = receiveResultString {
            vm.receiveResultString = receiveResultString
        }
        
        if let isSearchViewHidden = isSearchViewHidden {
            vm.isSearchViewHidden = isSearchViewHidden
        }
          
        if let isCancelButtonHidden = isCancelButtonHidden {
            vm.isCancelButtonHidden = isCancelButtonHidden
        }
        
        let pickerVC = FilterSearchPickerViewController(viewModel: vm)
        
        vc.present(pickerVC, animated: true)
    }
}
