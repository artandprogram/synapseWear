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
    
    /*override var preferredStatusBarStyle: UIStatusBarStyle {

        if #available(iOS 13, *) {
            print("darkContent")
            return .darkContent
        }
        else {
            return .default
        }
    }*/

    // MARK: mark - Set Variables methods

    func setParam() {
    }

    // MARK: mark - Set Views methods

    func setView() {

        self.view.backgroundColor = UIColor.grayBGColor
        self.setLoadingView()
    }

    func setLoadingView() {

        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = self.view.frame.width
        var h: CGFloat = self.view.frame.height
        self.loadingView = UIView()
        self.loadingView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.loadingView.backgroundColor = UIColor.clear
        self.view.addSubview(self.loadingView)

        x = 0
        y = 0
        w = self.loadingView.frame.size.width
        h = self.loadingView.frame.size.height
        let loadingBackView: UIView = UIView()
        loadingBackView.frame = CGRect(x: x, y: y, width: w, height: h)
        loadingBackView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.loadingView.addSubview(loadingBackView)

        w = 50.0
        h = 50.0
        x = (self.loadingView.frame.size.width - w) / 2
        y = (self.loadingView.frame.size.height - h) / 2
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.indicator.frame = CGRect(x: x, y: y, width: w, height: h)
        self.loadingView.addSubview(self.indicator)

        self.setHiddenLoadingView(true)
    }

    func setViewControllers() {

        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = self.view.frame.width
        var h: CGFloat = self.view.frame.height - y
        self.menuContainerView = UIView()
        self.menuContainerView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.menuContainerView.backgroundColor = UIColor.clear
        self.view.addSubview(self.menuContainerView)

        x = 0
        y = 0
        w = self.menuContainerView.frame.size.width
        h = self.menuContainerView.frame.size.height
        self.menuViewController = MenuViewController()
        self.menuViewController.view.frame = CGRect(x: x, y: y, width: w, height: h)
        self.menuContainerView.addSubview(self.menuViewController.view)
        self.addChildViewController(self.menuViewController)
        self.menuViewController.didMove(toParentViewController: self)

        x = self.menuContainerView.frame.origin.x
        y = self.menuContainerView.frame.origin.y
        w = self.menuContainerView.frame.size.width
        h = self.menuContainerView.frame.size.height
        self.mainContainerView = UIView()
        self.mainContainerView.frame = CGRect(x: x, y: y, width: w, height: h)
        self.mainContainerView.backgroundColor = UIColor.clear
        self.view.addSubview(self.mainContainerView)

        x = 0
        y = 0
        w = self.mainContainerView.frame.size.width
        h = self.mainContainerView.frame.size.height
        self.mainViewController = NavigationController()
        self.mainViewController.view.frame = CGRect(x: x, y: y, width: w, height: h)
        self.mainContainerView.addSubview(self.mainViewController.view)
        self.addChildViewController(self.mainViewController)
        self.mainViewController.didMove(toParentViewController: self)

        x = 0
        y = 0
        w = self.mainContainerView.frame.size.width
        h = self.mainContainerView.frame.size.height
        self.menuCloseButton = UIButton()
        self.menuCloseButton.frame = CGRect(x: x, y: y, width: w, height: h)
        self.menuCloseButton.backgroundColor = UIColor.clear
        self.menuCloseButton.addTarget(self, action: #selector(MainViewController.menuAction), for: .touchDown)
        self.menuCloseButton.isHidden = true
        self.mainContainerView.addSubview(self.menuCloseButton)

        self.view.bringSubview(toFront: self.loadingView)
    }

    func setHiddenLoadingView(_ flag: Bool) {

        self.loadingView.isHidden = flag
        if flag {
            self.indicator.stopAnimating()
        }
        else {
            self.indicator.startAnimating()
        }
    }

    // MARK: mark - Change Menu methods

    func changeMenu(_ indexPath: IndexPath) {

        self.mainViewController.changePage(indexPath)
        self.menuAction()
    }

    @objc func menuAction() {

        if mainContainerView.frame.origin.x == 0 {
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseIn,
                           animations: { () -> Void in
                self.mainContainerView.frame = CGRect(x: self.menuW,
                                                      y: self.mainContainerView.frame.origin.y,
                                                      width: self.mainContainerView.frame.size.width,
                                                      height: self.mainContainerView.frame.size.height)
            }, completion: { _ in
                self.menuCloseButton.isHidden = false
            })
        }
        else {
            self.menuCloseButton.isHidden = true
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseIn,
                           animations: { () -> Void in
                self.mainContainerView.frame = CGRect(x: 0,
                                                      y: self.mainContainerView.frame.origin.y,
                                                      width: self.mainContainerView.frame.size.width,
                                                      height: self.mainContainerView.frame.size.height)
            }, completion: { _ in
            })
        }
    }
}
