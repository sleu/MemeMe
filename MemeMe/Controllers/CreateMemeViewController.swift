//
//  CreateMemeViewController.swift
//  MemeMe
//
//  Created by Sean Leu on 8/10/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit



class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    let topText = "TOP"
    let bottomText = "BOTTOM"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField(topTextField, topText)
        setupTextField(bottomTextField, bottomText)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        
        //enables share button
        if(!shareStatus){
            actionShare.isEnabled = false
        } else{
            actionShare.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscriberFromKeyboardNotifications()
    }
    
    //select image from album
    @IBAction func selectImage(_ sender: Any) {
        imagePicker(.photoLibrary)
    }
    
    //select image from camera
    @IBAction func selectImageFromCamera(_ sender: Any){
        imagePicker(.camera)
    }
    func imagePicker(_ type: UIImagePickerControllerSourceType){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = type
        present(picker, animated: true, completion: nil)
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
    
    //move frame when keyboard appears for bottom text
    @objc func keyboardWillShow(_ notification:Notification){
        if bottomTextField.isEditing{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
        
    }

    @objc func keyboardWillHide(_ notification:Notification){
        if bottomTextField.isEditing{
            view.frame.origin.y = 0
        }
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
    
    //save to struct
    func save(_ memed: UIImage){
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: selectedImageView.image!, memedImage: memed)
        
        //add to memes array in appdeledate
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
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
        let memed = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memed], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        if let popOver = activityViewController.popoverPresentationController{
            popOver.sourceView = self.view
        }
        activityViewController.completionWithItemsHandler = {(activityType, success, items, error) in
            if success{
                self.save(memed)
                self.reset()
            }
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
    
    func setupTextField(_ tf: UITextField,_ text: String){
       //textfield attributes
        tf.defaultTextAttributes = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.black,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -4.0,]
        tf.textColor = UIColor.white
        tf.tintColor = UIColor.white
        tf.textAlignment = .center
        tf.text = text
        tf.delegate = self.textFieldDelegate
    }
    
}

