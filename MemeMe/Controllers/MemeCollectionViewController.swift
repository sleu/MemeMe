//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Sean Leu on 9/12/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController{
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    @IBOutlet weak var flowLayour: UICollectionViewFlowLayout!
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
}



