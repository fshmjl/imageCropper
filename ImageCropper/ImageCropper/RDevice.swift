//
//  RDevice.swift
//  tengmaoProduct
//
//  Created by RPK on 2019/12/4.
//  Copyright © 2019 Teng Mao Technology. All rights reserved.
//

import UIKit

//MARK: - 系统高度
let kScreenWidth : CGFloat  = UIScreen.main.bounds.size.width
let kScreenHeight : CGFloat = UIScreen.main.bounds.size.height

// Tabbar height.
let kTabbarHeight : CGFloat                 = UIDevice.isIphoneXLater() ? 83.0 : 49.0
// status bar height.
let kStatusBarHeight : CGFloat              = UIDevice.isIphoneXLater() ? 44.0 : 20.0
// navigationBar height
let kNavigationBarHeight : CGFloat          = 44.0
// Tabbar safe bottom margin.
let kTabbarSafeBottomMargin : CGFloat       = UIDevice.isIphoneXLater() ? 34.0 : 0.0
// navigationBar and Status Height
let kNavigationBarAndStatusHeight : CGFloat = UIDevice.isIphoneXLater() ? 88.0 : 64.0


extension UIDevice {
    // iPhone X设备
    class func isIphoneX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        return false
    }
    // iPhone X以上设备   iPhone XS / iPhone XS Max / iPhone XR
    class func isIphoneXLater() -> Bool {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.delegate!.window!
            if (window?.safeAreaInsets.bottom)! > 0.0 {
                return true
            }
            else {
                return false
            }
        } else {
            return false
        }
    }
}
