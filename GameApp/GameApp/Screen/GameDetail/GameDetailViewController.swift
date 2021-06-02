//
//  GameDetailViewController.swift
//  GameApp
//
//  Created by Alperen Arıcı on 30.05.2021.
//

import UIKit
import SDWebImage

extension GameDetailViewController {
    private enum Constants {
        enum Description {
            static let descriptionTextBottomConstant: CGFloat = 5
            static let descriptionBottomConstant: CGFloat = 12
            static let maxLine = 4
        }
        enum Metacritic {
            static let metacriticHigh = 75 ... 100
            static let metacriticMedium = 50 ... 75
            static let metacriticLow = 0 ... 50
        }
        static let outerViewHeight: CGFloat = 120
        static let innerTextViewHeight: CGFloat = 70
        static let containerRadius: CGFloat = 8
        static let metacriticBorderWidth: CGFloat = 0.5
        static let backgroundColor: CGColor = .init(red: 50 / 255, green: 50 / 255, blue: 50 / 255, alpha: 1)
        static let informationViewBgColor: UIColor = .init(red: 39 / 255, green: 39 / 255, blue: 39 / 255, alpha: 1)
    }
}

private extension UIView {
    func addBottomBorderWithColor() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 12, y: self.frame.size.height - 0.5, width: self.frame.size.width - 24, height: 0.5)
        bottomBorder.backgroundColor = UIColor(red: 50 / 255, green: 50 / 255, blue: 50 / 255, alpha: 1).cgColor
        self.layer.addSublayer(bottomBorder)
        self.clipsToBounds = true
    }
}

private extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }

    func customize(backgroundColor: UIColor = .clear, radiusSize: CGFloat = 0) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = backgroundColor
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
        subView.layer.cornerRadius = radiusSize
        subView.layer.masksToBounds = true
        subView.clipsToBounds = true
    }
}

final class GameDetailViewController: UIViewController, LoadingShowable {
    @IBOutlet private weak var descriptionView: UIView!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var descriptionViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var descriptionTextViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var descriptionTextBottomConstant: NSLayoutConstraint!
    @IBOutlet private weak var releaseDateView: UIView!
    @IBOutlet private weak var genresView: UIView!
    @IBOutlet private weak var playTimeView: UIView!
    @IBOutlet private weak var publishersView: UIView!
    @IBOutlet private weak var informationView: UIStackView!
    @IBOutlet private weak var visitRedditContainer: UIView!
    @IBOutlet private weak var visitWebsiteContainer: UIView!
    @IBOutlet private weak var metacriticContainer: UIView!
    @IBOutlet private weak var metacriticText: UILabel!
    @IBOutlet private weak var bannerImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var playTimeLabel: UILabel!
    @IBOutlet private weak var publishersLabel: UILabel!
    @IBOutlet private weak var wishButton: UIButton!

    private var isDescriptionExpand = true
    private var redditLink: String?
    private var websiteLink: String?

    var viewModel: GameDetailViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.load()
        viewModel.fecthSingleGame { [weak self] in
            self?.viewModel.setPageDatas()
        }
    }

    @objc private func expandDescription() {
        expandDescriptionView()
    }

    @IBAction func wishListButtonAction() {
        guard let id = viewModel.game?.id else { return }
        viewModel.addOrRemoveWishList(id: id)
    }

    @objc private func openRedditUrl() {
        if let url = URL(string: redditLink ?? "") {
            UIApplication.shared.open(url)
        }
    }

    @objc private func openWebsiteUrl() {
        if let url = URL(string: websiteLink ?? "") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - GameDetailViewModelDelegate
extension GameDetailViewController: GameDetailViewModelDelegate {

    func changeWishButtonStatus() {
        wishButton.tintColor = viewModel.wishStatus ? UIColor(red: 93 / 255, green: 197 / 255, blue: 52 / 255, alpha: 1):
            UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }

    func setWishButtonUI() {
        let wishImage = UIImage(named: "gift")
        let tintedImage = wishImage?.withRenderingMode(.alwaysTemplate)
        wishButton.setImage(tintedImage, for: .normal)
        wishButton.tintColor = viewModel.wishStatus ? UIColor(red: 93 / 255, green: 197 / 255, blue: 52 / 255, alpha: 1):
            UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }

    func loadingShow() {
        showLoading()
    }

    func loadingHide() {
        hideLoading()
    }

    func setImage(image: String) {
        let imageUrl = URL(string: image)
        bannerImageView.sd_setImage(with: imageUrl, completed: nil)
    }

    func setName(name: String) {
        nameLabel.text = name
    }

    func setMetacritic(metacritic: Int) {
        if Constants.Metacritic.metacriticHigh ~= metacritic {
            metacriticText.textColor = UIColor(ciColor: .green)
            metacriticContainer.layer.borderColor = UIColor(ciColor: .green).cgColor
        }
        if Constants.Metacritic.metacriticMedium ~= metacritic {
            metacriticText.textColor = UIColor(ciColor: .yellow)
            metacriticContainer.layer.borderColor = UIColor(ciColor: .yellow).cgColor
        }
        if Constants.Metacritic.metacriticLow ~= metacritic {
            metacriticText.textColor = UIColor(ciColor: .red)
            metacriticContainer.layer.borderColor = UIColor(ciColor: .red).cgColor
        }
        metacriticText.text = "\(metacritic)"
    }

    func setDescription(description: String) {
        descriptionTextView.text = description
    }

    func setInformation(releaseDate: String?, genres: [Developer]?, playtime: Int?, publishers: [Developer]?) {
        if let released = releaseDate {
            releaseDateView.isHidden = false
            releaseDateLabel.text = released.dateFormatMMMdyy()
        } else { releaseDateView.isHidden = true }

        if let genres = genres {
            var genreStr = ""
            genres.forEach { genre in
                guard let name = genre.name else { return }
                if name == genres.last?.name {
                    genreStr.append("\(name)")
                } else {
                    genreStr.append("\(name), ")
                }
            }
            genresLabel.text = genreStr
            genresView.isHidden = false
        } else { genresView.isHidden = true }

        if let playtime = playtime {
            playTimeLabel.text = "\(playtime) hours"
            playTimeView.isHidden = false
        } else { playTimeView.isHidden = true }

        if let publishers = publishers {
            var devStr = ""
            publishers.forEach { developer in
                guard let name = developer.name else { return }
                devStr.append(name)
            }
            publishersLabel.text = devStr
            publishersView.isHidden = false
        } else { publishersView.isHidden = true }
    }

    func setUrls(reddit: String?, website: String?) {
        // TODO
        if let redditUrl = reddit {
            visitRedditContainer.isHidden = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.openRedditUrl))
            visitRedditContainer.addGestureRecognizer(tap)
            redditLink = redditUrl
        } else { visitRedditContainer.isHidden = true }

        if let website = website {
            visitWebsiteContainer.isHidden = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.openWebsiteUrl))
            visitWebsiteContainer.addGestureRecognizer(tap)
            websiteLink = website

        } else { visitWebsiteContainer.isHidden = true }

    }

    func setMetacriticUI() {
        metacriticContainer.layer.cornerRadius = Constants.containerRadius / 2
        metacriticContainer.layer.borderWidth = Constants.metacriticBorderWidth
        metacriticContainer.layer.borderColor = UIColor.green.cgColor
    }

    func setLinksUI() {
        visitRedditContainer.layer.cornerRadius = Constants.containerRadius
        visitWebsiteContainer.layer.cornerRadius = Constants.containerRadius
    }

    func setInformationViewUI() {
        releaseDateView.addBottomBorderWithColor()
        genresView.addBottomBorderWithColor()
        playTimeView.addBottomBorderWithColor()
        publishersView.addBottomBorderWithColor()
        informationView.customize(backgroundColor: Constants.informationViewBgColor, radiusSize: Constants.containerRadius)
    }

    func setDescriptionViewUI() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandDescription))
        descriptionTextView.addGestureRecognizer(tapRecognizer)
        descriptionView.layer.cornerRadius = Constants.containerRadius
        descriptionTextView.textContainerInset.top = .zero
        descriptionTextView.textContainerInset.bottom = .zero
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.textContainer.maximumNumberOfLines = Constants.Description.maxLine
        descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
    }

    func expandDescriptionView() {
        if isDescriptionExpand {
            descriptionTextView.isScrollEnabled = true
            descriptionTextView.textContainer.maximumNumberOfLines = .zero
            descriptionTextView.textContainer.lineBreakMode = .byWordWrapping
            descriptionTextViewHeight.constant = descriptionTextView.contentSize.height
            descriptionViewHeight.constant = Constants.outerViewHeight + (Constants.Description.descriptionBottomConstant - Constants.Description.descriptionTextBottomConstant) + (descriptionTextView.contentSize.height - Constants.innerTextViewHeight)
            descriptionTextBottomConstant.constant = Constants.Description.descriptionBottomConstant
        } else {
            descriptionTextView.isScrollEnabled = false
            descriptionTextView.textContainer.maximumNumberOfLines = Constants.Description.maxLine
            descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
            descriptionTextViewHeight.constant = Constants.innerTextViewHeight
            descriptionViewHeight.constant = Constants.outerViewHeight
            descriptionTextBottomConstant.constant = Constants.Description.descriptionTextBottomConstant
        }
        isDescriptionExpand = !isDescriptionExpand
    }

}
