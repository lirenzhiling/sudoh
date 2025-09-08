// 文件：services/UserDataService.ets

import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from '../database/DatabaseHelper';

// 定义关系型数据库错误接口
interface RdbError {
  code: number;
  message: string;
}

export class UserDataService {
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();
  private readonly TABLE_USER: string = 'users';

  // 验证用户 credentials
  async verifyUser(username: string, password: string): Promise<boolean> {
    try {
      const rdbStore = this.dbHelper.getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.TABLE_USER);
      predicates.equalTo('username', username);

      const resultSet = await rdbStore.query(predicates, ['password']);

      if (resultSet.rowCount === 0) {
        resultSet.close();
        return false;
      }

      resultSet.goToFirstRow();
      const storedPassword = resultSet.getString(resultSet.getColumnIndex('password'));
      resultSet.close();

      // 使用相同的哈希方法验证
      const inputHashedPassword = this.simpleHash(password);
      return inputHashedPassword === storedPassword;

    } catch (error) {
      console.error('User verification failed:', error);
      return false;
    }
  }

  // 插入用户数据
  async insertUser(username: string, password: string): Promise<number> {
    const rdbStore = this.dbHelper.getRdbStore();

    // 一个非常简单的示例哈希函数（仅用于演示）
    const encryptedPassword = this.simpleHash(password);

    const valueBucket: relationalStore.ValuesBucket = {
      'username': username,
      'password': encryptedPassword,
    };

    try {
      const rowId = await rdbStore.insert(this.TABLE_USER, valueBucket);
      console.info(`User registered successfully. Row ID: ${rowId}`);
      return rowId;
    } catch (err) {
      const rdbError = err as RdbError;

      if (rdbError.code === 202) {
        console.error('Username already exists.');
        throw new Error('用户名已存在');
      } else {
        console.error(`Failed to insert user. Code: ${rdbError.code}, message: ${rdbError.message}`);
        throw new Error('注册失败，请重试');
      }
    }
  }

  // 检查用户名是否已存在
  async isUsernameExist(username: string): Promise<boolean> {
    const rdbStore = this.dbHelper.getRdbStore();
    try {
      // 使用 new 关键字创建 RdbPredicates 实例
      const predicates = new relationalStore.RdbPredicates(this.TABLE_USER);
      predicates.equalTo('username', username);
      const resultSet = await rdbStore.query(predicates, ['id']);
      const count = resultSet.rowCount;
      resultSet.close();
      return count > 0;
    } catch (err) {
      const rdbError = err as RdbError;
      console.error(`Failed to query username. Code: ${rdbError.code}, message: ${rdbError.message}`);
      return false;
    }
  }

  // 简单的示例哈希函数
  private simpleHash(input: string): string {
    return `hashed_${input}`; // 伪代码，实际请使用安全加密方法
  }
}