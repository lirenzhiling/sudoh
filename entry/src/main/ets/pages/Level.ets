import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct Level {
  private swiperController: SwiperController = new SwiperController();
  private imageArr=['img/level/one.png','img/level/two.png','img/level/three.png',
  'img/level/four.png','img/level/fine.png'];
  private myindex=0;
  private context = getContext(this) as common.UIAbilityContext;
  @State private gridData: number[][] = [
    [
      5, 0, 0, 6, 7, 8, 9, 1, 2,
      6, 7, 2, 1, 9, 5, 3, 4, 8,
      1, 9, 8, 3, 4, 2, 5, 6, 7,
      8, 5, 9, 7, 6, 1, 4, 2, 3,
      4, 2, 6, 8, 5, 3, 7, 9, 1,
      7, 1, 3, 9, 2, 4, 8, 5, 6,
      9, 6, 1, 5, 3, 7, 2, 8, 4,
      2, 8, 7, 4, 1, 9, 6, 3, 5,
      3, 4, 5, 2, 8, 6, 1, 7, 9
    ],
    [
      0, 0, 0, 0, 7, 0, 0, 0, 6,
      2, 0, 4, 0, 5, 1, 0, 7, 0,
      8, 0, 0, 0, 0, 2, 0, 1, 9,
      5, 0, 0, 6, 0, 0, 2, 0, 0,
      0, 0, 1, 0, 0, 4, 9, 5, 0,
      0, 0, 8, 0, 0, 0, 0, 0, 1,
      3, 7, 0, 1, 0, 0, 0, 0, 5,
      0, 1, 0, 3, 0, 0, 7, 0, 2,
      9, 0, 0, 0, 2, 0, 1, 0, 0
    ],
    [
      0, 7, 2, 1, 0, 0, 4, 0, 0,
      0, 1, 0, 8, 0, 4, 0, 2, 0,
      0, 4, 0, 3, 0, 0, 5, 9, 0,
      1, 0, 0, 9, 0, 0, 0, 4, 7,
      3, 0, 0, 5, 0, 6, 0, 0, 9,
      4, 2, 0, 0, 3, 0, 0, 0, 8,
      0, 5, 1, 0, 0, 7, 0, 3, 0,
      0, 9, 0, 2, 0, 3, 0, 6, 0,
      0, 0, 4, 0, 0, 9, 8, 7, 0
    ],
    [
      8, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 3, 6, 0, 0, 0, 0, 0,
      0, 7, 0, 0, 9, 0, 2, 0, 0,
      0, 5, 0, 0, 0, 7, 0, 0, 0,
      0, 0, 0, 0, 4, 5, 7, 0, 0,
      0, 0, 0, 1, 0, 0, 0, 3, 0,
      0, 0, 1, 0, 0, 0, 0, 6, 8,
      0, 0, 8, 5, 0, 0, 0, 1, 0,
      0, 9, 0, 0, 0, 0, 4, 0, 0
    ],
    [
      0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 3, 0, 0, 0, 0,
      0, 0, 2, 0, 0, 0, 1, 0, 0,
      0, 6, 0, 5, 0, 4, 0, 3, 0,
      0, 0, 0, 0, 7, 0, 0, 0, 0,
      0, 1, 0, 9, 0, 2, 0, 8, 0,
      0, 0, 7, 0, 0, 0, 6, 0, 0,
      0, 0, 0, 0, 8, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0
    ],
  ];

  build() {
    Column({ space: 20 }) {
      Text('关卡选择')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .margin({top:80})
        .padding(40)

      Swiper(this.swiperController) {
          Image('img/level/one.png')
            .width(300)
            .height(350)
            .padding({ bottom: 50 })
          Image('img/level/two.png')
            .width(300)
            .height(350)
            .padding({ bottom: 50 })
          Image('img/level/three.png')
            .width(300)
            .height(350)
            .padding({ bottom: 50 })
          Image('img/level/four.png')
            .width(300)
            .height(350)
            .padding({ bottom: 50 })
          Image('img/level/fine.png')
            .width(300)
            .height(350)
            .padding({ bottom: 50 })
      }
      .onChange((index: number) => {
        this.myindex = index; // 监听轮播索引变化
      })
      .indicator(
        new DotIndicator()
          .itemWidth(25)  // Swiper组件圆点导航指示器的宽
          .itemHeight(25)  // Swiper组件圆点导航指示器的高
          .selectedItemWidth(25)  // Swiper组件圆点导航指示器的选中状态的宽
          .selectedItemHeight(25)  // Swiper组件圆点导航指示器的选中状态的高
          .selectedColor(0x0a59f7)  // 圆点导航指示器的选中状态颜色
          .color(0x80000000) // 圆点导航指示器的颜色
      )


      Row({ space: 80 }) {
        Button('上一关')
          .onClick(() => {
            this.swiperController.showPrevious(); // 通过controller切换到前一页
          })
        Button('下一关')
          .onClick(() => {
            this.swiperController.showNext(); // 通过controller切换到后一页
          })
      }.margin(5)
      Button('开始挑战')
        .onClick(() => {
          let want: Want = {
            deviceId: "", // 空字符串表示本设备
            bundleName: "com.example.myapplication", // 当前应用包名
            abilityName: "EntryAbility", // 目标Ability名称
            moduleName: "entry",
            parameters: { // 可选参数传递
              mylevel: this.gridData[this.myindex],
            }
          };
          this.context.startAbility(want);
        })
        .width('65%')
    }.width('100%')
    .margin({ top: 5 })
  }

}