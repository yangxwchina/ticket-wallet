# Supabase 电子票夹 - 设置指南

这个版本使用 **Supabase** 作为后端，完全支持在中国大陆使用！

## 🌐 为什么选择Supabase？

✅ **在中国大陆完全可用** - 无需科学上网
✅ **开源后端即服务** - PostgreSQL数据库
✅ **实时功能** - 支持WebSocket实时同步
✅ **强大的身份验证** - 内置用户管理
✅ **对象存储** - 存储PDF文件
✅ **免费额度充足** - 适合个人项目

---

## 🚀 项目配置

### 1. Supabase项目信息

你已经拥有一个Supabase项目：
```
URL: https://kkuqgvxisowbavnnxisb.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrdXFndnhpc293YmF2bm54aXNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2NjEyNDEsImV4cCI6MjA5NzIzNzI0MX0.lGupsicMin0ADWRZQiArzzCbmShN9KbaCr4cgnZhLy0
```

这些值已自动配置在 `lib/main.dart` 中。

### 2. 创建数据库表

在 [Supabase Dashboard](https://supabase.com/dashboard) 中，打开 SQL编辑器并执行以下SQL：

```sql
-- 创建tickets表
create table tickets (
  id bigint primary key generated always as identity,
  name text not null,
  category text not null default '其他',
  file_url text not null,
  user_id text not null default 'anonymous',
  description text,
  location text,
  event_date date,
  uploaded_at timestamp default now(),
  created_at timestamp default now()
);

-- 添加索引以提高查询性能
create index idx_tickets_user_id on tickets(user_id);
create index idx_tickets_category on tickets(category);
create index idx_tickets_uploaded_at on tickets(uploaded_at desc);

-- 启用行级安全 (可选，用于用户隔离)
alter table tickets enable row level security;

create policy "Users can see their own tickets"
  on tickets for select
  using (user_id = current_user_id() or user_id = 'anonymous');

create policy "Users can insert their own tickets"
  on tickets for insert
  with check (user_id = current_user_id() or user_id = 'anonymous');

create policy "Users can delete their own tickets"
  on tickets for delete
  using (user_id = current_user_id() or user_id = 'anonymous');
```

### 3. 创建存储桶

1. 在Supabase Dashboard，进入 **Storage**
2. 创建新的公共存储桶，命名为 `tickets`
3. 点击创建

### 4. 配置存储权限

在存储桶的 **Policies** 标签中，添加以下规则：

```sql
-- 允许任何人上传
create policy "Allow uploads"
  on storage.objects for insert
  with check (bucket_id = 'tickets');

-- 允许公开访问
create policy "Allow public access"
  on storage.objects for select
  using (bucket_id = 'tickets');

-- 允许删除自己的文件
create policy "Allow deletes"
  on storage.objects for delete
  using (bucket_id = 'tickets');
```

---

## 💻 本地开发

### 1. 克隆项目
```bash
git clone https://github.com/yangxwchina/ticket-wallet.git
cd ticket-wallet
```

### 2. 安装依赖
```bash
flutter pub get
```

### 3. 运行应用
```bash
# 连接Android手机或启动模拟器
flutter devices

# 运行应用
flutter run
```

---

## 📱 应用功能

| 功能 | 说明 |
|------|------|
| ➕ 上传 | 选择PDF文件上传到Supabase Storage |
| 🏷️ 分类 | 演唱会、飞机、火车、电影、展览等 |
| 🔍 搜索 | 搜索门票名称、地点、描述 |
| 📅 日期 | 记录活动日期和地点 |
| ☁️ 同步 | 所有数据自动保存到Supabase |
| 📄 查看 | 直接在应用中查看PDF |
| 🗑️ 删除 | 删除不需要的门票 |

---

## 🔐 安全性

### 当前配置（开发模式）
- 允许匿名用户上传和访问

### 生产环境建议
1. **启用用户认证**
   - 添加登录页面
   - 实现Supabase Auth
   - 使用 `auth.currentUser?.id` 隔离用户数据

2. **启用RLS (行级安全)**
   - 见上面的SQL示例
   - 确保用户只能访问自己的数据

3. **配置CORS**
   - 在Supabase设置中配置allowed origins

---

## 🚀 构建发布版本

### 生成APK
```bash
flutter build apk --release
```

### 生成App Bundle (Google Play)
```bash
flutter build appbundle --release
```

---

## 📚 参考资源

- [Supabase 官方文档](https://supabase.com/docs)
- [Supabase Flutter 指南](https://supabase.com/docs/guides/with-flutter)
- [Flutter官方文档](https://flutter.dev/docs)

---

## ⚠️ 常见问题

### Q: 能在中国使用吗？
A: ✅ 完全可以。Supabase在全球CDN上运行，中国大陆可直接访问。

### Q: 免费额度是多少？
A: 
- 数据库：500MB
- 文件存储：1GB
- API调用：无限制
- 足够个人使用

### Q: 如何备份数据？
A: Supabase自动备份。访问 Dashboard → Backups 查看备份历史。

### Q: 支持离线访问吗？
A: 当前不支持，但可以通过以下方式添加：
- 使用 `hive` 或 `sqflite` 本地缓存
- 实现离线-同步机制

---

## 💡 后续改进建议

1. ✅ 添加用户认证
2. ✅ 实现黑暗主题
3. ✅ 添加二维码识别
4. ✅ 支持票夹导入/导出
5. ✅ 离线模式
6. ✅ 门票分享功能

---

## 📞 技术支持

有问题？检查以下内容：

1. **网络连接** - 确保能访问 supabase.co
2. **凭证正确** - 检查 URL 和 Key
3. **表结构** - 确保已创建 tickets 表
4. **权限配置** - 检查Storage和RLS策略

有任何问题欢迎提Issue！
