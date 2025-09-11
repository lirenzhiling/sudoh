// 文件：database/DatabaseHelper.ets

import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

export class DatabaseHelper {
  private static instance: DatabaseHelper | null = null;
  private rdbStore: relationalStore.RdbStore | null = null;
  private readonly DB_NAME: string = 'user.db'; // 数据库名称
  private readonly TABLE_USER: string = 'users'; // 用户表名

  // 用户表SQL语句
  private readonly CREATE_TABLE_USER: string = `
    CREATE TABLE IF NOT EXISTS ${this.TABLE_USER} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      level INTEGER DEFAULT 0,
      created_time INTEGER DEFAULT (strftime('%s','now'))
    )`;

  static getInstance(): DatabaseHelper {
    if (!DatabaseHelper.instance) {
      DatabaseHelper.instance = new DatabaseHelper();
    }
    return DatabaseHelper.instance;
  }

  async initDatabase(context: common.UIAbilityContext): Promise<void> {
    if (this.rdbStore) {
      return; // 避免重复初始化
    }
    try {
      const storeConfig: relationalStore.StoreConfig = {
        name: this.DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1, // 根据数据敏感度选择安全级别[6](@ref)
      };
      this.rdbStore = await relationalStore.getRdbStore(context, storeConfig);
      await this.createUserTable();
      console.info('Database initialized successfully.');
    } catch (err) {
      console.error(`Failed to initialize database. Code: ${err.code}, message: ${err.message}`);
      throw err as Error; // 抛出异常以便调用方处理
    }
  }

  private async createUserTable(): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('RdbStore is not initialized.');
    }
    try {
      await this.rdbStore.executeSql(this.CREATE_TABLE_USER);
      console.info('User table created or already exists.');
    } catch (err) {
      console.error(`Failed to create user table. Code: ${err.code}, message: ${err.message}`);
      throw err as Error;
    }
  }

  getRdbStore(): relationalStore.RdbStore {
    if (!this.rdbStore) {
      throw new Error('RdbStore is not initialized. Call initDatabase first.');
    }
    return this.rdbStore;
  }

  async getUserLevel(username: string): Promise<number | undefined> {
    if (!this.rdbStore) {
      throw new Error('RdbStore is not initialized. Call initDatabase first.');
    }

    try {
      // 1. 构建查询条件：查询指定用户名的用户
      let predicates = new relationalStore.RdbPredicates(this.TABLE_USER);
      predicates.equalTo('username', username);

      // 2. 执行查询，只获取 'level' 列
      const resultSet = await this.rdbStore.query(predicates, ['level']);

      // 3. 处理结果集
      if (resultSet && resultSet.rowCount > 0) {
        resultSet.goToFirstRow(); // 移动到第一行
        const level = resultSet.getDouble(resultSet.getColumnIndex('level')); // 获取 level 列的值
        resultSet.close(); // 必须关闭结果集[6,8](@ref)
        return level;
      } else {
        console.warn(`User1111 '${username}' not found.`);
        resultSet?.close(); // 确保结果集被关闭
        return undefined;
      }
    } catch (err) {
      console.error(`Failed to query user level. Code: ${err.code}, message: ${err.message}`);
      throw err as Error;
    }
  }
  async incrementUserLevel(username: string): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('RdbStore is not initialized. Call initDatabase first.');
    }

    try {
      // 使用原始SQL语句进行更新
      const sql = `UPDATE ${this.TABLE_USER} SET level = level + 1 WHERE username = ?`;
      // 注意：此处假设你的数据库列名确为 'level'，表名已正确替换
      await this.rdbStore.executeSql(sql, [username]); // 将参数作为数组传递，防止SQL注入

      // 如果需要获取受影响的行数，可能需要再执行一次查询
      // 或者使用其他方式确认更新成功
      console.info(`User '${username}' level incremented via SQL.`);
      return 1; // 或根据实际情况返回受影响的行数

    } catch (err) {
      const error = err as Error;
      console.error(`Failed to increment user level. Code: ${error}, message: ${error.message}`);
      throw error as Error;
    }
  }
}