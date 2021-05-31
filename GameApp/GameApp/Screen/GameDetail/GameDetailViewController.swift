//
//  GameDetailViewController.swift
//  GameApp
//
//  Created by Alperen Arıcı on 30.05.2021.
//

import UIKit

extension GameDetailViewController {
    private enum Constants {
        static let outerViewHeight: CGFloat = 120
        static let innerTextViewHeight: CGFloat = 70
        static let descriptionViewCornerRadius: CGFloat = 8
        static let descriptionTextBottomConstant: CGFloat = 5
    }
}

final class GameDetailViewController: UIViewController {
    @IBOutlet private weak var outerView: UIView!
    @IBOutlet private weak var innerTextView: UITextView!
    @IBOutlet private weak var outerViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var innerTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionTextBottomConstant: NSLayoutConstraint!
    var status = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setDescriptionViewUI()

    }

    private func setDescriptionViewUI() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandDescriptionView))
        innerTextView.addGestureRecognizer(tapRecognizer)
        outerView.layer.cornerRadius = Constants.descriptionViewCornerRadius
        innerTextView.textContainerInset.top = .zero
        innerTextView.textContainerInset.bottom = .zero
        innerTextView.isScrollEnabled = false
        innerTextView.textContainer.maximumNumberOfLines = 4
        innerTextView.textContainer.lineBreakMode = .byTruncatingTail
    }

    @objc private func expandDescriptionView() {
        if status {
            innerTextView.isScrollEnabled = true
            innerTextView.textContainer.maximumNumberOfLines = 0
            innerTextView.textContainer.lineBreakMode = .byWordWrapping
            innerTextViewHeight.constant = innerTextView.contentSize.height
            outerViewHeight.constant = Constants.outerViewHeight + CGFloat(7) + (innerTextView.contentSize.height - Constants.innerTextViewHeight)
            descriptionTextBottomConstant.constant = 12

        } else {
            innerTextView.isScrollEnabled = false
            innerTextView.textContainer.maximumNumberOfLines = 4
            innerTextView.textContainer.lineBreakMode = .byTruncatingTail
            innerTextViewHeight.constant = Constants.innerTextViewHeight
            outerViewHeight.constant = Constants.outerViewHeight
            descriptionTextBottomConstant.constant = Constants.descriptionTextBottomConstant
        }
        status = !status
    }
}

