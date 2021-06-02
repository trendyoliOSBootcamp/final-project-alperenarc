//
//  BigGameCell.swift
//  GameApp
//
//  Created by Alperen Arıcı on 26.05.2021.
//

import UIKit
import SDWebImage

extension BigGameCell {
    enum Constants {
        static let wishListButtonPadding: CGFloat = 10
        static let containerCornerRadius: CGFloat = 8
        static let metacriticBorderWidth: CGFloat = 0.5
        static let maxPlatformCount = 3
        static let metacriticHigh = 75 ... 100
        static let metacriticMedium = 50 ... 75
        static let metacriticLow = 0 ... 50
    }
}

final class BigGameCell: UICollectionViewCell {

    @IBOutlet private weak var gameImage: UIImageView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var releaseDate: UILabel!
    @IBOutlet private weak var genres: UILabel!
    @IBOutlet private weak var playTime: UILabel!
    @IBOutlet private weak var metacritic: UILabel!
    @IBOutlet private weak var metacriticContainer: UIView!
    @IBOutlet weak var wishListView: UIView!
    @IBOutlet weak var wishListButton: UIButton!
    @IBOutlet private weak var descriptionContainer: UIView!
    @IBOutlet private weak var genreView: UIStackView!
    @IBOutlet private weak var releaseDateView: UIStackView!
    @IBOutlet private weak var playTimeView: UIStackView!
    @IBOutlet private weak var firstBadge: UIView!
    @IBOutlet private weak var firstBadgeLabel: UILabel!
    @IBOutlet private weak var secondBadge: UIView!
    @IBOutlet private weak var secondBadgeLabel: UILabel!
    @IBOutlet private weak var thirdBadge: UIView!
    @IBOutlet private weak var thirdBadgeLabel: UILabel!
    @IBOutlet private weak var plusBadge: UIView!
    @IBOutlet private weak var plusBadgeLabel: UILabel!

    var viewModel: BigGameCellViewModelProtocol! {
        didSet {
            viewModel.delegate = self
            viewModel.load()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        descriptionContainer.clipsToBounds = true
        descriptionContainer.layer.cornerRadius = Constants.containerCornerRadius
        descriptionContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gameImage.clipsToBounds = true
        gameImage.layer.cornerRadius = Constants.containerCornerRadius
        gameImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        wishListView.layer.cornerRadius = Constants.containerCornerRadius / 2
        let wishImage = UIImage(named: "gift")
        let tintedImage = wishImage?.withRenderingMode(.alwaysTemplate)
        wishListButton.setImage(tintedImage, for: .normal)
        wishListButton.tintColor = .white
        wishListButton.contentVerticalAlignment = .fill
        wishListButton.contentHorizontalAlignment = .fill
        wishListButton.imageEdgeInsets = UIEdgeInsets(top: Constants.wishListButtonPadding, left: Constants.wishListButtonPadding, bottom: Constants.wishListButtonPadding, right: Constants.wishListButtonPadding)
        metacriticContainer.layer.cornerRadius = Constants.containerCornerRadius / 2
        metacriticContainer.layer.borderWidth = Constants.metacriticBorderWidth

    }
}

// MARK: - BigGameCellViewModelDelegate
extension BigGameCell: BigGameCellViewModelDelegate {
    func prepareNameLabel(name: String, isClicked: Bool) {
        self.name.text = name
        if isClicked {
            self.name.textColor = UIColor(red: 118 / 255, green: 118 / 255, blue: 118 / 255, alpha: 1)
        } else {
            self.name.textColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1)
        }
    }

    func preparePlayTime(playTime: Int?) {
        if let playTime = playTime {
            self.playTime.text = "\(playTime) hours"
            self.playTimeView.isHidden = false
        } else {
            self.playTimeView.isHidden = true
        }
    }

    func prepareReleaseDate(release: String?) {
        if let release = release {
            self.releaseDate.text = release.dateFormatMMMdyy()
            self.releaseDateView.isHidden = false
        } else {

            self.releaseDateView.isHidden = true
        }
    }

    func prepareGenreLabel(genres: [GameGenre]?) {
        if let genres = genres {
            var genreString = ""
            for genre in genres {
                guard let name = genre.name else { return }
                if genre == genres.last {
                    genreString += name
                } else {
                    genreString += "\(name), "
                }
            }
            self.genres.text = genreString
            self.genreView.isHidden = false
        } else {
            self.genreView.isHidden = true
        }

    }

    func prepareBadges(platforms: [ParentPlatform]) {
        var count = platforms.count
        if count > Constants.maxPlatformCount {
            plusBadgeLabel.text = "+\(count - Constants.maxPlatformCount)"
            count = Constants.maxPlatformCount
        } else {
            plusBadge.isHidden = true
        }

        for index in 0...count - 1 {
            guard let platform = platforms[index].platform else { return }
            setBadgeLabels(name: platform.name ?? "", index: index)
        }
    }

    func setBadgeLabels(name: String, index: Int) {
        switch index {
        case 0:
            firstBadgeLabel.text = name
            secondBadge.isHidden = true
            thirdBadge.isHidden = true
        case 1:
            secondBadgeLabel.text = name
            secondBadge.isHidden = false
            thirdBadge.isHidden = true
        case 2:
            thirdBadgeLabel.text = name
            thirdBadge.isHidden = false
        default:
            break
        }
    }

    func prepareMetacriticLabel(metacritic: Int) {
        if Constants.metacriticHigh ~= metacritic {
            self.metacritic.textColor = UIColor(ciColor: .green)
            metacriticContainer.layer.borderColor = UIColor(ciColor: .green).cgColor
        }
        if Constants.metacriticMedium ~= metacritic {
            self.metacritic.textColor = UIColor(ciColor: .yellow)
            metacriticContainer.layer.borderColor = UIColor(ciColor: .yellow).cgColor
        }
        if Constants.metacriticLow ~= metacritic {
            self.metacritic.textColor = UIColor(ciColor: .red)
            metacriticContainer.layer.borderColor = UIColor(ciColor: .red).cgColor
        }
        self.metacritic.text = "\(metacritic)"
    }

    func prepareImage(urlString: String?) {
        guard let urlString = urlString else { return }
        let photoURL = URL(string: urlString)
        self.gameImage.sd_setImage(with: photoURL)
    }

    func prepareWishListButton(wishListStatus: Bool?) {
        guard let status = wishListStatus else { return }
        if status {
            wishListView.layer.backgroundColor = .init(srgbRed: 93 / 255, green: 197 / 255, blue: 52 / 255, alpha: 1)
        } else {
            wishListView.layer.backgroundColor = .init(srgbRed: 55 / 255, green: 55 / 255, blue: 55 / 255, alpha: 1)
        }
    }

    func changeNameColor() {
        name.textColor = UIColor(red: 118 / 255, green: 118 / 255, blue: 118 / 255, alpha: 1)
    }
}
