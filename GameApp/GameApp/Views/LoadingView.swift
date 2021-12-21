//
//  LoadingView.swift
//  GameApp
//
//  Created by Alperen Arıcı on 1.06.2021.
//

import UIKit

class LoadingView {
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    static let shared = LoadingView()
    var blurView: UIVisualEffectView = UIVisualEffectView()

    private init() {
        configure()
    }

    func configure() {
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = UIWindow(frame: UIScreen.main.bounds).frame
        activityIndicator.center = blurView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        blurView.contentView.addSubview(activityIndicator)
    }

    func startLoading() {
        UIApplication.shared.windows.first?.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
    }

    func hideLoading() {
        blurView.removeFromSuperview()
        activityIndicator.stopAnimating()
    }
}
