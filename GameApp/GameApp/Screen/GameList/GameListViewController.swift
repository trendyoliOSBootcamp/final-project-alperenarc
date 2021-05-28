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
        static let categoryUnselectedColor = UIColor(red: 45 / 255, green: 45 / 255, blue: 45 / 255, alpha: 1)
        static let categorySelectedColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1)
        enum Cell {
            static let categoryCell = "CategoryViewCell"
            static let categoryCellHeight: CGFloat = 36
            static let categoryCellPadding: CGFloat = 16
            static let bigGameCell = "BigGameCell"
            static let smallGameCell = "SmallGameCell"
            static let descriptionHeight: CGFloat = 159
            static let bigGameCellPadding: CGFloat = 16
            static let bigGameCellImageAspectRatio: CGFloat = 201 / 358
            static let smallGameCellImageAspectRatio: CGFloat = 1 / 1
            static let smallGameCellPadding: CGFloat = 16
            static let smallGameCellNameHeight: CGFloat = 72
            static let gameItemPadding: CGFloat = 16
            static let categoryItemPadding: CGFloat = 12
        }
    }
}

final class GameListViewController: UIViewController {
    private var searchController = UISearchController(searchResultsController: nil)
    @IBOutlet private weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var gamesCollectionView: UICollectionView!
    @IBOutlet weak var cardTypeButton: UIButton!

    var viewModel: GameListViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.load()
        categoryCollectionView.register(UINib(nibName: Constants.Cell.categoryCell, bundle: nil), forCellWithReuseIdentifier: Constants.Cell.categoryCell)
        gamesCollectionView.register(UINib(nibName: Constants.Cell.bigGameCell, bundle: nil), forCellWithReuseIdentifier: Constants.Cell.bigGameCell)
        gamesCollectionView.register(UINib(nibName: Constants.Cell.smallGameCell, bundle: nil), forCellWithReuseIdentifier: Constants.Cell.smallGameCell)
    }
    @IBAction func cardTypeAction() {
        viewModel.changeCardType()
        viewModel.cardType ?
        cardTypeButton.setImage(UIImage(named: "bigLayoutButton"), for: .normal):
            cardTypeButton.setImage(UIImage(named: "smallLayoutButton"), for: .normal)
        reloadGameList()
    }
}

// MARK: - UICollectionViewDataSource
extension GameListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == categoryCollectionView ?
        viewModel.numberOfCategory: viewModel.numberOfGame
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cell.categoryCell, for: indexPath) as! CategoryViewCell

            let currentCategoryPlatform = viewModel.categoryPlatform(indexPath.row)
            if let platformName = currentCategoryPlatform?.name {
                if currentCategoryPlatform == viewModel.getSelectedCategory() {
                    cell.configure(name: platformName, bgColor: Constants.categorySelectedColor, textColor: Constants.categoryUnselectedColor)
                } else {
                    cell.configure(name: platformName, bgColor: Constants.categoryUnselectedColor, textColor: Constants.categorySelectedColor)
                }
            }
            return cell
        } else {
            if viewModel.cardType {
                let cell = gamesCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cell.bigGameCell, for: indexPath) as! BigGameCell
                let currentGameResult = viewModel.gameResult(indexPath.row)
                if let gameResult = currentGameResult {
                    cell.viewModel = BigGameCellViewModel(gameResult: gameResult, wishListStatus: viewModel.wishListContains(id: gameResult.id))
                    cell.wishListButton.tag = indexPath.row
                    cell.wishListButton.addTarget(self, action: #selector(addToWishList(_:)), for: .touchUpInside)
                }
                return cell
            }
            else {
                let cell = gamesCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cell.smallGameCell, for: indexPath) as! SmallGameCell
                let currentGameResult = viewModel.gameResult(indexPath.row)
                if let gameResult = currentGameResult {
                    cell.configure(image: gameResult.backgroundImage, name: gameResult.name, wishListStatus: viewModel.wishListContains(id: gameResult.id))
                    cell.wishListButton.tag = indexPath.row
                    cell.wishListButton.addTarget(self, action: #selector(addToWishList(_:)), for: .touchUpInside)
                }
                return cell
            }
        }
    }

    @objc func addToWishList(_ sender: UIButton) {
        guard let id = viewModel.getGames[safe: sender.tag]?.id else { return }
        viewModel.addOrRemoveWishList(id: id)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GameListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView == categoryCollectionView {
            return .init(width: view.frame.width, height: Constants.Cell.categoryCellHeight)
        } else {
            if viewModel.cardType {
                let cellWidth = view.frame.width - (Constants.Cell.bigGameCellPadding + Constants.Cell.bigGameCellPadding)
                let imageSize = cellWidth * Constants.Cell.bigGameCellImageAspectRatio
                return .init(width: cellWidth, height: Constants.Cell.descriptionHeight + imageSize)
            } else {
                let cellWidth = (view.frame.width / 2) - (Constants.Cell.smallGameCellPadding + Constants.Cell.smallGameCellPadding)
                let imageSize = cellWidth * Constants.Cell.smallGameCellImageAspectRatio
                return .init(width: cellWidth, height: Constants.Cell.smallGameCellNameHeight + imageSize)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        collectionView == categoryCollectionView ? Constants.Cell.categoryItemPadding : Constants.Cell.gameItemPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == categoryCollectionView {
            return .init(top: Constants.Cell.categoryCellPadding, left: Constants.Cell.categoryCellPadding, bottom: .zero, right: .zero)
        } else {
            if viewModel.cardType {
                return .init(top: .zero, left: Constants.Cell.bigGameCellPadding, bottom: .zero, right: Constants.Cell.bigGameCellPadding)
            } else {
                return .init(top: .zero, left: Constants.Cell.bigGameCellPadding, bottom: .zero, right: Constants.Cell.bigGameCellPadding)
            }
        }
    }

}

// MARK: - UICollectionViewDelegate
extension GameListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let category = viewModel.categoryPlatform(indexPath.row) else { return }
        viewModel.setSelectedCategory(category: category)
        reloadCategoryList()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.willDisplay(indexPath.item)
    }
}

// MARK: - GameListViewModelDelegate
extension GameListViewController: GameListViewModelDelegate {
    func showLoadingView() {
        gamesCollectionView.setLoading()
    }

    func hideLoadingView() {
        gamesCollectionView.restore()
    }

    func reloadGameList() {
        gamesCollectionView.reloadData()
    }

    func reloadCategoryList() {
        categoryCollectionView.reloadData()
    }

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

// MARK: - UISearchControllerDelegate
extension GameListViewController: UISearchBarDelegate, UISearchControllerDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print(searchText)
//    }
}

