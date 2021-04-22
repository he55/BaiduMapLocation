#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

struct BMPoint {
    double x;
    double y;
    double z;
};

typedef struct BMPoint BMPoint;

@interface BMapControl : NSObject
+ (id)mainControl;
- (_Bool)screenPoint:(struct CGPoint)arg1 toGeoPoint:(struct BMPoint *)arg2;
@end

@interface BMMNPTools : NSObject
+ (struct CLLocationCoordinate2D)coordinateTransToGCJ02:(struct BMPoint)arg1;
+ (struct BMPoint)coordinateTransFromGCJ02:(struct CLLocationCoordinate2D)arg1;
+ (struct CLLocationCoordinate2D)coordinateTransToWGS84:(struct BMPoint)arg1;
+ (struct BMPoint)coordinateTransFromWGS84:(struct CLLocationCoordinate2D)arg1;
+ (struct CLLocationCoordinate2D)coordinateTransToUser:(struct BMPoint)arg1;
+ (struct BMPoint)coordinateTransFromUser:(struct CLLocationCoordinate2D)arg1;
@end

@interface MapView : UIView
+ (instancetype)queryInstance;
@end

@interface BMBaseMapLogoView : UIView
@property(retain, nonatomic) UIButton *logoView; // @synthesize logoView=_logoView;
@end


%hook BMBaseMapLogoView

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {}

- (void)initSubviews {
    UIButton *coordinate2DButton = [[UIButton alloc] init];
    coordinate2DButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [coordinate2DButton setTitle:@"000.000000 000.000000" forState:UIControlStateNormal];
    [coordinate2DButton sizeToFit];
    [coordinate2DButton addTarget:self action:@selector(handleShare) forControlEvents:UIControlEventTouchUpInside];

    if (@available(iOS 13.0, *)) {
        [coordinate2DButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    } else {
        [coordinate2DButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }

    self.bounds = coordinate2DButton.bounds;
    self.logoView = coordinate2DButton;
    [self addSubview:coordinate2DButton];
}

- (void)setHidden:(BOOL)hidden {
    if (!hidden) {
        static MapView *mapView = nil;
        static CGFloat scale = 0;
        if (!mapView) {
            mapView = [%c(MapView) queryInstance];
            scale = [[UIScreen mainScreen] scale];
        }

        BMPoint bmPoint = {0};
        [[%c(BMapControl) mainControl] screenPoint:CGPointMake(mapView.center.x * scale, mapView.center.y * scale) toGeoPoint:&bmPoint];
        CLLocationCoordinate2D coordinate2D = [%c(BMMNPTools) coordinateTransToWGS84:bmPoint];
        NSString *coordinate2DString = [NSString stringWithFormat:@"%.6f %.6f", coordinate2D.latitude, coordinate2D.longitude];
        [self.logoView setTitle:coordinate2DString forState:UIControlStateNormal];
        [self.logoView sizeToFit];
    }
    %orig;
}

%new
- (void)handleShare {
    for (id obj = [self nextResponder]; obj; obj = [obj nextResponder]) {
        if ([obj isKindOfClass:[UIViewController class]]) {
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.logoView.currentTitle] applicationActivities:nil];
            [obj presentViewController:activityViewController animated:YES completion:nil];
            return;
        }
    }
}

%end
