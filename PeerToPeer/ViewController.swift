//
//  ViewController.swift
//  PeerToPeer
//
//  Created by 長谷川瞬哉 on 2015/07/19.
//  Copyright (c) 2015年 長谷川瞬哉. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics
import MultipeerConnectivity

class ViewController: UIViewController, UITextFieldDelegate{

  var Name: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
   
    self.view.backgroundColor = UIColor.whiteColor()
    
    Name = UITextField()
    Name.frame = CGRectMake(0, 0, 200, 50)
    Name.center = self.view.center
    Name.delegate = self
    Name.borderStyle = UITextBorderStyle.RoundedRect
    self.view.addSubview(Name)
    
    var search: UIButton!
    search = UIButton(frame: CGRectMake(0, 0, 100, 100))
    search.center = CGPointMake(self.view.center.x, self.view.frame.size.height - 50)
    search.setTitle("START", forState: UIControlState.Normal)
    search.addTarget(self, action: "search:", forControlEvents: UIControlEvents.TouchUpInside)
    search.backgroundColor = UIColor.yellowColor()
    self.view.addSubview(search)
  }

  func search(button: UIButton) {
    
    if (count(Name.text) < 1) {
      return;
    }

    // 遷移するViewを定義する.
    let targetViewController: TargetListViewController = TargetListViewController()
    targetViewController.createSessionWithDisplayName(self.Name.text)
    targetViewController.title = Name.text
    
    // アニメーションを設定する.
    targetViewController.modalTransitionStyle = UIModalTransitionStyle.PartialCurl
    
    println(self.navigationController)
    // Viewの移動する.
    self.navigationController?.pushViewController(targetViewController, animated: true)

//    self.performSegueWithIdentifier:SegueIdentifierPushPeerListView sender:self

  }
  
//  #pragma mark - UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    return true;
  }

}

