//
//  RSSViewCell.h
//
//  Created by Sertac Ozercan on 1/17/13.
//  Copyright (c) 2013 Sertac Ozercan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *category;
//@property (weak, nonatomic) IBOutlet UILabel *description;

@end
