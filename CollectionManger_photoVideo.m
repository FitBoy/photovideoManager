//
//  CollectionManger_photoVideo.m
//  videoqushuiyin
//
//  Created by 梁新帅 on 2022/5/24.
//
#define CollectionTitle  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
#import "CollectionManger_photoVideo.h"
#import "KJPredicateTool.h"

@implementation CollectionManger_photoVideo


/**自定义相册管理*/
-(PHAssetCollection *)getAssetCollectionAppNameAndCreate
{
    NSString *title = CollectionTitle;
    //获取与要创建的相册同名的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        //遍历
        if ([collection.localizedTitle isEqualToString:title]) {
            //找到了同名的自定义相册，返回
            return collection;
        }
    }
    //程序走到这，说明没有找到自定义的相册，需要创建
    NSError *error = nil;
    __block NSString *createID = nil; //用来获取创建好的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //发起了创建新相册的请求，并拿到相册的id，当前并没有创建成功，待创建成功后，通过id来获取创建好的自定义相册
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        createID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"创建失败");
        return nil;
    }else{
        NSLog(@"创建成功");
        //通过id获取创建完成的相册
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil].firstObject;
    }
}

///删除本地的视频
-(void)deleteVideoWithPath:(PHAsset *)asset block:(void(^)(BOOL success))block{
    NSArray *delAsset = @[asset];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:delAsset];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            block(success);
    }];
    
    
    
}

///保存视频
-(PHFetchResult<PHAsset *> *)saveVideoWithFileUrl:(NSString *)fileUrl videoName:(NSString *)name{
    
    __block NSString *createdAssetID = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //直接保存image，不可设置名称
//        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        // 根据路径保存视频，可设置名称
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        createdAssetID = request.placeholderForCreatedAsset.localIdentifier;
        PHAssetResourceCreationOptions *option = [[PHAssetResourceCreationOptions alloc] init];
        option.shouldMoveFile = YES;
        option.originalFilename = name;
        [request addResourceWithType:PHAssetResourceTypeVideo fileURL:[NSURL URLWithString:fileUrl] options:option];
    } error:&error];
    if (error) {
        NSLog(@"保存视频出错了");
        return nil;
    }
    //获取保存到系统相册成功后的 asset 对象集合(一张图片也是返回一个集合)
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    PHAsset *asset = assets.lastObject;
    
 
    
    
    return assets;
    
    
}
///保存视频到自定义的相册
- (void)saveVideoToAlbum:(NSString *)fileUrl videoName:(NSString *)name{
    PHAssetCollection *assetCollection = [self getAssetCollectionAppNameAndCreate];
    if (assetCollection == nil) {
           NSLog(@"相册创建失败");
           return;
    }
    //将图片保存到系统的相册
 PHFetchResult<PHAsset *> *assets = [self saveVideoWithFileUrl:fileUrl videoName:name];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
       
        
     /*
      //直接保存到指定文件的视频 ，不设置视频名称
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString:fileUrl]];
        
        PHAssetCollectionChangeRequest *collectionRequest = [PHAssetCollectionChangeRequest  changeRequestForAssetCollection:assetCollection];
        
        PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
        
        [collectionRequest addAssets:@[placeholder]];
      */
     
        //选取自定义相册进行操作
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        //插入图片到自定义相册
        PHFetchResult<PHAsset *> *assetCount = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:assetCount.count]];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"视频保存完成");
        }else{
        NSLog(@" 视频保存失败");
        }
    }];
    
}


///保存图片
-(PHFetchResult<PHAsset *> *)saveImageWithFileUrl:(NSString *)fileUrl
{
    __block NSString *createdAssetID = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //直接保存image，不可设置名称
//        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        // 根据路径保存图片，可设置名称
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        createdAssetID = request.placeholderForCreatedAsset.localIdentifier;
        PHAssetResourceCreationOptions *option = [[PHAssetResourceCreationOptions alloc] init];
        option.shouldMoveFile = YES;
        option.originalFilename = @"照片的名字啊";
       
        [request addResourceWithType:PHAssetResourceTypePhoto fileURL:[NSURL fileURLWithPath:fileUrl] options:option];
    } error:&error];
    if (error) {
        return nil;
    }
    //获取保存到系统相册成功后的 asset 对象集合(一张图片也是返回一个集合)
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    return assets;
}

// 保存到相册
- (void)keepToAlbum:(NSString *)fileUrl {
    PHAssetCollection *assetCollection = [self getAssetCollectionAppNameAndCreate];
    if (assetCollection == nil) {
           NSLog(@"相册创建失败");
           return;
    }
    //将图片保存到系统的相册
    PHFetchResult<PHAsset *> *assets = [self saveImageWithFileUrl:fileUrl];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //选取自定义相册进行操作
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        //插入图片到自定义相册
        PHFetchResult<PHAsset *> *assetCount = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:assetCount.count]];
        NSLog(@" 保存完成");
    } completionHandler:^(BOOL success, NSError * _Nullable error) {

    }];
}

/// 获取文件夹
-(PHAssetCollection *)getAssetCollectionAppName {
    //设置你想要创建的相册的名字, 和保存的时候名字相同即可获取到那个文件夹
    NSString *title =CollectionTitle ;
    //获取与要创建的相册同名的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        //遍历
        if ([collection.localizedTitle isEqualToString:title]) {
            //找到了同名的自定义相册，返回
            return collection;
        }
    }
    return nil;
}

// 获取视频的封面图以及其他信息
- (void)loadPhotoesBlock:(void(^)(NSArray* data))block{
    
    NSMutableArray *arr_data = [NSMutableArray arrayWithCapacity:0];
    PHAssetCollection *assetCollection = [self getAssetCollectionAppName];
    if (assetCollection == nil) {
           NSLog(@"相册创建失败");
        block(@[]);
           return ;
    }
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    //ascending为NO，即为逆序(由现在到过去)， ascending为YES时即为默认排序，由远到近
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    fetchOptions.sortDescriptors = @[sort];
    PHFetchResult<PHAsset *> *assetCount = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
    
    ///初始化所需要的数据
    NSMutableArray *keys =[NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *values_dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *values_dic1 = [NSMutableDictionary dictionaryWithCapacity:0];

    
    
    dispatch_group_t group = dispatch_group_create();
  
        for (int i = 0; i<assetCount.count; i++) {
            
            dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_group_enter(group);   //标志着一个任务追加
            PHAsset *asset1 = assetCount[i];
            if (asset1.mediaType == PHAssetMediaTypeVideo){
            PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc]init];
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset1 options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    AVURLAsset *urlasset = (AVURLAsset *)asset;
                    NSNumber *size;
                    [urlasset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                    float  total = [size floatValue]/(1024.0 * 1024.0);
                    [values_dic1 setObject:@[
                                           urlasset.URL.absoluteString,
                                           size
                    ] forKey:asset1.localIdentifier];
                  
                }
                
                dispatch_group_leave(group);   //标志着一个任务离开了
            }];
            }
            });
        }
       
      
    
   

        for (int i = 0; i<assetCount.count; i++) {
            
            ///开启第二个任务
            dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_group_enter(group);   //标志着一个任务追加到 group，执行一次，相当于 group 中未执行完毕任务数+1
            PHAsset *asset1 = assetCount[i];
            // 图片的大小
            CGSize size = CGSizeMake(asset1.pixelWidth, asset1.pixelHeight);
            if (asset1.mediaType == PHAssetMediaTypeVideo){
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.synchronous = YES;
                // iCloud图片
                options.networkAccessAllowed = YES;
                // 高清图
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                [PHImageManager.defaultManager requestImageForAsset:asset1 targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                   // 第一种获取照片路径的方法
                    NSString *fileUrl = [NSString stringWithFormat:@"%@",[info valueForKey:@"PHImageFileURLKey"]];
                    NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:asset1];
                    PHAssetResource *firstResource = resources.firstObject;
                  // 第二种获取照片路径的方法
                    NSString *privateFileURL = [NSString stringWithFormat:@"%@",[firstResource valueForKey:@"privateFileURL"]];
                    if (fileUrl.length <= 0 || [@"(null)" isEqualToString:fileUrl]) {
                        fileUrl = privateFileURL;
                    }
                   NSString *fileName = @"未命名";
                   if (firstResource){
                        fileName = firstResource.originalFilename;
                    }
                    NSString *date = [self getDateFromdate:asset1.creationDate];
                    if ([keys containsObject:date]) {
                        NSMutableArray *tarr = [NSMutableArray arrayWithArray:values_dic[date]];
                        [tarr addObject:@{
                            @"img":result,
                            @"asset":asset1,
                            @"filename":fileName,
                            @"fileimagepath":fileUrl,
                           
                        }];
                        values_dic[date] = tarr;
                    }else{
                        [keys addObject:date];
                        NSMutableArray *tarr = [NSMutableArray arrayWithCapacity:0];
                        [tarr addObject:@{
                            @"img":result,
                            @"asset":asset1,
                            @"filename":fileName,
                            @"fileimagepath":fileUrl,
                           
                        }];
                        values_dic[date] = tarr;
                    }
                  
                   NSLog(@"fileName:%@", fileName);
                  // 拿到了fileUrl 和 fileName，就可以根据自己的需要处理了
                    dispatch_group_leave(group);
                }];
            }
            });
        }
      
    
    ////上面开启了不确定的任务组；全部完成才能执行下面的逻辑

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //等前面的异步任务1、任务2都执行完毕后，回到主线程执行下边任务
        for (int i=0; i<keys.count; i++) {
            NSArray *tassets_arr =values_dic[keys[i]];
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:0];
            for (int j=0; j<tassets_arr.count; j++) {
                NSDictionary *tdic = tassets_arr[j];
                PHAsset *tasset = tdic[@"asset"];
                NSArray *tarr = values_dic1[tasset.localIdentifier];
                if (tarr==nil) {
                    tarr=@[
                    @"没有找到路径",
                    @(0)
                    ];
                }
                float total =[tarr[1] floatValue]/(1024.0 *1024.0);
                NSDictionary *tdic1 = @{
                    @"size":tarr[1],
                    @"path":tarr[0],
                    @"img":tdic[@"img"],
                    @"asset":tasset,
                    @"time": [self getTimeFromint:tasset.duration],
                    @"total":@(total),
                    @"filename":tdic[@"filename"],
                    @"fileimagepath":tdic[@"fileimagepath"],
                    @"createDate":tasset.creationDate,
                    
                };
                [list addObject:tdic1];
            }
            NSDictionary *tdic = @{
                @"date":keys[i],
                @"list":list,
            };
            [arr_data addObject:tdic];
        }
        
        //把获取的视频 按时间排下序，不排序是乱的
        NSMutableArray *tarr = [NSMutableArray arrayWithCapacity:0];//放排好序的数据
        for (int i=0; i<arr_data.count; i++) {
            
            NSDictionary *tdic = arr_data[i];
            NSArray *list = tdic[@"list"];
            NSMutableDictionary *mudic = [NSMutableDictionary dictionaryWithDictionary:tdic];
            NSArray *tlist = [KJPredicateTool kj_sortDescriptorWithTemps:list Key:@"createDate" Ascending:NO];
            mudic[@"list"] =tlist;
            [tarr addObject:mudic];
        }
        
        NSArray *arr_new  = [KJPredicateTool kj_sortDescriptorWithTemps:tarr Key:@"date" Ascending:NO];
        
        block(arr_new);
    });
  
}



-(NSString *)getDateFromdate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

-(NSString *)getTimeFromint:(NSInteger)time{
    NSInteger second = time %60+1;
    NSInteger minute = time/60;
    NSString *str_second = [NSString stringWithFormat:@"%ld",second];
    NSString *str_minute =[NSString stringWithFormat:@"%ld",minute];
    if (second <10) {
        str_second = [NSString stringWithFormat:@"0%ld",second];
    }
    if (minute <10) {
        str_minute =[NSString stringWithFormat:@"0%ld",minute];
    }
    return [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    
}




@end
