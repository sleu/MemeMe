//
//  TextFieldDelegate.swift
//  MemeMe
//
//  Created by Sean Leu on 8/20/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    //clears intital text
    func textFieldDidBeginEditing(_ textField:UITextField){
        if(textField.text == "TOP" || textField.text == "BOTTOM"){
            textField.text = ""
        }
    }
    //dismisses keyboard
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
}
