# 详细设置指南

## 第一步：环境准备

### 1.1 安装Flutter
访问 [Flutter官网](https://flutter.dev) 下载并安装Flutter SDK

```bash
# 验证安装
flutter --version
flutter doctor
```

### 1.2 安装Android Studio或Android SDK
- 下载 [Android Studio](https://developer.android.com/studio)
- 或仅下载 [Android SDK命令行工具](https://developer.android.com/studio/command-line)

## 第二步：创建Firebase项目

### 2.1 访问Firebase控制台
1. 打开 [https://console.firebase.google.com](https://console.firebase.google.com)
2. 用Google账号登录
3. 点击 "创建项目"
4. 项目名称: `ticket-wallet`
5. 完成创建

### 2.2 启用服务

#### Firestore数据库
1. 在左侧菜单找到 "Firestore数据库"
2. 点击 "创建数据库"
3. 选择 **测试模式** (开发用)
4. 地点选择最近的
5. 完成创建

#### Cloud Storage
1. 在左侧菜单找到 "Storage"
2. 点击 "开始使用"
3. 接受默认设置完成创建

## 第三步：添加Android应用

### 3.1 在Firebase中注册Android应用
1. 在项目设置页面，点击 "添加应用" → "Android"
2. 填写以下信息：
   - Android包名: `com.example.ticket_wallet`
   - 应用昵称: `Ticket Wallet`
   - SHA-1证书指纹: 输入 `keytool -list -v -keystore ~/.android/debug.keystore` 的结果（默认密码: android）

### 3.2 下载配置文件
1. 完成包名注册后，下载 `google-services.json`
2. 将文件放入: `ticket-wallet/android/app/` 目录

## 第四步：项目配置

### 4.1 克隆项目
```bash
git clone https://github.com/yangxwchina/ticket-wallet.git
cd ticket-wallet
```

### 4.2 获取依赖
```bash
flutter pub get
```

### 4.3 更新Firebase配置
编辑 `lib/firebase_options.dart`：

```dart
// 从google-services.json获取以下值：
static const FirebaseOptions android = FirebaseOptions(
  apiKey: '替换为你的API密钥',
  appId: '替换为你的App ID',
  messagingSenderId: '替换为你的Messaging Sender ID',
  projectId: '替换为你的Project ID',
  storageBucket: '替换为你的Storage Bucket',
);
```

**如何获取这些值**：
1. 打开下载的 `google-services.json`
2. 查找以下字段：
   - `apiKey`: 搜索 `"api_key"` 中的 `"current_key"`
   - `appId`: 搜索 `"mobile_sdk_app_id"`
   - `messagingSenderId`: 搜索 `"project_number"`
   - `projectId`: 搜索 `"project_id"`
   - `storageBucket`: 搜索 `"storage_bucket"`

## 第五步：设置Firestore安全规则

### 5.1 进入Firestore规则编辑器
1. Firebase Console → Firestore Database → 规则标签页
2. 替换为以下规则：

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tickets/{document=**} {
      allow read, write: if true;  // 测试模式
    }
  }
}
```

**⚠️ 安全提醒**: 上面的规则仅用于开发/测试。生产环境应该添加用户认证：

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tickets/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5.2 发布规则
点击 "发布" 按钮

## 第六步：设置Storage安全规则

### 6.1 进入Storage规则编辑器
1. Firebase Console → Storage → 规则标签页
2. 替换为以下规则：

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /tickets/{allPaths=**} {
      allow read, write: if true;  // 测试模式
    }
  }
}
```

**生产环境规则**：
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /tickets/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == userId;
    }
  }
}
```

### 6.2 发布规则
点击 "发布" 按钮

## 第七步：运行应用

### 7.1 检查Android设备
```bash
flutter devices
```

#### 选项A: 使用物理手机
1. 用USB连接Android手机
2. 在手机上启用"开发者选项"和"USB调试"
3. 允许计算机调试

#### 选项B: 使用Android模拟器
```bash
# 打开Android Studio，点击 AVD Manager 创建虚拟设备
# 或使用命令行
emulator -avd device_name
```

### 7.2 运行应用
```bash
flutter run
```

应用应该在30秒内启动。

## 第八步：构建发布版本

### 8.1 生成签名密钥
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10950 \
  -alias upload
```

### 8.2 配置签名
编辑 `android/app/build.gradle`：

```gradle
signingConfigs {
  release {
    keyAlias 'upload'
    keyPassword 'your-key-password'
    storeFile file('/path/to/upload-keystore.jks')
    storePassword 'your-store-password'
  }
}

buildTypes {
  release {
    signingConfig signingConfigs.release
  }
}
```

### 8.3 构建APK
```bash
flutter build apk --release
```

APK文件位于: `build/app/outputs/flutter-apk/app-release.apk`

## 故障排除

### 问题1: 找不到android SDK
```bash
flutter config --android-sdk /path/to/android/sdk
```

### 问题2: 依赖获取失败
```bash
flutter clean
flutter pub get
```

### 问题3: Firebase配置错误
- 检查 `google-services.json` 是否在 `android/app/` 目录
- 检查 `firebase_options.dart` 中的字段是否正确
- 运行 `flutter clean` 并重新构建

### 问题4: 上传失败
- 检查网络连接
- 检查Firestore和Storage规则
- 查看 `flutter run -v` 的错误日志

## 下一步

- 📚 查看 [README.md](README.md) 了解应用功能
- 🎨 自定义应用主题和颜色
- 🔐 实现用户认证（Firebase Auth）
- 🚀 部署到Google Play

## 帮助和支持

- Flutter文档: https://flutter.dev/docs
- Firebase文档: https://firebase.google.com/docs
- GitHub Issues: https://github.com/yangxwchina/ticket-wallet/issues
