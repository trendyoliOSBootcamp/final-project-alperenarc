//
//  UICollectionView+Loading.swift
//  GameApp
//
//  Created by Alperen Arıcı on 27.05.2021.
//

import UIKit

extension UICollectionView {
    func setLoading() {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .white
        self.backgroundView = activityIndicatorView
        activityIndicatorView.startAnimating()
    }
    func restore() {
        self.backgroundView = nil
    }
}
