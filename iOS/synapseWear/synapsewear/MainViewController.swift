//
//  MainViewController.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // const
    let menuW: CGFloat = 200.0
    // variables
    var mainViewController: NavigationController!
    var menuViewController: MenuViewController!
    // views
    var mainContainerView: UIView!
    var menuContainerView: UIView!
    //var backgroundImageView: UIImageView!
    //var menuButton: UIButton!
    var menuCloseButton: UIButton!
    var loadingView: UIView!
    var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setParam()
        self.setView()

        self.setViewControllers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    // MARK: mark - Set Variables methods

    func setParam() {
    }

    // MARK: mark - Set Views methods

    func setView() {

        self.view.backgroundColor = UIColor.grayBGColor
        //self.setBackgroundImageView()
        self.setLoadingView()
    }
    /*
    func setBackgroundImageView() {

        let baseW: CGFloat = 320.0
        let baseH: CGFloat = 463.0
        var imageW: CGFloat = self.view.frame.size.width
        var imageH: CGFloat = imageW / baseW * baseH
        if imageH < self.view.frame.size.height {
            imageH = self.view.frame.size.height;
            imageW = imageH / baseH * baseW;
        }

        backgroundImageView = UIImageView()
        backgroundImageView.frame = CGRect(x: 0, y: 0, width: imageW, height: imageH)
        backgroundImageView.image = UIImage(named: "bg_image.png")
        backgroundImageView.backgroundColor = UIColor.clear
        self.view.addSubview(backgroundImageView)
    } */

    func setLoadingView() {

        let x: CGFloat = 0
        let y: CGFloat = 0
        let w: CGFloat = self.view.frame.width
        let h: CGFloat = self.view.frame.height

        self.loadingView = UIView()
        self.loadingView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.loadingView.backgroundColor = UIColor.clear
        self.view.addSubview(self.loadingView)

        let loadingBackView: UIView = UIView()
        loadingBackView.frame = CGRect(x: 0, y: 0, width: self.loadingView.frame.size.width, height: self.loadingView.frame.size.height)
        loadingBackView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.loadingView.addSubview(loadingBackView)

        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.indicator.frame = CGRect(x: (self.loadingView.frame.size.width - 50.0) / 2, y: (self.loadingView.frame.size.height - 50.0) / 2, width: 50.0, height: 50.0)
        self.loadingView.addSubview(self.indicator)

        self.setHiddenLoadingView(true)
    }

    func setViewControllers() {

        let x: CGFloat = 0
        let y: CGFloat = 0
        let w: CGFloat = self.view.frame.width
        let h: CGFloat = self.view.frame.height - y

        self.menuContainerView = UIView()
        self.menuContainerView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.menuContainerView.backgroundColor = UIColor.clear
        self.view.addSubview(self.menuContainerView)

        self.menuViewController = MenuViewController();
        self.menuViewController.view.frame = CGRect(x: 0, y: 0, width: self.menuContainerView.frame.size.width, height: self.menuContainerView.frame.size.height)
        self.menuContainerView.addSubview(self.menuViewController.view)

        self.addChildViewController(self.menuViewController)
        self.menuViewController.didMove(toParentViewController: self)

        self.mainContainerView = UIView()
        self.mainContainerView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.mainContainerView.backgroundColor = UIColor.clear
        self.view.addSubview(self.mainContainerView)

        self.mainViewController = NavigationController();
        self.mainViewController.view.frame = CGRect(x: 0, y: 0, width: self.mainContainerView.frame.size.width, height: self.mainContainerView.frame.size.height)
        self.mainContainerView.addSubview(self.mainViewController.view)

        self.addChildViewController(self.mainViewController)
        self.mainViewController.didMove(toParentViewController: self)

        self.menuCloseButton = UIButton()
        self.menuCloseButton.frame = CGRect(x: 0, y: 0, width: self.mainContainerView.frame.size.width, height: self.mainContainerView.frame.size.height)
        self.menuCloseButton.backgroundColor = UIColor.clear
        self.menuCloseButton.addTarget(self, action: #selector(MainViewController.menuAction), for: .touchDown)
        self.menuCloseButton.isHidden = true
        self.mainContainerView.addSubview(self.menuCloseButton)

        self.view.bringSubview(toFront: self.loadingView)
    }
    /*
    func setMenuButton() {

        let x:CGFloat = 0
        let y:CGFloat = 20.0
        let w:CGFloat = 80.0
        let h:CGFloat = 44.0

        menuButton = UIButton()
        menuButton.frame = CGRect(x: x, y: y, width: w, height: h)
        menuButton.setTitle("Menu", for: .normal)
        menuButton.setTitleColor(UIColor.white, for: .normal)
        //menuButton.setTitle("Menu", for: .highlighted)
        //menuButton.setTitleColor(UIColor.yellow, for: .highlighted)
        menuButton.titleLabel?.font = UIFont(name: "HiraKakuProN-W6", size: 16)
        //menuButton.tag = 1
        menuButton.backgroundColor = UIColor.blue
        menuButton.layer.cornerRadius = 10
        menuButton.layer.borderWidth = 1
        menuButton.layer.borderColor = UIColor.white.cgColor
        menuButton.addTarget(self, action: #selector(MainViewController.menuAction), for: .touchUpInside)
        self.view.addSubview(menuButton)
    } */

    public func setHiddenLoadingView(_ flag: Bool) {

        self.loadingView.isHidden = flag
        if flag {
            self.indicator.stopAnimating()
        }
        else {
            self.indicator.startAnimating()
        }
    }

    // MARK: mark - Change Menu methods

    public func changeMenu(_ indexPath: IndexPath) {

        self.mainViewController.changePage(indexPath)
        self.menuAction()
    }

    @objc func menuAction() {

        //NSLog("menuAction")
        if mainContainerView.frame.origin.x == 0 {
            UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.mainContainerView.frame = CGRect(x: self.menuW, y: self.mainContainerView.frame.origin.y, width: self.mainContainerView.frame.size.width, height: self.mainContainerView.frame.size.height)
            }, completion: { _ in
                self.menuCloseButton.isHidden = false
            })
        }
        else {
            self.menuCloseButton.isHidden = true
            UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.mainContainerView.frame = CGRect(x: 0, y: self.mainContainerView.frame.origin.y, width: self.mainContainerView.frame.size.width, height: self.mainContainerView.frame.size.height)
            }, completion: { _ in
            })
        }
    }
}
