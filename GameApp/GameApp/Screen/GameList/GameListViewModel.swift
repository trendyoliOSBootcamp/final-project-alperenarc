//
//  GameListViewModel.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//

import CoreData
import CoreNetwork
import Foundation

extension GameListViewModel {
    enum Constants {
        static let firstPage = "1"
        static let wishListEntityName = "WishList"
        static let clickedGameEntityName = "ClickedGame"
    }
}

protocol GameListViewModelProtocol {
    var delegate: GameListViewModelDelegate? { get set }
    var numberOfCategory: Int { get }
    var numberOfGame: Int { get }
    var cardType: Bool { get }
    var getGames: [GameResult] { get }
    var game: Game? { get set }
    var clickedGameList: [ClickedGameItem] { get set }
    func load()
    func categoryPlatform(_ index: Int) -> CategoryPlatform?
    func gameResult(_ index: Int) -> GameResult?
    func setSelectedCategory(category: CategoryPlatform)
    func getSelectedCategory() -> CategoryPlatform?
    func willDisplay(_ index: Int)
    func changeCardType()
    func addOrRemoveWishList(id: Int)
    func wishListContains(id: Int?) -> Bool
    func clickedGameListContains(id: Int?) -> Bool
    func searchGame(searchText: String)
    func searchCancel()
    func getAllCategories() -> [CategoryPlatform]
    func addClickedGames(id: Int)
    func fetchClickedGames()

}

protocol GameListViewModelDelegate: AnyObject {
    func setTabbarUI()
    func setSearchBarUI()
    func setNavigationBarUI()
    func reloadCategoryList()
    func reloadGameList()
    func showLoadingView()
    func hideLoadingView()
    func getAppDelegate() -> AppDelegate
    func showEmptyCollectionView()
    func restoreCollectionView()
}

final class GameListViewModel {
    let networkManager: NetworkManager<EndpointItem>
    weak var delegate: GameListViewModelDelegate?
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
        // Search kelimesini ara
        // bulamazsan CollectionView'i boş göster
        // bulursan listele ve next page i ekle
        // pagination yapısı burada da olacak.
        // reload Collection View

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
            print("Fetch failed !")
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
            print("Doesn't save !")
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
        } catch _ {
            print("Doesn't delete !")
        }
    }

}

extension GameListViewModel: GameListViewModelProtocol {
    func clickedGameListContains(id: Int?) -> Bool {
        guard let id = id else { return false }
        return clickedGameList.contains { $0.id == id as NSNumber }
    }

    var clickedGameList: [ClickedGameItem] {
        get { clickedGames }
        set { clickedGames = newValue }
    }

    var game: Game? {
        get { _game }
        set(newValue) {
            _game = newValue
        }
    }

    var cardType: Bool { isBigCardActive }
    var numberOfCategory: Int { categories.count }
    var numberOfGame: Int { games.count }
    var getGames: [GameResult] { games }
    func changeCardType() { isBigCardActive = !isBigCardActive }
    func getSelectedCategory() -> CategoryPlatform? { selectedCategory }
    func categoryPlatform(_ index: Int) -> CategoryPlatform? { categories[safe: index] }
    func gameResult(_ index: Int) -> GameResult? { games[safe: index] }

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
        // Search flow started
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

    func getAllCategories() -> [CategoryPlatform] { categories }

    func addClickedGames(id: Int) {
        let entity = NSEntityDescription.entity(forEntityName: Constants.clickedGameEntityName, in: context)
        let newClickedItem = ClickedGameItem(entity: entity!, insertInto: context)
        newClickedItem.id = id as NSNumber
        if !clickedGames.contains(newClickedItem) {
            do {
                try context.save()
                clickedGames.append(newClickedItem)
            } catch {
                print("Doesn't save !")
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
            print("Fetch failed !")
        }
    }

    func load() {
        delegate?.setTabbarUI()
        delegate?.setNavigationBarUI()
        delegate?.setSearchBarUI()
        fetchCategories()
        fetchGames(page: nextPageNumber)
        fetchClickedGames()
        fetchWishList()
    }
}
