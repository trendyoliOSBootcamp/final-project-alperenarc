//
//  SmallGameCell.swift
//  GameApp
//
//  Created by Alperen Arıcı on 27.05.2021.
//

import UIKit
import SDWebImage

extension SmallGameCell {
    enum Constants {
        static let wishListButtonPadding: CGFloat = 10
        static let wishListRadius: CGFloat = 4
        static let containerRadius: CGFloat = 8
    }
}

final class SmallGameCell: UICollectionViewCell {
    @IBOutlet private weak var gameImage: UIImageView!
    @IBOutlet private weak var gameName: UILabel!
    @IBOutlet private weak var wishListContainer: UIView!
    @IBOutlet weak var wishListButton: UIButton!
    @IBOutlet weak var nameContainer: UIView!

    var viewModel: SmallGameCellViewModelProtocol! {
        didSet {
            viewModel.delegate = self
            viewModel.load()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func setupUI() {
        let wishImage = UIImage(named: "gift")
        let tintedImage = wishImage?.withRenderingMode(.alwaysTemplate)
        wishListButton.setImage(tintedImage, for: .normal)
        wishListButton.tintColor = .white
        wishListButton.contentVerticalAlignment = .fill
        wishListButton.contentHorizontalAlignment = .fill
        wishListButton.imageEdgeInsets = UIEdgeInsets(top: Constants.wishListButtonPadding, left: Constants.wishListButtonPadding, bottom: Constants.wishListButtonPadding, right: Constants.wishListButtonPadding)
        wishListContainer.layer.cornerRadius = Constants.wishListRadius
        gameImage.layer.cornerRadius = Constants.containerRadius
        gameImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        nameContainer.layer.cornerRadius = Constants.containerRadius
        nameContainer.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
}

extension SmallGameCell: SmallGameCellViewModelDelegate {
    func prepareWishListButton(wishListStatus: Bool) {
        if wishListStatus {
            wishListContainer.layer.backgroundColor = .init(srgbRed: 93 / 255, green: 197 / 255, blue: 52 / 255, alpha: 1)
        } else {
            wishListContainer.layer.backgroundColor = .init(srgbRed: 55 / 255, green: 55 / 255, blue: 55 / 255, alpha: 1)
        }
    }

    func prepareImage(image: String) {
        let photoURL = URL(string: image)
        self.gameImage.sd_setImage(with: photoURL)
    }

    func prepareName(name: String, isClicked: Bool) {
        self.gameName.text = name
        if isClicked {
            self.gameName.textColor = UIColor(red: 118 / 255, green: 118 / 255, blue: 118 / 255, alpha: 1)
        } else {
            self.gameName.textColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1)
        }
    }

    func changeNameColor() {
        gameName.textColor = UIColor(red: 118 / 255, green: 118 / 255, blue: 118 / 255, alpha: 1)
    }
}
