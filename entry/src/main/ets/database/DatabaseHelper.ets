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
}