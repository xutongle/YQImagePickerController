//
//  YQImageController.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/24.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class YQImageController: UICollectionViewController {
    
    private var maxImageCount: NSInteger {
    
        didSet {
        
        }
    }
    
    private var columnNumber: NSInteger {
    
        didSet {
        
        }
    }
    
    init(maxImageCount: NSInteger, columnNumber: NSInteger){
        
        self.maxImageCount = maxImageCount
        
        self.columnNumber = columnNumber
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
}


// MARK: UICollectionViewDataSource
extension YQImageController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell
        
        return cell
    }
}
