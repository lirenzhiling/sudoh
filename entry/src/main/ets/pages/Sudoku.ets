import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import promptAction from '@ohos.promptAction';
import Want from '@ohos.app.ability.Want';





@Styles function pageStyle() {
  .width('100%')
  .padding(0)
  .margin({top:-40,bottom:-40})
}
interface TimerEventData {
  action: 'start' | 'stop' | 'reset'; // 联合类型限定可能的操作
}
@Entry
@Component

struct Sudoku {
  private context = getContext(this) as common.UIAbilityContext;

  private gridDataone: number[] = [
    5, 3, 0, 0, 7, 0, 0, 0, 0,
    6, 0, 0, 1, 9, 5, 0, 0, 0,
    0, 9, 8, 0, 0, 0, 0, 6, 0,
    8, 0, 0, 0, 6, 0, 0, 0, 3,
    4, 0, 0, 8, 0, 3, 0, 0, 1,
    7, 0, 0, 0, 2, 0, 0, 0, 6,
    0, 6, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 4, 1, 9, 0, 0, 5,
    0, 0, 0, 0, 8, 0, 0, 7, 9
  ];
  @State private gridData: number[] = [
    5, 3, 0, 0, 7, 0, 0, 0, 0,
    6, 0, 0, 1, 9, 5, 0, 0, 0,
    0, 9, 8, 0, 0, 0, 0, 6, 0,
    8, 0, 0, 0, 6, 0, 0, 0, 3,
    4, 0, 0, 8, 0, 3, 0, 0, 1,
    7, 0, 0, 0, 2, 0, 0, 0, 6,
    0, 6, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 4, 1, 9, 0, 0, 5,
    0, 0, 0, 0, 8, 0, 0, 7, 9
  ];
  private numbers: number[] = [1,2,3,4,5,6,7,8,9];
  @State selectedIndex: number = -1;
  @State selectedNumber: number = -1;
  // 声明计时器控制器
  textTimerController: TextTimerController = new TextTimerController();

  // 新增Service启动方法
  // private startService() {
  //   let want: Want = {
  //     deviceId: "", // 空字符串表示本设备
  //     bundleName: "com.example.myapplication", // 当前应用包名
  //     abilityName: "MyServiceAbility", // 目标Ability名称
  //     moduleName: "entry",
  //     parameters: { // 可选参数传递
  //       taskType: "sync"
  //     }
  //   };
  //   this.context.startAbility(want);
  //   promptAction.showDialog({
  //     title: '游戏暂停',
  //     message: '是否继续游戏？',
  //     buttons: [
  //       { text: '确定', color: '#007AFF'},
  //       { text: '退出', color: '#999' }
  //     ]
  //   })
  // }

  //暂停与继续
  @State bgImage: string = 'img/play.png';

  // 接收端
  @StorageLink('timerStatus') timerStatus: string = '';
  @StorageLink('mylevel') mylevel: number[] = [];
  @State mylevelinit: number[] = [];

  aboutToAppear() {
    this.mylevelinit = [...this.mylevel]; // 或 JSON.parse(JSON.stringify(this.mylevel))
  }

  @State showConfirmDialog: boolean = false; // 控制弹窗显隐



  // aboutToAppear() {
  //   // 在生命周期中填充数组
  //   for (let i = 0; i < 81; i++) {
  //     this.gridData.push(1);
  //   }
  // }


  onPageShow() {
    // 从全局状态获取计时器状态
    // this.isTimerRunning = globalThis.timerStatus?.isRunning ?? false;
    // if (this.isTimerRunning) {
    //   this.textTimerController.start();
    // } else {
    //   this.textTimerController.pause();
    // }

    const shouldShow: boolean = AppStorage.get<boolean>('shouldShowDialog') || false; // 默认false
    PersistentStorage.persistProp('shouldShowDialog', false);

    // this.context.eventHub.emit('updateTimer', 1000);
    if (shouldShow) {
      this.showConfirmDialog = true; // 点击后显示弹窗
      this.timerStatus = 'pause';
      this.textTimerController.pause();
      this.bgImage = 'img/stop.png';
      // Dialog弹窗
      if (this.showConfirmDialog) {
        promptAction.showDialog({
          title: '游戏暂停',
          message: '是否继续游戏？',
          buttons: [
            { text: '确定', color: '#007AFF'},
            { text: '退出', color: '#999' }
          ]
        }).then((result) => {
          if (result.index === 0) { // 点击确定
            this.textTimerController.start();
            this.bgImage = 'img/play.png';
          }
          if (result.index === 1) { // 点击取消
            this.context.terminateSelf();
            this.showConfirmDialog=false;
            PersistentStorage.persistProp('shouldShowDialog', false);
          }
        });
      }
    }
    if (this.timerStatus === 'start') {
      this.textTimerController.start();
    }
    else if (this.timerStatus === 'pause'){
      this.textTimerController.pause();
    }
  }

  build() {
    Column(){
      Text('数独大师')
        .fontSize(30)
        .height('15%')
        .width('100%')
        .padding({top:50})
        .textAlign(TextAlign.Center)
        .backgroundColor('#FFcccccc')


      // 横向布局
      Row({ space: 20 }) { // 设置按钮间距为20vp
        Image(this.bgImage)
          .width(40)
          .height(40)
          .borderRadius(20)
          .onClick(()=>{
            this.showConfirmDialog = true; // 点击后显示弹窗
            this.timerStatus = 'pause';
            this.textTimerController.pause();
            this.bgImage = 'img/stop.png';
            // Dialog弹窗
            if (this.showConfirmDialog) {
              promptAction.showDialog({
                title: '游戏暂停',
                message: '是否继续游戏？',
                buttons: [
                  { text: '确定', color: '#007AFF'},
                  { text: '退出', color: '#999' }
                ]
              }).then((result) => {
                if (result.index === 0) { // 点击确定
                  this.textTimerController.start();
                  this.bgImage = 'img/play.png';
                }
                if (result.index === 1) { // 点击取消
                  this.context.terminateSelf();
                  this.showConfirmDialog=false;
                  PersistentStorage.persistProp('shouldShowDialog', false);
                }
              });
            }
          })

        Image('img/message.png')
          .width(40)
          .height(40)
          .borderRadius(20)
          .onClick(()=> {
            // this.startService();
          })

        TextTimer({
          controller: this.textTimerController,
        })
          .format('mm:ss')
          .fontSize(20)
          .fontColor(Color.Black)

        Image('img/reset.png')
          .width(40)
          .height(40)
          .borderRadius(20)

        Image('img/hint.png')
          .width(40)
          .height(40)
          .borderRadius(20)
      }
      .width('100%')
      .margin({top:40})
      .justifyContent(FlexAlign.Center) // 水平居中对齐

      Grid() {
        ForEach(this.mylevel, (item: number, index: number) => {
          GridItem() {
            Text(this.getBlockText(item,index))
              .fontSize(16)
              .fontColor(this.getBlockTextColor(index))
              .textAlign(TextAlign.Center)
          }
          .backgroundColor(this.getBlockColor(index))
          .onClick(() => {
            if (this.mylevelinit[index] === 0) { // 仅当item非0时响应点击
              this.selectedNumber=item;
              this.selectedIndex = index; // 更新选中索引
              this.mylevel[this.selectedIndex]=this.selectedNumber;
            }
          })
          .border({
            width:1,
            color: {
              left: (index % 3 === 0) ? '#FF333333' : '#FFDDDDDD',
              right: (index % 3 === 2) ? '#FF333333' : '#FFDDDDDD',
              top: (Math.floor(index / 9) % 3 === 0) ? '#FF333333' : '#FFDDDDDD',
              bottom: (Math.floor(index / 9) % 3 === 2) ? '#FF333333' : '#FFDDDDDD'
            }
          })
        })
      }
      // 关键：9行9列均分
      .rowsTemplate('1fr '.repeat(9))
      .columnsTemplate('1fr '.repeat(9))
      .columnsGap(0)  // 列间距
      .rowsGap(0)     // 行间距
      .width('90%')   // 控制整体宽度
      .margin({top:40})
      .aspectRatio(1) // 强制1:1宽高比（正方形网格）
      .border({
        width:2,
        color:'#FF333333'
      })
      Grid() {
        // 前3x3数字按钮（1~9）
        ForEach(this.numbers, (item: number) => {
          GridItem() {
            Button(item.toString())
              .width('90%')
              .height('90%')
              .fontSize(20)
              .backgroundColor("#FFbbbbbb")
              .fontColor("#FFFFFFFF")
              .onClick(() => {
                  this.selectedNumber = item; // 更新选中数值
                  this.mylevel[this.selectedIndex]=this.selectedNumber;
                })
          }
        })

        // 最后一行跨3列的提交按钮
        GridItem() {
          Button('提交')
            .width('95%')
            .height('80%')
            .fontSize(20)
            .backgroundColor("#FFbbbbbb")
            .fontColor("#FFFFFFFF")
            .onClick(() => {
              console.log('mylevel：'+this.mylevel[2]+'mylevelinit'+this.mylevelinit[2])
            })
        }
        .columnStart(0)  // 从第1列开始
        .columnEnd(2)    // 跨到第3列（索引从0开始）
        .rowStart(3)     // 第4行
        .rowEnd(3)       // 第4行
      }
      .columnsTemplate('1fr 1fr 1fr')  // 3等分列
      .rowsTemplate('1fr 1fr 1fr 1fr') // 4行
      .columnsGap(10)                  // 列间距
      .rowsGap(10)                     // 行间距
      .width('60%')
      .height('20%')
      .margin({top:50})
    }
    .width("100%")
    .height("100%")
    .pageStyle()
    // .backgroundColor('#FFaaFFFF')
  }

  getBlockText(item: number,index:number): string {
    if (this.selectedIndex === index) {
      item=this.selectedNumber;
      return item>0 ? item.toString(): " ";
    }else if (item===0||item===-1){
      return " ";
    }else{
      return item.toString();
    }
  }

  getBlockColor(index: number): string {
    const row=Math.floor((index) / 9);
    const col = (index) % 9;
    const crow=Math.floor(row/3);
    const ccol=Math.floor(col/3);
    console.log(row+" "+col+";"+crow+" "+ccol);
    if (crow==ccol||crow+ccol==2) {
      return (this.selectedIndex === index) ? '#FFca7731':'#FFF5F5F5';
    }else {
      return (this.selectedIndex === index) ? '#FFca7731': '#FFFFbbFF';
    }
  }
  getBlockTextColor(index:number):string{
    if (this.mylevelinit[index]===0) {
      return "#FF6666ff"
    }else {
      return "#FF000000"
    }
  }
}