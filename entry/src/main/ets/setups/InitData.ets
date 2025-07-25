import { DatabaseHelper } from '../models/DatabaseHelper';
import { ChatSession, ChatMessage } from '../models/ChatModels';
import { MessageDao } from '../models/MessageDao';
import { SessionDao } from '../models/SessionDao';
import { Language, getWelcomeMessages, getSampleConversations } from './DefaultConfig';
import { SettingsInit } from './SettingsInit';
import preferences from '@ohos.data.preferences';
import { promptAction } from '@kit.ArkUI';

export class InitData {
  private static readonly INIT_FLAG_KEY = 'app_initialized';
  private static readonly PREFERENCES_NAME = 'app_settings';

  /**
   * 初始化应用数据
   * 首次启动时创建欢迎会话和示例对话
   */
  public static async initializeAppData(context: Context): Promise<void> {
    try {
      // 检查是否已经初始化过
      const isInitialized = await InitData.checkIfInitialized(context);
      console.info('检查初始化状态:', isInitialized);
      
      if (isInitialized) {
        console.info('应用已初始化，跳过数据初始化');
        return;
      }

      console.info('首次启动，开始初始化数据...');

      // 初始化应用设置
      await SettingsInit.initializeSettings(context);

      // 初始化数据库
      const dbHelper = DatabaseHelper.getInstance();
      await dbHelper.initDatabase(context);

      // 创建欢迎会话
      await InitData.createWelcomeSession();

      // 创建示例会话
      await InitData.createSampleSessions();

      // 标记为已初始化
      await InitData.markAsInitialized(context);

      console.info('数据初始化完成');
      
    } catch (error) {
      console.error('数据初始化失败:', error);
      throw new Error('数据初始化失败');
    }
  }

  /**
   * 检查应用是否已经初始化过
   */
  private static async checkIfInitialized(context: Context): Promise<boolean> {
    try {
      const dataPreferences = await preferences.getPreferences(context, InitData.PREFERENCES_NAME);
      return await dataPreferences.get(InitData.INIT_FLAG_KEY, false) as boolean;
    } catch (error) {
      console.error('检查初始化状态失败:', error);
      return false;
    }
  }

  /**
   * 标记应用为已初始化
   */
  private static async markAsInitialized(context: Context): Promise<void> {
    try {
      const dataPreferences = await preferences.getPreferences(context, InitData.PREFERENCES_NAME);
      await dataPreferences.put(InitData.INIT_FLAG_KEY, true);
      await dataPreferences.flush();
    } catch (error) {
      console.error('标记初始化状态失败:', error);
      throw new Error('标记初始化状态失败');
    }
  }

  /**
   * 创建欢迎会话
   */
  private static async createWelcomeSession(): Promise<void> {
    const now = Date.now();
    const sessionId = `session_${now}`;
    const welcomeTexts = getWelcomeMessages(Language.ZH_CN);

    // 创建欢迎会话
    const welcomeSession: ChatSession = {
      id: sessionId,
      name: '欢迎使用 ChatWithAI',
      type: 'chat',
      createdAt: now,
      updatedAt: now,
      starred: true,
      avatarKey: undefined,
      picUrl: undefined
    };

    // 创建欢迎消息
    const welcomeMessages: ChatMessage[] = [
      {
        id: `msg_${now}_1`,
        sessionId: sessionId,
        role: 'assistant',
        content: `${welcomeTexts.greeting}\n\n${welcomeTexts.introduction}`,
        timestamp: now,
        wordCount: InitData.countWords(`${welcomeTexts.greeting}\n\n${welcomeTexts.introduction}`),
        tokenCount: 35,
        generating: false,
        aiProvider: 'deepseek',
        model: 'deepseek-chat'
      },
      {
        id: `msg_${now}_2`,
        sessionId: sessionId,
        role: 'user',
        content: '你好！请介绍一下你的功能',
        timestamp: now + 1000,
        wordCount: InitData.countWords('你好！请介绍一下你的功能'),
        tokenCount: 10,
        generating: false
      },
      {
        id: `msg_${now}_3`,
        sessionId: sessionId,
        role: 'assistant',
        content: welcomeTexts.capabilities,
        timestamp: now + 2000,
        wordCount: InitData.countWords(welcomeTexts.capabilities),
        tokenCount: 65,
        generating: false,
        aiProvider: 'deepseek',
        model: 'deepseek-chat'
      }
    ];

    // 保存会话和消息
    const sessionDao = new SessionDao();
    const messageDao = new MessageDao();
    
          // 创建会话并获取实际的会话ID
      const createdSession = await sessionDao.createSession({
        name: welcomeSession.name,
        type: welcomeSession.type,
        starred: welcomeSession.starred
      });
      console.info('欢迎会话创建成功, ID:', createdSession.id);
      
      // 使用实际创建的会话ID来创建消息
      for (let i = 0; i < welcomeMessages.length; i++) {
        const message = welcomeMessages[i];
        const createdMessage = await messageDao.createMessage({
          sessionId: createdSession.id, // 使用实际创建的会话ID
          role: message.role,
          content: message.content,
          contentParts: message.contentParts
        });
        console.info(`欢迎消息 ${i + 1} 创建成功, ID: ${createdMessage.id}`);
      }

      console.info('欢迎会话创建完成');
  }

  /**
   * 创建示例会话
   */
  private static async createSampleSessions(): Promise<void> {
    const now = Date.now();
    const sessionDao = new SessionDao();
    const messageDao = new MessageDao();
    const sampleConversations = getSampleConversations();

    // 示例会话1：编程助手
    const codingSessionId = `session_${now + 1000}`;
    const codingSession: ChatSession = {
      id: codingSessionId,
      name: sampleConversations.coding.name,
      type: 'chat',
      createdAt: now + 1000,
      updatedAt: now + 1000,
      starred: false
    };

    const codingMessages: ChatMessage[] = [
      {
        id: `msg_${now + 1000}_1`,
        sessionId: codingSessionId,
        role: 'user',
        content: sampleConversations.coding.userMessage,
        timestamp: now + 1000,
        wordCount: InitData.countWords(sampleConversations.coding.userMessage),
        tokenCount: 18,
        generating: false
      },
      {
        id: `msg_${now + 1000}_2`,
        sessionId: codingSessionId,
        role: 'assistant',
        content: sampleConversations.coding.assistantReply,
        timestamp: now + 2000,
        wordCount: InitData.countWords(sampleConversations.coding.assistantReply),
        tokenCount: 140,
        generating: false,
        aiProvider: 'deepseek',
        model: 'deepseek-coder'
      }
    ];

    // 创建编程助手会话并获取实际的会话ID
    const createdCodingSession = await sessionDao.createSession({
      name: codingSession.name,
      type: codingSession.type,
      starred: codingSession.starred
    });
    console.info('编程助手会话创建成功, ID:', createdCodingSession.id);
    
    // 使用实际创建的会话ID来创建消息
    for (let i = 0; i < codingMessages.length; i++) {
      const message = codingMessages[i];
      const createdMessage = await messageDao.createMessage({
        sessionId: createdCodingSession.id, // 使用实际创建的会话ID
        role: message.role,
        content: message.content,
        contentParts: message.contentParts
      });
      console.info(`编程助手消息 ${i + 1} 创建成功, ID: ${createdMessage.id}`);
    }

    // 示例会话2：学习助手
    const studySessionId = `session_${now + 2000}`;
    const studySession: ChatSession = {
      id: studySessionId,
      name: sampleConversations.learning.name,
      type: 'chat',
      createdAt: now + 2000,
      updatedAt: now + 2000,
      starred: false
    };

    const studyMessages: ChatMessage[] = [
      {
        id: `msg_${now + 2000}_1`,
        sessionId: studySessionId,
        role: 'user',
        content: sampleConversations.learning.userMessage,
        timestamp: now + 2000,
        wordCount: InitData.countWords(sampleConversations.learning.userMessage),
        tokenCount: 6,
        generating: false
      },
      {
        id: `msg_${now + 2000}_2`,
        sessionId: studySessionId,
        role: 'assistant',
        content: sampleConversations.learning.assistantReply,
        timestamp: now + 3000,
        wordCount: InitData.countWords(sampleConversations.learning.assistantReply),
        tokenCount: 95,
        generating: false,
        aiProvider: 'deepseek',
        model: 'deepseek-chat'
      }
    ];

    // 创建学习助手会话并获取实际的会话ID
    const createdStudySession = await sessionDao.createSession({
      name: studySession.name,
      type: studySession.type,
      starred: studySession.starred
    });
    console.info('学习助手会话创建成功, ID:', createdStudySession.id);
    
    // 使用实际创建的会话ID来创建消息
    for (let i = 0; i < studyMessages.length; i++) {
      const message = studyMessages[i];
      const createdMessage = await messageDao.createMessage({
        sessionId: createdStudySession.id, // 使用实际创建的会话ID
        role: message.role,
        content: message.content,
        contentParts: message.contentParts
      });
      console.info(`学习助手消息 ${i + 1} 创建成功, ID: ${createdMessage.id}`);
    }

    console.info('示例会话创建完成');
  }


  /**
   * 重置应用数据（仅用于开发测试）
   */
  public static async resetAppData(context: Context): Promise<void> {
    try {
      console.info('重置应用数据...');
      
      // 清除初始化标记
      const dataPreferences = await preferences.getPreferences(context, InitData.PREFERENCES_NAME);
      await dataPreferences.delete(InitData.INIT_FLAG_KEY);
      await dataPreferences.flush();
      
      // 清空数据库
      const dbHelper = DatabaseHelper.getInstance();
      await dbHelper.clearAllData();
      
      // 重新初始化
      await InitData.initializeAppData(context);
      
      console.info('应用数据重置完成');
      
      await promptAction.showToast({
        message: '应用数据已重置',
        duration: 2000
      });
      
    } catch (error) {
      console.error('重置应用数据失败:', error);
      throw new Error('重置应用数据失败');
    }
  }

  /**
   * 统计文本字数
   */
  private static countWords(text: string): number {
    if (!text) return 0;
    // 简单的字数统计：中文按字符数，英文按单词数
    const chineseCharCount = (text.match(/[\u4e00-\u9fa5]/g) || []).length;
    const englishWordCount = (text.match(/[a-zA-Z]+/g) || []).length;
    return chineseCharCount + englishWordCount;
  }
} 