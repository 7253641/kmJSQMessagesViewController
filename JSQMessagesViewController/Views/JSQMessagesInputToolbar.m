//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesInputToolbar.h"

#import "JSQMessagesComposerTextView.h"

#import "JSQMessagesToolbarButtonFactory.h"

#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "UIView+JSQMessages.h"

static void * kJSQMessagesInputToolbarKeyValueObservingContext = &kJSQMessagesInputToolbarKeyValueObservingContext;


@interface JSQMessagesInputToolbar ()

@property (assign, nonatomic) BOOL jsq_isObserving;

- (void)jsq_leftBarButtonPressed:(UIButton *)sender;
- (void)jsq_rightBarButtonPressed:(UIButton *)sender;
- (void)jsq_rightBarButtonBPressed:(UIButton *)sender;

- (void)jsq_addObservers;
- (void)jsq_removeObservers;

@end



@implementation JSQMessagesInputToolbar

@dynamic delegate;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.jsq_isObserving = NO;
    self.sendButtonOnRight = YES;

    self.preferredDefaultHeight = 44.0f;
    self.maximumHeight = NSNotFound;

    JSQMessagesToolbarContentView *toolbarContentView = [self loadToolbarContentView];
    toolbarContentView.frame = self.frame;
    [self addSubview:toolbarContentView];
    [self jsq_pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    _contentView = toolbarContentView;

    [self jsq_addObservers];
	
	self.contentView.leftBarButtonItem = [JSQMessagesToolbarButtonFactory defaultVoiceButtonItem];
	self.contentView.rightBarButtonItem = [JSQMessagesToolbarButtonFactory defaultEmotionButtonItem];
	self.contentView.rightBarButtonItemB = [JSQMessagesToolbarButtonFactory defaultMoreSelectButtonItem];
	
}

- (JSQMessagesToolbarContentView *)loadToolbarContentView
{
    NSArray *nibViews = [[NSBundle bundleForClass:[JSQMessagesInputToolbar class]] loadNibNamed:NSStringFromClass([JSQMessagesToolbarContentView class])
                                                                                          owner:nil
                                                                                        options:nil];
    return nibViews.firstObject;
}

- (void)dealloc
{
    [self jsq_removeObservers];
    _contentView = nil;
}

#pragma mark - Setters

- (void)setPreferredDefaultHeight:(CGFloat)preferredDefaultHeight
{
    NSParameterAssert(preferredDefaultHeight > 0.0f);
    _preferredDefaultHeight = preferredDefaultHeight;
}

- (void)setAllowVoiceInput:(BOOL)allowVoiceInput {
	if (!allowVoiceInput) {
		[self.contentView removeObserver:self forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem)) context:kJSQMessagesInputToolbarKeyValueObservingContext];
		self.contentView.leftBarButtonItem = nil;
	}
	_allowVoiceInput = allowVoiceInput;
}

#pragma mark - Actions

- (void)jsq_leftBarButtonPressed:(UIButton *)sender
{
	kmInputToolBarContentViewState slctd = [self.contentView toggleKeyboard:sender];
    [self.delegate messagesInputToolbar:self didPressLeftBarButton:sender inputBarState:slctd];
}

- (void)jsq_rightBarButtonPressed:(UIButton *)sender
{
	kmInputToolBarContentViewState slctd = [self.contentView toggleKeyboard:sender];
    [self.delegate messagesInputToolbar:self didPressRightBarButton:sender inputBarState:slctd];
}

- (void)jsq_rightBarButtonBPressed:(UIButton *)sender
{
	kmInputToolBarContentViewState slctd = [self.contentView toggleKeyboard:sender];
	[self.delegate messagesInputToolbar:self didPressRightBarButtonB:sender inputBarState:slctd];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kJSQMessagesInputToolbarKeyValueObservingContext) {
        if (object == self.contentView) {

            if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftBarButtonItem))]) {

                [self.contentView.leftBarButtonItem removeTarget:self
                                                          action:NULL
                                                forControlEvents:UIControlEventTouchUpInside];

                [self.contentView.leftBarButtonItem addTarget:self
                                                       action:@selector(jsq_leftBarButtonPressed:)
                                             forControlEvents:UIControlEventTouchUpInside];
            }
            else if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightBarButtonItem))]) {

                [self.contentView.rightBarButtonItem removeTarget:self
                                                           action:NULL
                                                 forControlEvents:UIControlEventTouchUpInside];

                [self.contentView.rightBarButtonItem addTarget:self
                                                        action:@selector(jsq_rightBarButtonPressed:)
                                              forControlEvents:UIControlEventTouchUpInside];
			}
			else if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightBarButtonItemB))]) {
				
				[self.contentView.rightBarButtonItemB removeTarget:self
															action:NULL
												  forControlEvents:UIControlEventAllEvents];
				
				[self.contentView.rightBarButtonItemB addTarget:self
														 action:@selector(jsq_rightBarButtonBPressed:)
											   forControlEvents:UIControlEventTouchUpInside];
			}
        }
    }
}

- (void)jsq_addObservers
{
    if (self.jsq_isObserving) {
        return;
    }

    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];

    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];
	
	[self.contentView addObserver:self
					   forKeyPath:NSStringFromSelector(@selector(rightBarButtonItemB))
						  options:0
						  context:kJSQMessagesInputToolbarKeyValueObservingContext];
	
    self.jsq_isObserving = YES;
}

- (void)jsq_removeObservers
{
    if (!_jsq_isObserving) {
        return;
    }

    @try {
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                             context:kJSQMessagesInputToolbarKeyValueObservingContext];

        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                             context:kJSQMessagesInputToolbarKeyValueObservingContext];
		
		[_contentView removeObserver:self
						  forKeyPath:NSStringFromSelector(@selector(rightBarButtonItemB))
							 context:kJSQMessagesInputToolbarKeyValueObservingContext];
		
    }
    @catch (NSException *__unused exception) { }
    
    _jsq_isObserving = NO;
}

@end
