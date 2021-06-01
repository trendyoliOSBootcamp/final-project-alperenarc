//
//  WishListViewModel.swift
//  GameApp
//
//  Created by Alperen Arıcı on 28.05.2021.
//

import Foundation
import CoreData
import CoreNetwork

extension WishListViewModel {
    enum Constants {
        static let wishListEntityName = "WishList"
    }
}

protocol WishListViewModelProtocol {
    var delegate: WishListViewModelDelegate? { get set }
    var wishList: [GameResult] { get }
    func currentGame(at index: Int) -> GameResult
    func load()
    func wishListContains(id: Int?) -> Bool
    func removeWishList(id: Int)
}

protocol WishListViewModelDelegate: AnyObject {
    func getAppDelegate() -> AppDelegate
    func alertShow(title: String, action: String, message: String)
    func showLoadingView()
    func hideLoadingView()
    func reloadData()
    func showEmptyCollectionView()
    func restoreCollectionView()
}

final class WishListViewModel {
    let networkManager: NetworkManager<EndpointItem>
    weak var delegate: WishListViewModelDelegate?
    lazy var appDelegate = delegate?.getAppDelegate()
    lazy var context: NSManagedObjectContext = appDelegate!.persistentContainer.viewContext
    private var wishListCoreData: [WishListItem] = []
    private var wishGames: [GameResult] = []

    init(networkManager: NetworkManager<EndpointItem>) {
        self.networkManager = networkManager
    }

    private func fetchGame(id: NSNumber, completion: @escaping () -> ()) {
        networkManager.request(endpoint: .game(id: Int(id)), type: Game.self) { [weak self] result in
            switch result {
            case .success(let response):
                let gameResult = GameResult(id: response.id ?? 0,
                    name: response.name ?? "",
                    image: response.backgroundImage ?? "")
                if self?.wishGames.count == 0 {
                    self?.wishGames = [gameResult]
                } else {
                    self?.wishGames.append(gameResult)
                }
                completion()
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }

    private func fetchWishList(completion: @escaping () -> ()) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.wishListEntityName)
        do {
            let results: NSArray = try context.fetch(request) as NSArray
            for result in results {
                let wishListItem = result as! WishListItem
                wishListCoreData.append(wishListItem)
            }
            completion()
        } catch {
            delegate?.alertShow(title: "Warning", action: "Ok", message: "Fetch Failed !")
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
            delegate?.alertShow(title: "Warning", action: "Ok", message: "An error was occured while deleting !")
        }
    }

    private func prepareWisList(completion: @escaping () -> ()) {
        let wishSet = Set(wishListCoreData.map { $0.id })
        if wishSet.isEmpty {
            delegate?.showEmptyCollectionView()
            delegate?.reloadData()
            return
        } else {
            delegate?.restoreCollectionView()
            delegate?.reloadData()
        }
        let wishGameAsyncGroup: DispatchGroup = DispatchGroup()
        for wishGame in wishSet {
            wishGameAsyncGroup.enter()
            guard let game = wishGame else { return }
            fetchGame(id: game as NSNumber) {
                wishGameAsyncGroup.leave()
            }
        }
        wishGameAsyncGroup.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
}

extension WishListViewModel: WishListViewModelProtocol {
    func load() {
        wishListCoreData = []
        wishGames = []
        delegate?.showLoadingView()
        fetchWishList { [weak self] in
            self?.prepareWisList {
                self?.delegate?.hideLoadingView()
                self?.delegate?.reloadData()
            }
        }
    }
    var wishList: [GameResult] { wishGames }
    func currentGame(at index: Int) -> GameResult { wishGames[index] }

    func wishListContains(id: Int?) -> Bool {
        guard let id = id else { return false }
        return wishListCoreData.contains { $0.id == id as NSNumber }
    }

    func removeWishList(id: Int) {
        deleteWishListFromDB(id: id)
        wishGames = wishGames.filter { $0.id != id }
        if wishGames.isEmpty {
            delegate?.showEmptyCollectionView()
        } else {
            delegate?.restoreCollectionView()
        }
        delegate?.reloadData()
    }
}
