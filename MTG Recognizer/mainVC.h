//
//  mainVC.h
//  MTG Recognizer
//
//  Created by SDG - Carlos on 2/14/15.
//  Copyright (c) 2015 TTU Software Engineering. All rights reserved.
//

#import "PageContentViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <TesseractOCR/TesseractOCR.h>
#import "cardDetailVC.h"

@interface mainVC : PageContentViewController <G8TesseractDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureFileOutputRecordingDelegate>
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (weak, nonatomic) IBOutlet UIImageView *imageToRecognize;



@end
