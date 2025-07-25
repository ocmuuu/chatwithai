# ChatwithAI 对话助手

一款专为 HarmonyOS 设计的多平台 AI 对话应用，支持 OpenAI、Azure、Claude、Gemini、DeepSeek、Groq、Ollama 本地模型等多种大语言模型平台，提供专业级的多窗口对话管理与 Markdown 渲染体验。

## 📸 应用截图

<div align="center">
  <img src="docs/images/snap.png" alt="主界面" width="800">
</div>

<div align="center">
  <sub>三栏式主界面（会话列表 / 聊天记录 / 平台与模型选择器）</sub>
</div>

## ✨ 核心功能

### 💬 多平台 AI 对话
- **一键切换平台与模型**：内置十余种主流平台及模型，支持 context window、Vision、Tools 等能力标签显示
- **本地 LLM 支持**：通过 Ollama 或 LM-Studio 运行本地模型，无网络亦可对话
- **消息持久化**：所有会话与消息自动保存到本地数据库，断点续聊
- **自动生成会话标题**：AI 自动为新会话生成上下文相关标题
- **多格式 Markdown 渲染**：支持代码高亮、表格、列表、数学公式、任务清单等

### 🗂️ 会话管理
- **侧边栏折叠**：可折叠会话列表，专注聊天
- **拖拽调整宽度**：支持拖拽与双击复位，宽度自动保存
- **多会话并行**：无限会话数量，快速切换历史对话
- **快速创建 / 删除 / 清空**：一键新建会话或重置数据（开发者模式）

### ⚙️ 高级设置
- **平台 API Key 管理**：统一管理各平台密钥，离线安全存储
- **模型能力提示**：展示 Vision、Tools 支持与上下文窗口大小
- **首选项持久化**：平台、模型、侧边栏状态等 UI 偏好自动保存

## 💾 数据持久化
- **关系型数据库**：基于 RelationalStore 实现会话与消息表
- **增量更新**：仅写入变更字段，减少 I/O
- **事务安全**：批量操作使用事务，确保数据一致性

## 🛠️ 技术架构

### 开发环境
- **HarmonyOS SDK**：5.0.5(17)
- **开发语言**：TypeScript / ArkTS
- **架构模式**：Stage 模式
- **应用版本**：1.0.0
- **Bundle ID**：com.example.chatwithai

### 模块划分
```
entry/src/main/ets/
├── pages/              # 页面
│   ├── Index.ets          # 主界面
│   └── Platform.ets       # 平台设置
├── models/             # 数据模型
│   ├── ChatModels.ets     # 会话 / 消息定义
│   └── DatabaseHelper.ets # 数据库工具
├── services/           # 业务服务
│   ├── AIService.ets      # 调用大模型平台
│   └── DataService.ets    # 封装数据库 CRUD
├── setups/             # 初始化与默认配置
│   ├── DefaultConfig.ets   # 平台 / 模型清单
│   ├── InitData.ets       # 数据库初始化
│   └── SettingsInit.ets   # 设置初始化
└── utils/              # 工具类
    ├── MarkdownItRenderer.ets # Markdown 渲染
    └── PreferencesUtil.ets    # 偏好设置工具
```

## 🚀 快速开始

### 系统要求
- **操作系统**：HarmonyOS NEXT 或 HarmonyOS 4.0+
- **SDK 版本**：5.0.5(17) 及以上
- **网络连接**：使用在线模型时需网络，可选本地模型离线使用

### 安装部署

#### 方式一：源码编译
```bash
# 确保已安装 DevEco Studio 5.0+
# 克隆项目
git clone [项目地址]
cd ChatwithAI

# 编译 HAP
hvigor clean
hvigor assembleHap
```

#### 方式二：HAP 包安装
```bash
hdc install ChatwithAI.hap
```

## 📋 功能清单

### ✅ 已实现功能
- [x] 多平台 / 多模型切换
- [x] 本地 LLM 支持（Ollama / LM-Studio）
- [x] 三栏式响应式布局
- [x] 会话与消息持久化
- [x] AI 自动生成会话标题
- [x] Markdown 渲染（代码高亮 / 数学公式）
- [x] 侧边栏拖拽与折叠
- [x] 首选项持久化（Provider / Model / UI 状态）
- [x] 错误处理与重试提示
- [x] ArkTS 合规性严格类型

### 🔄 开发中功能
- [ ] 插件工具调用（Function Calling）
- [ ] 图像输入（Vision）完善交互
- [ ] Prompt 预设与共享

### 📅 规划功能
- [ ] 聊天记录导出（Markdown / JSON）
- [ ] 数据同步多设备
- [ ] 聊天搜索 / 过滤
- [ ] 多语言界面

## 💡 贡献指南

1. Fork 本仓库并创建特性分支：`git checkout -b feature/AmazingFeature`
2. 提交更改：`git commit -m 'Add some AmazingFeature'`
3. 推送分支：`git push origin feature/AmazingFeature`
4. 发起 Pull Request

> 欢迎提出 Issue 与 PR，共同完善 ChatwithAI！ 