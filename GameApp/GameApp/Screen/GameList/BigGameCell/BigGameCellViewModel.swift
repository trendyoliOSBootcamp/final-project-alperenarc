//
//  BigGameCellViewModel.swift
//  GameApp
//
//  Created by Alperen Arıcı on 27.05.2021.
//

import Foundation

// MARK: - BigGameCellViewModelProtocol
protocol BigGameCellViewModelProtocol {
    var delegate: BigGameCellViewModelDelegate? { get set }
    var getWishListStatus: Bool { get }
    func load()
}

// MARK: - BigGameCellViewModelDelegate
protocol BigGameCellViewModelDelegate: AnyObject {
    func prepareNameLabel(name: String)
    func preparePlayTime(playTime: Int?)
    func prepareReleaseDate(release: String?)
    func prepareGenreLabel(genres: [GameGenre]?)
    func prepareBadges(platforms: [ParentPlatform])
    func setBadgeLabels(name: String, index: Int)
    func prepareMetacriticLabel(metacritic: Int)
    func prepareImage(urlString: String?)
    func prepareWishListButton(wishListStatus: Bool?)
}

// MARK: - BigGameCellViewModel
final class BigGameCellViewModel {
    weak var delegate: BigGameCellViewModelDelegate?
    private let gameResult: GameResult?
    private var wishListStatus: Bool = false

    init(gameResult: GameResult?, wishListStatus: Bool) {
        self.gameResult = gameResult
        self.wishListStatus = wishListStatus
    }
}

// MARK: - BigGameCellViewModelProtocol
extension BigGameCellViewModel: BigGameCellViewModelProtocol {
    var getWishListStatus: Bool { self.wishListStatus }

    func load() {
        guard let name = gameResult?.name, let backgroundImage = gameResult?.backgroundImage, let metacritic = gameResult?.metacritic, let platforms = gameResult?.parentPlatforms else { return }
        delegate?.prepareGenreLabel(genres: gameResult?.genres)
        delegate?.prepareImage(urlString: backgroundImage)
        delegate?.prepareReleaseDate(release: gameResult?.released)
        delegate?.prepareMetacriticLabel(metacritic: metacritic)
        delegate?.prepareBadges(platforms: platforms)
        delegate?.preparePlayTime(playTime: gameResult?.playtime)
        delegate?.prepareNameLabel(name: name)
        delegate?.prepareWishListButton(wishListStatus: wishListStatus)
    }

}
