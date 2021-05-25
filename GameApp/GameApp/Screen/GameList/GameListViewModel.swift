//
//  GameListViewModel.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//

import CoreNetwork

protocol GameListViewModelProtocol {
    var delegate: GameListViewModelDelegate? { get set }
    func load()
}

protocol GameListViewModelDelegate: AnyObject {
    func setTabbarUI()
    func setSearchBarUI()
}

final class GameListViewModel {
    let networkManager: NetworkManager<EndpointItem>
    weak var delegate: GameListViewModelDelegate?

    init(networkManager: NetworkManager<EndpointItem>) {
        self.networkManager = networkManager
    }
}

extension GameListViewModel: GameListViewModelProtocol {
    func load() {
        delegate?.setTabbarUI()
        delegate?.setSearchBarUI()
    }
}
