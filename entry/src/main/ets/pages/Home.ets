import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import media from '@ohos.multimedia.media';



PersistentStorage.persistProp('isLoggedIn', false);
PersistentStorage.persistProp('username', '');


@Entry
@Component
struct Home {
  // 修改前：使用 @StorageLink (双向同步，修改会写回持久化存储)
  // @StorageLink('isLoggedIn') setLoggedIn: boolean = false;
  // @StorageLink('username') username: string = '';

  // 修改后：使用 @StorageProp (单向同步，修改不会写回持久化存储)
  @StorageProp('isLoggedIn') isLoggedIn: boolean = false;
  @StorageProp('username') username: string = '';
  @StorageLink('isLoggedIn') setLoggedIn: boolean = this.isLoggedIn;

  @State isMusicPlaying: boolean = false;

  private avPlayer: media.AVPlayer | null = null;
  private context = getContext(this) as common.UIAbilityContext;
  aboutToAppear() {
    // 这里应该从持久化存储中检查实际的登录状态
    this.username = this.isLoggedIn ? this.username : '未登录';

    this.initAVPlayer();
  }

  // 初始化AVPlayer并设置回调
  async initAVPlayer() {
    try {
      // 1. 创建AVPlayer实例
      this.avPlayer = await media.createAVPlayer();
      // 2. 设置回调监听
      // this.setAVPlayerCallback();
      // 3. 设置播放源
      await this.setSource();
    } catch (error) {
      console.error(`初始化播放器失败: ${JSON.stringify(error)}`);
    }
  }

  // 设置播放源 (使用rawfile中的文件)
  async setSource() {
    if (!this.avPlayer) return;

    try {
      // 关键：获取rawfile目录下音乐文件的文件描述符
      let fileDescriptor = await this.context.resourceManager.getRawFd('music.mp3');
      // 解构获取需要的字段
      let avFileDescriptor: media.AVFileDescriptor = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      // 设置为播放源
      this.avPlayer.fdSrc = avFileDescriptor;
    } catch (error) {
      console.error(`设置播放源失败: ${JSON.stringify(error)}`);
    }
  }

  build() {
    Column() {

      Row() {
        // 用户头像
        Image('img/user.jpg') // 建议使用Resource资源方式管理本地图片[1](@ref)
          .width(40)
          .height(40)
          .borderRadius(20) // 圆形头像
          .objectFit(ImageFit.Contain) // 关键修改：确保图片完整显示在容器内[3](@ref)
          .backgroundColor('#f0f0f0') // 可选项：如果图片有透明区域或非方形，设置背景色
          .margin({ right: 10 })
          .onClick(() => {
            // 点击头像后的操作，例如跳转到个人资料页
          })

        // 用户昵称
        Text(this.username) // 使用获取到的昵称
          .fontSize(16)
          .fontColor(Color.Black)
          .flexGrow(1)
          .onClick(() => {
            if (this.isLoggedIn) {
              promptAction.showDialog({
                title: '是否退出登录',
                buttons: [
                  { text: '确定', color: '#007AFF'},
                  { text: '退出', color: '#999' }
                ]
              }).then((result) => {
                if (result.index === 0) { // 点击确定
                  this.setLoggedIn=false;
                  this.username='未登录';
                }
                if (result.index === 1) { // 点击取消
                }
              });
            }else {
              router.pushUrl({ url: 'pages/Login' });
            }
          })

        Image(this.isMusicPlaying ? 'img/music.png':'img/musicstop.png') // 建议使用Resource资源
          .width(30)
          .height(30)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            // 点击音乐图片后的操作
            this.isMusicPlaying = !this.isMusicPlaying;

            // 根据状态执行不同操作
            if (this.avPlayer){
              if (this.isMusicPlaying) {
                // 开始播放音乐的代码
                this.avPlayer.play();
                // promptAction.showToast({
                //   message: '播放',
                //   duration: 2000
                // });

              } else {
                // 暂停播放音乐的代码
                this.avPlayer.pause();
              }
            }
          })
        Column(){
          // 排行榜图片 - 将被flexGrow(1)推到最右边
          Image('img/rank.png') // 建议使用Resource资源
            .width(30)
            .height(30)
            .objectFit(ImageFit.Contain)

          Text('排行榜') // 使用获取到的昵称
            .fontSize(16)
            .fontColor(Color.Black)
        }
        .margin({ left: 10,right:15 }) // 添加与左边元素的间距
        .onClick(() => {
          // 点击排行榜后的操作
        })

      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: 20, left: 20 })
      .padding(10)
      .zIndex(1) // 确保在最上层

      Text('数独大师')
        .id('PageHelloWorld')
        .fontSize(60)
        .fontWeight(FontWeight.Bold)
        .padding(40)
        .onClick(() => {
        })

      Text('关卡选择')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .margin({top:50})
        .padding(10)
        .border({
          width:5
        })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Level' });
        })

      Text('随机挑战')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .margin({top:30})
        .padding(10)
        .border({
          width:5
        })

        .onClick(() => {
          let want: Want = {
            deviceId: "", // 空字符串表示本设备
            bundleName: "com.example.myapplication", // 当前应用包名
            abilityName: "EntryAbility", // 目标Ability名称
            moduleName: "entry",
            parameters: { // 可选参数传递
              mylevel: [
                5, 3, 0, 0, 7, 0, 0, 0, 0,
                6, 0, 0, 1, 9, 5, 0, 0, 0,
                0, 9, 8, 0, 0, 0, 0, 6, 0,
                8, 0, 0, 0, 6, 0, 0, 0, 3,
                4, 0, 0, 8, 0, 3, 0, 0, 1,
                7, 0, 0, 0, 2, 0, 0, 0, 6,
                0, 6, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 4, 1, 9, 0, 0, 5,
                0, 0, 0, 0, 8, 0, 0, 7, 9
              ],
            }
          };
          this.context.startAbility(want);
        })

      Text('双人挑战')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .margin({top:30})
        .padding(10)
        .border({
          width:5
        })
        .onClick(() => {
        })

      Text('个人中心')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .margin({top:30})
        .padding(10)
        .border({
          width:5
        })
        .onClick(() => {
        })
    }
    .height('100%')
    .width('100%')
  }
}