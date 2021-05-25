//
//  ViewController.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//

import UIKit

extension GameListViewController {
    enum Constants {
        static let barTintColor = UIColor(red: 22 / 255, green: 22 / 255, blue: 22 / 255, alpha: 0.1)
        static let unselectedItemTintColor = UIColor(red: 117 / 255, green: 117 / 255, blue: 117 / 255, alpha: 1)
    }
}

final class GameListViewController: UIViewController {
    var searchController = UISearchController(searchResultsController: nil)

    var viewModel: GameListViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.load()
    }

}
extension GameListViewController: GameListViewModelDelegate {
    func setTabbarUI() {
        tabBarController?.tabBar.tintColor = .white
        tabBarController?.tabBar.barTintColor = Constants.barTintColor
        tabBarController?.tabBar.unselectedItemTintColor = Constants.unselectedItemTintColor
        tabBarController?.tabBar.clipsToBounds = true
    }

    func setSearchBarUI() {
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .white
        navigationItem.searchController = searchController
    }
}
extension GameListViewController: UISearchControllerDelegate {

}

