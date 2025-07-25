import preferences from '@ohos.data.preferences';
import { AppSettings, getDefaultSettings, AIProvider, ThemeMode, Language } from './DefaultConfig';

/**
 * 用户配置接口
 */
export interface UserConfig {
  // DeepSeek 配置
  deepseek_api_key?: string;
  deepseek_base_url?: string;
  deepseek_model?: string;
  
  // OpenAI 配置
  openai_api_key?: string;
  openai_base_url?: string;
  openai_model?: string;
  
  // Claude 配置
  claude_api_key?: string;
  claude_base_url?: string;
  claude_model?: string;
  
  // Gemini 配置
  gemini_api_key?: string;
  gemini_base_url?: string;
  gemini_model?: string;
  
  // 其他平台配置
  siliconflow_api_key?: string;
  volcengine_api_key?: string;
  xai_api_key?: string;
  groq_api_key?: string;
  chatglm_api_key?: string;
}

/**
 * 导出数据接口
 */
export interface ExportData {
  settings: AppSettings;
  exportTime: number;
  version: string;
}

/**
 * 应用设置初始化管理
 */
export class SettingsInit {
  private static readonly SETTINGS_PREFERENCES_NAME = 'app_settings';
  private static readonly USER_PREFERENCES_NAME = 'user_preferences';

  /**
   * 初始化应用设置
   */
  public static async initializeSettings(context: Context): Promise<AppSettings> {
    try {
      const settingsPrefs = await preferences.getPreferences(context, SettingsInit.SETTINGS_PREFERENCES_NAME);
      
      // 检查是否已有设置
      const hasSettings = await settingsPrefs.has('initialized');
      
      if (!hasSettings) {
        // 首次初始化，使用默认设置
        const defaultSettings = getDefaultSettings();
        await SettingsInit.saveSettings(context, defaultSettings);
        console.info('应用设置初始化完成，使用默认配置');
        return defaultSettings;
      } else {
        // 加载现有设置
        const settings = await SettingsInit.loadSettings(context);
        console.info('加载现有应用设置');
        return settings;
      }
    } catch (error) {
      console.error('设置初始化失败:', error);
      // 如果加载失败，返回默认设置
      return getDefaultSettings();
    }
  }

  /**
   * 保存应用设置
   */
  public static async saveSettings(context: Context, settings: AppSettings): Promise<void> {
    try {
      const settingsPrefs = await preferences.getPreferences(context, SettingsInit.SETTINGS_PREFERENCES_NAME);
      
      // AI配置
      await settingsPrefs.put('defaultProvider', settings.defaultProvider);
      await settingsPrefs.put('defaultModel', settings.defaultModel);
      await settingsPrefs.put('temperature', settings.temperature);
      await settingsPrefs.put('maxTokens', settings.maxTokens);
      await settingsPrefs.put('maxContextMessages', settings.maxContextMessages);
      
      // UI配置
      await settingsPrefs.put('theme', settings.theme);
      await settingsPrefs.put('language', settings.language);
      await settingsPrefs.put('fontSize', settings.fontSize);
      await settingsPrefs.put('showWordCount', settings.showWordCount);
      await settingsPrefs.put('showTokenCount', settings.showTokenCount);
      
      // 聊天配置
      await settingsPrefs.put('autoSave', settings.autoSave);
      await settingsPrefs.put('enableMarkdown', settings.enableMarkdown);
      await settingsPrefs.put('enableCodeHighlight', settings.enableCodeHighlight);
      await settingsPrefs.put('sendOnEnter', settings.sendOnEnter);
      
      // 隐私配置
      await settingsPrefs.put('allowTracking', settings.allowTracking);
      await settingsPrefs.put('saveHistory', settings.saveHistory);
      
      // 标记为已初始化
      await settingsPrefs.put('initialized', true);
      await settingsPrefs.put('lastUpdated', Date.now());
      
      await settingsPrefs.flush();
      console.info('应用设置保存成功');
    } catch (error) {
      console.error('保存设置失败:', error);
      throw new Error('保存设置失败');
    }
  }

  /**
   * 加载应用设置
   */
  public static async loadSettings(context: Context): Promise<AppSettings> {
    try {
      const settingsPrefs = await preferences.getPreferences(context, SettingsInit.SETTINGS_PREFERENCES_NAME);
      const defaultSettings = getDefaultSettings();
      
      const settings: AppSettings = {
        // AI配置
        defaultProvider: await settingsPrefs.get('defaultProvider', defaultSettings.defaultProvider) as AIProvider,
        defaultModel: await settingsPrefs.get('defaultModel', defaultSettings.defaultModel) as string,
        temperature: await settingsPrefs.get('temperature', defaultSettings.temperature) as number,
        maxTokens: await settingsPrefs.get('maxTokens', defaultSettings.maxTokens) as number,
        maxContextMessages: await settingsPrefs.get('maxContextMessages', defaultSettings.maxContextMessages) as number,
        
        // UI配置
        theme: await settingsPrefs.get('theme', defaultSettings.theme) as ThemeMode,
        language: await settingsPrefs.get('language', defaultSettings.language) as Language,
        fontSize: await settingsPrefs.get('fontSize', defaultSettings.fontSize) as number,
        showWordCount: await settingsPrefs.get('showWordCount', defaultSettings.showWordCount) as boolean,
        showTokenCount: await settingsPrefs.get('showTokenCount', defaultSettings.showTokenCount) as boolean,
        
        // 聊天配置
        autoSave: await settingsPrefs.get('autoSave', defaultSettings.autoSave) as boolean,
        enableMarkdown: await settingsPrefs.get('enableMarkdown', defaultSettings.enableMarkdown) as boolean,
        enableCodeHighlight: await settingsPrefs.get('enableCodeHighlight', defaultSettings.enableCodeHighlight) as boolean,
        sendOnEnter: await settingsPrefs.get('sendOnEnter', defaultSettings.sendOnEnter) as boolean,
        
        // 隐私配置
        allowTracking: await settingsPrefs.get('allowTracking', defaultSettings.allowTracking) as boolean,
        saveHistory: await settingsPrefs.get('saveHistory', defaultSettings.saveHistory) as boolean
      };
      
      return settings;
    } catch (error) {
      console.error('加载设置失败:', error);
      return getDefaultSettings();
    }
  }

  /**
   * 更新特定设置项
   */
  public static async updateSetting(context: Context, key: string, value: string | number | boolean): Promise<void> {
    try {
      const settingsPrefs = await preferences.getPreferences(context, SettingsInit.SETTINGS_PREFERENCES_NAME);
      await settingsPrefs.put(key, value);
      await settingsPrefs.put('lastUpdated', Date.now());
      await settingsPrefs.flush();
      console.info(`设置项 ${key} 更新成功`);
    } catch (error) {
      console.error(`更新设置项 ${key} 失败:`, error);
      throw new Error(`更新设置项 ${key} 失败`);
    }
  }

  /**
   * 重置为默认设置
   */
  public static async resetToDefault(context: Context): Promise<AppSettings> {
    try {
      const defaultSettings = getDefaultSettings();
      await SettingsInit.saveSettings(context, defaultSettings);
      console.info('设置已重置为默认值');
      return defaultSettings;
    } catch (error) {
      console.error('重置设置失败:', error);
      throw new Error('重置设置失败');
    }
  }

  /**
   * 保存用户个人配置（如API密钥等敏感信息）
   */
  public static async saveUserConfig(context: Context, config: UserConfig): Promise<void> {
    try {
      const userPrefs = await preferences.getPreferences(context, SettingsInit.USER_PREFERENCES_NAME);
      
      const keys = Object.keys(config);
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        let value: string | undefined;
        if (key === 'deepseek_api_key') {
          value = config.deepseek_api_key;
        } else if (key === 'deepseek_base_url') {
          value = config.deepseek_base_url;
        } else if (key === 'deepseek_model') {
          value = config.deepseek_model;
        }
        
        if (value !== undefined) {
          await userPrefs.put(key, value);
        }
      }
      
      await userPrefs.put('lastUpdated', Date.now());
      await userPrefs.flush();
      console.info('用户配置保存成功');
    } catch (error) {
      console.error('保存用户配置失败:', error);
      throw new Error('保存用户配置失败');
    }
  }

  /**
   * 加载用户个人配置
   */
  public static async loadUserConfig(context: Context, keys: string[]): Promise<UserConfig> {
    try {
      const userPrefs = await preferences.getPreferences(context, SettingsInit.USER_PREFERENCES_NAME);
      const config: UserConfig = {};
      
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        if (key === 'deepseek_api_key') {
          config.deepseek_api_key = await userPrefs.get(key, '') as string;
        } else if (key === 'deepseek_base_url') {
          config.deepseek_base_url = await userPrefs.get(key, '') as string;
        } else if (key === 'deepseek_model') {
          config.deepseek_model = await userPrefs.get(key, '') as string;
        }
      }
      
      return config;
    } catch (error) {
      console.error('加载用户配置失败:', error);
      const emptyConfig: UserConfig = {};
      return emptyConfig;
    }
  }

  /**
   * 清除用户个人配置
   */
  public static async clearUserConfig(context: Context): Promise<void> {
    try {
      const userPrefs = await preferences.getPreferences(context, SettingsInit.USER_PREFERENCES_NAME);
      await userPrefs.clear();
      await userPrefs.flush();
      console.info('用户配置已清除');
    } catch (error) {
      console.error('清除用户配置失败:', error);
      throw new Error('清除用户配置失败');
    }
  }

  /**
   * 导出设置配置
   */
  public static async exportSettings(context: Context): Promise<string> {
    try {
      const settings = await SettingsInit.loadSettings(context);
      const exportData: ExportData = {
        settings: settings,
        exportTime: Date.now(),
        version: '1.0.0'
      };
      return JSON.stringify(exportData, null, 2);
    } catch (error) {
      console.error('导出设置失败:', error);
      throw new Error('导出设置失败');
    }
  }

  /**
   * 导入设置配置
   */
  public static async importSettings(context: Context, configJson: string): Promise<AppSettings> {
    try {
      const importData = JSON.parse(configJson) as ExportData;
      
      if (!importData.settings) {
        throw new Error('无效的配置文件格式');
      }
      
      const settings = importData.settings;
      await SettingsInit.saveSettings(context, settings);
      console.info('设置导入成功');
      return settings;
    } catch (error) {
      console.error('导入设置失败:', error);
      throw new Error('导入设置失败');
    }
  }
} 