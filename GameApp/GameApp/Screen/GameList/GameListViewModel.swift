//
//  GameListViewModel.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//

import CoreNetwork
import Foundation

extension GameListViewModel {
    enum Constants {
        static let firstPage = "1"
    }
}

protocol GameListViewModelProtocol {
    var delegate: GameListViewModelDelegate? { get set }
    var numberOfCategory: Int { get }
    var numberOfGame: Int { get }
    func load()
    func categoryPlatform(_ index: Int) -> CategoryPlatform?
    func gameResult(_ index: Int) -> GameResult?
    func setSelectedCategory(category: CategoryPlatform)
    func getSelectedCategory() -> CategoryPlatform
}

protocol GameListViewModelDelegate: AnyObject {
    func setTabbarUI()
    func setSearchBarUI()
    func reloadCategoryList()
    func reloadGameList()
}

final class GameListViewModel {
    let networkManager: NetworkManager<EndpointItem>
    weak var delegate: GameListViewModelDelegate?
    private var categories: [CategoryPlatform] = []
    private var games: [GameResult] = []
    private var selectedCategory: CategoryPlatform
    private var nextPageNumber: String = Constants.firstPage
    private var shouldFetchNextPage: Bool = true

    init(networkManager: NetworkManager<EndpointItem>) {
        self.networkManager = networkManager
        selectedCategory = CategoryPlatform(id: nil)
    }

    private func fetchGames(page: String) {
        networkManager.request(endpoint: .games(page: page), type: Games.self) { [weak self] result in
            switch result {
            case .success(let response):
                if let gameList = response.results {
                    if self?.nextPageNumber == Constants.firstPage {
                        self?.games = gameList
                    } else {
                        self?.games.append(contentsOf: gameList)
                    }

                    if let next = response.next {
                        self?.calculateNextPageNumber(next: next)
                    } else {
                        self?.shouldFetchNextPage = false
                    }
                    self?.delegate?.reloadGameList()
                }
            case .failure(let error):
                print(error)
                break
            }
        }
    }

    private func fetchCategories() {
        networkManager.request(endpoint: .categories, type: Category.self) { [weak self] result in

            switch result {
            case .success(let response):
                if let category = response.results {
                    self?.categories = category
                    self?.delegate?.reloadCategoryList()
                }
            case .failure(let error):
                print(error)
                break
            }
        }
    }

    private func calculateNextPageNumber(next: String) {
        let number = next.components(separatedBy: "&page=")

        if !number[1].isEmpty {
            nextPageNumber = number[1]
        } else {
            shouldFetchNextPage = false
        }
    }
}

extension GameListViewModel: GameListViewModelProtocol {

    func getSelectedCategory() -> CategoryPlatform {
        selectedCategory
    }

    func setSelectedCategory(category: CategoryPlatform) {
        if selectedCategory == category {
            selectedCategory = CategoryPlatform(id: nil)
        } else {
            selectedCategory = category
        }
    }

    func load() {
        delegate?.setTabbarUI()
        delegate?.setSearchBarUI()
        fetchCategories()
        fetchGames(page: nextPageNumber)
    }

    func categoryPlatform(_ index: Int) -> CategoryPlatform? {
        categories[safe: index]
    }

    var numberOfCategory: Int {
        categories.count
    }

    func gameResult(_ index: Int) -> GameResult? {
        games[safe: index]
    }

    var numberOfGame: Int {
        games.count
    }
}
