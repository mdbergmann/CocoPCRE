//
//  RegexTest.m
//  CocoPCRE
//
//  Created by Manfred Bergmann on 04.07.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CocoPCRE/CocoPCRE.h>


@interface RegexTest : XCTestCase {
    
}

@end

@implementation RegexTest

- (void)setUp {
    
}

- (void)testMatch {
    NSString *text = @"Hallo Welt";
    RegexResultType stat = [[Regex regexWithPattern:@"Hallo"] matchIn:text matchResult:nil];
    XCTAssertTrue(stat == RegexMatch, @"");
}

- (void)testNoMatch {
    NSString *text = @"Hallo Welt";
    RegexResultType stat = [[Regex regexWithPattern:@"Manfred"] matchIn:text matchResult:nil];    
    XCTAssertTrue(stat == RegexNoMatch, @"");
}

- (void)testCapture {
    NSString *text = @"Hallo Welt";
    Regex *regex = [Regex regexWithPattern:@"^(.*) Welt$"];
    
    MatchResult *result = [MatchResult matchResult];
    RegexResultType stat = [regex matchIn:text matchResult:&result];
    XCTAssertTrue(stat == RegexMatch, @"");

    XCTAssertTrue([regex numberOfCapturingSubpatterns] == 1, @"");
    
    [regex setCaptureSubstrings:YES];
    stat = [regex matchIn:text matchResult:&result];
    XCTAssertTrue(stat == RegexMatch, @"");
    XCTAssertTrue([result numberOfMatches] == 2, @"");
    NSString *matchedString = [result matchAtIndex:0];
    NSString *substring = [result matchAtIndex:1];
    XCTAssertTrue([@"Hallo Welt" isEqualToString:matchedString], @"");
    XCTAssertTrue([@"Hallo" isEqualToString:substring], @"");
    
}

@end
