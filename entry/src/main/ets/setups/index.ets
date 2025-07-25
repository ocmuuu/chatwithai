/**
 * setups 模块统一导出
 * 提供应用初始化和配置相关的所有功能
 */

// 核心初始化模块
export { InitData } from './InitData';

// 设置管理模块
export { SettingsInit } from './SettingsInit';

// 默认配置模块
export { 
  AIProvider, 
  ChatMode, 
  ThemeMode, 
  Language,
  DEFAULT_MODELS,
  DEFAULT_PROVIDERS,
  DEFAULT_SETTINGS,
  getDefaultSettings,
  getSupportedModels,
  getWelcomeMessages,
  getSampleConversations,
  getRandomSessionName,
  getProviderConfig,
  getAllProviders,
  getProviderModels
} from './DefaultConfig';

// 类型定义
export type { AppSettings, ModelConfig, ProviderConfig } from './DefaultConfig'; 