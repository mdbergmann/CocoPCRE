//
//  Regex.m
//  CocoPCRE
//
//  Created by Manfred Bergmann on 20.03.06.
//  Copyright 2006 mabe. All rights reserved.
//

#import "Regex.h"


@interface Regex (privateAPI)

- (RegexErrorCodeType)compile:(NSString **)errorMsg;

- (void)setErrorMessageOfLastAction:(NSString *)errMsg;
- (void)setErrorCodeOfLastAction:(int)aCode;

@end

@implementation Regex (privateAPI)

/**
 \brief this will compile the given pattern
 if no pattern is given, the pcre struct is released if the pointer is not nil
*/
- (RegexErrorCodeType)compile:(NSString **)errorMsg {
	int ret = RegexSuccess;
	
	int erroffset;
	char *error;
	
	// free the old struct, we might get a new one
	if(re != nil) {
		free(re);
		re = nil;
	}

	// free the extra struct on a new compile
	if(pe != nil) {
		free(pe);
		pe = nil;
	}	
	
	// do we have a pattern?
	if(pattern != nil) {
		re = pcre_compile([pattern UTF8String],options,(const char **)&error,&erroffset,NULL);
		
		// if pcre struct is nil, we had an error compiling the regex
		if(re == nil) {
			if(error != nil) {
				if(*errorMsg != nil) {
					// take error message
					*errorMsg = [NSString stringWithUTF8String:error];
				}
				ret = RegexCompileError;
				
				// free error message
				free(error);
			}
		}
	}
	
	return ret;
}

/**
\brief set the errorcode of the last action made
 @param[in] aCode action code taken from MBDBAccessErrorCodes enum
 */
- (void)setErrorCodeOfLastAction:(int)aCode {
	errorCodeOfLastAction = aCode;
}

/**
\brief set the errormessage of the last action made
 @param[in] errMsg message
 */
- (void)setErrorMessageOfLastAction:(NSString *)errMsg {
	[errMsg retain];
	[errorMessageOfLastAction release];
	errorMessageOfLastAction = errMsg;
}

@end


@implementation Regex

/**
 \brief convenient allocator
*/
+ (id)regexWithPattern:(NSString *)pat {
	return [[[Regex alloc] initWithPattern:pat] autorelease];
}

/**
\brief convenient allocator
 */
+ (id)regexWithPattern:(NSString *)pat options:(int)opts {
	return [[[Regex alloc] initWithPattern:pat options:opts] autorelease];
}

- (id)init {
	// call init with empty pattern
	// set default options CaseInsensitive and multiline
	return [self initWithPattern:@"" options:(PCRE_CASELESS | PCRE_MULTILINE)];
}

/**
 \brief normal init
*/
- (id)initWithPattern:(NSString *)pat {
	// call init with empty pattern and no options
	return [self initWithPattern:pat options:(PCRE_CASELESS | PCRE_MULTILINE)];
}

/**
\brief normal init
 */
- (id)initWithPattern:(NSString *)pat options:(int)opts {
	self = [super init];
	if(self) {
		// init things
		options = opts;
	
		// nil re
		re = nil;
		pe = nil;
		
		// set error message
		[self setErrorMessageOfLastAction:nil];
		[self setErrorCodeOfLastAction:RegexSuccess];

		// set pattern
		[self setPattern:pat];
		// set origPattern
		[self setOrigPattern:nil];
	}
	
	return self;
}

- (void)dealloc {
	[self setPattern:nil];
	[self setOrigPattern:nil];
	
	[self setErrorMessageOfLastAction:nil];
	
	if(pe != nil) {
		free(pe);
		pe = nil;
	}
	
	if(re != nil) {
		free(re);
	}
	
	[super dealloc];
}

// getter and setter for the pattern
- (void)setPattern:(NSString *)pat {
	int err = RegexSuccess;
	[self setErrorMessageOfLastAction:@""];

	if(pat != pattern) {
		[pat retain];
		[pattern release];
		pattern = pat;		
	}
	
	// compile new pcre structure
	// we might have a error message
	NSString *error = @"";
	err = [self compile:&error];
	if(err != RegexSuccess) {
		// set error message
		[self setErrorMessageOfLastAction:error];
	}
	
	[self setErrorCodeOfLastAction:err];
}

- (NSString *)pattern {
	return pattern;
}

- (void)setOrigPattern:(NSString *)origPat {
	if(origPat != origPattern) {
		[origPat retain];
		[origPattern release];
		origPattern = origPat;
	}
}

- (NSString *)origPattern {
	return origPattern;
}

/**
 \brief study the pattern to speed things um on matching. use if pattern is used several times
*/
- (void)studyPattern {
	if(re != nil)
	{
		// if pe is not nil, we first have to free it
		if(pe != nil) {
			// free the old study information and get new ones
			free(pe);
			pe = nil;
		}
		
		char *error;
		pe = pcre_study(re,0,(const char **)&error);
		if(error != nil) {
			free(error);
		}
	}
}

/**
 \brief set option multiline
*/
- (void)setMultiline:(BOOL)flag {
	if(flag) {
		options = options | PCRE_MULTILINE;
	} else {
		options = options & ~PCRE_MULTILINE;
	}

	// compile new pcre structure
	// we might have a error message
	NSString *error = @"";
	int err = [self compile:&error];
	if(err != RegexSuccess) {
		[self setErrorMessageOfLastAction:error];
	}
	
	[self setErrorCodeOfLastAction:err];
}

/**
\brief set option case sensitive
 */
- (void)setCaseSensitive:(BOOL)flag {
	if(!flag) {
		options = options | PCRE_CASELESS;
	} else {
		options = options & ~PCRE_CASELESS;
	}
	
	// compile new pcre structure
	// we might have a error message
	NSString *error = @"";
	int err = [self compile:&error];
	if(err != RegexSuccess) {
		// set error message
		[self setErrorMessageOfLastAction:error];
	}
	
	[self setErrorCodeOfLastAction:err];
}

- (void)setExtended:(BOOL)flag {
	if(flag) {
		options = options | PCRE_EXTENDED;
	} else {
		options = options & ~PCRE_EXTENDED;
	}	

	// compile new pcre structure
	// we might have a error message
	NSString *error = @"";
	int err = [self compile:&error];
	if(err != RegexSuccess) {
		[self setErrorMessageOfLastAction:error];
	}
	
	[self setErrorCodeOfLastAction:err];
}

// general options
- (void)setCaptureSubstrings:(BOOL)flag {
	captureSubstrings = flag;
}

- (BOOL)captureSubstrings {
	return captureSubstrings;
}

- (void)setFindAll:(BOOL)flag {
	findAll = flag;
}

- (BOOL)findAll {
	return findAll;
}


/**
 \brief try to match against the given string
 this method sets error type and message
*/
- (RegexResultType)matchIn:(NSString *)string matchResult:(MatchResult **)mResult {
	int ret = RegexSuccess;	
	[self setErrorMessageOfLastAction:@""];
	
	// init the vector for the captured substrings
	int num = 0;
	int *ovector = NULL;

	if(captureSubstrings) {
		// init the vector for the captured substrings
        int captures = [self numberOfCapturingSubpatterns];
		num = (captures*3*3);
		ovector = (int *)calloc(num, sizeof(int));
	} else {
		num = 30;
		ovector = (int *)malloc(num * sizeof(int));
	}
	
	// the subject
	const char *subject = [string UTF8String];
	int len = (int)[string length];
	int i = 0;
	int rc = 0;
    int err = 0;
	int offset = 0;
	do {
		rc = pcre_exec(re,pe,subject,len,offset,0,ovector,num);
		
		if(rc < 1) {
			switch(rc) {
				case PCRE_ERROR_NOMATCH:
					// only set No Match if this is the first run
					if(i == 0) {
						ret = RegexNoMatch;
					}
					break;
				default:
					// this is an error
					ret = RegexMatchError;
                    err = ret;
					[self setErrorMessageOfLastAction:@"Error on pcre_execute!"];
					break;
			}
		} else {
			ret = RegexMatch;
			
			if(captureSubstrings) {
				// only get substrings, if we have to return a result
				if(*mResult != nil) {
					// get captured substrings
					const char *substring = NULL;
                    for(int i = 0;i < rc;i++) {
                        pcre_get_substring(subject, ovector, rc, i, &substring);
                        if(substring) {
                            NSString *str = [NSString stringWithUTF8String:substring];
                            if(str != nil) {
                                CLOG2(@"Have substring: %@", str);
                                [*mResult addMatch:str];
                            }
                            pcre_free_substring(substring);
                        }
                    }                    
				} else {
					CLOG1(@"[Regex -matchIn:matchResult:] we have to capture substrings but mResult is nil!");
				}
			}
		}
		
		i++;
	}
	while((findAll == YES) && (rc > 0));
	
	// free ovec
	if(ovector != NULL) {
		free(ovector);
	}
	
	[self setErrorCodeOfLastAction:err];
	
	return ret;
}

/**
 \brief get the number of caturing subpatterns in the current compiled pattern
 the pattern has to be compiled before
 */
- (int)numberOfCapturingSubpatterns {
	int ret = 0;
	
	if(re != nil) {
		// get the number of capturing subpatterns
		int rc = pcre_fullinfo(re,pe,PCRE_INFO_CAPTURECOUNT,&ret);
		if(rc != 0) {
			CLOG1(@"[Regex -numberOfCapturingSubpatterns] error on pcre_fullinfo()!");
			ret = -1;
		}
	}
	
	return ret;
}

// error handling
- (NSString *)errorMessageOfLastAction {
	return errorMessageOfLastAction;
}

- (int)errorCodeOfLastAction {
	return errorCodeOfLastAction;
}

@end
