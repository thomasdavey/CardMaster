//
//  CardViewController.swift
//  Card Master
//
//  Created by Thomas Davey on 01/06/2020.
//  Copyright © 2020 Thomas Davey. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CardViewController: UIViewController, GADInterstitialDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    var interstitial: GADInterstitial!
    
    var players: [String] = []
    
    let helpButton: CustomButton = {
        let button = CustomButton()
        button.setImage(UIImage(systemName: "questionmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)), for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(handleHelpTapped), for: .touchUpInside)
        return button
    }()
    
    let exitButton: CustomButton = {
        let button = CustomButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)), for: .normal)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(handleExitTapped), for: .touchUpInside)
        return button
    }()
    
    let logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cardlogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: NSLayoutConstraint.Axis.horizontal)
        return imageView
    }()
    
    let buttonView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    // MARK: - Scene Building
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0, green: 0.7529411765, blue: 0.9764705882, alpha: 1)
        
        if UserDefaults.standard.value(forKey: "adsOn") == nil {
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["a8b8d6f3ae204773ace4065881af8e10" ]
            interstitial = createAndLoadInterstitial()
        }
        
        view.addSubview(mainStack)
        
        mainStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)

        buttonView.addArrangedSubview(helpButton)
        buttonView.addArrangedSubview(logoView)
        buttonView.addArrangedSubview(exitButton)
        
        activateShadow(for: logoView, shadow: .init(width: 2, height: 2))
        
        mainStack.addSubview(buttonView)
        
        buttonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonView.anchor(top: mainStack.topAnchor, leading: mainStack.leadingAnchor, bottom: nil, trailing: mainStack.trailingAnchor, padding: .init(top: 0, left: 35, bottom: 0, right: 35))
        
        let cardPile = UIView()
        
        mainStack.addSubview(cardPile)
        
        cardPile.anchor(top: buttonView.bottomAnchor, leading: mainStack.leadingAnchor, bottom: mainStack.bottomAnchor, trailing: mainStack.trailingAnchor)
        
        let creator = CardCreator(playersList: players)
        let deck = creator.buildDeck()

        for card in deck {
            cardPile.addSubview(card)
            if card != deck.last {
                card.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: -50)
            } else {
                card.activate()
            }
        }
        
        SKPaymentQueue.default().add(self)
        getPurchaseInfo()
        buttonEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.setBackgroundImage(image: UIImage(named: "background"), alpha: 1)
//        view.backgroundColor = #colorLiteral(red: 0, green: 0.6980392157, blue: 0.9725490196, alpha: 1)
        if UserDefaults.standard.value(forKey: "isFirstLoad") == nil {
            addTutorial()
            UserDefaults.standard.set(false, forKey: "isFirstLoad")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.subviews.first?.removeFromSuperview()
    }
    
    // MARK: - Top Bar Buttons
    
    @objc fileprivate func handleExitTapped(sender: UIButton) {
        if type(of: sender) == type(of: CustomButton()) {
            let alert = UIAlertController(title: "Are you sure you want to exit the game?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                if self.interstitial != nil && self.interstitial.isReady {
                    self.interstitial.present(fromRootViewController: self)
                } else {
                    self.dismiss(animated: true)
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    var isFlipped = false
    var flippedCard: CardView?
    
    @objc func handleHelpTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        if !isFlipped {
            handleOpenHelp()
        } else {
            handleCloseHelp()
        }
    }
    
    fileprivate func handleOpenHelp() {
        if (self.mainStack.subviews.last!.subviews.last as? CardView) != nil {
            helpButton.isEnabled = false
            let helpCard = CardHelpView(referenceCard: (self.mainStack.subviews.last!.subviews.last as! CardView))
            UIView.transition(with: (self.mainStack.subviews.last!.subviews.last as! CardView), duration: 0, options: .transitionCrossDissolve, animations: {
                self.flippedCard = (self.mainStack.subviews.last!.subviews.last as! CardView)
                self.mainStack.subviews.last!.subviews.last!.removeFromSuperview()
                let container = UIView()
                self.mainStack.subviews.last!.addSubview(container)
                container.fillSuperview()
                container.addSubview(self.flippedCard!)
            }) { (_) in
                UIView.transition(from: (self.mainStack.subviews.last!.subviews.last!.subviews.first as! CardView), to: helpCard, duration: 0.4, options: .transitionFlipFromLeft) { (_) in
                    self.isFlipped = true
                    self.helpButton.isEnabled = true
                }
            }
        }
    }
    
    @objc fileprivate func handleCloseHelp() {
        helpButton.isEnabled = false
        UIView.transition(from: (self.mainStack.subviews.last!.subviews.last!.subviews.first as! CardHelpView), to: self.flippedCard!, duration: 0.4, options: .transitionFlipFromRight) { (_) in
            self.mainStack.subviews.last!.subviews.last!.removeFromSuperview()
            self.mainStack.subviews.last!.addSubview(self.flippedCard!)
            self.isFlipped = false
            self.helpButton.isEnabled = true
        }
    }
    
    // MARK: - Game Over Screen
    
    var gameOver = false
    
    var doneLabel: UILabel {
        if _doneLabel == nil {
            _doneLabel = UILabel()
            _doneLabel!.text = "Game Over"
            _doneLabel!.textAlignment = .center
            _doneLabel!.font = UIFont.systemFont(ofSize: 50, weight: .heavy)
            _doneLabel!.numberOfLines = 0
            _doneLabel!.textColor = .white
            _doneLabel!.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
        return _doneLabel!
    }

    var _doneLabel: UILabel?
    
    var playAgainButton: UIButton {
        if _playAgainButton == nil {
            _playAgainButton = UIButton()
            _playAgainButton!.setTitle("Play Again", for: .normal)
            _playAgainButton!.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.5215686275, blue: 0.2196078431, alpha: 1)
            _playAgainButton!.titleLabel?.font = UIFont(name: "TitanOne", size: 25)
            _playAgainButton!.layer.cornerRadius = 18
            _playAgainButton!.heightAnchor.constraint(equalToConstant: 65).isActive = true
            _playAgainButton!.transform = CGAffineTransform(scaleX: 0, y: 0)
            _playAgainButton!.addTarget(self, action: #selector(handlePlayAgainTapped), for: .touchUpInside)
        }
        return _playAgainButton!
    }
    
    var _playAgainButton: UIButton?
    
    var exitGameButton: UIButton {
        if _exitGameButton == nil {
            _exitGameButton = UIButton()
            _exitGameButton!.setTitle("Exit Game", for: .normal)
            _exitGameButton!.backgroundColor = #colorLiteral(red: 1, green: 0.8156862745, blue: 0.0431372549, alpha: 1)
            _exitGameButton!.titleLabel?.font = UIFont(name: "TitanOne", size: 25)
            _exitGameButton!.layer.cornerRadius = 18
            _exitGameButton!.heightAnchor.constraint(equalToConstant: 65).isActive = true
            _exitGameButton!.transform = CGAffineTransform(scaleX: 0, y: 0)
            _exitGameButton!.addTarget(self, action: #selector(handleExitTapped), for: .touchUpInside)
        }
        return _exitGameButton!
    }
    
    var _exitGameButton: UIButton?
    
    var gameOverStack: UIStackView {
        if _gameOverStack == nil {
            _gameOverStack = UIStackView()
            _gameOverStack!.axis = .vertical
            _gameOverStack!.spacing = 20
            _gameOverStack!.distribution = .fillProportionally
        }
        return _gameOverStack!
    }
    
    var _gameOverStack: UIStackView?
    
    var purchaseButton: UIButton {
        if _purchaseButton == nil {
            _purchaseButton = UIButton()
            _purchaseButton!.setTitle("Remove Ads (" + (Locale.current.currencySymbol ?? "$") + "0.99)", for: .normal)
            _purchaseButton!.titleLabel?.font = UIFont(name: "TitanOne", size: 25)
            _purchaseButton!.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            _purchaseButton!.layer.cornerRadius = 18
            _purchaseButton!.heightAnchor.constraint(equalToConstant: 65).isActive = true
            _purchaseButton!.transform = CGAffineTransform(scaleX: 0, y: 0)
//            _purchaseButton!.addTarget(self, action: #selector(handlePurchaseTapped), for: .touchUpInside)
            _purchaseButton!.alpha = 0.6
            _purchaseButton!.isEnabled = false
        }
        return _purchaseButton!
    }
    
    var _purchaseButton: UIButton?
    
    func prepareFinish() {
        if interstitial != nil && interstitial.isReady {
            gameOver = true
//            interstitial.present(fromRootViewController: self)
        } else {
            addFinish()
        }
    }
    
    func addFinish() {
        self.mainStack.subviews.last!.addSubview(gameOverStack)
        
        gameOverStack.anchor(top: nil, leading: gameOverStack.superview!.leadingAnchor, bottom: nil, trailing: gameOverStack.superview!.trailingAnchor, padding: .init(top: 0, left: 40, bottom: 0, right: 40))
        gameOverStack.centerXAnchor.constraint(equalTo: gameOverStack.superview!.superview!.centerXAnchor).isActive = true
        gameOverStack.centerYAnchor.constraint(equalTo: gameOverStack.superview!.superview!.centerYAnchor).isActive = true
        
        activateShadow(for: doneLabel, shadow: .init(width: 4, height: 4))
        gameOverStack.addArrangedSubview(doneLabel)
        
        activateShadow(for: playAgainButton, shadow: .init(width: 4, height: 4))
        gameOverStack.addArrangedSubview(playAgainButton)
        
        activateShadow(for: exitGameButton, shadow: .init(width: 4, height: 4))
        gameOverStack.addArrangedSubview(exitGameButton)
        
        if UserDefaults.standard.value(forKey: "adsOn") == nil {
            activateShadow(for: purchaseButton, shadow: .init(width: 4, height: 4))
            gameOverStack.addArrangedSubview(purchaseButton)
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            self.doneLabel.transform = .identity
        })
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            self.playAgainButton.transform = .identity
        })
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            self.exitGameButton.transform = .identity
        })
        UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            self.purchaseButton.transform = .identity
        })
    }
    
    @objc fileprivate func handlePlayAgainTapped() {
        gameOver = false
        
        let creator = CardCreator(playersList: self.players)
        let deck = creator.buildDeck()
        
        for view in mainStack.subviews.last!.subviews {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { (_) in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                }) { (_) in
                    view.removeFromSuperview()
                    for card in deck {
                        self.mainStack.subviews.last!.addSubview(card)
                        if card != deck.last {
                            card.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: self.view.frame.height)
                        } else {
                            card.activate()
                            card.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
                        }
                    }

                    for view in self.mainStack.subviews.last!.subviews {
                        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
                            if view != self.mainStack.subviews.last!.subviews.last {
                                view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: -50)
                            } else {
                                view.transform = .identity
                            }
                        }) { (_) in
                            self.exitButton.isEnabled = true
                            self.helpButton.isEnabled = true
                            
                            self._gameOverStack = nil
                            self._doneLabel = nil
                            self._playAgainButton = nil
                            self._exitGameButton = nil
                            self._purchaseButton = nil
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Shake Handling
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        print("SHAKE")
        if let card = view.subviews.last?.subviews.last?.subviews.last as? CardView {
            let generator = UINotificationFeedbackGenerator()
            
            if card.shakeText != "" && card.textLabel.text != card.shakeText {
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    let degrees: CGFloat = -5
                    let angle = degrees * .pi / 100
                    
                    card.transform = CGAffineTransform(rotationAngle: angle)
                }) { (_) in
                    card.textLabel.attributedText = NSAttributedString(string: card.shakeText, attributes: [.font: UIFont.systemFont(ofSize: CGFloat(27), weight: .regular)])
                    generator.notificationOccurred(.success)
                    
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
                        card.transform = CGAffineTransform.identity
                    })
                }
            }
        }
    }
    
    // MARK: - IAP
    
    var product: SKProduct?
    var productID = "Thomas.Tipsy.RemoveAds"
    
    var buttonEnabled = true {
        didSet {
            if buttonEnabled == false {
                purchaseButton.isEnabled = false
                purchaseButton.alpha = 0.6
            } else {
                purchaseButton.isEnabled = true
                purchaseButton.alpha = 1
            }
        }
    }
    
    func getPurchaseInfo() {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: NSSet(objects: self.productID) as! Set<String>)
            request.delegate = self
            request.start()
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        
        if products.count > 0 {
            product = products[0]
            
            print(product!.localizedTitle)
            print(product!.localizedDescription)
            
            if UserDefaults.standard.value(forKey: "adsOn") == nil {
                DispatchQueue.main.async {
                    self.buttonEnabled = true
                }
            }
        }
        
        let invalids = response.invalidProductIdentifiers
        
        for product in invalids {
            print("Product not found: \(product)")
        }
    }
    
    @objc func handlePurchaseTapped() {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product!)
            SKPaymentQueue.default().add(payment)
            buttonEnabled = false
        } else {
            let alert = UIAlertController(title: "Purchasing Disabled", message: "In-app purchasing is disabled. Please enable this if you wish to make purchases.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Payment Queue Triggered")
        
        for transaction in transactions {
            
            
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                
                let alert = UIAlertController(title: "Purchase Successful", message: "Your purchase was successfully made. Thank you for supporting Card Master, we hope you enjoy your ad-free experience!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                buttonEnabled = false
                purchaseButton.setTitle("Purchased", for: .normal)
                
                UserDefaults.standard.set(false, forKey: "adsOn")
                UserDefaults.standard.synchronize()
                interstitial = nil
                
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                
                let alert = UIAlertController(title: "Purchase Unsuccessful", message: "Your purchase was unsuccessful. Please try again later!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                buttonEnabled = true
                
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                
                let alert = UIAlertController(title: "Purchase Restored", message: "Your purchase was successfully restored. Thank you for supporting Card Master, we hope you enjoy your ad-free experience!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                buttonEnabled = false
                purchaseButton.setTitle("Purchased", for: .normal)
                
                UserDefaults.standard.set(false, forKey: "adsOn")
                UserDefaults.standard.synchronize()
                interstitial = nil
                
            default:
                break
            }
        }
    }
    
    // MARK: - AdMob
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-6591462150524454/6645203434")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
//        view.setBackgroundImage(image: UIImage(named: "background"), alpha: 1)
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        interstitial = createAndLoadInterstitial()
        if gameOver {
            addFinish()
        } else {
            self.dismiss(animated: true)
        }
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
    // MARK: - Tutorial Screen
    
    let tutorialView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.9)
        return view
    }()
    
    let tutorialStack: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 30
        stackView.axis = .vertical
        return stackView
    }()
    
    let tutorialGestureImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "swipe_gesture"))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        return imageView
    }()
    
    let tutorialLabel1: UILabel = {
        let label = UILabel()
        label.text = "Swipe away playing cards in any direction to progress through the game"
        label.font = UIFont.systemFont(ofSize: 25)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let tutorialHelpButton: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "questionmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .regular))?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        return imageView
    }()
    
    let tutorialLabel2: UILabel = {
        let label = UILabel()
        label.text = "Press the help button if you get stuck and need more information about any card"
        label.font = UIFont.systemFont(ofSize: 25)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let tutorialButton: UIButton = {
        let button = UIButton()
        button.setTitle("Got It!", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(handleTutorialDismissPressed), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3)
        button.layer.cornerRadius = 15
        return button
    }()
    
    func addTutorial() {
        view.insertSubview(tutorialView, at: 500)
        tutorialView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        tutorialView.addSubview(tutorialStack)
        tutorialStack.anchor(top: nil, leading: tutorialView.leadingAnchor, bottom: nil, trailing: tutorialView.trailingAnchor, padding: .init(top: 0, left: 40, bottom: 0, right: 40))
        tutorialStack.centerYAnchor.constraint(equalTo: tutorialView.centerYAnchor).isActive = true
        tutorialStack.addArrangedSubview(tutorialGestureImage)
        tutorialStack.addArrangedSubview(tutorialLabel1)
        tutorialStack.addArrangedSubview(tutorialHelpButton)
        tutorialStack.addArrangedSubview(tutorialLabel2)
        tutorialStack.addArrangedSubview(tutorialButton)
        UIView.animate(withDuration: 0.2, animations: {
            self.tutorialView.alpha = 1
        })
    }
    
    @objc func handleTutorialDismissPressed() {
        UIView.animate(withDuration: 0.2, animations: {
            self.tutorialView.alpha = 0
        }) { (_) in
            self.tutorialView.removeFromSuperview()
        }
    }
    
    // MARK: - Helpers
    
    func activateShadow(for v: UIView, shadow: CGSize) {
        v.layer.masksToBounds = false
        v.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        v.layer.shadowOpacity = 0.2
        v.layer.shadowRadius = 0
        v.layer.shouldRasterize = true
        v.layer.shadowOffset = shadow
        v.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
