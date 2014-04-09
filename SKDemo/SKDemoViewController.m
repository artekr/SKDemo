//
//  SKDemoViewController.m
//  SKDemo
//
//  Created by Heng Wang on 4/9/14.
//  Copyright (c) 2014 Heng Wang. All rights reserved.
//

#import "SKDemoViewController.h"
#import "SKDemoMyScene.h"
@import AVFoundation;

@interface SKDemoViewController()
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@end


@implementation SKDemoViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // This is some simple code to start the background music playing with endless loops.
    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background-music-aac" withExtension:@"caf"];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = -1; //playing with endless loops.
    [self.backgroundMusicPlayer prepareToPlay];
    [self.backgroundMusicPlayer play];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [SKDemoMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
