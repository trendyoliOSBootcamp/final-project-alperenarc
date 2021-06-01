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
}

protocol GameDetailViewModelDelegate: AnyObject {
    func setMetacriticUI()
    func setLinksUI()
    func setInformationViewUI()
    func setDescriptionViewUI()
    func expandDescriptionView()
    func setImage(image: String)
    func setName(name: String)
    func setMetacritic(metacritic: Int)
    func setDescription(description: String)
    func setInformation(releaseDate: String?, genres: [Developer]?, playtime: Int?, publishers: [Developer]?)
    func setUrls(reddit: String?, website: String?)
}

final class GameDetailViewModel {
    let networkManager: NetworkManager<EndpointItem>
    weak var delegate: GameDetailViewModelDelegate?
    weak var gameDetailDelegate: GameDetailDelegate?
    var gameId: Int?
    private var _game: Game?

    init(networkManager: NetworkManager<EndpointItem>) {
        self.networkManager = networkManager
    }
}

extension GameDetailViewModel: GameDetailViewModelProtocol {
    func fecthSingleGame(completion: @escaping () -> ()) {
        networkManager.request(endpoint: .game(id: gameId ?? 0), type: Game.self) { [weak self] result in
            switch result {
            case .success(let response):
                self?.game = response
                completion()
            case .failure(let error):
                print(error)
                break
            }
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
    
    func setPageDatas(){
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
    }
}

extension GameDetailViewModel: GameDetailDelegate {
    func addOrRemoveWishListFromDetail(id: Int) {
        gameDetailDelegate?.addOrRemoveWishListFromDetail(id: id)
    }
}
