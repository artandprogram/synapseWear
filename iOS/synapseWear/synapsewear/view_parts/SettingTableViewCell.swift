//
//  SettingTableViewCell.swift
//  synapsewear
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    let cellH: CGFloat = 44.0
    let titleF: CGFloat = 16.0
    let swicthW: CGFloat = 50.0
    let swicthH: CGFloat = 32.0
    let arrowW: CGFloat = 7.0
    let arrowH: CGFloat = 14.0
    let checkmarkW: CGFloat = 18.0
    let checkmarkH: CGFloat = 16.0
    let space: CGFloat = 10.0

    var iconImageView: UIImageView!
    var titleLabel: UILabel!
    var textField: UITextField!
    var swicth: UISwitch!
    var lineView: UIView!
    var arrowView: ArrowView!
    var checkmarkView: CheckmarkView!
    var useCheckmark: Bool = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder: ) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.resizeView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setView() {

        self.contentView.backgroundColor = UIColor.clear

        self.iconImageView = UIImageView()
        self.iconImageView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.iconImageView)

        self.titleLabel = UILabel()
        self.titleLabel.backgroundColor = UIColor.clear
        self.titleLabel.font = UIFont(name: "HelveticaNeue", size: self.titleF)
        self.titleLabel.textColor = UIColor.darkGray
        self.titleLabel.textAlignment = .left
        self.titleLabel.numberOfLines = 1
        self.contentView.addSubview(self.titleLabel)

        self.textField = UITextField()
        self.textField.backgroundColor = UIColor.clear
        self.textField.textColor = UIColor.fluorescentPink
        self.textField.font = UIFont(name: "HelveticaNeue", size: 14)
        self.textField.borderStyle = .none
        self.textField.textAlignment = .right
        self.textField.clearButtonMode = .whileEditing
        self.contentView.addSubview(self.textField)

        self.swicth = UISwitch()
        self.swicth.onTintColor = UIColor.fluorescentPink
        self.contentView.addSubview(self.swicth)

        self.lineView = UIView()
        self.lineView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.contentView.addSubview(self.lineView)

        self.arrowView = ArrowView()
        self.arrowView.frame = CGRect(x: 0, y: 0, width: self.arrowW, height: self.arrowH)
        self.arrowView.backgroundColor = .clear
        self.arrowView.type = ArrowView.right
        self.arrowView.triangleColor = UIColor.black
        self.arrowView.alpha = 0.2
        self.contentView.addSubview(self.arrowView)

        self.checkmarkView = CheckmarkView()
        self.checkmarkView.frame = CGRect(x: 0, y: 0, width: self.checkmarkW, height: self.checkmarkH)
        self.checkmarkView.backgroundColor = .clear
        self.checkmarkView.triangleColor = UIColor.fluorescentPink
        self.checkmarkView.isHidden = true
        self.contentView.addSubview(self.checkmarkView)
    }
    
    func resizeView() {

        let cellWidth: CGFloat = self.contentView.frame.size.width
        let cellHeight: CGFloat = self.contentView.frame.size.height
        var x: CGFloat = self.space
        var y: CGFloat = 0
        var w: CGFloat = 0
        var h: CGFloat = cellHeight
        if !self.iconImageView.isHidden {
            let imageH: CGFloat = h - 12.0
            self.iconImageView.frame = CGRect(x: x + (h - imageH) / 2, y: y + (h - imageH) / 2, width: imageH, height: imageH)
            x += h + self.space
        }
        self.titleLabel.frame = CGRect(x: x, y: y, width: w, height: h)

        x = cellWidth
        if !self.arrowView.isHidden {
            w = self.arrowW
            h = self.arrowH
            y = (cellHeight - h) / 2
            x -= w + self.space
            self.arrowView.frame = CGRect(x: x, y: y, width: w, height: h)
        }

        if self.useCheckmark {
            w = self.checkmarkW
            h = self.checkmarkH
            y = (cellHeight - h) / 2
            x -= w + self.space
            self.checkmarkView.frame = CGRect(x: x, y: y, width: w, height: h)
        }

        if !self.swicth.isHidden {
            w = self.swicthW
            h = self.swicthH
            y = (cellHeight - h) / 2
            x -= w + self.space
            self.swicth.frame = CGRect(x: x, y: y, width: w, height: h)
        }

        w = x - (self.titleLabel.frame.origin.x + self.space)
        h = self.titleLabel.frame.size.height
        x = self.titleLabel.frame.origin.x
        y = self.titleLabel.frame.origin.y
        if !self.textField.isHidden {
            var altW: CGFloat = 0
            if let text = self.titleLabel.text, text.count > 0 {
                self.titleLabel.sizeToFit()
                altW = self.titleLabel.frame.size.width + 8.0
            }
            self.textField.frame = CGRect(x: x + altW, y: y, width: w - altW, height: h)
        }
        self.titleLabel.frame = CGRect(x: x, y: y, width: w, height: h)

        x = self.titleLabel.frame.origin.x
        w = cellWidth - x
        h = 1.0
        y = cellHeight - h
        self.lineView.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    /*
    func getCellHeight(_ width: CGFloat, title: String?, subtitle: String?, isButtonHidden: Bool) -> CGFloat {

        return self.cellH
    }
     */
}

