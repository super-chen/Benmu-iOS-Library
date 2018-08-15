//
//  UpgradeViewController.h
//  BMBaseLibrary
//
//  Created by chenyuan on 2018/4/24.
//

#import <UIKit/UIKit.h>
#import "ASProgressPopUpView.h"

typedef void (^Click) ();

@interface UpgradeView : UIView<ASProgressPopUpViewDelegate>


@property(nonatomic,copy) NSString * title;
@property(nonatomic,copy) NSString * content;
@property(nonatomic,assign) Boolean isForce;
@property(nonatomic,assign) Boolean isAPP;
@property(nonatomic,strong) ASProgressPopUpView *progressView;
@property(nonatomic,strong) UIButton *btnConfirm;

@property (atomic, copy) Click clickUpgrade;

- (void)drawView;


@end
