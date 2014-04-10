//
//  SKDemoGameOverScene.m
//  SKDemo
//
//  Created by Heng Wang on 4/9/14.
//  Copyright (c) 2014 Heng Wang. All rights reserved.
//

#import "SKDemoGameOverScene.h"
#import "SKDemoMyScene.h"

@implementation SKDemoGameOverScene

- (id)initWithSize:(CGSize)size won:(BOOL)won {
    
    if (self == [super initWithSize:size]) {
        
        //
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
        
        //
        NSString * message;
        if (won) {
            message = @"You Won!!";
        } else {
            message = @"You Lose :(";
        }
        
        //
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        // First it waits for 3 seconds, then it uses the runBlock action to run some arbitrary code.
        [self runAction:
            [SKAction sequence:@[
                [SKAction waitForDuration:3.0],
                [SKAction runBlock:^{
                    //This is how you transition to a new scene in Sprite Kit. First you can pick from a variety of different animated transitions for how you want the scenes to display – you choose a flip transition here that takes 0.5 seconds. Then you create the scene you want to display, and use the presentScene:transition: method on the self.view property.
                SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
                    SKScene *myScene = [[SKDemoMyScene alloc] initWithSize:self.size];
                    [self.view presentScene:myScene transition:reveal];
                }]
            ]]
        ];
    }
    return self;
}

@end
