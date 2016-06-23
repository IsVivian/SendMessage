//
//  ViewController.swift
//  SendMessage
//
//  Created by sherry on 16/6/22.
//  Copyright © 2016年 sherry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mobileNumber: UITextField!
    
    @IBOutlet weak var testNumber: UITextField!
    
    @IBOutlet weak var getNumBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func getTestNum(sender: AnyObject) {
        
        let mobileNum = mobileNumber.text
        
        SMSSDK.getVerificationCodeByMethod(SMSGetCodeMethodSMS, phoneNumber: mobileNum, zone: "86", customIdentifier: nil) { (error) in
            
            if error == nil {
            
                print("发送成功")
                self.countDown(10)
            
            
            }else {
            
                print("发送失败" + "\(error)")
            
            }
            
        }
        
    }
    
    @IBAction func commitBtn(sender: AnyObject) {
        
        let testNum = testNumber.text
        let mobileNum = mobileNumber.text
        var resultMsg = ""
        
        SMSSDK.commitVerificationCode(testNum, phoneNumber: mobileNum, zone: "86") { (error) in
            
            if error == nil {
            
                resultMsg = "恭喜您，验证成功"
                
                print("验证成功")
            
            }else {
            
                resultMsg = "验证失败"
                print("验证失败")
            
            }
            
            let alert = UIAlertController(title: "提示", message: resultMsg, preferredStyle: .Alert)
            let action = UIAlertAction(title: "确定", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
          
            
        }
        
    }
    
    //验证码倒计时
    func countDown(timeOut: Int) {
    
        //倒计时时间
        var timeOut = timeOut
        let queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let _timer:dispatch_source_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(_timer, dispatch_walltime(nil, 0), 1*NSEC_PER_SEC, 0)
        
        //每秒执行
        dispatch_source_set_event_handler(_timer) {
            
            //倒计时结束，关闭
            if timeOut <= 0 {
            
                dispatch_source_cancel(_timer)
                dispatch_sync(dispatch_get_main_queue(), {
                    
                    self.getNumBtn.setTitle("重新", forState: .Normal)
                    
                })
                
            }else {
            
                let second = timeOut % 60
                let strTime = NSString.localizedStringWithFormat("%@.2d", second)
                
                dispatch_sync(dispatch_get_main_queue(), {
                    
                    print("\(strTime as String)")
                    
                    UIView.animateWithDuration(1, animations: {
                        self.getNumBtn.setTitle(strTime as String, forState: .Normal)
                        self.getNumBtn.userInteractionEnabled = false
                    })
                    
                    timeOut -= 1
                    
                })
            
            }
            
            dispatch_resume(_timer)
            
        }
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

