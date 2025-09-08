import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';


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
  private context = getContext(this) as common.UIAbilityContext;
  aboutToAppear() {
    // 这里应该从持久化存储中检查实际的登录状态
    this.username = this.isLoggedIn ? this.username : '未登录';
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
      }
      .width('100%')
      .justifyContent(FlexAlign.Start) // 左对齐
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

      Text('新的开始')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .margin({top:50})
        .padding(10)
        .border({
          width:5
        })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Sudoku' });
        })

      Text('继续游戏')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .margin({top:30})
        .padding(10)
        .border({
          width:5
        })
        .onClick(() => {
        })

      Text('关卡选择')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .margin({top:30})
        .padding(10)
        .border({
          width:5
        })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Level' });
        })

      Text('开发选项')
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