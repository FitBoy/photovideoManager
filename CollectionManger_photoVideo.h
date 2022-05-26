//
//  CollectionManger_photoVideo.h
//  videoqushuiyin
//
//  Created by 梁新帅 on 2022/5/24.
// 照片或者视频 创建自定义文件夹的公用类

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionManger_photoVideo : NSObject
///保存视频到自定义的相册
- (void)saveVideoToAlbum:(NSString *)fileUrl videoName:(NSString *)name;
///获取到指定文件夹的视频
- (void)loadPhotoesBlock:(void(^)(NSArray* data))block;
///删除指定的视频
-(void)deleteVideoWithPath:(PHAsset *)asset block:(void(^)(BOOL success))block;
@end

NS_ASSUME_NONNULL_END
