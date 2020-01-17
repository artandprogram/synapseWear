//
//  GraphDataTableViewCell.swift
//  synapsewear
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class GraphDataTableViewCell: UITableViewCell {

    let cellH: CGFloat = 36.0
    let cellH2: CGFloat = 20.0
    let titleF: CGFloat = 24.0
    let labelF: CGFloat = 16.0
    let space: CGFloat = 10.0

    var type: Int = 0
    var iconImageView: UIImageView!
    var titleLabel: UILabel!
    var text1Label: UILabel!
    var text2Label: UILabel!
    var text3Label: UILabel!
    var text4Label: UILabel!
    var text5Label: UILabel!
    var text6Label: UILabel!
    var lineView: UIView!

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
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.textAlignment = .left
        self.titleLabel.numberOfLines = 1
        self.contentView.addSubview(self.titleLabel)

        self.text1Label = UILabel()
        self.text1Label.backgroundColor = UIColor.clear
        self.text1Label.font = UIFont(name: "Migu 2M", size: self.labelF)
        self.text1Label.textColor = UIColor.fluorescentPink
        self.text1Label.textAlignment = .left
        self.text1Label.numberOfLines = 1
        self.contentView.addSubview(self.text1Label)

        self.text2Label = UILabel()
        self.text2Label.backgroundColor = UIColor.clear
        self.text2Label.font = UIFont(name: "Migu 2M", size: self.labelF)
        self.text2Label.textColor = UIColor.white
        self.text2Label.textAlignment = .left
        self.text2Label.numberOfLines = 1
        self.contentView.addSubview(self.text2Label)

        self.text3Label = UILabel()
        self.text3Label.backgroundColor = UIColor.clear
        self.text3Label.font = UIFont(name: "Migu 2M", size: self.labelF)
        self.text3Label.textColor = UIColor.white
        self.text3Label.textAlignment = .left
        self.text3Label.numberOfLines = 1
        self.contentView.addSubview(self.text3Label)

        self.text4Label = UILabel()
        self.text4Label.backgroundColor = UIColor.clear
        self.text4Label.font = UIFont(name: "Migu 2M", size: self.labelF)
        self.text4Label.textColor = UIColor.fluorescentPink
        self.text4Label.textAlignment = .left
        self.text4Label.numberOfLines = 1
        self.contentView.addSubview(self.text4Label)

        self.text5Label = UILabel()
        self.text5Label.backgroundColor = UIColor.clear
        self.text5Label.font = UIFont(name: "Migu 2M", size: self.labelF)
        self.text5Label.textColor = UIColor.white
        self.text5Label.textAlignment = .left
        self.text5Label.numberOfLines = 1
        self.contentView.addSubview(self.text5Label)

        self.text6Label = UILabel()
        self.text6Label.backgroundColor = UIColor.clear
        self.text6Label.font = UIFont(name: "Migu 2M", size: self.labelF)
        self.text6Label.textColor = UIColor.white
        self.text6Label.textAlignment = .left
        self.text6Label.numberOfLines = 1
        self.contentView.addSubview(self.text6Label)

        self.lineView = UIView()
        self.lineView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        self.contentView.addSubview(self.lineView)
    }

    func resizeView() {

        let cellWidth: CGFloat = self.contentView.frame.size.width
        let cellHeight: CGFloat = self.contentView.frame.size.height
        var x: CGFloat = self.space
        var y: CGFloat = 0
        var w: CGFloat = 0
        var h: CGFloat = 0
        if self.type == 0 {
            self.text1Label.sizeToFit()
            self.text2Label.sizeToFit()
            self.text3Label.sizeToFit()
            self.text4Label.sizeToFit()
            self.text5Label.sizeToFit()
            self.text6Label.sizeToFit()

            w = self.text1Label.frame.size.width
            h = cellHeight
            self.text1Label.frame = CGRect(x: x, y: y, width: w, height: h)

            if w > 0 {
                x += w + self.space / 2
            }
            w = self.text2Label.frame.size.width
            self.text2Label.frame = CGRect(x: x, y: y, width: w, height: h)

            if w > 0 {
                x += w + self.space
            }
            w = self.text3Label.frame.size.width
            self.text3Label.frame = CGRect(x: x, y: y, width: w, height: h)

            if w > 0 {
                x += w + 2.0
            }
            w = self.text4Label.frame.size.width
            self.text4Label.frame = CGRect(x: x, y: y, width: w, height: h)

            if w > 0 {
                x += w + self.space / 2
            }
            w = self.text5Label.frame.size.width
            self.text5Label.frame = CGRect(x: x, y: y, width: w, height: h)

            if w > 0 {
                x += w + 2.0
            }
            w = self.text6Label.frame.size.width
            self.text6Label.frame = CGRect(x: x, y: y, width: w, height: h)

            self.iconImageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.titleLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.lineView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        else if self.type == 1 {
            w = self.cellH
            h = self.cellH
            self.iconImageView.frame = CGRect(x: x, y: y, width: w, height: h)

            x += w + self.space
            w = cellWidth - (x + self.space)
            self.titleLabel.frame = CGRect(x: x, y: y, width: w, height: h)

            x = self.space
            y += h + self.cellH2 / 2
            w = cellWidth - x * 2
            h = 1.0
            self.lineView.frame = CGRect(x: x, y: y, width: w, height: h)

            self.text1Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.text2Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.text3Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.text4Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.text5Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.text6Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        else if self.type == 2 {
            y = self.cellH2 / 2
            w = cellWidth - x * 2
            h = 1.0
            self.lineView.frame = CGRect(x: x, y: y, width: w, height: h)

            self.iconImageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.titleLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.text1Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.text2Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.text3Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.text4Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.text5Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.text6Label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
    }

    func getCellHeight() -> CGFloat {

        if self.type == 0 {
            return self.cellH
        }
        else if self.type == 1 {
            return self.cellH + self.cellH2
        }
        else if self.type == 2 {
            return self.cellH2
        }
        return 0
    }
}
