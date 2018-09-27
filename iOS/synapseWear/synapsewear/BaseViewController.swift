//
//  BaseViewController.swift
//  synapsewear
//
//  Copyright © 2017年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    // variables
    var vcData: [String: Any] = [:]
    // views
    var loadingView: UIView?
    var indicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setParam()
        self.setView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nav = self.navigationController as? NavigationController {
            nav.checkHeaderButtons()
            nav.headerSettingBtn.isHidden = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.resizeView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: mark - BaseViewController methods

    public func setParam() {
    }

    public func setView() {

        self.setLoadingView()
    }

    public func resizeView() {
    }

    // MARK: mark - LoadingView methods

    public func setLoadingView() {

        let x: CGFloat = 0
        let y: CGFloat = 0
        let w: CGFloat = self.view.frame.width
        let h: CGFloat = self.view.frame.height

        self.loadingView = UIView()
        self.loadingView?.frame = CGRect(x: x, y: y, width: w, height: h)
        self.loadingView?.backgroundColor = UIColor.clear
        self.view.addSubview(self.loadingView!)

        let loadingBackView: UIView = UIView()
        loadingBackView.frame = CGRect(x: 0, y: 0, width: self.loadingView!.frame.size.width, height: self.loadingView!.frame.size.height)
        loadingBackView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.loadingView?.addSubview(loadingBackView)

        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.indicator?.frame = CGRect(x: (self.loadingView!.frame.size.width - 50.0) / 2, y: (self.loadingView!.frame.size.height - 50.0) / 2, width: 50.0, height: 50.0)
        self.loadingView?.addSubview(self.indicator!)

        self.setHiddenLoadingView(true)
    }

    public func setHiddenLoadingView(_ flag: Bool) {

        self.loadingView?.isHidden = flag
        if flag {
            self.indicator?.stopAnimating()
            if self.loadingView != nil {
                self.view.sendSubview(toBack: self.loadingView!)
            }
        }
        else {
            self.indicator?.startAnimating()
            if self.loadingView != nil {
                self.view.bringSubview(toFront: self.loadingView!)
            }
        }
    }
}
