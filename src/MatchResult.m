//
//  MatchResult.m
//  CocoPCRE
//
//  Created by Manfred Bergmann on 17.05.06.
//  Copyright 2006 mabe. All rights reserved.
//

#import "MatchResult.h"


@implementation MatchResult

+ (id)matchResult {
	return [[[MatchResult alloc] init] autorelease];
}

+ (id)matchResultWithMatches:(NSArray *)list {
	return [[[MatchResult alloc] initWithMatches:list] autorelease];
}

- (id)init {
	return [self initWithMatches:[NSArray array]];
}

- (id)initWithMatches:(NSArray *)list {
	self = [super init];
	
	if(self) {
		[self setMatches:list];
	}
	
	return self;
}

- (void)dealloc {
	[self setMatches:nil];
	
	[super dealloc];
}

- (void)addMatch:(NSString *)substring {
	[listOfMatches addObject:substring];
}

- (void)setMatches:(NSArray *)list {
	if(list != listOfMatches) {
		NSMutableArray *mutableList = [list mutableCopy];
		[listOfMatches release];
		listOfMatches = mutableList;
	}
}

- (NSArray *)matches {
	return listOfMatches;
}

- (NSString *)matchAtIndex:(int)index {
    return [listOfMatches objectAtIndex:index];
}

- (int)numberOfMatches {
	return (int)[listOfMatches count];
}

@end
