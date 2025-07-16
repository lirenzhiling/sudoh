import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct Home {
  private context = getContext(this) as common.UIAbilityContext;
  build() {
    Column() {
      Text('数独大师')
        .id('PageHelloWorld')
        .fontSize(60)
        .fontWeight(FontWeight.Bold)
        .margin({top:80})
        .padding(40)
        .border({
          width:5
        })
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
          let want: Want = {
            deviceId: "", // 空字符串表示本设备
            bundleName: "com.example.myapplication", // 当前应用包名
            abilityName: "EntryAbility", // 目标Ability名称
            moduleName: "entry",
            parameters: { // 可选参数传递
              key1: "value1",
              key2: 100
            }
          };
          this.context.startAbility(want);
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