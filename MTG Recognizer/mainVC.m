//
//  mainVC.m
//  MTG Recognizer
//
//  Created by Omega Tango - Carlos on 2/14/15.
//  Copyright (c) 2015 Omega Tango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mainVC.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AVCamPreviewView.h"
#import <AFNetworking/AFNetworking.h>

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;


@interface mainVC ()
@property (weak, nonatomic) IBOutlet AVCamPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *stillButton;
- (IBAction)snapStillImage:(id)sender;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
//@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation mainVC{
    
    NSDictionary *updatedetailsDictionary;
}

- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self checkDeviceAuthorizationStatus]; // Check for device authorization
    [self setDeviceAuthorized:YES];
    

                    //Added code here:
                    // Do any additional setup after loading the view.
                    self.operationQueue = [[NSOperationQueue alloc] init];
                    AVCaptureSession *session = [[AVCaptureSession alloc] init];
                    session.sessionPreset = AVCaptureSessionPreset1280x720; //Or other preset supported by the input device
                    
                    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
                    UIView *rectangle = [[UIView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width*(20.0f/320.0f), [[UIScreen mainScreen] bounds].size.height*(80.0f/568.0f), [[UIScreen mainScreen] bounds].size.width*(280.0f/320.0f), [[UIScreen mainScreen] bounds].size.height*(35.0f/568.0f))];
                    rectangle.backgroundColor = [UIColor colorWithRed:10.0 green:230.0 blue:50.0 alpha:0.7f];
                    [self.previewView addSubview:rectangle];
                    [self.previewView.layer addSublayer:previewLayer];
                    
                    // Setup the preview view
                    [[self previewView] setSession:session];
    
                    
                    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
                    [self setSessionQueue:sessionQueue];
                    
                    dispatch_async(sessionQueue, ^{
                        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
                        
                        NSError *error = nil;
                        
                        AVCaptureDevice *photoDevice = [mainVC deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
                        AVCaptureDeviceInput *photoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:photoDevice error:&error];
                        
                        if (error)
                        {
                            NSLog(@"%@", error);
                        }
                        if ([session canAddInput:photoDeviceInput])
                        {
                            [session addInput:photoDeviceInput];
                            [self setVideoDeviceInput:photoDeviceInput];
                            
                        }
                        
                        
                        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
                        if ([session canAddOutput:stillImageOutput])
                        {
                            //NSLog(@"Made it inside add Output.");
                            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
                            [session addOutput:stillImageOutput];
                            [self setStillImageOutput:stillImageOutput];
                            
                            [session startRunning];
                        }
                    });
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak mainVC *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            mainVC *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{

                NSLog(@"Manually restarting the session since it must have been stopped due to an error.");
                [[strongSelf session] startRunning];
 
            });
        }]];
        [[self session] startRunning];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        
    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage)
        {
            [self runStillImageCaptureAnimation];
        }
    }

    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning)
            {

                [[self stillButton] setEnabled:YES];
            }
            else
            {

                [[self stillButton] setEnabled:NO];
            }
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Actions


- (IBAction)snapStillImage:(id)sender
{
    
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
        
        // Flash set to Auto for Still Capture
        [mainVC setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer)
            {
                //NSLog(@"CAPTURE BUTTON WAS PUSHED!!\n");
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                image = [self toGrayscale:image];
                //NSLog(@"The actual image has width %f and height %f", image.size.width, image.size.height);
                image = [self customResize:image];
                //NSLog(@"The resized image has has width %f and height %f", image.size.width, image.size.height);
                //[[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
                [self recognizeImageWithTesseract:image];
                //NSLog(@"The image after recognizeImageWithTesseract has width %f and height %f", image.size.width, image.size.height);
                //[self recognizeImageWithTesseract:[UIImage imageNamed:@"sample1.jpg"]];
            }
        }];
    });
}

-(UIImage *)customResize:(UIImage *)image{
    
    CGSize size = image.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [[UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationRight] drawInRect:CGRectMake(0,0,size.width ,size.height)];
    UIImage* newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //NSLog(@"The new image has width %f and height %f", newimage.size.width, newimage.size.height);
    
  
    CGRect cropRect = CGRectMake((float)newimage.size.width*(20.0f/320.0f), (float)newimage.size.height*(80.0f/568.0f), (float)newimage.size.width*(280.0f/320.0f), (float)newimage.size.height*(35.0f/568.0f));
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(newimage.CGImage, cropRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:newimage.scale orientation:newimage.imageOrientation];
    //NSLog(@"The result image in customRisze has width %f and height %f", result.size.width, result.size.height);
    CGImageRelease(imageRef);
    
    return result;
}

- (UIImage *) toGrayscale:(UIImage*)img
{
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, img.size.width * img.scale, img.size.height * img.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [img CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method:     http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    //done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:img.scale
                                           orientation:UIImageOrientationUp];
    
    //done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}



-(void)recognizeImageWithTesseract:(UIImage *)image
{
    // Preprocess the image so Tesseract's recognition will be more accurate
    UIImage *bwImage = [image g8_blackAndWhite];
    
    // Animate a progress activity indicator
    [self.activityIndicator startAnimating];
    
    // Display the preprocessed image to be recognized in the view
    //self.imageToRecognize.image = bwImage;
    
    // Create a new `G8RecognitionOperation` to perform the OCR asynchronously
    // It is assumed that there is a .traineddata file for the language pack
    // you want Tesseract to use in the "tessdata" folder in the root of the
    // project AND that the "tessdata" folder is a referenced folder and NOT
    // a symbolic group in your project
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];
    
    // Use the original Tesseract engine mode in performing the recognition
    // (see G8Constants.h) for other engine mode options
    //operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    //operation.tesseract.engineMode = G8OCREngineModeCubeOnly;
    operation.tesseract.engineMode = G8OCREngineModeTesseractCubeCombined;
    
    // Let Tesseract automatically segment the page into blocks of text
    // based on its analysis (see G8Constants.h) for other page segmentation
    // mode options
    //operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeSingleLine;
    
    // Optionally limit the time Tesseract should spend performing the
    // recognition
    //operation.tesseract.maximumRecognitionTime = 1.0;
    
    // Set the delegate for the recognition to be this class
    // (see `progressImageRecognitionForTesseract` and
    // `shouldCancelImageRecognitionForTesseract` methods below)
    operation.delegate = self;
    
    // Optionally limit Tesseract's recognition to the following whitelist
    // and blacklist of characters
    operation.tesseract.charWhitelist = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZR";
    //operation.tesseract.charBlacklist = @"56789";
    
    // Set the image on which Tesseract should perform recognition
    operation.tesseract.image = bwImage;
    
    // Optionally limit the region in the image on which Tesseract should
    // perform recognition to a rectangle
    operation.tesseract.rect = CGRectMake(10, 0, bwImage.size.width, bwImage.size.height);
    //operation.tesseract.rect = CGRectMake(20, 20, 100, 100);
    
    // Specify the function block that should be executed when Tesseract
    // finishes performing recognition on the image
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        // Fetch the recognized text
        NSString *recognizedText = tesseract.recognizedText;
        NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSString *trimmedReplacement = [[recognizedText componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
        
        
        //NSLog(@"Trimmed replacelment: %@", trimmedReplacement);
        
        if (![trimmedReplacement isEqualToString:@""] && ![trimmedReplacement isEqualToString:nil]){
            NSString *urlstring = [NSString stringWithFormat:@"http://api.mtgdb.info/search/%@?start=0&limit=1",trimmedReplacement];
            NSURL *url = [NSURL URLWithString:urlstring];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            AFHTTPRequestOperation *AFoperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            AFoperation.responseSerializer = [AFJSONResponseSerializer serializer];
            

            [AFoperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *AFoperation, id responseObject) {
                //NSLog(@"Inside AF Operation completion block");
                NSDictionary *jsonResults = (NSDictionary *)responseObject;
                if ([jsonResults count]>0){
                    
                    //NSLog(@"cardID value is %@", cardID);
                    NSLog(@"JSON: %@", jsonResults);
                    cardDetailVC *cardDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"cardDetailVC"];
                    [cardDetailVC view];
                    cardDetailVC.cardTitle.text = [[jsonResults valueForKey:@"name"] objectAtIndex:0];
                    cardDetailVC.cardDetails.text = [[jsonResults valueForKey:@"description"] objectAtIndex:0];
                    
                    NSString *urlstring = [NSString stringWithFormat:@"http://api.mtgdb.info/content/hi_res_card_images/%@.jpg",[[jsonResults valueForKey:@"id"] objectAtIndex:0]];
                    NSURL *url = [NSURL URLWithString:urlstring];
                    NSURLRequest *requestImage = [NSURLRequest requestWithURL:url];
                    
                    
                    AFHTTPRequestOperation *AFgetImage = [[AFHTTPRequestOperation alloc] initWithRequest:requestImage];
                    AFgetImage.responseSerializer = [AFImageResponseSerializer serializer];
                    
                    [AFgetImage setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *AFgetImage, id responseObject) {
          
                        //NSLog(@"responseObject is %@", responseObject);
                        UIImage *cardImage = responseObject;
                        cardDetailVC.cardImage.image = cardImage;
                        
                        updatedetailsDictionary = @{@"name" : [[jsonResults valueForKey:@"name"] objectAtIndex:0], @"description" : [[jsonResults valueForKey:@"description"] objectAtIndex:0], @"image" : cardImage};
                        
                        NSUserDefaults *cardScans = [NSUserDefaults standardUserDefaults];
                        NSInteger index = [cardScans integerForKey:@"cardIndex"];
                        index++;
                        
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:updatedetailsDictionary];
                        
                        [cardScans setObject:data forKey:[NSString stringWithFormat:@"%ld", (long)index]]; //put data in UserDefaults
                        [cardScans setInteger:index forKey:@"cardIndex"]; //update cardCount
                        [cardScans synchronize];
                        
                    } failure:^(AFHTTPRequestOperation *AFgetImage, NSError *error) {
                        NSLog(@"Network Error while grabbing image: %@", error);
                    }];
                    [AFgetImage start];
                    
                    [self presentViewController:cardDetailVC animated:YES completion:nil];
                    
                        
                        //retrieve
                            NSUserDefaults *cardScans = [NSUserDefaults standardUserDefaults];
                            NSInteger index = [cardScans integerForKey:@"cardIndex"];
                            NSData *dataRetrieved = [cardScans objectForKey:[NSString stringWithFormat:@"%ld", (long)index]];
                            NSDictionary *storedResults = [NSKeyedUnarchiver unarchiveObjectWithData:dataRetrieved];
                        
                            NSLog(@"stored Results are %@", storedResults);
                    }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card not found." message:@"Please try your scan again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    [alert show];
                }
                
            } failure:^(AFHTTPRequestOperation *AFoperation, NSError *error) {
                    NSLog(@"AFHTTPReuqest failed with error %@", error);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:[NSString //stringWithFormat:@"Please try again. Error: %@",error] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        stringWithFormat:@"Please check your connection and try again."] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                
            }];
           
            [AFoperation start];
        }
        // Remove the animated progress activity indicator
        [self.activityIndicator stopAnimating];
        
        
        // Spawn an alert with the recognized text
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OCR Result"
                                                        message:trimmedReplacement
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];*/
    };
    
    // Finally, add the recognition operation to the queue
    [self.operationQueue addOperation:operation];
}




-(void)showCardDetailsVC:(cardDetailVC *)viewController andCardDetails: (NSDictionary *)detailsDictionary{

    

    
    [self presentViewController:viewController animated:YES completion:nil];
    
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error)
        NSLog(@"%@", error);
    
    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error)
            NSLog(@"%@", error);
        
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        
        if (backgroundRecordingID != UIBackgroundTaskInvalid)
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    }];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self previewView] layer] setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [[[self previewView] layer] setOpacity:1.0];
        }];
    });
}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"MTG Recognizer"
                                            message:@"MTG Recognizer doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}





@end
