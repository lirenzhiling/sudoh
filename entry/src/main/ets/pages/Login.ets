import Want from '@ohos.app.ability.Want';
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { preferences } from '@kit.ArkData';
import { DatabaseHelper } from '../database/DatabaseHelper'; // 导入数据库帮助类
import { UserDataService } from '../services/UserDataService'; // 导入用户服务
import relationalStore from '@ohos.data.relationalStore';

@Entry
@Component
struct Login {
  private context = getContext(this) as common.UIAbilityContext;
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();
  private userService: UserDataService = new UserDataService();

  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('username') myusername: string = '';

  // 用户名和密码状态
  @State username: string = '';
  @State password: string = '';
  @State showPassword: boolean = false;
  @State isLoading: boolean = false;
  @State errorMessage: string = ''; // 错误消息状态

  aboutToAppear() {
    // 初始化数据库
    this.initDatabase();
  }

  private async initDatabase() {
    try {
      await this.dbHelper.initDatabase(this.context);
      console.log('Database initialized in Login page');
    } catch (err) {
      console.error('Failed to initialize database:', err);
    }
  }

  build() {
    Column() {
      // 顶部品牌区域
      Column() {
        Text('欢迎登录')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text('请输入账号密码登录系统')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 8 })
      }
      .margin({ top: 80, bottom: 60 })
      .width('100%')

      // 错误消息显示
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#ff4d4f')
          .margin({ bottom: 20 })
          .width('90%')
      }

      // 表单区域
      Column() {
        // 用户名输入框
        TextInput({ placeholder: '请输入用户名' })
          .width('90%')
          .height(50)
          .type(InputType.Normal)
          .placeholderColor('#999999')
          .caretColor('#409EFF')
          .maxLength(20)
          .onChange((value: string) => {
            this.username = value;
            this.errorMessage = ''; // 清除错误信息
          })
          .margin({ bottom: 20 })
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding(10)

        // 密码输入框
        TextInput({ placeholder: '请输入密码' })
          .width('90%')
          .height(50)
          .type(this.showPassword ? InputType.Normal : InputType.Password)
          .placeholderColor('#999999')
          .caretColor('#409EFF')
          .maxLength(20)
          .onChange((value: string) => {
            this.password = value;
            this.errorMessage = ''; // 清除错误信息
          })
          .margin({ bottom: 10 })
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .padding(10)

        // 显示/隐藏密码切换
        Row() {
          Checkbox()
            .select(this.showPassword)
            .onChange((value: boolean) => {
              this.showPassword = value;
            })
          Text('显示密码')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 8 })
        }
        .width('90%')
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 30 })

        // 登录按钮
        Button('登录', { type: ButtonType.Capsule })
          .width('90%')
          .height(50)
          .backgroundColor('#409EFF')
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .enabled(!this.isLoading && this.username.length > 0 && this.password.length > 0)
          .onClick(() => {
            this.handleLogin();
          })
          .margin({ bottom: 20 })

        // 加载指示器
        if (this.isLoading) {
          LoadingProgress()
            .width(30)
            .height(30)
            .margin({ bottom: 20 })
        }

        // 注册链接
        Text('立即注册')
          .fontSize(14)
          .fontColor('#409EFF')
          .margin({ top: 20 })
          .onClick(() => {
            this.handleRegister();
          })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  // 登录处理逻辑
  private async handleLogin() {
    // 基本验证
    if (this.username.trim().length === 0) {
      this.errorMessage = '请输入用户名';
      return;
    }

    if (this.password.length === 0) {
      this.errorMessage = '请输入密码';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      // 使用数据库验证用户 credentials[1,3](@ref)
      const isValid = await this.verifyUserCredentials(this.username, this.password);

      if (isValid) {
        // 保存登录状态[1](@ref)
        await this.saveLoginStatus();

        this.isLoggedIn = true;
        this.myusername =this.username;
        promptAction.showToast({
          message: '登录成功',
          duration: 2000
        });

        // 跳转到主页[1,2,3](@ref)
        router.pushUrl({
          url: 'pages/Home'
        });
      } else {
        this.errorMessage = '用户名或密码错误';
        promptAction.showToast({
          message: '登录失败，请检查用户名和密码',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Login error:', error);
      this.errorMessage = '登录过程中发生错误，请重试';
      promptAction.showToast({
        message: '登录失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 验证用户凭据
  private async verifyUserCredentials(username: string, password: string): Promise<boolean> {
    try {
      const rdbStore = this.dbHelper.getRdbStore();

      // 构建查询条件[1](@ref)
      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('username', username);

      // 执行查询
      const resultSet = await rdbStore.query(predicates, ['password']);

      if (resultSet.rowCount === 0) {
        resultSet.close();
        return false; // 用户不存在
      }

      // 移动到第一行并获取存储的密码
      resultSet.goToFirstRow();
      const storedPassword = resultSet.getString(resultSet.getColumnIndex('password'));
      resultSet.close();

      // 验证密码（使用与注册时相同的哈希方法）
      const inputHashedPassword = this.simpleHash(password);
      return inputHashedPassword === storedPassword;

    } catch (error) {
      console.error('验证用户凭据失败:', error);
      return false;
    }
  }

  // 简单的哈希函数（与实际注册时使用的保持一致）
  private simpleHash(input: string): string {
    // 注意：这只是一个示例，实际项目中应该使用安全的哈希算法
    return `hashed_${input}`;
  }

  // 保存登录状态
  private async saveLoginStatus() {
    try {
      const options: preferences.Options = { name: 'userStore' };
      const dataPreference = await preferences.getPreferences(this.context, options);

      // 保存用户登录状态[1](@ref)
      await dataPreference.put('username', this.username);
      await dataPreference.put('isLoggedIn', true);
      await dataPreference.put('loginTime', new Date().getTime());
      await dataPreference.flush();

      console.info('登录状态保存成功');
    } catch (error) {
      console.error('保存登录状态失败:', error);
      throw error as Error;
    }
  }

  // 注册处理
  private handleRegister() {
    router.pushUrl({
      url: 'pages/Register'
    });
  }
}