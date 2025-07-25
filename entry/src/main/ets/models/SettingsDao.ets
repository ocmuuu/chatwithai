import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { Setting, SettingsMap } from './ChatModels';

export class SettingsDao {
  private dbHelper: DatabaseHelper;

  constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  // 获取设置值
  async getSetting(key: string, defaultValue?: string): Promise<string | null> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const resultSet = await rdbStore.querySql(
        'SELECT value FROM settings WHERE key = ?',
        [key]
      );

      if (resultSet.rowCount === 0) {
        resultSet.close();
        return defaultValue || null;
      }

      resultSet.goToFirstRow();
      const value = resultSet.getString(resultSet.getColumnIndex('value'));
      resultSet.close();

      return value;
    } catch (error) {
      console.error('获取设置失败:', error);
      return defaultValue || null;
    }
  }

  // 设置值
  async setSetting(key: string, value: string): Promise<void> {
    const rdbStore = this.dbHelper.getRdbStore();
    const now = Date.now();

    const valueBucket: relationalStore.ValuesBucket = {
      key: key,
      value: value,
      updated_at: now
    };

    try {
      // 先尝试更新，如果不存在则插入
      const predicates = new relationalStore.RdbPredicates('settings');
      predicates.equalTo('key', key);
      
      const updateCount = await rdbStore.update({ value: value, updated_at: now }, predicates);
      
      if (updateCount === 0) {
        await rdbStore.insert('settings', valueBucket);
      }
    } catch (error) {
      console.error('设置值失败:', error);
      throw new Error('设置值失败');
    }
  }

  // 批量设置
  async setMultipleSettings(settings: SettingsMap): Promise<void> {
    const rdbStore = this.dbHelper.getRdbStore();
    const now = Date.now();

    try {
      // 开启事务
      await rdbStore.beginTransaction();

      const entries = settings.entries();
      for (let i = 0; i < entries.length; i++) {
        const entry = entries[i];
        const key = entry[0];
        const value = entry[1];
        
        const predicates = new relationalStore.RdbPredicates('settings');
        predicates.equalTo('key', key);
        
        const updateCount = await rdbStore.update({ value: value, updated_at: now }, predicates);
        
        if (updateCount === 0) {
          await rdbStore.insert('settings', {
            key: key,
            value: value,
            updated_at: now
          });
        }
      }

      await rdbStore.commit();
    } catch (error) {
      await rdbStore.rollBack();
      console.error('批量设置失败:', error);
      throw new Error('批量设置失败');
    }
  }

  // 获取所有设置
  async getAllSettings(): Promise<SettingsMap> {
    const rdbStore = this.dbHelper.getRdbStore();
    const settings = new SettingsMap();

    try {
      const resultSet = await rdbStore.querySql('SELECT key, value FROM settings');

      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          const key = resultSet.getString(resultSet.getColumnIndex('key'));
          const value = resultSet.getString(resultSet.getColumnIndex('value'));
          settings.set(key, value);
        } while (resultSet.goToNextRow());
      }

      resultSet.close();
      return settings;
    } catch (error) {
      console.error('获取所有设置失败:', error);
      throw new Error('获取所有设置失败');
    }
  }

  // 删除设置
  async deleteSetting(key: string): Promise<void> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const predicates = new relationalStore.RdbPredicates('settings');
      predicates.equalTo('key', key);
      
      await rdbStore.delete(predicates);
    } catch (error) {
      console.error('删除设置失败:', error);
      throw new Error('删除设置失败');
    }
  }

  // 清空所有设置
  async clearAllSettings(): Promise<void> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      await rdbStore.executeSql('DELETE FROM settings');
    } catch (error) {
      console.error('清空设置失败:', error);
      throw new Error('清空设置失败');
    }
  }

  // 获取设置对象
  async getSettingObject<T>(key: string, defaultValue?: T): Promise<T | null> {
    const value = await this.getSetting(key);
    
    if (value === null) {
      return defaultValue || null;
    }

    try {
      return JSON.parse(value) as T;
    } catch (error) {
      console.error('解析设置对象失败:', error);
      return defaultValue || null;
    }
  }

  // 设置对象
  async setSettingObject<T>(key: string, value: T): Promise<void> {
    try {
      const jsonValue = JSON.stringify(value);
      await this.setSetting(key, jsonValue);
    } catch (error) {
      console.error('设置对象失败:', error);
      throw new Error('设置对象失败');
    }
  }

  // 获取布尔值设置
  async getBooleanSetting(key: string, defaultValue?: boolean): Promise<boolean> {
    const value = await this.getSetting(key);
    
    if (value === null) {
      return defaultValue || false;
    }

    return value === 'true';
  }

  // 设置布尔值
  async setBooleanSetting(key: string, value: boolean): Promise<void> {
    await this.setSetting(key, value ? 'true' : 'false');
  }

  // 获取数字设置
  async getNumberSetting(key: string, defaultValue?: number): Promise<number | null> {
    const value = await this.getSetting(key);
    
    if (value === null) {
      return defaultValue || null;
    }

    const number = parseFloat(value);
    return isNaN(number) ? (defaultValue || null) : number;
  }

  // 设置数字值
  async setNumberSetting(key: string, value: number): Promise<void> {
    await this.setSetting(key, value.toString());
  }

  // 检查设置是否存在
  async hasSettings(key: string): Promise<boolean> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const resultSet = await rdbStore.querySql(
        'SELECT COUNT(*) as count FROM settings WHERE key = ?',
        [key]
      );

      if (resultSet.rowCount === 0) {
        resultSet.close();
        return false;
      }

      resultSet.goToFirstRow();
      const count = resultSet.getLong(resultSet.getColumnIndex('count'));
      resultSet.close();

      return count > 0;
    } catch (error) {
      console.error('检查设置是否存在失败:', error);
      return false;
    }
  }

  // 导出设置
  async exportSettings(): Promise<Setting[]> {
    const rdbStore = this.dbHelper.getRdbStore();
    const settings: Setting[] = [];

    try {
      const resultSet = await rdbStore.querySql('SELECT * FROM settings ORDER BY key');

      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          settings.push({
            key: resultSet.getString(resultSet.getColumnIndex('key')),
            value: resultSet.getString(resultSet.getColumnIndex('value')),
            updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at'))
          });
        } while (resultSet.goToNextRow());
      }

      resultSet.close();
      return settings;
    } catch (error) {
      console.error('导出设置失败:', error);
      throw new Error('导出设置失败');
    }
  }

  // 导入设置
  async importSettings(settings: Setting[]): Promise<void> {
    const rdbStore = this.dbHelper.getRdbStore();

    try {
      // 开启事务
      await rdbStore.beginTransaction();

      // 清空现有设置
      await rdbStore.executeSql('DELETE FROM settings');

      // 插入新设置
      for (let i = 0; i < settings.length; i++) {
        const setting = settings[i];
        const valueBucket: relationalStore.ValuesBucket = {
          key: setting.key,
          value: setting.value,
          updated_at: setting.updatedAt
        };
        await rdbStore.insert('settings', valueBucket);
      }

      await rdbStore.commit();
    } catch (error) {
      await rdbStore.rollBack();
      console.error('导入设置失败:', error);
      throw new Error('导入设置失败');
    }
  }
}

// 预定义的设置键常量
export class SettingKeys {
  // 主题设置
  static readonly THEME = 'theme';
  static readonly LANGUAGE = 'language';
  
  // AI 提供商设置
  static readonly AI_PROVIDER = 'aiProvider';
  static readonly OPENAI_API_KEY = 'openaiApiKey';
  static readonly OPENAI_API_HOST = 'openaiApiHost';
  static readonly OPENAI_MODEL = 'openaiModel';
  
  // Claude 设置
  static readonly CLAUDE_API_KEY = 'claudeApiKey';
  static readonly CLAUDE_MODEL = 'claudeModel';
  
  // 对话设置
  static readonly MAX_CONTEXT_MESSAGES = 'maxContextMessages';
  static readonly TEMPERATURE = 'temperature';
  static readonly TOP_P = 'topP';
  
  // 界面设置
  static readonly FONT_SIZE = 'fontSize';
  static readonly SHOW_WORD_COUNT = 'showWordCount';
  static readonly SHOW_TOKEN_COUNT = 'showTokenCount';
  
  // 其他设置
  static readonly AUTO_GENERATE_TITLE = 'autoGenerateTitle';
  static readonly SEND_WITH_ENTER = 'sendWithEnter';
  static readonly ENABLE_SOUND = 'enableSound';
} 