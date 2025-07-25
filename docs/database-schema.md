# ChatwithAI 数据库设计

> 存储引擎：**RelationalStore** (SQLite Compatible)
>
> 数据库文件名：`ChatWithAI.db`

---

## 1️⃣ 表结构一览

| 表 | 主键 | 用途 |
|----|------|------|
| `sessions` | `id` | 会话元信息 |
| `messages` | `id` | 聊天消息记录 |
| `session_threads` | `id` | 子线程（分支对话） |
| `thread_messages` | `id` (auto) | 线程 ↔ 消息 多对多顺序映射 |
| `message_files` | `id` | 消息附件文件 |
| `message_links` | `id` | 消息中提及的外部链接 |
| `settings` | `key` | 全局键值配置 |
| `session_settings` | `session_id` | 单会话级别参数 |

---

## 2️⃣ 字段详解

### 2.1 `sessions`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | TEXT | UUIDv4 |
| `name` | TEXT | 会话标题（可由 AI 生成）|
| `type` | TEXT | `chat` / `picture` |
| `thread_name` | TEXT | 默认线程名称 |
| `created_at` | INTEGER | Epoch ms |
| `updated_at` | INTEGER | Epoch ms，列表排序依据 |
| `starred` | INTEGER | 0/1 收藏标记 |
| `avatar_key` | TEXT | 预留，用户头像存储键 |
| `pic_url` | TEXT | 预留，封面图 |

索引：`idx_sessions_updated_at` (`updated_at` DESC)

---

### 2.2 `messages`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | TEXT | UUIDv4 |
| `session_id` | TEXT | 外键 → `sessions.id` |
| `role` | TEXT | `user` / `assistant` / `system` |
| `content` | TEXT | Markdown or plain text |
| `content_parts` | TEXT | JSON 序列化的 `MessageContentPart[]` |
| `timestamp` | INTEGER | Epoch ms |
| `word_count` | INTEGER | 单词数（缓存） |
| `token_count` | INTEGER | LLM Token 数（缓存） |
| `generating` | INTEGER | 0/1 是否生成中 |
| `error_message` | TEXT | 调用失败的错误信息 |
| `error_code` | INTEGER | 错误码 |
| `ai_provider` | TEXT | 生成消息的平台标识 |
| `model` | TEXT | 使用的模型 |
| `first_token_latency` | INTEGER | 首 token 延迟(ms) |
| `tokens_used` | INTEGER | 消耗 token 数 |

索引：
- `idx_messages_session_id` (`session_id`)
- `idx_messages_timestamp` (`timestamp`)

---

### 2.3 `session_threads`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | TEXT | UUIDv4 |
| `session_id` | TEXT | 外键 → `sessions.id` |
| `name` | TEXT | 线程名称 |
| `created_at` | INTEGER | Epoch ms |

---

### 2.4 `thread_messages`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INTEGER | AUTOINCREMENT |
| `thread_id` | TEXT | 外键 → `session_threads.id` |
| `message_id` | TEXT | 外键 → `messages.id` |
| `message_order` | INTEGER | 保证顺序 |

---

### 2.5 `message_files`

存储文件元信息，文件本体存储于 Sandbox 下 MediaDir。

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | TEXT | UUIDv4 |
| `message_id` | TEXT | 外键 → `messages.id` |
| `name` | TEXT | 文件名 |
| `file_type` | TEXT | MIME 类型 |
| `storage_key` | TEXT | 文件实际路径或 OSS 键 |
| `file_size` | INTEGER | 字节 |
| `created_at` | INTEGER | Epoch ms |

---

### 2.6 `message_links`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | TEXT | UUIDv4 |
| `message_id` | TEXT | 外键 |
| `url` | TEXT | 链接地址 |
| `title` | TEXT | 网页标题（可抓取）|
| `storage_key` | TEXT | 预留：缓存快照 |
| `created_at` | INTEGER | Epoch ms |

---

### 2.7 `settings`

用于全局键值对，如当前 provider/model、UI 偏好等。

| 字段 | 类型 | 说明 |
|------|------|------|
| `key` | TEXT | PrimaryKey |
| `value` | TEXT | JSON 字符串 |
| `updated_at` | INTEGER | Epoch ms |

---

### 2.8 `session_settings`

每个会话可覆盖全局默认。

| 字段 | 类型 | 说明 |
|------|------|------|
| `session_id` | TEXT | PrimaryKey |
| `provider` | TEXT | 指定平台 |
| `model_id` | TEXT | 指定模型 |
| `max_context_message_count` | INTEGER | 上下文条数 |
| `temperature` | REAL | Temp 参数 |
| `top_p` | REAL | top_p 参数 |
| `image_generate_num` | INTEGER | DALL·E 专用 |
| `dalle_style` | TEXT | Style 参数 |

---

## 3️⃣ 版本管理

- 当前 `databaseVersion = 1`（见 `DatabaseHelper`）。
- 若未来变更：
  1. **递增** `databaseVersion`。
  2. 在 `onUpgrade(vOld, vNew)` 中编写迁移脚本。
  3. 保证向前兼容，避免数据丢失。

---

## 4️⃣ 数据导出

`DataService.exportData()` 会生成如下结构：

```ts
interface ExportData {
  sessions: ChatSession[];
  messages: MessagesBySession; // Map<sessionId, ChatMessage[]>
  settings: SettingsMap;      // Map<key, value>
  exportTime: number;
}
```

可序列化为 JSON 备份，未来支持加密与云同步。

---

如需新增表或字段，请同步更新：
1. `DatabaseHelper.createTables()` & 索引。
2. 对应 DAO & Model Interface。
3. `docs/database-schema.md` 本文件说明。 