# ChatwithAI 开发指南

> 本文面向开发者，帮助快速理解并参与 ChatwithAI 项目开发。

---

## 1️⃣ 环境准备

| 组件 | 推荐版本 | 说明 |
|------|----------|------|
| HarmonyOS SDK | `5.0.5(17)` 及以上 | DevEco Studio 自带 |
| DevEco Studio | `5.0` 及以上 | IDE，支持 ArkTS 调试 |
| Node.js | `>=16` | hvigor 使用 |
| hvigor | 随 DevEco 安装 | HarmonyOS 构建工具 |
| Git | 最新 | 版本控制 |

### 1.1 安装步骤
1. 从 [官方站点](https://developer.harmonyos.com/cn) 下载并安装 DevEco Studio。
2. 在 **SDK Manager** 中安装 `HarmonyOS NEXT` 或目标设备兼容的 SDK Platform。
3. 安装 Node.js：`https://nodejs.org/zh-cn/download/`。
4. 配置 `HARMONY_SDK_HOME` 环境变量（可选）。

---

## 2️⃣ 项目结构

```
ChatwithAI/
├── entry/                # 主模块
│   └── src/main/ets/
│       ├── pages/        # UI 页面
│       ├── models/       # 数据模型 & DAO
│       ├── services/     # 业务服务
│       ├── setups/       # 初始化 & 默认配置
│       └── utils/        # 工具类
├── docs/                 # 开发/设计文档
├── hvigorfile.ts         # 构建脚本入口
└── build-profile.json5   # 构建配置
```

> 建议阅读 [`docs/architecture.md`](architecture.md) 了解完整架构分层。

---

## 3️⃣ 构建与运行

```bash
# 清理输出
hvigor clean
# 构建 Debug HAP
hvigor assembleHap -p entry -m debug
# 连接设备/模拟器后安装并运行
hdc install -r entry/build/outputs/hap/debug/*.hap
```

### 3.1 运行时配置
- 默认数据库文件：`ChatWithAI.db` 存储于应用沙箱。
- AI 平台密钥：首次运行跳转「设置」页面进行配置，保存于安全存储，不纳入版本控制。

---

## 4️⃣ 调试技巧

| 场景 | 方法 |
|------|------|
| 查看 SQL 执行 | 调试窗口过滤 `Sql` 关键字 |
| 打印复杂对象 | `console.info(JSON.stringify(obj, null, 2))` |
| UI 层性能 | DevEco Studio > Profiler > UI | 
| 长日志折叠 | 使用 `console.group/console.groupEnd` |

> ArkTS 运行时抛出的异常堆栈对行号并不友好，可使用 **SourceMap** 模式在 DevEco Studio 中还原。

---

## 5️⃣ 代码规范

1. **严格类型**：开启 `strict`、避免 `any`。
2. **命名约定**：
   - 文件使用 `PascalCase.ets` / `camelCase.ts`。
   - 类/接口 `PascalCase`，变量/函数 `camelCase`。
3. **空值处理**：优先使用 `??` / 可选链 `?.`。
4. **日志级别**：`info` > `warn` > `error`，禁止遗留 `console.log`。
5. **提交信息**：遵循 `feat/fix/docs/chore/refactor/test` + 描述。
6. **Lint**：执行 `hvigor lint`（配置见 `code-linter.json5`）。

---

## 6️⃣ 单元测试

- 框架：`@ohos.testRunner` + `ArkTS test`。
- 目录：`entry/src/main/test/`、`entry/src/mock/`。
- 运行：DevEco Studio > **Run > Run Tests**。
- 覆盖率：待集成 Jacoco ArkTS 支持。

示例：
```ts
// 12:34:entry/src/test/List.test.ets
@UnitTest
export default class ListTest {
  @Test
  testPush() {
    const list: number[] = [];
    list.push(1);
    expect(list.length).assertEqual(1);
  }
}
```

---

## 7️⃣ 数据库迁移

- 首次安装时执行 `DatabaseHelper.createTables()` 创建所有表。
- 未来升级需增加 `databaseVersion` 并在 `onUpgrade()` 中写迁移 SQL。
- 避免 **破坏性变更**，如需删除列请使用新表+迁移数据方案。

> 详细结构见 [`docs/database-schema.md`](database-schema.md)。

---

## 8️⃣ 常见开发任务

| 任务 | 步骤简述 |
|------|----------|
| 新增 AI 平台 | 1) 编辑 `setups/DefaultConfig.ets` 新增 `ProviderConfig`.<br/>2) 在 `AIService` 中实现发送逻辑或适配新 SDK。|
| 新增模型 | 同上，更新 `ModelConfig` 数组并标注 `supportVision` / `supportTools`。|
| 修改 UI 主题 | `resources/` 目录的 `color.json`、`float.json` 配置。|
| 重置应用数据 | 运行 UI 上的「重置数据」按钮或调用 `InitData.resetAppData()`。|

---

## 9️⃣ 发布流程

1. `hvigor clean && hvigor assembleHap -p entry -m release` 生成 **release** 包。
2. 使用 `hap-sign` 进行签名，确保证书与线上一致。
3. 通过 **AppGallery Connect** 上传并填写元数据。
4. 通过 **Beta** 通道进行灰度分发。

---

## 0️⃣ FAQ

- **Q**：模拟器无法联网？
  **A**：检查 DevEco Studio > Tools > HTTP Proxy 设置，或启用 Wi-Fi 网络。
- **Q**：AI 请求超时？
  **A**：确认 API Key 正确，且在企业/校园网需配置代理。

---

如有任何疑问请在 Issues 中讨论或加入微信群共同交流。 