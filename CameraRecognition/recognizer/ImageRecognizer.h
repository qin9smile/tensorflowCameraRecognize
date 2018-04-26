//
//  ImageRecognizer.h
//  tensorflowiOS
//
//  Created by charlotte on 2018/4/12.
//  Copyright © 2018年 gago. All rights reserved.
//

#ifndef ImageRecognizer_h
#define ImageRecognizer_h
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@protocol ImageRecognizerDelegate <NSObject>
-(void)imageRecognizer:(NSDictionary *)predicationValue withPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end

@interface ImageRecognizer: NSObject
{
  NSMutableDictionary *oldPredictionValues;
}
@property (assign) id <ImageRecognizerDelegate> delegate;
- (void)loadModel:(NSString *)modelFileName withLabelFileName:(NSString *)labelFileName;
- (void)recognizer:(CVPixelBufferRef)pixelBuffer;
@end
#endif /* ImageRecognizer_h */
