//
//  GYZStepProgressView.swift
//  JSMachine
//  横向步骤进度条
//  Created by gouyz on 2018/12/4.
//  Copyright © 2018 gouyz. All rights reserved.
//

import UIKit

let selectorColor = kBlueFontColor
let normalColor = kGaryFontColor
let labelFont = 12.0

class GYZStepProgressView: UIScrollView {
    let proWIDTH:Double = 40    //UIView控件的宽高
    let proConfig = 20          //整体控件的前后空隙
    var selectedIndex: Int = 0 //完成的索引
    
    var auditTitles = NSArray() {
        didSet{
            
            if auditTitles.count <= 1 {
                return
            }
            
            if auditTitles.count < 6 && auditTitles.count >= 4{
                SpaceWidth = (Double(BHRect.width) - (Double(auditTitles.count)*proWIDTH) - Double(proConfig * 2)) / Double(auditTitles.count - 1)
            }else if auditTitles.count > 5{
                SpaceWidth = 50
            }else {
                SpaceWidth = (Double(BHRect.width) - (Double(auditTitles.count)*proWIDTH) - Double(proConfig * 2)) / Double(auditTitles.count - 1)
            }
            
            self.contentSize = CGSize(width: (proWIDTH * Double(auditTitles.count)) + (Double(auditTitles.count - 1) * SpaceWidth) + Double(proConfig * 2), height: Double(BHRect.height))
            
            auditTitles.enumerateObjects({ (obj, idx, UnsafeMutablePointer) in
                
                if idx == 0 {
                    self.showOneUI(isShow: true, text: obj as! String)
                    
                }else if idx > 0  &&  idx <= selectedIndex {
                    self.showLaterViewToUI(idx: Double(idx), isShow: true, text: obj as! String)
                }else {
                    self.showLaterViewToUI(idx: Double(idx), isShow: false, text: obj as! String)
                }
            })
            
        }
    }
    
    var BHRect = CGRect()
    var SpaceWidth = Double()
    var SupViewRect = CGRect()
    
    //var progressView = UIProgressView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = UIColor.yellow
        BHRect = frame
        self.showsHorizontalScrollIndicator = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: ================== 第一次放置UIView =================
    func showOneUI(isShow:Bool, text:String) -> Void {
        let BHAuditView = BHAuditProgressView.init(frame: CGRect(x: 20.0, y: Double(0), width: proWIDTH, height: proWIDTH))
        underlabelText(title: text, point: BHAuditView.center, isTextColor: isShow)
        SupViewRect = BHAuditView.frame
        BHAuditView.isImageColor = isShow//UIView的颜色设定
        self.addSubview(BHAuditView)
        
    }
    
    //MARK: ================== 第二次或以后放置的UIView =================
    func showLaterViewToUI(idx:Double ,isShow:Bool, text:String) -> Void {
        let BHAuditView = BHAuditProgressView.init(frame: CGRect(x: Double(Double(proConfig) + (proWIDTH + SpaceWidth) * idx), y: Double(0), width: proWIDTH, height: proWIDTH))
        underlabelText(title: text, point: BHAuditView.center, isTextColor: isShow)
        BHAuditView.isImageColor = isShow       //UIView的颜色设定
        showLineUI(isShow: isShow)              //一定要放置在SupViewRect设置前
        SupViewRect = BHAuditView.frame
        self.addSubview(BHAuditView)
        
    }
    
    //MARK: ================== 中间线 =================
    func showLineUI(isShow:Bool) -> Void {
        let BHProLabel = lineLabel()
        BHProLabel.frame = CGRect(x: SupViewRect.origin.x + SupViewRect.size.width, y: SupViewRect.size.width/2 + SupViewRect.origin.y, width: CGFloat(SpaceWidth), height: CGFloat(2))
        if isShow == true {
            BHProLabel.backgroundColor = selectorColor
        }
        
        self.addSubview(BHProLabel)
    }
    
    //MARK: ================== 为下面的label赋值 =================
    func underlabelText(title:String ,point:CGPoint, isTextColor:Bool) -> Void {
        let textWidth = SpaceWidth/2
        let nameLabHeight = getLabHeigh(labelStr: title, font: UIFont.systemFont(ofSize: CGFloat(labelFont)), width: CGFloat(proWIDTH + textWidth))
        
        let nameLabel = textLabel(frame: CGRect(x: Double(point.x) - Double((proWIDTH + textWidth)/2), y: Double(point.y) + Double(proWIDTH/2), width: proWIDTH + textWidth, height: Double(nameLabHeight)))
        nameLabel.isTextColor = isTextColor
        
        nameLabel.text = title
        //nameLabel.center = point
        self.addSubview(nameLabel)
        
    }
    
    func getLabHeigh(labelStr:String,font:UIFont,width:CGFloat) -> CGFloat {
        
        let statusLabelText: String = labelStr
        
        let size = CGSize(width: width, height: 999)
        
        let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any], context: nil).size
        
        return strSize.height
        
    }
}

class BHAuditProgressView: UIView {
    let backImageView = UIImageView()//按钮的背景颜色
    var isImageColor = Bool(){
        didSet{
            if isImageColor == false{
                //                backImageView.backgroundColor = normalColor
                backImageView.image = UIImage.init(named: "icon_progress")
            }else {
                //                backImageView.backgroundColor = selectorColor
                backImageView.image = UIImage.init(named: "icon_progress_finished")
            }
        }
    } //背景颜色是否存在
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = UIColor.red
        let baseImageView = UIImageView()
        baseImageView.backgroundColor = UIColor.white
        baseImageView.frame = CGRect(x: frame.size.width/2 - 20, y: frame.size.height/2 - 20, width: 40, height: 40)
        //baseImageView.center = self.center
        self.addSubview(baseImageView)
        
        
        
        backImageView.frame = CGRect(x: baseImageView.frame.width/2 - 10, y: baseImageView.frame.height/2 - 10, width: 20, height: 20)
        backImageView.layer.cornerRadius = 10
        //backImageView.center = baseImageView.center
        
        
        baseImageView.addSubview(backImageView)
        
        let btn = UIButton(type: .custom)
        btn.frame = backImageView.frame
        btn.center = backImageView.center
        btn.layer.cornerRadius = 10
        //btn.backgroundColor = UIColor.blue
        baseImageView.addSubview(btn)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class lineLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.systemFont(ofSize: 12.0)
        self.backgroundColor = normalColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class textLabel: UILabel {
    var isTextColor = Bool(){
        didSet{
            if isTextColor {
                self.textColor = selectorColor
            }else{
                self.textColor = normalColor
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.systemFont(ofSize: CGFloat(labelFont))
        self.textAlignment = .center
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 2
        //self.backgroundColor = selectorColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
