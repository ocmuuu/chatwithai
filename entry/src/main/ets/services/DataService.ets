import { DatabaseHelper } from '../models/DatabaseHelper';
import { SessionDao } from '../models/SessionDao';
import { MessageDao } from '../models/MessageDao';
import { SettingsDao } from '../models/SettingsDao';
import { InitData } from '../setups/InitData';
import { 
  ChatSession, 
  SessionDetail, 
  ChatMessage, 
  MessageDetail,
  CreateSessionParams,
  CreateMessageParams,
  QueryCondition,
  PageResult,
  ExportData,
  MessagesBySession,
  SettingsMap,
  DbStats
} from '../models/ChatModels';

export class DataService {
  private static instance: DataService;
  private dbHelper: DatabaseHelper;
  private sessionDao: SessionDao;
  private messageDao: MessageDao;
  private settingsDao: SettingsDao;
  private isInitialized = false;

  private constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
    this.sessionDao = new SessionDao();
    this.messageDao = new MessageDao();
    this.settingsDao = new SettingsDao();
  }

  public static getInstance(): DataService {
    if (!DataService.instance) {
      DataService.instance = new DataService();
    }
    return DataService.instance;
  }

  // 初始化数据库
  public async initialize(context: Context): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    try {
      await this.dbHelper.initDatabase(context);
      
      // 使用 InitData 进行完整的数据初始化
      await InitData.initializeAppData(context);
      
      this.isInitialized = true;
      console.info('DataService 初始化成功');
    } catch (error) {
      console.error('DataService 初始化失败:', error);
      throw new Error('DataService 初始化失败');
    }
  }

  // 重置 DataService 状态（开发测试用）
  public resetForTesting(): void {
    this.isInitialized = false;
    console.info('DataService 状态已重置');
  }

  // ==================== 会话相关方法 ====================

  // 创建会话
  async createSession(params: CreateSessionParams): Promise<ChatSession> {
    return await this.sessionDao.createSession(params);
  }

  // 获取所有会话
  async getAllSessions(condition?: QueryCondition): Promise<PageResult<ChatSession>> {
    return await this.sessionDao.getAllSessions(condition);
  }

  // 获取会话详情
  async getSessionById(sessionId: string): Promise<SessionDetail | null> {
    const sessionDetail = await this.sessionDao.getSessionById(sessionId);
    if (!sessionDetail) {
      return null;
    }

    // 获取会话的消息列表
    const messagesResult = await this.messageDao.getMessagesBySessionId(sessionId);
    sessionDetail.messages = messagesResult.data;

    return sessionDetail;
  }

  // 更新会话
  async updateSession(sessionId: string, updates: Partial<ChatSession>): Promise<void> {
    await this.sessionDao.updateSession(sessionId, updates);
  }

  // 删除会话
  async deleteSession(sessionId: string): Promise<void> {
    // 先删除会话相关的消息
    await this.messageDao.deleteMessagesBySessionId(sessionId);
    // 再删除会话
    await this.sessionDao.deleteSession(sessionId);
  }

  // 创建会话线程
  async createSessionThread(sessionId: string, name: string) {
    return await this.sessionDao.createSessionThread(sessionId, name);
  }

  // 获取会话线程
  async getSessionThreads(sessionId: string) {
    return await this.sessionDao.getSessionThreads(sessionId);
  }

  // ==================== 消息相关方法 ====================

  // 创建消息
  async createMessage(params: CreateMessageParams): Promise<ChatMessage> {
    const message = await this.messageDao.createMessage(params);
    
    // 更新会话的最后更新时间
    const sessionUpdate: Partial<ChatSession> = {
      updatedAt: Date.now()
    };
    await this.sessionDao.updateSession(params.sessionId, sessionUpdate);

    return message;
  }

  // 获取会话消息
  async getMessagesBySessionId(sessionId: string, condition?: QueryCondition): Promise<PageResult<ChatMessage>> {
    return await this.messageDao.getMessagesBySessionId(sessionId, condition);
  }

  // 获取消息详情
  async getMessageById(messageId: string): Promise<MessageDetail | null> {
    return await this.messageDao.getMessageById(messageId);
  }

  // 更新消息
  async updateMessage(messageId: string, updates: Partial<ChatMessage>): Promise<void> {
    await this.messageDao.updateMessage(messageId, updates);
  }

  // 删除消息
  async deleteMessage(messageId: string): Promise<void> {
    await this.messageDao.deleteMessage(messageId);
  }

  // 搜索消息
  async searchMessages(searchText: string, condition?: QueryCondition): Promise<PageResult<ChatMessage>> {
    return await this.messageDao.searchMessages(searchText, condition);
  }

  // ==================== 设置相关方法 ====================

  // 获取设置
  async getSetting(key: string, defaultValue?: string): Promise<string | null> {
    return await this.settingsDao.getSetting(key, defaultValue);
  }

  // 设置值
  async setSetting(key: string, value: string): Promise<void> {
    await this.settingsDao.setSetting(key, value);
  }

  // 获取布尔设置
  async getBooleanSetting(key: string, defaultValue?: boolean): Promise<boolean> {
    return await this.settingsDao.getBooleanSetting(key, defaultValue);
  }

  // 设置布尔值
  async setBooleanSetting(key: string, value: boolean): Promise<void> {
    await this.settingsDao.setBooleanSetting(key, value);
  }

  // 获取数字设置
  async getNumberSetting(key: string, defaultValue?: number): Promise<number | null> {
    return await this.settingsDao.getNumberSetting(key, defaultValue);
  }

  // 设置数字值
  async setNumberSetting(key: string, value: number): Promise<void> {
    await this.settingsDao.setNumberSetting(key, value);
  }

  // 获取对象设置
  async getSettingObject<T>(key: string, defaultValue?: T): Promise<T | null> {
    return await this.settingsDao.getSettingObject(key, defaultValue);
  }

  // 设置对象
  async setSettingObject<T>(key: string, value: T): Promise<void> {
    await this.settingsDao.setSettingObject(key, value);
  }

  // 获取所有设置
  async getAllSettings(): Promise<SettingsMap> {
    return await this.settingsDao.getAllSettings();
  }

  // 批量设置
  async setMultipleSettings(settings: SettingsMap): Promise<void> {
    await this.settingsDao.setMultipleSettings(settings);
  }

  // ==================== 数据导入导出 ====================

  // 导出所有数据
  async exportAllData(): Promise<ExportData> {
    try {
      const sessionsResult = await this.getAllSessions();
      const sessions = sessionsResult.data;
      
      const messages = new MessagesBySession();
      for (let i = 0; i < sessions.length; i++) {
        const session = sessions[i];
        const messagesResult = await this.getMessagesBySessionId(session.id);
        messages.set(session.id, messagesResult.data);
      }

      const settings = await this.getAllSettings();

      const exportData: ExportData = {
        sessions,
        messages,
        settings,
        exportTime: Date.now()
      };

      return exportData;
    } catch (error) {
      console.error('导出数据失败:', error);
      throw new Error('导出数据失败');
    }
  }

  // 导入所有数据
  async importAllData(data: ExportData): Promise<void> {
    try {
      // 清空现有数据
      await this.clearAllData();

      // 导入设置
      await this.setMultipleSettings(data.settings);

      // 导入会话和消息
      for (let i = 0; i < data.sessions.length; i++) {
        const session = data.sessions[i];
        // 创建会话
        await this.sessionDao.createSession({
          name: session.name,
          type: session.type,
          threadName: session.threadName
        });

        // 导入会话的消息
        const sessionMessages = data.messages.get(session.id) || [];
        for (let j = 0; j < sessionMessages.length; j++) {
          const message = sessionMessages[j];
          await this.messageDao.createMessage({
            sessionId: session.id,
            role: message.role,
            content: message.content,
            contentParts: message.contentParts
          });
        }
      }

      console.info('数据导入完成');
    } catch (error) {
      console.error('导入数据失败:', error);
      throw new Error('导入数据失败');
    }
  }

  // 清空所有数据
  async clearAllData(): Promise<void> {
    try {
      await this.settingsDao.clearAllSettings();
      // 会话删除会级联删除消息，所以只需要删除会话
      const sessionsResult = await this.getAllSessions();
      for (let i = 0; i < sessionsResult.data.length; i++) {
        const session = sessionsResult.data[i];
        await this.deleteSession(session.id);
      }
      
      console.info('所有数据已清空');
    } catch (error) {
      console.error('清空数据失败:', error);
      throw new Error('清空数据失败');
    }
  }

  // ==================== 工具方法 ====================

  // 获取数据库统计信息
  async getDbStats(): Promise<DbStats> {
    try {
      const sessionsResult = await this.getAllSessions();
      const sessionCount = sessionsResult.total;

      const messagesResult = await this.searchMessages(''); // 获取所有消息
      const messageCount = messagesResult.total;

      const settings = await this.getAllSettings();
      const settingCount = settings.size();

      const stats: DbStats = {
        sessionCount,
        messageCount,
        settingCount,
        dbSize: '未知' // 鸿蒙API可能不提供数据库大小信息
      };

      return stats;
    } catch (error) {
      console.error('获取数据库统计失败:', error);
      const defaultStats: DbStats = {
        sessionCount: 0,
        messageCount: 0,
        settingCount: 0,
        dbSize: '未知'
      };
      return defaultStats;
    }
  }

  // 检查是否已初始化
  public isDbInitialized(): boolean {
    return this.isInitialized;
  }

  // 关闭数据库连接
  async close(): Promise<void> {
    await this.dbHelper.closeDatabase();
    this.isInitialized = false;
  }
} 