//
//  CategoryViewCell.swift
//  GameApp
//
//  Created by Alperen Arıcı on 25.05.2021.
//

import UIKit

final class CategoryViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }

    func setUI() {
        categoryView.layer.cornerRadius = 4
    }

    func configure(name: String, bgColor: UIColor, textColor: UIColor) {
        categoryName.text = name
        categoryView.backgroundColor = bgColor
        categoryName.textColor = textColor
    }
}
