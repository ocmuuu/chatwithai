import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { 
  ChatSession, 
  ChatMessage,
  SessionDetail, 
  SessionThread, 
  SessionSettings,
  SessionSettingsInput,
  CreateSessionParams,
  QueryCondition,
  PageResult 
} from './ChatModels';

export class SessionDao {
  private dbHelper: DatabaseHelper;

  constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  // 创建新会话
  async createSession(params: CreateSessionParams): Promise<ChatSession> {
    const rdbStore = this.dbHelper.getRdbStore();
    const now = Date.now();
    const sessionId = this.generateId();

    const session: ChatSession = {
      id: sessionId,
      name: params.name,
      type: params.type,
      threadName: params.threadName,
      createdAt: now,
      updatedAt: now,
      starred: params.starred || false
    };

    const valueBucket: relationalStore.ValuesBucket = {
      id: session.id,
      name: session.name,
      type: session.type,
      thread_name: session.threadName || null,
      created_at: session.createdAt,
      updated_at: session.updatedAt,
      starred: session.starred ? 1 : 0,
      avatar_key: session.avatarKey || null,
      pic_url: session.picUrl || null
    };

    try {
      await rdbStore.insert('sessions', valueBucket);

      // 如果有设置参数，同时创建会话设置
      if (params.settings) {
        await this.createSessionSettings(sessionId, params.settings);
      }

      return session;
    } catch (error) {
      console.error('创建会话失败:', error);
      throw new Error('创建会话失败');
    }
  }

  // 获取所有会话
  async getAllSessions(condition?: QueryCondition): Promise<PageResult<ChatSession>> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    let sql = 'SELECT * FROM sessions';
    const params: string[] = [];

    // 添加搜索条件
    if (condition?.searchText) {
      sql += ' WHERE name LIKE ?';
      params.push(`%${condition.searchText}%`);
    }

    // 添加排序
    const orderBy = condition?.orderBy || 'updated_at';
    const orderDirection = condition?.orderDirection || 'DESC';
    sql += ` ORDER BY ${orderBy} ${orderDirection}`;

    // 添加分页
    if (condition?.limit) {
      sql += ' LIMIT ?';
      params.push(condition.limit.toString());
      
      if (condition?.offset) {
        sql += ' OFFSET ?';
        params.push(condition.offset.toString());
      }
    }

    try {
      const resultSet = await rdbStore.querySql(sql, params);
      const sessions: ChatSession[] = [];

      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          sessions.push(this.parseSessionFromResultSet(resultSet));
        } while (resultSet.goToNextRow());
      }

      resultSet.close();

      // 获取总数
      const countSql = condition?.searchText 
        ? 'SELECT COUNT(*) as total FROM sessions WHERE name LIKE ?'
        : 'SELECT COUNT(*) as total FROM sessions';
      const countParams = condition?.searchText ? [`%${condition.searchText}%`] : [];
      const countResult = await rdbStore.querySql(countSql, countParams);
      
      let total = 0;
      if (countResult.rowCount > 0) {
        countResult.goToFirstRow();
        total = countResult.getLong(countResult.getColumnIndex('total'));
      }
      countResult.close();

      const hasMore = condition?.limit ? (condition.offset || 0) + sessions.length < total : false;

      return {
        data: sessions,
        total,
        hasMore
      };
    } catch (error) {
      console.error('获取会话列表失败:', error);
      throw new Error('获取会话列表失败');
    }
  }

  // 根据ID获取会话详情
  async getSessionById(sessionId: string): Promise<SessionDetail | null> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const resultSet = await rdbStore.querySql(
        'SELECT * FROM sessions WHERE id = ?',
        [sessionId]
      );

      if (resultSet.rowCount === 0) {
        resultSet.close();
        return null;
      }

      resultSet.goToFirstRow();
      const session = this.parseSessionFromResultSet(resultSet);
      resultSet.close();

      // 获取消息列表（这里引用MessageDao会造成循环依赖，所以先返回空数组）
      const messages: ChatMessage[] = [];

      // 获取线程列表
      const threads = await this.getSessionThreads(sessionId);

      // 获取会话设置
      const settings = await this.getSessionSettings(sessionId);

      const sessionDetail: SessionDetail = {
        id: session.id,
        name: session.name,
        type: session.type,
        threadName: session.threadName,
        createdAt: session.createdAt,
        updatedAt: session.updatedAt,
        starred: session.starred,
        avatarKey: session.avatarKey,
        picUrl: session.picUrl,
        messages,
        threads,
        settings: settings || undefined
      };

      return sessionDetail;
    } catch (error) {
      console.error('获取会话详情失败:', error);
      throw new Error('获取会话详情失败');
    }
  }

  // 更新会话
  async updateSession(sessionId: string, updates: Partial<ChatSession>): Promise<void> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    const valueBucket: relationalStore.ValuesBucket = {
      updated_at: Date.now()
    };

    if (updates.name !== undefined) valueBucket.name = updates.name;
    if (updates.threadName !== undefined) valueBucket.thread_name = updates.threadName;
    if (updates.starred !== undefined) valueBucket.starred = updates.starred ? 1 : 0;
    if (updates.avatarKey !== undefined) valueBucket.avatar_key = updates.avatarKey;
    if (updates.picUrl !== undefined) valueBucket.pic_url = updates.picUrl;

    try {
      const predicates = new relationalStore.RdbPredicates('sessions');
      predicates.equalTo('id', sessionId);
      
      await rdbStore.update(valueBucket, predicates);
    } catch (error) {
      console.error('更新会话失败:', error);
      throw new Error('更新会话失败');
    }
  }

  // 删除会话
  async deleteSession(sessionId: string): Promise<void> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const predicates = new relationalStore.RdbPredicates('sessions');
      predicates.equalTo('id', sessionId);
      
      await rdbStore.delete(predicates);
    } catch (error) {
      console.error('删除会话失败:', error);
      throw new Error('删除会话失败');
    }
  }

  // 获取会话线程
  async getSessionThreads(sessionId: string): Promise<SessionThread[]> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const resultSet = await rdbStore.querySql(
        'SELECT * FROM session_threads WHERE session_id = ? ORDER BY created_at DESC',
        [sessionId]
      );

      const threads: SessionThread[] = [];
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          threads.push({
            id: resultSet.getString(resultSet.getColumnIndex('id')),
            sessionId: resultSet.getString(resultSet.getColumnIndex('session_id')),
            name: resultSet.getString(resultSet.getColumnIndex('name')),
            createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at'))
          });
        } while (resultSet.goToNextRow());
      }

      resultSet.close();
      return threads;
    } catch (error) {
      console.error('获取会话线程失败:', error);
      throw new Error('获取会话线程失败');
    }
  }

  // 创建会话线程
  async createSessionThread(sessionId: string, name: string): Promise<SessionThread> {
    const rdbStore = this.dbHelper.getRdbStore();
    const threadId = this.generateId();
    const now = Date.now();

    const thread: SessionThread = {
      id: threadId,
      sessionId,
      name,
      createdAt: now
    };

    const valueBucket: relationalStore.ValuesBucket = {
      id: thread.id,
      session_id: thread.sessionId,
      name: thread.name,
      created_at: thread.createdAt
    };

    try {
      await rdbStore.insert('session_threads', valueBucket);
      return thread;
    } catch (error) {
      console.error('创建会话线程失败:', error);
      throw new Error('创建会话线程失败');
    }
  }

  // 获取会话设置
  async getSessionSettings(sessionId: string): Promise<SessionSettings | null> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const resultSet = await rdbStore.querySql(
        'SELECT * FROM session_settings WHERE session_id = ?',
        [sessionId]
      );

      if (resultSet.rowCount === 0) {
        resultSet.close();
        return null;
      }

      resultSet.goToFirstRow();
      const settings: SessionSettings = {
        sessionId: resultSet.getString(resultSet.getColumnIndex('session_id')),
        provider: resultSet.getString(resultSet.getColumnIndex('provider')),
        modelId: resultSet.getString(resultSet.getColumnIndex('model_id')),
        maxContextMessageCount: resultSet.getLong(resultSet.getColumnIndex('max_context_message_count')),
        temperature: resultSet.getDouble(resultSet.getColumnIndex('temperature')),
        topP: resultSet.getDouble(resultSet.getColumnIndex('top_p')),
        imageGenerateNum: resultSet.getLong(resultSet.getColumnIndex('image_generate_num')),
        dalleStyle: resultSet.getString(resultSet.getColumnIndex('dalle_style'))
      };

      resultSet.close();
      return settings;
    } catch (error) {
      console.error('获取会话设置失败:', error);
      throw new Error('获取会话设置失败');
    }
  }

  // 创建或更新会话设置
  async createSessionSettings(sessionId: string, settings: SessionSettingsInput): Promise<void> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    const valueBucket: relationalStore.ValuesBucket = {
      session_id: sessionId,
      provider: settings.provider || null,
      model_id: settings.modelId || null,
      max_context_message_count: settings.maxContextMessageCount || null,
      temperature: settings.temperature || null,
      top_p: settings.topP || null,
      image_generate_num: settings.imageGenerateNum || null,
      dalle_style: settings.dalleStyle || null
    };

    try {
      // 先尝试更新，如果不存在则插入
      const predicates = new relationalStore.RdbPredicates('session_settings');
      predicates.equalTo('session_id', sessionId);
      
      const updateCount = await rdbStore.update(valueBucket, predicates);
      
      if (updateCount === 0) {
        await rdbStore.insert('session_settings', valueBucket);
      }
    } catch (error) {
      console.error('创建会话设置失败:', error);
      throw new Error('创建会话设置失败');
    }
  }

  // 工具方法：从结果集解析会话对象
  private parseSessionFromResultSet(resultSet: relationalStore.ResultSet): ChatSession {
    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      type: resultSet.getString(resultSet.getColumnIndex('type')) as 'chat' | 'picture',
      threadName: resultSet.getString(resultSet.getColumnIndex('thread_name')),
      createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
      updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at')),
      starred: resultSet.getLong(resultSet.getColumnIndex('starred')) === 1,
      avatarKey: resultSet.getString(resultSet.getColumnIndex('avatar_key')),
      picUrl: resultSet.getString(resultSet.getColumnIndex('pic_url'))
    };
  }

  // 工具方法：生成唯一ID
  private generateId(): string {
    return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
} 