//
//  GameDetailViewModel.swift
//  GameApp
//
//  Created by Alperen Arıcı on 30.05.2021.
//

import Foundation
import CoreNetwork

protocol GameDetailViewModelProtocol {
    var delegate: GameDetailViewModelDelegate? { get set }
    var game: Game? { get set }
    func load()
    func addOrRemoveWishList(id: Int)
    func fecthSingleGame(completion: @escaping () -> ())
    func setPageDatas()
    var wishStatus: Bool { get set }
}

protocol GameDetailViewModelDelegate: AnyObject {
    func setMetacriticUI()
    func setLinksUI()
    func setInformationViewUI()
    func setDescriptionViewUI()
    func setWishButtonUI()
    func changeWishButtonStatus()
    func expandDescriptionView()
    func setImage(image: String)
    func setName(name: String)
    func setMetacritic(metacritic: Int)
    func setDescription(description: String)
    func setInformation(releaseDate: String?, genres: [Developer]?, playtime: Int?, publishers: [Developer]?)
    func setUrls(reddit: String?, website: String?)
    func loadingShow()
    func loadingHide()
}

final class GameDetailViewModel {
    private let networkManager: NetworkManager<EndpointItem>
    weak var delegate: GameDetailViewModelDelegate?
    weak var gameDetailDelegate: GameDetailDelegate?
    var gameId: Int?
    var isOnWishList: Bool = false
    private var _game: Game?

    init(networkManager: NetworkManager<EndpointItem>) {
        self.networkManager = networkManager
    }
}

extension GameDetailViewModel: GameDetailViewModelProtocol {
    var wishStatus: Bool {
        get { isOnWishList }
        set { isOnWishList = newValue }
    }

    func fecthSingleGame(completion: @escaping () -> ()) {
        delegate?.loadingShow()
        networkManager.request(endpoint: .game(id: gameId ?? 0), type: Game.self) { [weak self] result in
            self?.delegate?.loadingHide()
            switch result {
            case .success(let response):
                self?.game = response
            case .failure(let error):
                print(error)
                break
            }
            completion()
        }
    }

    var game: Game? {
        get { return _game }
        set (newValue) { _game = newValue }
    }

    func load() {
        delegate?.setDescriptionViewUI()
        delegate?.setInformationViewUI()
        delegate?.setLinksUI()
        delegate?.setMetacriticUI()
    }

    func addOrRemoveWishList(id: Int) {
        addOrRemoveWishListFromDetail(id: id)
    }

    func setPageDatas() {
        guard let game = _game,
            let description = game.descriptionRaw,
            let image = game.backgroundImage,
            let name = game.name,
            let metacritic = game.metacritic
            else { return }

        delegate?.setImage(image: image)
        delegate?.setName(name: name)
        delegate?.setMetacritic(metacritic: metacritic)
        delegate?.setDescription(description: description)
        delegate?.setInformation(releaseDate: game.released, genres: game.genres, playtime: game.playtime, publishers: game.publishers)
        delegate?.setUrls(reddit: game.redditURL, website: game.website)
        delegate?.setWishButtonUI()
    }
}

extension GameDetailViewModel: GameDetailDelegate {
    func addOrRemoveWishListFromDetail(id: Int) {
        isOnWishList = !isOnWishList
        gameDetailDelegate?.addOrRemoveWishListFromDetail(id: id)
        delegate?.changeWishButtonStatus()
    }
}
