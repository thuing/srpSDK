//
//  frameworkTest.swift
//  srpSDKFramework
//
//  Created by 小福 on 2019/3/19.
//  Copyright © 2019 小福. All rights reserved.
//


import UIKit

// MARK: 自定义的一个首页视图
public class YLXHomeView: UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        layout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 配置页面
    func setupUI() {
        addSubview(iconImgV)
    }
    
    // 布局页面
    func layout() {
        iconImgV.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    lazy var iconImgV: UIImageView = {
        let view = UIImageView.init()
        view.backgroundColor = UIColor.purple
        return view
    }()
    
}
