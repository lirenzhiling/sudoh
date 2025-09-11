import { RankingItem, RankStyles } from './model/RankingItem';

@Entry
@Component
struct RankingPage {
  // 初始化数据（带默认样式，避免undefined）
  private rankingData: RankingItem[] = [
    { rank: 0, name: '玩家一', level: 25, styles: { rankBgColor: $r('app.color.light_gray'), itemBgColor: $r('app.color.white'), borderColor: $r('app.color.light_gray') } },
    { rank: 0, name: '玩家二', level: 22, styles: { rankBgColor: $r('app.color.light_gray'), itemBgColor: $r('app.color.white'), borderColor: $r('app.color.light_gray') } },
    { rank: 0, name: '玩家三', level: 18, styles: { rankBgColor: $r('app.color.light_gray'), itemBgColor: $r('app.color.white'), borderColor: $r('app.color.light_gray') } },
    { rank: 0, name: '路人甲', level: 15, styles: { rankBgColor: $r('app.color.light_gray'), itemBgColor: $r('app.color.white'), borderColor: $r('app.color.light_gray') } },
    { rank: 0, name: '路人乙', level: 12, styles: { rankBgColor: $r('app.color.light_gray'), itemBgColor: $r('app.color.white'), borderColor: $r('app.color.light_gray') } },
    { rank: 0, name: '路人丙', level: 10, styles: { rankBgColor: $r('app.color.light_gray'), itemBgColor: $r('app.color.white'), borderColor: $r('app.color.light_gray') } }
  ];

  // 页面渲染前：完成数据补充、排序、样式预计算
  aboutToAppear(): void {
    // 补充15条数据（含初始6条）
    for (let i = 7; i <= 15; i++) {
      this.rankingData.push({
        rank: 0,
        name: `路人玩家 ${i}`,
        level: 18 - i,
        styles: { rankBgColor: $r('app.color.light_gray'), itemBgColor: $r('app.color.white'), borderColor: $r('app.color.light_gray') }
      });
    }

    // 按关卡数降序排序
    this.rankingData.sort((a, b) => b.level - a.level);

    // 重新计算排名 + 预生成样式（@Builder无需再计算）
    this.rankingData.forEach((item, index) => {
      item.rank = index + 1;
      item.styles = this._calcStyles(item.rank);
    });
  }

  // 纯逻辑：计算排名对应的样式（与@Builder完全分离）
  private _calcStyles(rank: number): RankStyles {
    switch (rank) {
      case 1:
        return {
          rankBgColor: $r('app.color.gold'),
          itemBgColor: $r('app.color.gold_light'),
          borderColor: $r('app.color.light_gray')
        };
      case 2:
        return {
          rankBgColor: $r('app.color.silver'),
          itemBgColor: $r('app.color.silver_light'),
          borderColor: $r('app.color.light_gray')
        };
      case 3:
        return {
          rankBgColor: $r('app.color.bronze'),
          itemBgColor: $r('app.color.bronze_light'),
          borderColor: $r('app.color.light_gray')
        };
      default:
        return {
          rankBgColor: $r('app.color.light_gray'),
          itemBgColor: $r('app.color.white'),
          borderColor: $r('app.color.light_gray')
        };
    }
  }

  // 纯UI构建：仅渲染组件，无任何逻辑计算（@Builder内无变量/函数调用）
  @Builder
  private _renderItem(item: RankingItem): void {
    Row() {
      // 排名（圆形背景）
      Text(item.rank.toString())
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.black')) // 正确API：fontColor
        .backgroundColor(item.styles.rankBgColor)
        .borderRadius(20);

      // 头像（确保资源存在：resources/base/media/avatar.png）
      Image('img/user.jpg') // 替换为项目中实际存在的头像资源名
        .width(48)
        .height(48)
        .margin({ left: 16, right: 16 })
        .objectFit(ImageFit.Cover)
        .borderRadius(24)
        .border({ width: 2, color: $r('app.color.gray') });

      // 玩家名称
      Text(item.name)
        .fontSize(18)
        .fontColor($r('app.color.black')) // 正确API：fontColor
        .flexGrow(1);

      // 关卡数
      Text(`${item.level} 关`)
        .fontSize(18)
        .fontColor($r('app.color.primary')) // 正确API：fontColor
        .fontWeight(FontWeight.Bold)
        .margin({ right: 16 });
    }
    .width('100%')
    .height(60)
    .padding({ left: 12, right: 12 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(item.styles.itemBgColor)
    .borderRadius(8)
    .border({ width: item.rank > 3 ? 1 : 0, color: item.styles.borderColor })
    .margin({ bottom: 8 });
  }

  // 页面根布局：仅包含UI组件，无任何逻辑
  build(): void {
    Column() {
      // 标题栏
      Row() {
        Text('数独排行榜')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.white'));
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.primary'))
      .justifyContent(FlexAlign.Center);

      // 排行榜列表
      List() {
        ForEach(
          this.rankingData,
          (item: RankingItem) => {
            ListItem() {
              this._renderItem(item);
            }
          },
          (item: RankingItem) => `${item.rank}-${item.name}` // 唯一Key，避免复用冲突
        );
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .divider({ strokeWidth: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'));
  }
}