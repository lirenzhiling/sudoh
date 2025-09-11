import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import media from '@ohos.multimedia.media';

import { DatabaseHelper } from '../database/DatabaseHelper';


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
  @State level: number = 0; // 用于存储并响应式更新level数据
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();



  private context = getContext(this) as common.UIAbilityContext;
  async aboutToAppear() {
    // 这里应该从持久化存储中检查实际的登录状态
    this.username = this.isLoggedIn ? this.username : '未登录';

    await this.dbHelper.initDatabase(this.context);
    try {
      const userLevel = await this.dbHelper.getUserLevel(this.username);
      if (userLevel !== undefined) {
        this.level = userLevel; // 更新状态变量，UI会自动刷新
      } else {
        console.error(`未找到用户 ${this.username} 的等级信息`);
        // 可以设置一个默认值或显示错误信息
        this.level = 0;
      }
    } catch (error) {
      console.error("获取用户等级失败: ", error);
      // 处理错误情况
      this.level = 0;
    }
  }

  build() {
    Column() {
      // 用户头像
      Image('img/user.jpg') // 建议使用Resource资源方式管理本地图片[1](@ref)
        .width(150)
        .height(150)
        .margin({ top:100 })
        .borderRadius(75) // 圆形头像
        .objectFit(ImageFit.Contain) // 关键修改：确保图片完整显示在容器内[3](@ref)
        .backgroundColor('#f0f0f0') // 可选项：如果图片有透明区域或非方形，设置背景色
        .border({ // 添加边框
          width: 5, // 边框宽度
          color: Color.Black, // 边框颜色，可以使用Color预定义颜色，或使用$r('app.color.your_color')引用资源
          style: BorderStyle.Solid // 边框样式，默认为Solid（实线），还可选Dotted（点线）或Dashed（虚线）
        })

      Text(this.username)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top:20 })

      Text(`通关数：${this.level}关`)
        .fontSize(15)
        .margin({ top:50 })
        .flexGrow(1)

      Button('退出登录', { type: ButtonType.Capsule })
        .width('90%')
        .height(50)
        .backgroundColor('#409EFF')
        .fontColor(Color.White)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 30 ,bottom:50})
        .onClick(() => {
          promptAction.showDialog({
            title: '是否退出登录',
            buttons: [
              { text: '确定', color: '#007AFF'},
              { text: '取消', color: '#999' }
            ]
          }).then((result) => {
            if (result.index === 0) { // 点击确定
              this.setLoggedIn=false;
              router.pushUrl({ url: 'pages/Home' });
            }
            if (result.index === 1) { // 点击取消
            }
          });

        })

    }
    .height('100%')
    .width('100%')
  }
}