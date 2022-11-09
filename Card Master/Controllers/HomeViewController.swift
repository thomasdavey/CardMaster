//
//  HomeViewController.swift
//  Card Master
//
//  Created by Thomas Davey on 06/06/2020.
//  Copyright © 2020 Thomas Davey. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 25
        return stackView
    }()
    
    let logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logonew"))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        return imageView
    }()
    
    let aboutButton: CustomButton = {
        let button = CustomButton()
        button.setImage(UIImage(systemName: "info.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)), for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(handleAboutTapped), for: .touchUpInside)
        return button
    }()
    
    let playerInputView = PlayerInputView()
    
    let playButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handlePlayTapped), for: .touchUpInside)
        button.setTitle("Play", for: .normal)
        button.titleLabel?.font = UIFont(name: "TitanOne", size: 25)
        button.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.5215686275, blue: 0.2196078431, alpha: 1)
        button.layer.cornerRadius = 18
        button.heightAnchor.constraint(equalToConstant: 65).isActive = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.setBackgroundImage(image: UIImage(named: "background"), alpha: 1)
        
        view.backgroundColor = #colorLiteral(red: 0, green: 0.7529411765, blue: 0.9764705882, alpha: 1)
        
        activateShadow(for: logoView)
        activateShadow(for: playerInputView)
        activateShadow(for: playButton)
        mainStack.addArrangedSubview(logoView)
        mainStack.addArrangedSubview(playerInputView)
        mainStack.addArrangedSubview(playButton)
        
        view.addSubview(mainStack)
        
        mainStack.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 40, bottom: 0, right: 40))
        mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.addSubview(aboutButton)
        aboutButton.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 30, left: 0, bottom: 0, right: 30))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: "firstLoad") != nil {
            print("First Load")
            addWarning()
            UserDefaults.standard.set(nil, forKey: "firstLoad")
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.mainStack.transform = .identity
            self.aboutButton.transform = .identity
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.mainStack.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
            self.aboutButton.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
        })
    }
    
    @objc fileprivate func handleKeyboardShow(notification: Notification) {
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = value.cgRectValue
        let bottomSpace = view.frame.height - mainStack.frame.height - mainStack.frame.origin.y
        let difference = keyboardFrame.height - bottomSpace + 20
        view.transform = CGAffineTransform(translationX: 0, y: -difference)
    }
    
    @objc fileprivate func handleKeyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    
    @objc fileprivate func handleTapDismiss() {
        view.endEditing(true)
    }
    
    @objc fileprivate func handlePlayTapped() {
        if playerInputView.players.count < 2 {
            playerInputView.playerInputField.becomeFirstResponder()
        } else {
            if playerInputView.playerInputField.text != "" {
                playerInputView.addPlayer()
            }
            let cardViewController = CardViewController()
            cardViewController.modalPresentationStyle = .fullScreen
            cardViewController.players = playerInputView.players
            
//            let vc = TutorialViewController()
//            vc.modalPresentationStyle = .fullScreen
            
            self.present(cardViewController, animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func handleAboutTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let aboutViewController = AboutViewController()
        aboutViewController.modalPresentationStyle = .fullScreen
        
        self.present(aboutViewController, animated: true, completion: nil)
    }
    
    func activateShadow(for v: UIView) {
        v.layer.masksToBounds = false
        v.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        v.layer.shadowOpacity = 0.2
        v.layer.shadowRadius = 0
        v.layer.shouldRasterize = true
        v.layer.shadowOffset = CGSize(width: 4, height: 4)
        v.layer.rasterizationScale = UIScreen.main.scale
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    
    
    let warningView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.9)
        return view
    }()
    
    let warningStack: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 45
        stackView.axis = .vertical
        return stackView
    }()
    
    let warningImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "noalcohol"))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        return imageView
    }()
    
    let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Card Master is a party game that is not intended to be played with alcohol. Please only play the game with a soft drink, such as juice or water."
        label.font = UIFont.systemFont(ofSize: 25)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let warningButton: UIButton = {
        let button = UIButton()
        button.setTitle("Got It!", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(handleWarningDismissPressed), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3)
        button.layer.cornerRadius = 15
        return button
    }()
    
    func addWarning() {
        view.insertSubview(warningView, at: 500)
        warningView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        warningView.addSubview(warningStack)
        warningStack.anchor(top: nil, leading: warningView.leadingAnchor, bottom: nil, trailing: warningView.trailingAnchor, padding: .init(top: 0, left: 40, bottom: 0, right: 40))
        warningStack.centerYAnchor.constraint(equalTo: warningView.centerYAnchor).isActive = true
        warningStack.addArrangedSubview(warningImage)
        warningStack.addArrangedSubview(warningLabel)
        warningStack.addArrangedSubview(warningButton)
        UIView.animate(withDuration: 0.2, animations: {
            self.warningView.alpha = 1
        })
    }
    
    @objc func handleWarningDismissPressed() {
        UIView.animate(withDuration: 0.2, animations: {
            self.warningView.alpha = 0
        }) { (_) in
            self.warningView.removeFromSuperview()
        }
    }
}

class CustomButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adjustsImageWhenHighlighted = false
        self.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
        self.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            if (isHighlighted) {
                self.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                self.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
            }
        }
    }
}
