//
//  ViewController.swift
//  SendMessage
//
//  Created by sherry on 16/6/22.
//  Copyright © 2016年 sherry. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var mobileNumber: UITextField!
    
    @IBOutlet weak var testNumber: UITextField!
    
    @IBOutlet weak var getNumBtn: UIButton!
    
    @IBOutlet weak var callNumber: UIButton!
    
    @IBOutlet weak var receiveMail: UITextField!
    
    @IBOutlet weak var copyMail: UITextField!
    
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
            self.presentViewController(alert, animated: false, completion: nil)
          
            
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
    
    @IBAction func callBtnAct(sender: AnyObject) {
        
//        let url = NSURL(string: "telprompt:10086")
//        
//        UIApplication.sharedApplication().openURL(url!)
        
        let url = NSURL(string: "tel:10086")
        let callView = UIWebView()
        callView.loadRequest(NSURLRequest(URL: url!))
        self.view.addSubview(callView)
        
//        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        
    }
    
    @IBAction func sendMsgBtnAct(sender: AnyObject) {
        
        //显示发送短信的控制器
        let msgVC = MFMessageComposeViewController()
        
        //设置短信内容
        msgVC.body = "Test！Test！I have send a iMessage to you."
        
        //设置收件人
        msgVC.recipients = [mobileNumber.text!]
        
        //设置代理
        msgVC.messageComposeDelegate = self
        
        
        presentViewController(msgVC, animated: true, completion: nil)
        
        
        
    }
    
    //代理方法，当短信页面关闭后调用，会自动回到原应用
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if result == MessageComposeResultCancelled {
            print("取消发送")
        }else if result == MessageComposeResultSent {
        
            print("已经发出")
        
        }else {
        
            print("发送失败")
        
        }
        
    }
    
    @IBAction func sendEmaBtnAct(sender: AnyObject) {
        
//        //打开设置中的wifi连接
//        let url = "prefs:root=WIFI"
//        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        
        if !MFMailComposeViewController.canSendMail() {
            return
        }
        
        let mailVC = MFMailComposeViewController()
        
        //设置邮件主题
        mailVC.setSubject("主题")
        
        //设置邮件内容
        mailVC.setMessageBody("邮件内容", isHTML: false)
        
        //设置收件人列表
        mailVC.setToRecipients([receiveMail.text!])
        
        //设置抄送人列表
        mailVC.setCcRecipients([copyMail.text!])

        //设置密送人列表
        mailVC.setBccRecipients([copyMail.text!])
        
        //添加附件
        let img = UIImage(named: "IMG_1884.JPG")
        let data = UIImageJPEGRepresentation(img!, 0.5)
        
        mailVC.addAttachmentData(data!, mimeType: "image/JPG", fileName: "IMG_1884.JPG")
        
        //设置代理
        mailVC.mailComposeDelegate = self

        //显示控制器
        self.presentViewController(mailVC, animated: true, completion: nil)
        
    }
    
    //邮件发送后的代理方法，发完调用，会自动回到原应用
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        //关闭邮件页面
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        if result == MFMailComposeResultCancelled {
            print("取消发送")
        }else if result == MFMailComposeResultSent {
        
            print("已经发出")
        
        }else {
        
            print("发送失败")
            
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

