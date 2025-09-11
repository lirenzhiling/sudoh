// 文件：database/RankingDatabaseHelper.ets

import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from '../database/DatabaseHelper';
import { RankingItem,RankStyles } from '../pages/model/RankingItem';



// 玩家数据接口
interface PlayerData {
  id: number;
  username: string;
  level: number;
}


export class RankingDatabaseHelper {
  private dbHelper: DatabaseHelper; // 使用你已有的DatabaseHelper实例

  constructor(dbHelper: DatabaseHelper) {
    this.dbHelper = dbHelper;
  }

  /**
   * 获取所有玩家数据并按等级降序排列
   * @returns 按等级排序的玩家数据数组
   */
  async getAllPlayersByLevel(): Promise<PlayerData[]> {
    try {
      const rdbStore = this.dbHelper.getRdbStore();
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('users');

      // 设置排序条件：按level降序
      predicates.orderByDesc('level');

      // 指定要查询的列
      const columns: string[] = ['id', 'username', 'level'];

      const resultSet = await rdbStore.query(predicates, columns);
      const players: PlayerData[] = [];

      if (resultSet && resultSet.rowCount > 0) {
        let hasRow = resultSet.goToFirstRow();
        while (hasRow) {
          players.push({
            id: resultSet.getDouble(resultSet.getColumnIndex('id')),
            username: resultSet.getString(resultSet.getColumnIndex('username')),
            level: resultSet.getDouble(resultSet.getColumnIndex('level'))
          });
          hasRow = resultSet.goToNextRow();
        }
      }

      resultSet.close(); // 关闭结果集释放资源[3](@ref)
      return players;

    } catch (err) {
      console.error(`获取排行榜数据失败. Code: ${err.code}, message: ${err.message}`);
      throw err as Error;
    }
  }

  /**
   * 获取带排名的排行榜数据
   * @returns 包含排名信息的排行榜项数组
   */
  async getRankingWithOrder(): Promise<RankingItem[]> {
    const players = await this.getAllPlayersByLevel();

    // 为每位玩家添加排名信息
    return players.map((player, index): RankingItem => {
      // 创建符合 RankStyles 接口的样式对象
      const rankStyles: RankStyles = {
        rankBgColor: $r('app.color.light_gray'),
        itemBgColor: $r('app.color.white'),
        borderColor: $r('app.color.light_gray')
      };

      // 返回符合 RankingItem 接口的对象
      return {
        rank: index + 1, // 排名从1开始
        name: player.username,
        level: player.level,
        styles: rankStyles // 使用已创建的样式对象
      };
    });
  }

  /**
   * 获取前N名玩家（用于显示顶部排行榜）
   * @param limit 要获取的玩家数量
   * @returns 前N名玩家的排行榜数据
   */
  async getTopPlayers(limit: number = 10): Promise<RankingItem[]> {
    const allPlayers = await this.getRankingWithOrder();
    return allPlayers.slice(0, Math.min(limit, allPlayers.length));
  }

  /**
   * 获取指定玩家的排名及其周围玩家（用于显示玩家所在位置）
   * @param username 要查找的用户名
   * @param range 要显示的周围玩家范围
   * @returns 包含指定玩家及其周围玩家的排行榜数据
   */
  async getPlayerRankingContext(username: string, range: number = 2): Promise<RankingItem[]> {
    const allRankings = await this.getRankingWithOrder();
    const playerIndex = allRankings.findIndex(item => item.name === username);

    if (playerIndex === -1) {
      return []; // 玩家未找到
    }

    // 计算要显示的起始和结束索引
    const start = Math.max(0, playerIndex - range);
    const end = Math.min(allRankings.length, playerIndex + range + 1);

    return allRankings.slice(start, end);
  }
}