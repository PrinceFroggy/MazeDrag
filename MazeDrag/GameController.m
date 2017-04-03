//
//  ViewController.m
//  MazeDrag
//
//  Created by Andrew Solesa on 2017-03-31.
//  Copyright © 2017 KSG. All rights reserved.
//

#import "GameController.h"

@interface GameController ()
@property (nonatomic) UIImageView *levelView;
@property (nonatomic) UIImageView *home;
@property (nonatomic) UIImageView *upgrade;
@property (nonatomic) UIImageView *draggablePiece;

@property NSDictionary *level0;
@property NSDictionary *level1;
@property NSDictionary *level2;
@property NSDictionary *level3;
@property NSDictionary *levels;

@property int level;
@property BOOL animationFlag;

// MAP IS RENDERING PIECE LAST TO BE ABOVE REST OF ASSETS

#define HOME 0
#define UPGRADE 1
#define PIECE 2

@property UIAlertController *alertController;
@end

@implementation GameController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _level0 = @{ @"name" : @"level_0", @"homeX" : @140, @"homeY" : @-10, @"pieceX" : @-140, @"pieceY" : @-10};
    _level1 = @{ @"name" : @"level_1", @"homeX" : @75, @"homeY" : @-195, @"upgradeX" : @104, @"upgradeY" : @40, @"pieceX" : @-147, @"pieceY" : @295};
    _levels = [[NSDictionary alloc] initWithObjectsAndKeys:_level0, @"0", _level1, @"1", _level2, @"2", nil];
    
    _level = 0;
    
    [self createLevel: _level];
    
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(pieceDeath) userInfo:nil repeats:YES];
    
}

- (void) createLevel : (int) level
{
    
    self.levelView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.levelView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.levelView.image = [UIImage imageNamed:[self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", level, @"name"]]];
    
    [self.view addSubview:self.levelView];
    
    NSLayoutConstraint *levelBottom = [NSLayoutConstraint constraintWithItem:self.levelView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:0.0];
    
    NSLayoutConstraint *levelLeft = [NSLayoutConstraint constraintWithItem:self.levelView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:0.0];
    
    NSLayoutConstraint *levelTop = [NSLayoutConstraint constraintWithItem:self.levelView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0];
    
    NSLayoutConstraint *levelRight = [NSLayoutConstraint constraintWithItem:self.levelView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0
                                                                   constant:0.0];
    
    [self.view addConstraint:levelLeft];
    [self.view addConstraint:levelRight];
    [self.view addConstraint:levelTop];
    [self.view addConstraint:levelBottom];
    
    CGFloat newX;
    CGFloat newY;
    
    newX = [[self loadPiece:@"X" Piece: HOME] floatValue];
    newY = [[self loadPiece:@"Y" Piece: HOME] floatValue];
    
    [self createHomeAtX:newX andY:newY];
    
    newX = self.defaultFloatValue;
    newY = self.defaultFloatValue;
    
    switch (self.level)
    {
        case 1:
            newX = [[self loadPiece:@"X" Piece: UPGRADE] floatValue];
            newY = [[self loadPiece:@"Y" Piece: UPGRADE] floatValue];
            break;
    }
    
    if (newX != 0 || newY != 0)
    {
        [self createUpgradeAtX:newX andY:newY];
    }
    
    newX = self.defaultFloatValue;
    newY = self.defaultFloatValue;
    
    newX = [[self loadPiece:@"X" Piece: PIECE] floatValue];
    newY = [[self loadPiece:@"Y" Piece: PIECE] floatValue];
    
    [self createDraggablePieceAtX:newX andY:newY];
}

- (CGFloat) defaultFloatValue
{
    return 0;
}

- (void) createHomeAtX : (CGFloat) X andY: (CGFloat) Y
{
    self.home = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.home.translatesAutoresizingMaskIntoConstraints = NO;
    self.home.contentMode = UIViewContentModeScaleAspectFit;
    self.home.image = [UIImage imageNamed:@"home"];
    
    [self.view addSubview:self.home];
    
    NSLayoutConstraint *homeX = [NSLayoutConstraint constraintWithItem:self.home
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:X];
    
    NSLayoutConstraint *homeY = [NSLayoutConstraint constraintWithItem:self.home
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:Y];
    
    
    [self.view addConstraint:homeX];
    [self.view addConstraint:homeY];
}

- (void) createUpgradeAtX: (CGFloat) X andY: (CGFloat) Y
{
    self.upgrade = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.upgrade.translatesAutoresizingMaskIntoConstraints = NO;
    self.upgrade.contentMode = UIViewContentModeScaleAspectFit;
    self.upgrade.image = [UIImage imageNamed:@"upgrade"];
    
    [self.view addSubview:self.upgrade];
    
    NSLayoutConstraint *upgradeX = [NSLayoutConstraint constraintWithItem:self.upgrade
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:X];
    
    NSLayoutConstraint *upgradeY = [NSLayoutConstraint constraintWithItem:self.upgrade
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:Y];
    
    
    [self.view addConstraint:upgradeX];
    [self.view addConstraint:upgradeY];
}

- (void) createDraggablePieceAtX : (CGFloat) X andY: (CGFloat) Y
{
    self.draggablePiece = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.draggablePiece.translatesAutoresizingMaskIntoConstraints = NO;
    self.draggablePiece.contentMode = UIViewContentModeScaleAspectFit;
    self.draggablePiece.image = [UIImage imageNamed:@"draggablePiece"];
    
    [self.view addSubview:self.draggablePiece];
    
    NSLayoutConstraint *pieceX = [NSLayoutConstraint constraintWithItem:self.draggablePiece
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:X];
    
    NSLayoutConstraint *pieceY = [NSLayoutConstraint constraintWithItem:self.draggablePiece
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:Y];
    
    
    [self.view addConstraint:pieceX];
    [self.view addConstraint:pieceY];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [self.draggablePiece addGestureRecognizer:pan];
    
    self.draggablePiece.userInteractionEnabled = YES;
}

- (NSNumber *) loadPiece : (NSString *) XY Piece: (int) piece
{
    NSNumber *coordinate;
    
    if ([XY isEqualToString:@"X"])
    {
        switch (piece)
        {
            case HOME:
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"homeX"]];
                break;
                
            case UPGRADE:
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"upgradeX"]];
                break;
                
            case PIECE:
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"pieceX"]];
                break;
        }
    }
    else
    {
        switch (piece)
        {
            case HOME:
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"homeY"]];
                break;
                
            case UPGRADE:
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"upgradeY"]];
                break;
                
            case PIECE:
                coordinate = [self.levels valueForKeyPath: [NSString stringWithFormat:@"%d.%@", self.level, @"pieceY"]];
                break;
        }
    }
    
    return coordinate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) tapPiece : (UITapGestureRecognizer *) tap
{
    CGRect rect = [self.draggablePiece frame];
    
    if ([self.draggablePiece frame].size.height == 30)
    {
        rect.size.width = 23.0f;
        rect.size.height = 22.0f;
    }
    else
    {
        rect.size.width = 31.0f;
        rect.size.height = 30.0f;
    }
    
    [self.draggablePiece setFrame:rect];
}

- (void) panPiece : (UIPanGestureRecognizer *) pan
{
    if (!self.animationFlag)
    {
        if (pan.state == UIGestureRecognizerStateChanged)
        {
            self.draggablePiece.center = [pan locationInView:self.view];
        }
        
        [self checkWaterBoundaries: self.draggablePiece.frame];
        
        [self checkHomeBoundaries: pan];
        
        [self checkUpgradeBoundaries: pan];
    }
}

- (void) checkWaterBoundaries : (CGRect) piece
{
    if ([self pixelColorInImage:[self.levelView image] atX:piece.origin.x atY:piece.origin.y] == [UIColor blueColor]
        || [self pixelColorInImage:[self.levelView image] atX:piece.origin.x + piece.size.width atY:piece.origin.y + piece.size.height])
    {
        [self pieceDeath];
    }
}

- (void) pieceDeath
{
    if (!self.animationFlag)
    {
        self.animationFlag = YES;
        
        [UIImageView animateWithDuration:2.0 animations:^(void)
         {
             self.draggablePiece.alpha = 0.0;
         }
                              completion:^(BOOL completion)
         {
             [self.draggablePiece removeFromSuperview];
             
             [self regenerateUpgrade];
             
             CGFloat newX;
             CGFloat newY;
             
             newX = [[self loadPiece:@"X" Piece: PIECE] floatValue];
             newY = [[self loadPiece:@"Y" Piece: PIECE] floatValue];
             
             [self createDraggablePieceAtX:newX andY:newY];
             
             self.animationFlag = NO;
         }];
    }
    
}

- (void) regenerateUpgrade
{
    if (self.upgrade.alpha == 0.0)
    {
        self.upgrade.alpha = 1.0;
    }
}

- (UIColor *)pixelColorInImage: (UIImage*) mazeImage atX:(int)x atY:(int)y
{
    CGImageRef imageRef = [mazeImage CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    int index = 4 * ( (width * round(y) ) + round(x) );
    
    int R = rawData[index];
    
    UIColor *boundaries;
    
    switch (R)
    {
        case 36:
        case 37:
        case 38:
        case 40:
        case 42:
        case 44:
        case 45:
            boundaries = [UIColor blueColor];
            break;
    }
    
    return boundaries;
}

- (void) checkHomeBoundaries : (UIPanGestureRecognizer *) pan
{
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        if (CGRectIntersectsRect(self.draggablePiece.frame, self.home.frame))
        {
            if ([self.draggablePiece frame].size.height == 30)
            {
                if (!self.animationFlag)
                {
                    self.animationFlag = YES;
                    
                    [UIImageView animateWithDuration:2.0 animations:^(void)
                     {
                         self.draggablePiece.alpha = 0.0;
                     }
                                          completion:^(BOOL completion)
                     {
                         [self.draggablePiece removeFromSuperview];
                         
                         self.alertController = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You beat level %d", self.level + 1] preferredStyle:UIAlertControllerStyleAlert];
                         
                         [self.alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                          {
                                                              [self closeCongratulationsView];
                                                          }]];
                         
                         [self presentViewController:self.alertController animated:YES completion:nil];
                         
                         _animationFlag = NO;
                     }];
                }
            }
        }
    }
}

- (void) closeCongratulationsView
{
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
    self.level++;
    [self createLevel: self.level];
}

- (void) checkUpgradeBoundaries : (UIPanGestureRecognizer *) pan
{
    if ([self isUpgradeAvailable])
    {
        if (pan.state == UIGestureRecognizerStateEnded)
        {
            if (CGRectIntersectsRect(self.draggablePiece.frame, self.upgrade.frame))
            {
                if ([self.draggablePiece frame].size.height == 30)
                {
                    if (!self.animationFlag)
                    {
                        self.animationFlag = YES;
                        
                        [UIImageView animateWithDuration:2.0 animations:^(void)
                         {
                             self.upgrade.alpha = 0.0;
                         }
                                              completion:^(BOOL completion)
                         {
                             //[self.upgrade removeFromSuperview]; // teleports spider back to beginning?
                             
                             self.alertController = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You unlocked the tap upgrade!"] preferredStyle:UIAlertControllerStyleAlert];
                             
                             [self.alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                              {
                                                                  [self closeUpgradeView];
                                                              }]];
                             
                             [self presentViewController:self.alertController animated:YES completion:nil];
                             
                             _animationFlag = NO;
                         }];
                    }
                }
            }
        }
    }
}

- (BOOL) isUpgradeAvailable
{
    return self.upgrade.alpha == 1.0 ? YES : NO;
}

- (void) closeUpgradeView
{
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
    
    if (_level > 0)
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPiece:)];
        tap.numberOfTapsRequired = 1;
        [self.draggablePiece addGestureRecognizer:tap];
    }
}

@end
