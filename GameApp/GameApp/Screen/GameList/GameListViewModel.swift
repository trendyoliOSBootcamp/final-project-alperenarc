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
    var cardType: Bool { get }
    var getGames: [GameResult] { get }
    func load()
    func categoryPlatform(_ index: Int) -> CategoryPlatform?
    func gameResult(_ index: Int) -> GameResult?
    func setSelectedCategory(category: CategoryPlatform)
    func getSelectedCategory() -> CategoryPlatform
    func willDisplay(_ index: Int)
    func changeCardType()
    func addOrRemoveWishList(id: Int)
    func wishListContains(id: Int?) -> Bool

}

protocol GameListViewModelDelegate: AnyObject {
    func setTabbarUI()
    func setSearchBarUI()
    func reloadCategoryList()
    func reloadGameList()
    func showLoadingView()
    func hideLoadingView()
}

final class GameListViewModel {
    let networkManager: NetworkManager<EndpointItem>
    weak var delegate: GameListViewModelDelegate?
    private var categories: [CategoryPlatform] = []
    private var games: [GameResult] = []
    private var selectedCategory: CategoryPlatform
    private var nextPageNumber: String = Constants.firstPage
    private var shouldFetchNextPage: Bool = true
    private var isBigCardActive = true
    private var wishList: [Int] = [3498]

    init(networkManager: NetworkManager<EndpointItem>) {
        self.networkManager = networkManager
        selectedCategory = CategoryPlatform(id: nil)
    }

    private func fetchGames(page: String) {
        delegate?.showLoadingView()
        networkManager.request(endpoint: .games(page: page), type: Games.self) { [weak self] result in
            self?.delegate?.hideLoadingView()
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

    private func fetchWishList() {
        // MARK: CoreData' dan çekilecek.
    }
}

extension GameListViewModel: GameListViewModelProtocol {
    var cardType: Bool { isBigCardActive }
    var numberOfCategory: Int { categories.count }
    var numberOfGame: Int { games.count }
    var getGames: [GameResult] { games }
    func changeCardType() { isBigCardActive = !isBigCardActive }
    func getSelectedCategory() -> CategoryPlatform { selectedCategory }
    func categoryPlatform(_ index: Int) -> CategoryPlatform? { categories[safe: index] }
    func gameResult(_ index: Int) -> GameResult? { games[safe: index] }

    func addOrRemoveWishList(id: Int) {
        // if wishList contains this id remove it. else add to wishList
        // MARK: CoreData' ya eklenip çıkartılacak.
        if wishListContains(id: id) {
            guard let index = wishList.firstIndex(of: id) else { return }
            wishList.remove(at: index)
        } else {
            wishList.append(id)
        }
        print(wishList)
        delegate?.reloadGameList()
    }

    func wishListContains(id: Int?) -> Bool {
        guard let id = id else { return false }
        return wishList.contains { $0 == id }
    }

    func willDisplay(_ index: Int) {
        if index == (games.count - 5), shouldFetchNextPage {
            fetchGames(page: nextPageNumber)
        }
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
        fetchWishList()
    }
}
