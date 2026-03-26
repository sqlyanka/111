//
//  lara-Bridging-Header.h
//  lara
//

#import <Foundation/Foundation.h>
#import "darksword.h"
#import "utils.h"
#import "kfs.h"
#import "translation.h"

void test(NSString *path);

bool lara_set_kernproc_offset_from_kernelcache(NSString *path);
bool lara_download_kernelcache_and_set_offsets(void);
uint64_t lara_get_kernproc_offset(void);
bool lara_has_kernproc_offset(void);
NSString *lara_get_kernelcache_path(void);
void lara_clear_kernelcache_data(void);
