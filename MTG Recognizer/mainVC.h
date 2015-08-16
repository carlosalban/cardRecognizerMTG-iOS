//
//  mainVC.h
//  MTG Recognizer
//
//  Created by Omega Tango - Carlos on 2/14/15.
//  Copyright (c) 2015 Omega Tango. All rights reserved.
//

#import "PageContentViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <TesseractOCR/TesseractOCR.h>
#import "cardDetailVC.h"
#import <UIKit/UIKit.h>

@interface mainVC : PageContentViewController <G8TesseractDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureFileOutputRecordingDelegate>
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (weak, nonatomic) IBOutlet UIImageView *imageToRecognize;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;



@end
