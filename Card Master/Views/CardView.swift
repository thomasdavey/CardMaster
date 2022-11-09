//
//  CardView.swift
//  Card Master
//
//  Created by Thomas Davey on 02/06/2020.
//  Copyright © 2020 Thomas Davey. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
        label.numberOfLines = 0
        label.textColor = .white
        label.alpha = 0
        return label
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        label.alpha = 0
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: NSLayoutConstraint.Axis.vertical)
        return label
    }()
    
    var helpText = ""
    var shakeText = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .random
        
        layer.cornerRadius = 30
        layer.masksToBounds = true
        
        self.addSubview(categoryLabel)
        categoryLabel.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: .init(top: 30, left: 30, bottom: 0, right: 30))
        
        self.addSubview(textLabel)
        textLabel.anchor(top: categoryLabel.bottomAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 30, left: 30, bottom: 30, right: 30))
    }
    
    override func didMoveToSuperview() {
        self.fillSuperview(padding: .init(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func activate() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        
        self.addGestureRecognizer(panGesture)
        
        self.transform = .identity
        
        self.activateShadow()
        
        self.categoryLabel.alpha = 1
        self.textLabel.alpha = 1
        
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 15
        
//        let bool = self.superview?.superview?.superview?.next?.isKind(of: CardViewController.self)
//        print(bool!)
    }
    
    fileprivate func prepareNextCard() {
        if self.superview!.subviews.count > 1 {
            for view in self.superview!.subviews.reversed() {
                if view != self {
                    if (view as? CardView) != nil {
                        (view as? CardView)?.activate()
                        print("Next!")
                    }
                    break
                }
            }
        } else {
            print("Done!")
            (superview!.superview!.subviews.first!.subviews.first as! UIButton).isEnabled = false
            (superview!.superview!.subviews.first!.subviews.last as! UIButton).isEnabled = false
        }
    }
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case.began:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            self.superview!.subviews.last?.layer.removeAllAnimations()
        case .changed:
            handlePanChanged(gesture)
        case .ended:
            handlePanEnded(gesture)
        default:
            ()
        }
    }
    
    fileprivate func handlePanChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        
        let degrees: CGFloat = translation.x / 30
        let angle = degrees * .pi / 100
        
        let rotationalTransform = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransform.translatedBy(x: translation.x, y: translation.y)
    }
    
    fileprivate func handlePanEnded(_ gesture: UIPanGestureRecognizer) {
        let translationXDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let translationYDirection: CGFloat = gesture.translation(in: nil).y > 0 ? 1 : -1
        let shouldDismiss = abs(gesture.translation(in: nil).x) > 100 || abs(gesture.translation(in: nil).y) > 100
        
        if shouldDismiss {
            UIView.animate(withDuration: 0.2, animations: {
                self.layer.frame = CGRect(x: abs(gesture.translation(in: nil).x) * (8 * translationXDirection), y: abs(gesture.translation(in: nil).y) * (8 * translationYDirection), width: self.frame.width, height: self.frame.height)
                self.prepareNextCard()
                
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }) { (_) in
                let superview = self.superview!
                self.removeFromSuperview()
                if superview.subviews.count == 0 {
                    (superview.superview!.superview!.next as! CardViewController).prepareFinish()
                }
            }
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.transform = .identity
            })
        }
    }
    
    fileprivate func activateShadow() {
        layer.masksToBounds = false
        layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

extension UIColor {
    static var random: UIColor {
        return .init(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)
    }
}
