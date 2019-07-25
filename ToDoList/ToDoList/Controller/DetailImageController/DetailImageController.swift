//
//  DetailImageController.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/24/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import SDWebImage

class DetailImageController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    var arrURLs = [URL]()
    var imgChoiced: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.collectionView!.register(DetailImageCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let img = imgChoiced else {return}
        if let index = arrURLs.firstIndex(of: img) {
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as DetailImageCell
        cell.config(path: arrURLs[indexPath.row])
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //For entire screen size
        let screenSize = UIScreen.main.bounds.size
        return screenSize
    }
    
}
