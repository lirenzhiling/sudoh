import Want from '@ohos.app.ability.Want';
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { preferences } from '@kit.ArkData';

import { DatabaseHelper } from '../database/DatabaseHelper';
import { UserDataService } from '../services/UserDataService';
@Entry
@Component
struct Register {
  private context = getContext(this) as common.UIAbilityContext;
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();
  private userService: UserDataService = new UserDataService();
  // ... 其他已有状态

  aboutToAppear() {
    // 在组件即将出现时初始化数据库
    this.initDatabase();
  }

  private async initDatabase() {
    try {
      await this.dbHelper.initDatabase(this.context);
      console.log('Database initialized in Register page');
    } catch (err) {
      console.error('Failed to initialize database in Register page:', err);
      promptAction.showToast({ message: '数据库初始化失败', duration: 2000 });
    }
  }

  // 用户名和密码状态
  @State username: string = '';
  @State password: string = '';
  @State showPassword: boolean = false; // 控制密码显示/隐藏
  @State isLoading: boolean = false; // 加载状态

  // 页面布局
  build() {
    Column() {

      // 顶部品牌区域
      Column() {
        Text('注册账号')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text('请输入账号密码注册系统')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 8 })
      }
      .margin({ top: 80, bottom: 60 })
      .width('100%')

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
        Button('注册', { type: ButtonType.Capsule })
          .width('90%')
          .height(50)
          .backgroundColor('#409EFF')
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .enabled(!this.isLoading && this.username.length > 0 && this.password.length > 0)
          .onClick(() => {
            this.handleRegister();
          })
          .margin({ bottom: 20 })

        // 加载指示器
        if (this.isLoading) {
          LoadingProgress()
            .width(30)
            .height(30)
            .margin({ bottom: 20 })
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Center)
  }

  private async handleRegister() {
    // 简单验证
    if (this.username.trim().length === 0) {
      promptAction.showToast({ message: '请输入用户名', duration: 2000 });
      return;
    }

    if (this.password.length === 0) {
      promptAction.showToast({ message: '请输入密码', duration: 2000 });
      return;
    }

    this.isLoading = true;

    try {
      // 在实际注册前，可以先检查用户名是否存在（可选）
      // const exists = await this.userService.isUsernameExist(this.username);
      // if (exists) {
      //   promptAction.showToast({ message: '用户名已存在', duration: 2000 });
      //   this.isLoading = false;
      //   return;
      // }

      // 执行注册，插入用户数据到数据库
      await this.userService.insertUser(this.username, this.password);

      promptAction.showToast({ message: '注册成功', duration: 2000 });

      // 跳转到登录页
      router.pushUrl({ url: 'pages/Login' });
    } catch (error) {
      console.error('Registration error:', error);
      promptAction.showToast({ message: error.message || '注册失败，请重试', duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }

  // 模拟请求
  // private async mockLoginRequest(): Promise<void> {
  //   return new Promise((resolve, reject) => {
  //     setTimeout(() => {
  //       // 模拟成功（实际项目中根据接口返回判断）
  //       if (this.username === 'demo' && this.password === '123456') {
  //         resolve();
  //       } else {
  //         // 模拟其他情况都成功，实际项目中根据接口返回处理
  //         resolve();
  //       }
  //     }, 1500);
  //   });
  // }

}