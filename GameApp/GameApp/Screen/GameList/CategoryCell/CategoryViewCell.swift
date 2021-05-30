//
//  CategoryViewCell.swift
//  GameApp
//
//  Created by Alperen Arıcı on 25.05.2021.
//

import UIKit

extension CategoryViewCell {
    private enum Constants {
        static let categoryUnselectedColor = UIColor(red: 45 / 255, green: 45 / 255, blue: 45 / 255, alpha: 1)
        static let categorySelectedColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1)
    }
}

final class CategoryViewCell: UICollectionViewCell {
    @IBOutlet private weak var categoryName: UILabel!
    @IBOutlet private weak var categoryView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
        
    }

    func setUI() {
        categoryView.layer.cornerRadius = 4
    }

    func configure(name: String,bgColor: UIColor, textColor: UIColor) {
        categoryName.text = name
        categoryView.backgroundColor = bgColor
        categoryName.textColor = textColor
    }
}
