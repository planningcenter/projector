//
//  ViewController.m
//  MCTDocument
//
//  Created by Skylar Schipper on 3/28/14.
//

#import "ViewController.h"

#import <MCTDocument/MCTDocument.h>

@interface ViewController ()

@property (nonatomic, strong) MCTDocument *document;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"EVEOnline" ofType:@"pptx"];

    typeof(self) __weak wSelf = self;

    self.document = [[MCTDocument alloc] initWithFilePath:path];
    [self.document parseWithCompletion:^(MCTDocument *document, NSError *error) {
        [wSelf.collectionView reloadData];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.document.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIWebView *view = (UIWebView *)[cell.contentView viewWithTag:999];
    if (!view) {
        view = [[UIWebView alloc] initWithFrame:cell.contentView.bounds];
        view.userInteractionEnabled = NO;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.tag = 999;
        view.scalesPageToFit = YES;
        [cell.contentView addSubview:view];
    }

    MCTDocumentSlide *slide = [self.document slideForIndex:indexPath.row];

    [view loadHTMLString:[slide HTML] baseURL:nil];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    UIWebView *view = (UIWebView *)[cell.contentView viewWithTag:999];
    if ([view isLoading]) {
        [view stopLoading];
    }

    [view loadHTMLString:@"" baseURL:nil];
}

@end
