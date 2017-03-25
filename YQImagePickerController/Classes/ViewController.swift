//
//  ViewController.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/11.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnDidClick(_ sender: Any) {
        
        let picker = YQImagePickerController(delegate: self)
        
        self.present(picker, animated: true, completion: nil)
        
    }
}

//MARK:- YQImagePickerControllerDelegate


extension ViewController: YQImagePickerControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: YQImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: Any!) {
        
    }
    
    func imagePickerController(_ picker: YQImagePickerController!, didFinishPickingGifImage animatedImage: UIImage!, sourceAssets asset: Any!) {
        
    }
    
    func imagePickerController(_ picker: YQImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
    }
    
    func imagePickerControllerDidClickCancelButton(_ picker: YQImagePickerController!) {
        
    }
}

