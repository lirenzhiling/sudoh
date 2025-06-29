@Styles function pageStyle() {
  .width('100%')
  .padding(0)
  .margin({top:-40,bottom:-40})
}

@Entry
@Component

struct Index {
  @State message: string = 'Hello World';
  private gridData: number[] = [
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
  private numbers: string[] = ['1','2','3','4','5','6','7','8','9'];
  // aboutToAppear() {
  //   // 在生命周期中填充数组
  //   for (let i = 0; i < 81; i++) {
  //     this.gridData.push(1);
  //   }
  // }

  build() {
    Column(){
        Text('数独大师')
          .fontSize(30)
          .height('15%')
          .width('100%')
          .padding({top:50})
          .textAlign(TextAlign.Center)
          .backgroundColor('#FFcccccc')

      Grid() {
        ForEach(this.gridData, (item: number, index: number) => {
          GridItem() {
            Text(item.toString())
              .fontSize(16)
              .textAlign(TextAlign.Center)
          }
          .backgroundColor(this.getBlockColor(index))
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
      .margin({top:80})
      .aspectRatio(1) // 强制1:1宽高比（正方形网格）
      .border({
        width:2,
        color:'#FF333333'
      })
      Grid() {
        // 前3x3数字按钮（1~9）
        ForEach(this.numbers, (item: string) => {
          GridItem() {
            Button(item)
              .width('90%')
              .height('90%')
              .fontSize(20)
              .backgroundColor("#FFbbbbbb")
              .fontColor("#FFFFFFFF")
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

  getBlockColor(index: number): string {
    const row=Math.floor((index) / 9);
    const col = (index) % 9;
    const crow=Math.floor(row/3);
    const ccol=Math.floor(col/3);
    console.log(row+" "+col+";"+crow+" "+ccol);
    if (crow==ccol||crow+ccol==2) {
      return'#FFF5F5F5';
    }else {
      return '#FFFFbbFF';
    }
  }
}