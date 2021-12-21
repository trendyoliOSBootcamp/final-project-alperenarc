//
//  ViewController.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//

import UIKit

// MARK: - GameListViewController
extension GameListViewController {
    enum Constants {
        enum Category {
            static let barTintColor = UIColor(red: 22 / 255, green: 22 / 255, blue: 22 / 255, alpha: 0.1)
            static let unselectedItemTintColor = UIColor(red: 117 / 255, green: 117 / 255, blue: 117 / 255, alpha: 1)
            static let categoryUnselectedColor = UIColor(red: 45 / 255, green: 45 / 255, blue: 45 / 255, alpha: 1)
            static let categorySelectedColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1)
        }
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
        static let detailViewSegueID = "GameDetailViewSegue"
        static let bigButton = "bigLayoutButton"
        static let smallButton = "smallLayoutButton"
    }
}

// MARK: - GameListViewController
final class GameListViewController: UIViewController {
    @IBOutlet private weak var categoryCollectionView: UICollectionView!
    @IBOutlet private weak var gamesCollectionView: UICollectionView!
    @IBOutlet private weak var cardTypeButton: UIButton!
    private let searchController = UISearchController()

    var viewModel: GameListViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.load()
        registerCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadGameList()
    }

    private func registerCells() {
        categoryCollectionView.register(UINib(nibName: Constants.Cell.categoryCell, bundle: nil), forCellWithReuseIdentifier: Constants.Cell.categoryCell)
        gamesCollectionView.register(UINib(nibName: Constants.Cell.bigGameCell, bundle: nil), forCellWithReuseIdentifier: Constants.Cell.bigGameCell)
        gamesCollectionView.register(UINib(nibName: Constants.Cell.smallGameCell, bundle: nil), forCellWithReuseIdentifier: Constants.Cell.smallGameCell)
    }

    @IBAction private func cardTypeAction() {
        viewModel.changeCardType()
        viewModel.cardType ?
        cardTypeButton.setImage(UIImage(named: Constants.bigButton), for: .normal):
            cardTypeButton.setImage(UIImage(named: Constants.smallButton), for: .normal)
        reloadGameList()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let vc as GameDetailViewController:
            let vm = GameDetailViewModel(networkManager: viewModel.getNetworkManager) 
            let gameModel = viewModel.game
            vm.gameDetailDelegate = self
            vm.gameId = sender as? Int
            vm.isOnWishList = viewModel.wishListContains(id: sender as? Int)
            vm.game = gameModel
            vc.viewModel = vm
        default:
            break
        }
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
                cell.configure(name: platformName, bgColor: Constants.Category.categoryUnselectedColor, textColor: Constants.Category.categorySelectedColor)
            }
            return cell
        } else {
            if viewModel.cardType {
                let cell = gamesCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cell.bigGameCell, for: indexPath) as! BigGameCell
                let currentGameResult = viewModel.gameResult(indexPath.row)
                if let gameResult = currentGameResult {
                    cell.viewModel = BigGameCellViewModel(gameResult: gameResult, wishListStatus: viewModel.wishListContains(id: gameResult.id), clickedStatus: viewModel.clickedGameListContains(id: gameResult.id))
                    cell.wishListButton.tag = indexPath.row
                    cell.wishListButton.addTarget(self, action: #selector(addToWishList(_:)), for: .touchUpInside)
                }
                return cell
            }
            else {
                let cell = gamesCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cell.smallGameCell, for: indexPath) as! SmallGameCell
                let currentGameResult = viewModel.gameResult(indexPath.row)
                if let gameResult = currentGameResult {
                    cell.viewModel = SmallGameCellViewModel(gameResult: gameResult, wishListStatus: viewModel.wishListContains(id: gameResult.id), clickedStatus: viewModel.clickedGameListContains(id: gameResult.id))
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
                let cellWidth = (gamesCollectionView.frame.size.width - (Constants.Cell.smallGameCellPadding + Constants.Cell.smallGameCellPadding + Constants.Cell.smallGameCellPadding)) / 2
                let imageSize = cellWidth * Constants.Cell.smallGameCellImageAspectRatio
                return .init(width: cellWidth, height: Constants.Cell.smallGameCellNameHeight + imageSize)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        collectionView == categoryCollectionView ? Constants.Cell.categoryItemPadding : Constants.Cell.gameItemPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.Cell.smallGameCellPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == categoryCollectionView {
            return .init(top: Constants.Cell.categoryCellPadding, left: Constants.Cell.categoryCellPadding, bottom: .zero, right: .zero)
        } else {
            if viewModel.cardType {
                return .init(top: .zero, left: Constants.Cell.bigGameCellPadding, bottom: .zero, right: Constants.Cell.bigGameCellPadding)
            } else {
                return .init(top: .zero, left: Constants.Cell.smallGameCellPadding, bottom: .zero, right: Constants.Cell.smallGameCellPadding)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension GameListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            let cell = categoryCollectionView.cellForItem(at: indexPath) as! CategoryViewCell
            guard let category = viewModel.categoryPlatform(indexPath.row) else { return }
            viewModel.setSelectedCategory(category: category)
            let currentCategoryPlatform = viewModel.categoryPlatform(indexPath.row)

            if let platformName = currentCategoryPlatform?.name {
                if viewModel.getSelectedCategory == currentCategoryPlatform {
                    cell.configure(name: platformName, bgColor: Constants.Category.categorySelectedColor, textColor: Constants.Category.categoryUnselectedColor)
                } else {
                    cell.configure(name: platformName, bgColor: Constants.Category.categoryUnselectedColor, textColor: Constants.Category.categorySelectedColor)
                }
            }
        } else {
            if viewModel.cardType {
                let cell = gamesCollectionView.cellForItem(at: indexPath) as! BigGameCell
                cell.changeNameColor()
            } else {
                let cell = gamesCollectionView.cellForItem(at: indexPath) as! SmallGameCell
                cell.changeNameColor()
            }

            let gameId = viewModel.gameResult(indexPath.row)?.id
            viewModel.addClickedGames(id: gameId ?? 0)
            performSegue(withIdentifier: Constants.detailViewSegueID, sender: gameId)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            if let selectedCategory = viewModel.getSelectedCategory, let row = viewModel.getAllCategories.firstIndex(of: selectedCategory) {
                let previousIndexPath = IndexPath(row: row, section: 0)
                guard let previousCell = categoryCollectionView.cellForItem(at: previousIndexPath) as? CategoryViewCell else { return }
                let previousCategory = viewModel.categoryPlatform(previousIndexPath.row)
                previousCell.configure(name: previousCategory?.name ?? "", bgColor: Constants.Category.categoryUnselectedColor, textColor: Constants.Category.categorySelectedColor)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.willDisplay(indexPath.item)
    }
}

// MARK: - GameListViewModelDelegate
extension GameListViewController: GameListViewModelDelegate, ShowAlert {
    func alertShow(alertTitle: String, alertActionTitle: String, alertMessage: String) {
        showError(alertTitle: alertTitle, alertActionTitle: alertActionTitle, alertMessage: alertMessage, ownerVC: self)
    }

    func showEmptyCollectionView() {
        gamesCollectionView.setEmptyMessage(message: "No game has been found !")
    }

    func restoreCollectionView() {
        gamesCollectionView.restore()
    }

    func getAppDelegate() -> AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

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
        tabBarController?.tabBar.barTintColor = Constants.Category.barTintColor
        tabBarController?.tabBar.unselectedItemTintColor = Constants.Category.unselectedItemTintColor
        tabBarController?.tabBar.clipsToBounds = true
    }

    func setSearchBarUI() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .white
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

// MARK: - UISearchControllerDelegate
extension GameListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.searchGame(searchText: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchCancel()
    }
}

// MARK: - GameDetailDelegate
extension GameListViewController: GameDetailDelegate {
    func addOrRemoveWishListFromDetail(id: Int) {
        viewModel.addOrRemoveWishList(id: id)
    }
}
