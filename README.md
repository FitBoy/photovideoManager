# photovideoManager
获取指定相册下的本地视频，视频包括 本地地址，描述，视频时长，视频大小，封面图等；
使用：


1.比如从下载视频到本地，code:

+(void)downloadWithUrl:(NSString *)urlstring videoname:(NSString*)name block:(void (^)(NSDictionary *tdic))block{
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    NSURL *url = [NSURL URLWithString:urlstring];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask*download = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"===%@",[NSString stringWithFormat:@"%f",1.0*downloadProgress.completedUnitCount/ downloadProgress.totalUnitCount]);

      } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
          NSURL *pathURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];

          return [pathURL URLByAppendingPathComponent:[response suggestedFilename]];

        
      } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
          NSLog(@"filePath ===%@",filePath);
          //获取缓存的视频路径
          block(@{
            @"filepath":filePath.absoluteString
          });
    }];
    
    [download resume];
    
}

2. 根据路径保存视频

CollectionManger_photoVideo.h

///保存视频到自定义的相册
- (void)saveVideoToAlbum:(NSString *)fileUrl videoName:(NSString *)name;
- 
自定义相册的名字是 应用的名字，这个可以自己修改代码
fileurl 就是上面下载的视频路径，videoname 是自定义的视频的名字

3.获取自定义相册的视频列表

///获取到指定文件夹的视频
- (void)loadPhotoesBlock:(void(^)(NSArray* data))block;


data的数据结构是：
[
{
date:2022-05
list:[
                {
                    @"size":tarr[1],//文件大小
                    @"path":tarr[0],//文件路径
                    @"img":tdic[@"img"],// UIimage 封面图
                    @"asset":tasset,// PHAsset 
                    @"time": [self getTimeFromint:tasset.duration],// 显示的 时间
                    @"total":@(total),// 文件大小
                    @"filename":tdic[@"filename"],//上面自定义的视频的名字
                    @"fileimagepath":tdic[@"fileimagepath"],// 文件路径
                    @"createDate":tasset.creationDate,// 创建的时间
                    
                },
                ……
}
]
},
……

]

以上数据结构 用 KJPredicateTool 进行了重新排序，可以根据自己的需求修改代码进行排序


4.删除指定的视频

///删除指定的视频
-(void)deleteVideoWithPath:(PHAsset *)asset block:(void(^)(BOOL success))block;

根据 PHasset 删除指定的视频

