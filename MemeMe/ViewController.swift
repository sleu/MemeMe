//
//  ViewController.swift
//  MemeMe
//
//  Created by Sean Leu on 8/10/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var actionShare: UIBarButtonItem!
    
    
    let textFieldDelegate = TextFieldDelegate()
    var shareStatus = false
    
    struct Meme{
        let topText: String
        let bottomText: String
        let originalImage: UIImage
        let memedImage: UIImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set textlabel initial text
        //set textlabel Impact font, all caps, white with a black outline use defaultTextAttributes
        //textFieldDidBeginEditing to clear text field of Default text only not user entered text
        //textfieldshouldreturn to dismiss keyboard
        
        //text field attributes
        let memeTextAttributes:[String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: 10,
        ]
        //setting default text field attributes
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        //setting delegate
        self.topTextField.delegate = self.textFieldDelegate
        self.bottomTextField.delegate = self.textFieldDelegate
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        if(!shareStatus){
            actionShare.isEnabled = false
        } else{
            actionShare.isEnabled = true
        }
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscriberFromKeyboardNotifications()
    }
    
    //select image from album
    @IBAction func selectImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        shareStatus = true
    }
    
    @IBAction func selectImageFromCamera(_sender: Any){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        shareStatus = true
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageView.contentMode = .scaleAspectFit //change images scale
            selectedImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //move frame when keyboard appears
    @objc func keyboardWillShow(_ notification:Notification){
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    //keyboard sign up to be notified
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    
    //unsub keyboard
    func unsubscriberFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    func save() -> UIImage{
        let memeImage = generateMemedImage()
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: selectedImageView.image!, memedImage: memeImage)
        
        return meme.memedImage
    }
    
    //create image
    func generateMemedImage() -> UIImage {
        
        //hide toolbar
        self.topToolbar.isHidden = true
        self.bottomToolbar.isHidden = true
        
        //render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //show toolbar
        self.topToolbar.isHidden = false
        self.bottomToolbar.isHidden = false
        
        return memedImage
    }
    
    //share button triggers save
    @IBAction func share(_ sender: Any) {
        let memed = save()
        let activityViewController = UIActivityViewController(activityItems: [memed], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        if let popOver = activityViewController.popoverPresentationController{
            popOver.sourceView = self.view
        }
        activityViewController.completionWithItemsHandler = {(activityType, success, items, error) in
            if success{
                print("ok cool")
            }
            
            self.reset()
        }
    }
    //returns to default
    func reset(){
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        selectedImageView.image = nil
        shareStatus = false
        actionShare.isEnabled = false
    }
    @IBAction func cancel(_ sender: Any) {
        self.reset()
    }
    
}

