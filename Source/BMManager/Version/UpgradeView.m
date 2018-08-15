//
//  UpgradeViewController.m
//  BMBaseLibrary
//
//  Created by chenyuan on 2018/4/24.
//

#import "UpgradeView.h"

@implementation UpgradeView


- (void)drawView{
    float scale = 1;
    if(isIphone5){
        scale = 0.8;
    }
    self.frame = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
    self.backgroundColor = [UIColor colorWithRed:1/123 green:1/23 blue:1/233 alpha:0.5];
    
    UIView *view_container = [[UIView alloc] init];
    view_container.backgroundColor = [UIColor whiteColor];
    view_container.layer.cornerRadius = 15;
    view_container.translatesAutoresizingMaskIntoConstraints = NO;
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, -55*scale, 330*scale, 226*scale)];
    image.image = [UIImage imageNamed:@"upgradeBackground"];
    [view_container addSubview:image];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(25, 175*scale, 280*scale, 30*scale)];
    lab.text = self.title;
    [view_container addSubview:lab];
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(22, 210*scale, 286*scale, 140*scale)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    text.attributedText = [[NSAttributedString alloc] initWithString:self.content attributes:attributes];
    text.editable = NO;
    text.textColor = [UIColor darkGrayColor];
    [view_container addSubview:text];
    
    self.btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnConfirm.frame = CGRectMake(25, 350*scale, 280*scale, 40*scale);
    [self.btnConfirm setBackgroundColor:UIColorFromRGB(45, 140, 240)];
    [self.btnConfirm setTitle:@"立 刻 升 级" forState:UIControlStateNormal];
    
    [self.btnConfirm addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnConfirm.layer.cornerRadius = 7;
    [view_container addSubview:self.btnConfirm];
    
    //进度条
    self.progressView = [[ASProgressPopUpView alloc] initWithFrame:CGRectMake(25, 350*scale, 280*scale, 40*scale)];
    
    self.progressView.popUpViewAnimatedColors = @[RGB(45, 140, 240)];
    self.progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:12];
    [self.progressView showPopUpViewAnimated:YES];
    [view_container addSubview:self.progressView];
    
    if(self.isAPP){
        self.btnConfirm.hidden = false;
        self.progressView.hidden = true;
    }else if(self.isForce){
        self.btnConfirm.hidden = true;
        self.progressView.hidden = false;
    }else{
        self.btnConfirm.hidden = false;
        self.progressView.hidden = true;
    }
    
    [self addSubview:view_container];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view_container
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.f
                                                      constant:330*scale]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view_container
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.f
                                                      constant:410*scale]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view_container attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view_container attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    if(!self.isForce){
        UIImageView *btn_close = [[UIImageView alloc] init];
        btn_close.image = [UIImage imageNamed:@"upgradeClose"];
        btn_close.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickClose)];
        [btn_close addGestureRecognizer:singleTap];
        btn_close.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:btn_close];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:btn_close attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:btn_close
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.f
                                                          constant:42*scale]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:btn_close
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.f
                                                          constant:101*scale]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:btn_close
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:view_container
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.f
                                                          constant:0.f]];
    }
}

-(void)clickClose{
    [self removeFromSuperview];
}

-(BOOL)progressViewShouldPreCalculatePopUpViewSize:(ASProgressPopUpView *)progressView
{
    return NO;
}

-(void)click:(UIButton *)button{
    if(!self.isAPP){
        self.btnConfirm.hidden = true;
        self.progressView.hidden = false;
    }
    if(self.clickUpgrade){
        self.clickUpgrade();
    }
//    [self removeFromSuperview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
