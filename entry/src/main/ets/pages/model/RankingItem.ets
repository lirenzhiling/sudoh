export interface RankStyles {
  rankBgColor: ResourceColor;
  itemBgColor: ResourceColor;
  borderColor: ResourceColor;
}

export interface RankingItem {
  rank: number;
  name: string;
  level: number;
  styles: RankStyles; // 预计算样式，@Builder直接使用
}