//
//  WishListViewController.swift
//  GameApp
//
//  Created by Alperen Arıcı on 25.05.2021.
//

import UIKit

extension WishListViewController {
    enum Constants {
        enum Cell {
            static let smallGameCell = "SmallGameCell"
            static let smallGameCellImageAspectRatio: CGFloat = 1 / 1
            static let smallGameCellPadding: CGFloat = 16
            static let smallGameCellNameHeight: CGFloat = 72
            static let gameItemPadding: CGFloat = 16
        }
    }
}

final class WishListViewController: UIViewController {
    @IBOutlet private weak var wishListCollectionView: UICollectionView!

    var viewModel: WishListViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    func registerNib() {
        wishListCollectionView.register(UINib(nibName: Constants.Cell.smallGameCell, bundle: nil), forCellWithReuseIdentifier: Constants.Cell.smallGameCell)
    }
}

// MARK: - UICollectionViewDataSource
extension WishListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.wishList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = wishListCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cell.smallGameCell, for: indexPath) as! SmallGameCell
        let currentGameResult = viewModel.currentGame(at: indexPath.row)
        cell.viewModel = SmallGameCellViewModel(gameResult: currentGameResult, wishListStatus: viewModel.wishListContains(id: currentGameResult.id))
        cell.wishListButton.tag = currentGameResult.id ?? 0
        cell.wishListButton.addTarget(self, action: #selector(removeFromWishList(_:)), for: .touchUpInside)
        return cell
    }

    @objc func removeFromWishList(_ sender: UIButton) {
        let gameId = sender.tag
        viewModel.removeWishList(id: gameId)
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension WishListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellWidth = (wishListCollectionView.frame.size.width - (Constants.Cell.smallGameCellPadding + Constants.Cell.smallGameCellPadding + Constants.Cell.smallGameCellPadding)) / 2
        let imageSize = cellWidth * Constants.Cell.smallGameCellImageAspectRatio
        return .init(width: cellWidth, height: Constants.Cell.smallGameCellNameHeight + imageSize)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.Cell.gameItemPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.Cell.smallGameCellPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            .init(top: Constants.Cell.smallGameCellPadding, left: Constants.Cell.smallGameCellPadding, bottom: Constants.Cell.smallGameCellPadding, right: Constants.Cell.smallGameCellPadding)
    }
}

// MARK: - WishListViewModelDelegate
extension WishListViewController: WishListViewModelDelegate, ShowAlert {
    func getAppDelegate() -> AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    func alertShow(title: String, action: String, message: String) {
        showError(alertTitle: title, alertActionTitle: action, alertMessage: message, ownerVC: self)
    }

    func showLoadingView() {
        wishListCollectionView.setLoading()
    }

    func hideLoadingView() {
        wishListCollectionView.restore()
    }

    func reloadData() {
        wishListCollectionView.reloadData()
    }

    func showEmptyCollectionView() {
        wishListCollectionView.setEmptyMessage(message: "No wishlisted game has been found !")
    }

    func restoreCollectionView() {
        wishListCollectionView.restore()
    }
}
