//
//  GameListViewModel.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//

import CoreData
import CoreNetwork
import Foundation

// MARK: - GameListViewModel
extension GameListViewModel {
    enum Constants {
        static let firstPage = "1"
        static let wishListEntityName = "WishList"
        static let clickedGameEntityName = "ClickedGame"
    }
}

// MARK: - GameListViewModelProtocol
protocol GameListViewModelProtocol {
    var delegate: GameListViewModelDelegate? { get set }
    var numberOfCategory: Int { get }
    var numberOfGame: Int { get }
    var cardType: Bool { get }
    var getGames: [GameResult] { get }
    var game: Game? { get set }
    var clickedGameList: [ClickedGameItem] { get set }
    var getSelectedCategory: CategoryPlatform? { get }
    var getAllCategories: [CategoryPlatform] { get }
    var getNetworkManager: NetworkManager<EndpointItem> { get }
    func load()
    func categoryPlatform(_ index: Int) -> CategoryPlatform?
    func gameResult(_ index: Int) -> GameResult?
    func setSelectedCategory(category: CategoryPlatform)
    func willDisplay(_ index: Int)
    func changeCardType()
    func addOrRemoveWishList(id: Int)
    func wishListContains(id: Int?) -> Bool
    func clickedGameListContains(id: Int?) -> Bool
    func searchGame(searchText: String)
    func searchCancel()
    func addClickedGames(id: Int)
    func fetchClickedGames()
}

// MARK: - GameListViewModelDelegate
protocol GameListViewModelDelegate: AnyObject {
    func setTabbarUI()
    func setSearchBarUI()
    func reloadCategoryList()
    func reloadGameList()
    func showLoadingView()
    func hideLoadingView()
    func getAppDelegate() -> AppDelegate
    func showEmptyCollectionView()
    func restoreCollectionView()
    func alertShow(alertTitle: String, alertActionTitle: String, alertMessage: String)
}

// MARK: - GameListViewModel
final class GameListViewModel: ShowAlert {
    weak var delegate: GameListViewModelDelegate?
    private let networkManager: NetworkManager<EndpointItem>
    private var categories: [CategoryPlatform] = []
    private var games: [GameResult] = []
    private var selectedCategory: CategoryPlatform?
    private var nextPageNumber: String = Constants.firstPage
    private var shouldFetchNextPage: Bool = true
    private var isBigCardActive = true
    private var wishListCoreData: [WishListItem] = []
    private var _game: Game?
    private var clickedGames: [ClickedGameItem] = []
    lazy var appDelegate = delegate?.getAppDelegate()
    lazy var context: NSManagedObjectContext = appDelegate!.persistentContainer.viewContext

    init(networkManager: NetworkManager<EndpointItem>) {
        self.networkManager = networkManager
    }

    private func fetchGames(page: String) {
        var platformStr = ""
        if let platform = selectedCategory?.id {
            platformStr = "&parent_platforms=\(platform)"
        }
        delegate?.showLoadingView()
        networkManager.request(endpoint: .games(page: page, platform: platformStr), type: Games.self) { [weak self] result in
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

    private func fetchSearchGameResults(searchText: String, page: String) {
        delegate?.showLoadingView()
        var platformStr = ""
        if let platform = selectedCategory?.id {
            platformStr = "&parent_platforms=\(platform)"
        }

        networkManager.request(endpoint: .searchGame(searchText: searchText, page: page, platform: platformStr), type: Games.self) { [weak self] result in
            self?.delegate?.hideLoadingView()
            switch result {
            case .success(let response):
                if let gameList = response.results {
                    if gameList.isEmpty {
                        self?.delegate?.showEmptyCollectionView()
                    } else {
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
                    }
                    self?.delegate?.reloadGameList()
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.wishListEntityName)
        do {
            let results: NSArray = try context.fetch(request) as NSArray
            for result in results {
                let wishListItem = result as! WishListItem
                wishListCoreData.append(wishListItem)
            }
        } catch {
            delegate?.alertShow(alertTitle: "Error", alertActionTitle: "Ok", alertMessage: "Fetch failed !")
        }
    }

    private func addWishListToDB(id: Int) {
        let entity = NSEntityDescription.entity(forEntityName: Constants.wishListEntityName, in: context)
        let newWishListItem = WishListItem(entity: entity!, insertInto: context)
        newWishListItem.id = id as NSNumber
        do {
            try context.save()
            wishListCoreData.append(newWishListItem)
        } catch {
            delegate?.alertShow(alertTitle: "Error", alertActionTitle: "Ok", alertMessage: "Doesn't save !")
        }
    }

    private func deleteWishListFromDB(id: Int) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.wishListEntityName)
        request.predicate = NSPredicate.init(format: "id==\(id)")
        do {
            let results: NSArray = try context.fetch(request) as NSArray
            for object in results {
                context.delete(object as! NSManagedObject)
            }
            try context.save()
        } catch {
            delegate?.alertShow(alertTitle: "Error", alertActionTitle: "Ok", alertMessage: "Doesn't delete !")
        }
    }
}

// MARK: - GameListViewModelProtocol
extension GameListViewModel: GameListViewModelProtocol {
    var cardType: Bool { isBigCardActive }
    var numberOfCategory: Int { categories.count }
    var numberOfGame: Int { games.count }
    var getGames: [GameResult] { games }
    var getSelectedCategory: CategoryPlatform? { selectedCategory }
    var clickedGameList: [ClickedGameItem] {
        get { clickedGames }
        set { clickedGames = newValue }
    }

    var game: Game? {
        get { _game }
        set { _game = newValue }
    }

    var getAllCategories: [CategoryPlatform] {
        get { categories }
    }

    var getNetworkManager: NetworkManager<EndpointItem> {
        get {
            NetworkManager()
        }
    }

    func categoryPlatform(_ index: Int) -> CategoryPlatform? { categories[safe: index] }
    func gameResult(_ index: Int) -> GameResult? { games[safe: index] }
    func changeCardType() { isBigCardActive = !isBigCardActive }
    func clickedGameListContains(id: Int?) -> Bool {
        guard let id = id else { return false }
        return clickedGameList.contains { $0.id == id as NSNumber }
    }

    func addOrRemoveWishList(id: Int) {
        let entity = NSEntityDescription.entity(forEntityName: Constants.wishListEntityName, in: context)
        let wishListItem = WishListItem(entity: entity!, insertInto: context)
        wishListItem.id = id as NSNumber
        if wishListContains(id: id) {
            var index: Int = 0
            for item in 0...wishListCoreData.count - 1 {
                if wishListCoreData[safe: item] == id as NSNumber {
                    index = item
                    return
                }
            }
            wishListCoreData.remove(at: index)
            deleteWishListFromDB(id: id)
        } else {
            addWishListToDB(id: id)
            wishListCoreData.append(wishListItem)
        }
        delegate?.reloadGameList()
    }

    func wishListContains(id: Int?) -> Bool {
        guard let id = id else { return false }
        return wishListCoreData.contains { $0.id == id as NSNumber }
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
        games = []
        nextPageNumber = Constants.firstPage
        shouldFetchNextPage = true
        fetchGames(page: nextPageNumber)
    }

    func searchGame(searchText: String) {
        games = []
        nextPageNumber = Constants.firstPage
        shouldFetchNextPage = true
        fetchSearchGameResults(searchText: searchText, page: nextPageNumber)
    }

    func searchCancel() {
        games = []
        nextPageNumber = Constants.firstPage
        fetchGames(page: nextPageNumber)
    }

    func addClickedGames(id: Int) {
        let entity = NSEntityDescription.entity(forEntityName: Constants.clickedGameEntityName, in: context)
        let newClickedItem = ClickedGameItem(entity: entity!, insertInto: context)
        newClickedItem.id = id as NSNumber
        if !clickedGames.contains(newClickedItem) {
            do {
                try context.save()
                clickedGames.append(newClickedItem)
            } catch {
                delegate?.alertShow(alertTitle: "Error", alertActionTitle: "Ok", alertMessage: "Doesn't save !")

            }
        }
    }

    func fetchClickedGames() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.clickedGameEntityName)
        do {
            let results: NSArray = try context.fetch(request) as NSArray
            for result in results {
                let clickedGame = result as! ClickedGameItem
                clickedGameList.append(clickedGame)
            }
        } catch {
            delegate?.alertShow(alertTitle: "Error", alertActionTitle: "Ok", alertMessage: "Fetch failed !")
        }
    }

    func load() {
        delegate?.setTabbarUI()
        delegate?.setSearchBarUI()
        fetchCategories()
        fetchGames(page: nextPageNumber)
        fetchClickedGames()
        fetchWishList()
    }
}
