# ChatwithAI 架构概览

> 本文档聚焦技术架构与模块职责，帮助开发者快速定位代码位置。

---

## 1️⃣ 分层视图

```
┌───────────────────────────────────┐
│            UI Pages              │ ← ArkUI 组件（pages/*）
└──────────────┬────────────────────┘
               │ 事件 / 状态
┌──────────────┴────────────────────┐
│          Service Layer           │ ← AIService / DataService
└──────────────┬────────────────────┘
               │ DAO 调用 / Provider 调用
┌──────────────┴────────────────────┐
│           Data Access            │ ← *Dao.ets & DatabaseHelper
└──────────────┬────────────────────┘
               │ RDB SQL
┌──────────────┴────────────────────┐
│           RelationalStore         │
└───────────────────────────────────┘
```

- **UI 层**：ArkUI 声明式界面，`EntryAbility` 加载 `Index.ets`，通过 `@State` 实现数据响应。
- **Service 层**：业务逻辑集中于 `AIService`（LLM 调用）与 `DataService`（聚合 DAO 并简化调用）。
- **DAO 层**：每张表对应一个 *Dao，封装增删改查。
- **数据层**：`DatabaseHelper` 负责数据库初始化 & 版本迁移。

---

## 2️⃣ 关键流程

### 2.1 应用启动
1. `EntryAbility.ets.aboutToAppear()` → 初始化 `PreferencesUtil`。
2. `DataService.initialize()` → `DatabaseHelper.initDatabase()` 创建表。
3. `AIService.initialize()` 加载默认 Provider & Model。
4. 加载会话列表并渲染 UI。

### 2.2 发送消息序列

```mermaid
sequenceDiagram
    actor User
    participant IndexPage as Index.ets
    participant DataSvc as DataService
    participant Db as RelationalStore
    participant AI as AIService

    User ->> IndexPage: 输入内容
    IndexPage ->> DataSvc: createMessage(role="user")
    DataSvc ->> Db: INSERT messages
    IndexPage -- push --> UI: 更新列表
    Note over IndexPage: 创建临时 loading 消息
    IndexPage ->> AI: sendMessage(messages)
    AI ->> ProviderSDK: HTTP / WS 调用
    ProviderSDK -->> AI: 回复内容
    AI -->> IndexPage: 返回字符串
    IndexPage ->> DataSvc: createMessage(role="assistant")
    DataSvc ->> Db: INSERT messages
    IndexPage -- push --> UI: 更新列表
```

### 2.3 自动生成会话标题
- 在 AI 回复写入数据库后，若会话名仍为 `新对话`，`AIService.generateTitle()` 调用 LLM 生成摘要，随后 `DataService.updateSession()` 更新 `sessions` 表。

---

## 3️⃣ 组件职责

| 目录 | 组件 | 说明 |
|------|------|------|
| pages | `Index.ets` | 主界面（对话列表 + 聊天区） |
| pages | `Platform.ets` | 平台/API Key 设置页 |
| services | `AIService` | 封装对多家 LLM 平台的请求流程 |
| services | `DataService` | 聚合各 DAO，提供更高阶数据操作 |
| models | `*Dao.ets` | 表级别 CRUD |
| models | `ChatModels.ets` | TypeScript 类型声明 |
| setups | `DefaultConfig.ets` | Provider & Model 静态数据 |
| utils | `PreferencesUtil` | ArkTS 偏好设置封装 |
| utils | `MarkdownItRenderer` | Markdown + 代码高亮 |

---

## 4️⃣ AIService 设计

```
AIService
├─ providers/
│  ├─ openai.ts
│  ├─ azure.ts
│  └─ ...
└─ sendMessage(history, prompt)
    ├─ 根据 currentProvider 选中适配器
    ├─ 构造 payload（stream / completion）
    ├─ 处理异常 & 超时
    └─ 返回纯文本/Markdown
```

- 新增 Provider 时实现 `IProvider` 接口并注册到 `providersMap`。
- 本地模型（Ollama / LM-Studio）通过本地 HTTP 端口调用。

---

## 5️⃣ 状态持久化

| 类型 | 存储 | 说明 |
|------|------|------|
| 会话/消息 | RelationalStore | 断点续聊 |
| UI 偏好 | `PreferencesUtil` | 使用 `LocalStorage` 实现 |
| API Key | 安全存储 | HarmonyOS Keychain，未纳入 RDB |

---

## 6️⃣ 扩展点

1. **Function Calling**：在 `AIService` 中解析工具调用 JSON 并路由到 ArkTS 能力。
2. **Vision**：在消息 `contentParts` 中新增 `type="image"` 并在前端渲染。
3. **多语言**：扩展 `resources/base/element/string.json` 并使用 `I18n` API。

---

如需更深入的讨论，请在 PR 或 Issue 中提出。 