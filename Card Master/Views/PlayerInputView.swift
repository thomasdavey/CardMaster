//
//  PlayerInputView.swift
//  Card Master
//
//  Created by Thomas Davey on 11/06/2020.
//  Copyright © 2020 Thomas Davey. All rights reserved.
//

import UIKit

class PlayerInputView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var players: [String] = []
    
    let playerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let playersLabel: UILabel = {
        let label = UILabel()
        label.text = "Players"
        label.font = UIFont(name: "TitanOne", size: 32)
        label.textColor = #colorLiteral(red: 0.4, green: 0.3137254902, blue: 0.2509803922, alpha: 1)
        label.textAlignment = .center
        label.heightAnchor.constraint(equalToConstant: 65).isActive = true
        return label
    }()
    
    let playerTable: UITableView = {
        let table = UITableView()
        table.heightAnchor.constraint(equalToConstant: 132).isActive = true
        table.allowsSelection = false
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: "MyCell")
        return table
    }()
    
    var playerInputView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.heightAnchor.constraint(equalToConstant: 65).isActive = true
        return stackView
    }()
    
    let playerInputField: CustomTextField = {
        let inputField = CustomTextField(height: 39, cornerRadius: 12, padding: 10)
        inputField.placeholder = "Add Player"
        inputField.addTarget(self, action: #selector(addPlayer), for: UIControl.Event.primaryActionTriggered)
        return inputField
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        button.tintColor = #colorLiteral(red: 1, green: 0.8156862745, blue: 0.0431372549, alpha: 1)
        button.backgroundColor = .white
        button.layer.cornerRadius = 80
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 39, weight: .regular)), for: .normal)
        button.contentHorizontalAlignment = .center
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.addTarget(self, action: #selector(addPlayer), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.8941176471, blue: 0.5176470588, alpha: 1)
        self.layer.cornerRadius = 18
        
        playerTable.dataSource = self
        playerTable.delegate = self
        
        let playerInputFieldContainer = UIView()
        playerInputView.addArrangedSubview(playerInputFieldContainer)
        playerInputView.addArrangedSubview(addButton)
        
        playerInputFieldContainer.addSubview(playerInputField)
        playerInputField.anchor(top: playerInputFieldContainer.topAnchor, leading: playerInputFieldContainer.leadingAnchor, bottom: playerInputFieldContainer.bottomAnchor, trailing: playerInputFieldContainer.trailingAnchor, padding: .init(top: 13, left: 13, bottom: 13, right: 0))
        playerInputFieldContainer.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: NSLayoutConstraint.Axis.horizontal)
        
        self.addSubview(playerView)
        playerView.addArrangedSubview(playersLabel)
        playerView.addArrangedSubview(playerTable)
        playerView.addArrangedSubview(playerInputView)
        
        self.heightAnchor.constraint(equalTo: playerView.heightAnchor).isActive = true
        self.widthAnchor.constraint(equalTo: playerView.widthAnchor).isActive = true
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        playerTable.separatorStyle = .none
    }
    
    @objc func addPlayer() {
        if playerInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            players.append(playerInputField.text!.trimmingCharacters(in: .whitespaces))
            print(playerInputField.text!)
            playerTable.reloadData()
            playerTable.scrollToRow(at: IndexPath(row: self.players.count-1, section: 0), at: .bottom, animated: true)
            playerInputField.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(players.count,3)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath) as! CustomTableViewCell
        if indexPath.row >= players.count {
            cell.label.text = ""
            cell.button.alpha = 0
        } else {
            cell.label.text = "\(players[indexPath.row])"
            cell.label.textColor = #colorLiteral(red: 0.4, green: 0.3137254902, blue: 0.2509803922, alpha: 1)
            cell.label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            cell.label.textAlignment = .center
            
            cell.button.alpha = 1
            cell.button.addTarget(self, action: #selector(handleRowDelete), for: .touchUpInside)
            cell.button.tag = indexPath.row
        }
        if(indexPath.row % 2 == 0) {
            cell.backgroundColor = #colorLiteral(red: 1, green: 0.9777502418, blue: 0.8982934952, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc fileprivate func handleRowDelete(sender: UIButton) {
        players.remove(at: sender.tag)
        playerTable.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomTextField: UITextField {
    let padding: CGFloat
    let height: Int
    
    init(height: Int, cornerRadius: CGFloat, padding: CGFloat) {
        self.padding = padding
        self.height = height
        super.init(frame: .zero)
        
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        layer.cornerRadius = cornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: height)
    }
}

class CustomTableViewCell: UITableViewCell {
    let label = UILabel()
    let button = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        contentView.addSubview(button)
        
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: .init(top: 0, left: 40, bottom: 0, right: 40))
        
        button.anchor(top: contentView.topAnchor, leading: nil, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: .init(top: 10.5, left: 0, bottom: 10.5, right: 10.5))

        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)), for: .normal)
        
        button.tintColor = #colorLiteral(red: 0.4, green: 0.3137254902, blue: 0.2509803922, alpha: 1)
        
        button.alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

