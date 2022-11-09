//
//  CardHelpView.swift
//  Card Master
//
//  Created by Thomas Davey on 11/06/2020.
//  Copyright © 2020 Thomas Davey. All rights reserved.
//

import UIKit

class CardHelpView: UIView, UITextViewDelegate {
    var referenceCard: CardView
    var topGradient = CAGradientLayer()
    var bottomGradient = CAGradientLayer()
    
    var helpTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        label.numberOfLines = 0
        label.textColor = .white
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: NSLayoutConstraint.Axis.vertical)
        return label
    }()
    
    var helpText: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: 25, weight: .regular)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: NSLayoutConstraint.Axis.vertical)
        textView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Got It!", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 65).isActive = true
        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        return button
    }()
    
    init(referenceCard: CardView) {
        self.referenceCard = referenceCard
        
//        button.addTarget(self, action: #selector(), for: .touchUpInside)
        
        super.init(frame: CGRect.zero)
        
        backgroundColor = referenceCard.backgroundColor
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 15
        layer.masksToBounds = false
        layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.cornerRadius = 30
        
        addSubview(helpTitle)
        addSubview(helpText)
        addSubview(doneButton)
        
        helpTitle.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: .init(top: 30, left: 30, bottom: 0, right: 30))
        helpText.anchor(top: helpTitle.bottomAnchor, leading: self.leadingAnchor, bottom: doneButton.topAnchor, trailing: self.trailingAnchor, padding: .init(top: 15, left: 20, bottom: 15, right: 20))
        doneButton.anchor(top: nil, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 0, left: 30, bottom: 30, right: 30))
        
        let text = NSMutableAttributedString(string: "HOW TO PLAY\n", attributes: [.font: UIFont.systemFont(ofSize: 28, weight: .medium)])
        text.append(NSAttributedString(string: "\(referenceCard.categoryLabel.text!)", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)]))
        
        helpTitle.attributedText = text
        helpText.text = "\(referenceCard.helpText)"
        helpText.delegate = self
        
        setupGradientView()
    }
    
    override func didMoveToWindow() {
        doneButton.addTarget(self, action: #selector(handleDoneTapped), for: .touchUpInside)
    }
    
    @objc func handleDoneTapped() {
        (self.superview!.superview!.superview!.superview!.next! as! CardViewController).handleHelpTapped()
    }
    
    // Percentage of frame that gradient covers
    let gradientSpread = 0.13
    
    // Percentage of frame that needs to be scrolled for gradient opacity to reach 100%
    let gradientFadeSpeed = CGFloat(0.03)
    
    func setupGradientView(){
        topGradient.colors = [referenceCard.backgroundColor!.withAlphaComponent(0).cgColor, referenceCard.backgroundColor!.withAlphaComponent(0).cgColor]
        topGradient.startPoint = CGPoint.zero
        topGradient.endPoint = CGPoint(x: 0, y: 1)
        topGradient.locations = [0.0, NSNumber(value: 0.0 + self.gradientSpread)]
        layer.addSublayer(topGradient)
        
        bottomGradient.colors = [referenceCard.backgroundColor!.withAlphaComponent(0).cgColor, referenceCard.backgroundColor!.cgColor]
        bottomGradient.startPoint = CGPoint.zero
        bottomGradient.endPoint = CGPoint(x: 0, y: 1)
        bottomGradient.locations = [NSNumber(value: 1.0 - self.gradientSpread), 1.0]
        layer.addSublayer(bottomGradient)
    }
    
    override func didMoveToSuperview() {
        self.fillSuperview(padding: .init(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topGradient.frame = CGRect(x: 0, y: 0, width: helpText.bounds.width-20, height: helpText.bounds.height)
        topGradient.position = helpText.center
        bottomGradient.frame = CGRect(x: 0, y: 0, width: helpText.bounds.width-20, height: helpText.bounds.height)
        bottomGradient.position = helpText.center
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            let percentage = scrollView.contentOffset.y/(self.gradientFadeSpeed * scrollView.frame.height)
            topGradient.colors = [referenceCard.backgroundColor!.withAlphaComponent(percentage).cgColor, referenceCard.backgroundColor!.withAlphaComponent(0).cgColor]
        } else {
            topGradient.colors = [referenceCard.backgroundColor!.withAlphaComponent(0).cgColor, referenceCard.backgroundColor!.withAlphaComponent(0).cgColor]
        }
        if (scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height) < (self.gradientFadeSpeed * scrollView.frame.height) {
            let percentage = (scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height)/(self.gradientFadeSpeed * scrollView.frame.height)
            bottomGradient.colors = [referenceCard.backgroundColor!.withAlphaComponent(0).cgColor, referenceCard.backgroundColor!.withAlphaComponent(percentage).cgColor]
        } else {
            bottomGradient.colors = [referenceCard.backgroundColor!.withAlphaComponent(0).cgColor, referenceCard.backgroundColor!.withAlphaComponent(1).cgColor]
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
