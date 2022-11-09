//
//  AboutViewController.swift
//  Card Master
//
//  Created by Thomas Davey on 22/06/2020.
//  Copyright © 2020 Thomas Davey. All rights reserved.
//

import UIKit
import StoreKit

class AboutViewController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
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
    
    let closeButton: CustomButton = {
        let button = CustomButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)), for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
        return button
    }()
    
    let logoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logonew"))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        return imageView
    }()
    
    let aboutView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.8941176471, blue: 0.5176470588, alpha: 1)
        view.layer.cornerRadius = 18
        return view
    }()
    
    let aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "Credits"
        label.font = UIFont(name: "TitanOne", size: 32)
        label.textColor = #colorLiteral(red: 0.4, green: 0.3137254902, blue: 0.2509803922, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = #colorLiteral(red: 1, green: 0.9907886562, blue: 0.9578937636, alpha: 1)
        textView.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: NSLayoutConstraint.Axis.vertical)
//        textView.numberOfLines = 0
        textView.isSelectable = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
//        let text = NSMutableAttributedString(string: "Please do not use alcohol to play Card Master. This game should be played with a non-alcoholic drink, such as juice or water.\n\n")
        let text = NSMutableAttributedString(string: "")
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        text.setAttributes([.font: UIFont.systemFont(ofSize: 18, weight: .regular), .paragraphStyle: paragraph, .foregroundColor: #colorLiteral(red: 0.4, green: 0.3137254902, blue: 0.2509803922, alpha: 1)], range: NSMakeRange(0, text.length))
        
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        text.append(NSAttributedString(string: "Pop-up icons created by Freepik and downloaded from www.flaticon.com\n\n Card Master Version \(appVersionString)", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .paragraphStyle: paragraph, .foregroundColor: #colorLiteral(red: 0.4, green: 0.3137254902, blue: 0.2509803922, alpha: 0.5)]))
        
        textView.attributedText = text
        return textView
    }()
    
    //Icon made by Freepik from www.flaticon.com
    
    let purchaseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove Ads (" + (Locale.current.currencySymbol ?? "$") + "0.99)", for: .normal)
        button.titleLabel?.font = UIFont(name: "TitanOne", size: 22)
        button.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 65).isActive = true
//        button.addTarget(self, action: #selector(handlePurchaseTapped), for: .touchUpInside)
        return button
    }()
    
    let restoreButton: UIButton = {
        let button = UIButton()
//        button.addTarget(self, action: #selector(handleRestorePurchasesTapped), for: .touchUpInside)
        button.setTitle("Restore Purchases", for: .normal)
        button.titleLabel?.font = UIFont(name: "TitanOne", size: 22)
        button.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.5215686275, blue: 0.2196078431, alpha: 1)
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 65).isActive = true
        return button
    }()
    
    let temp = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0, green: 0.7529411765, blue: 0.9764705882, alpha: 1)
        
        view.addSubview(closeButton)
        closeButton.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 30, left: 0, bottom: 0, right: 30))

        
        let outerStack = UIStackView()
        outerStack.axis = .vertical
        outerStack.spacing = 25
        view.addSubview(outerStack)
        outerStack.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 30, bottom: 0, right: 30))
        outerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        activateShadow(for: logoView)
        outerStack.addArrangedSubview(logoView)
        
        activateShadow(for: aboutView)
        outerStack.addArrangedSubview(aboutView)
        
        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 13
        aboutView.addSubview(innerStack)
        innerStack.anchor(top: aboutView.topAnchor, leading: aboutView.leadingAnchor, bottom: aboutView.bottomAnchor, trailing: aboutView.trailingAnchor, padding: .init(top: 13, left: 0, bottom: 13, right: 0))
        innerStack.addArrangedSubview(aboutLabel)
        innerStack.addArrangedSubview(textView)
        
        let buttonView = UIView()
        innerStack.addArrangedSubview(buttonView)
        let buttonStack = UIStackView()
        buttonView.addSubview(buttonStack)
        buttonStack.anchor(top: buttonView.topAnchor, leading: buttonView.leadingAnchor, bottom: buttonView.bottomAnchor, trailing: buttonView.trailingAnchor, padding: .init(top: 0, left: 13, bottom: 0, right: 13))
        buttonStack.axis = .vertical
        buttonStack.spacing = 13
        buttonStack.addArrangedSubview(purchaseButton)
        buttonStack.addArrangedSubview(restoreButton)
        
        
//        SKPaymentQueue.default().add(self)
//        getPurchaseInfo()
//        buttonEnabled = false
        purchaseButton.isEnabled = false
        restoreButton.isEnabled = false
        purchaseButton.alpha = 0.6
        restoreButton.alpha = 0.6
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        view.setBackgroundImage(image: UIImage(named: "background"), alpha: 1)
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.subviews.first?.removeFromSuperview()
    }
    
    @objc fileprivate func handleCloseTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        self.dismiss(animated: true)
    }
    
    func getPurchaseInfo() {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: NSSet(objects: self.productID) as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "Purchasing Disabled", message: "In-app purchasing is disabled. Please enable this if you wish to make purchases.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        
        if products.count == 0 {
            let alert = UIAlertController(title: "Store Error", message: "A connection to the App Store was not established. Please try again later if you wish to make purchases.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else {
            product = products[0]
            
            print(product!.localizedTitle)
            print(product!.localizedDescription)
            
            if UserDefaults.standard.value(forKey: "adsOn") == nil {
                DispatchQueue.main.async {
                    self.buttonEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self.purchaseButton.setTitle("Purchased", for: .normal)
                }
            }
        }
        
        let invalids = response.invalidProductIdentifiers
        
        for product in invalids {
            print("Product not found: \(product)")
        }
    }
    
    
    @objc func handlePurchaseTapped() {
        let payment = SKPayment(product: product!)
        SKPaymentQueue.default().add(payment)
        buttonEnabled = false
    }
    
    @objc func handleRestorePurchasesTapped() {
        if (SKPaymentQueue.canMakePayments()) {
            SKPaymentQueue.default().restoreCompletedTransactions()
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
                
            default:
                break
            }
        }
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
}
