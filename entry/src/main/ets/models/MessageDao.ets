import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { 
  ChatMessage, 
  MessageDetail,
  MessageFile,
  MessageLink,
  MessageContentPart,
  CreateMessageParams,
  CreateMessageFileInput,
  CreateMessageLinkInput,
  QueryCondition,
  PageResult 
} from './ChatModels';

export class MessageDao {
  private dbHelper: DatabaseHelper;

  constructor() {
    this.dbHelper = DatabaseHelper.getInstance();
  }

  // 创建新消息
  async createMessage(params: CreateMessageParams): Promise<ChatMessage> {
    const rdbStore = this.dbHelper.getRdbStore();
    const now = Date.now();
    const messageId = this.generateId();

    const message: ChatMessage = {
      id: messageId,
      sessionId: params.sessionId,
      role: params.role,
      content: params.content,
      contentParts: params.contentParts,
      timestamp: now,
      wordCount: this.countWords(params.content),
      tokenCount: 0, // 需要后续计算
      generating: false
    };

    const valueBucket: relationalStore.ValuesBucket = {
      id: message.id,
      session_id: message.sessionId,
      role: message.role,
      content: message.content,
      content_parts: message.contentParts ? JSON.stringify(message.contentParts) : null,
      timestamp: message.timestamp,
      word_count: message.wordCount,
      token_count: message.tokenCount,
      generating: message.generating ? 1 : 0,
      error_message: message.errorMessage || null,
      error_code: message.errorCode || null,
      ai_provider: message.aiProvider || null,
      model: message.model || null,
      first_token_latency: message.firstTokenLatency || null,
      tokens_used: message.tokensUsed || null
    };

    try {
      await rdbStore.insert('messages', valueBucket);

      // 创建相关的文件记录
      if (params.files && params.files.length > 0) {
        for (let i = 0; i < params.files.length; i++) {
          await this.createMessageFile(messageId, params.files[i]);
        }
      }

      // 创建相关的链接记录
      if (params.links && params.links.length > 0) {
        for (let i = 0; i < params.links.length; i++) {
          await this.createMessageLink(messageId, params.links[i]);
        }
      }

      return message;
    } catch (error) {
      console.error('创建消息失败:', error);
      throw new Error('创建消息失败');
    }
  }

  // 获取会话的所有消息
  async getMessagesBySessionId(sessionId: string, condition?: QueryCondition): Promise<PageResult<ChatMessage>> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    let sql = 'SELECT * FROM messages WHERE session_id = ?';
    const params: string[] = [sessionId];

    // 添加搜索条件
    if (condition?.searchText) {
      sql += ' AND content LIKE ?';
      params.push(`%${condition.searchText}%`);
    }

    // 添加排序
    const orderBy = condition?.orderBy || 'timestamp';
    const orderDirection = condition?.orderDirection || 'ASC';
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
      const messages: ChatMessage[] = [];

      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          messages.push(this.parseMessageFromResultSet(resultSet));
        } while (resultSet.goToNextRow());
      }

      resultSet.close();

      // 获取总数
      const countSql = condition?.searchText 
        ? 'SELECT COUNT(*) as total FROM messages WHERE session_id = ? AND content LIKE ?'
        : 'SELECT COUNT(*) as total FROM messages WHERE session_id = ?';
      const countParams = condition?.searchText ? [sessionId, `%${condition.searchText}%`] : [sessionId];
      const countResult = await rdbStore.querySql(countSql, countParams);
      
      let total = 0;
      if (countResult.rowCount > 0) {
        countResult.goToFirstRow();
        total = countResult.getLong(countResult.getColumnIndex('total'));
      }
      countResult.close();

      const hasMore = condition?.limit ? (condition.offset || 0) + messages.length < total : false;

      return {
        data: messages,
        total,
        hasMore
      };
    } catch (error) {
      console.error('获取会话消息失败:', error);
      throw new Error('获取会话消息失败');
    }
  }

  // 根据ID获取消息详情
  async getMessageById(messageId: string): Promise<MessageDetail | null> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const resultSet = await rdbStore.querySql(
        'SELECT * FROM messages WHERE id = ?',
        [messageId]
      );

      if (resultSet.rowCount === 0) {
        resultSet.close();
        return null;
      }

      resultSet.goToFirstRow();
      const message = this.parseMessageFromResultSet(resultSet);
      resultSet.close();

      // 获取文件列表
      const files = await this.getMessageFiles(messageId);

      // 获取链接列表
      const links = await this.getMessageLinks(messageId);

      const messageDetail: MessageDetail = {
        id: message.id,
        sessionId: message.sessionId,
        role: message.role,
        content: message.content,
        contentParts: message.contentParts,
        timestamp: message.timestamp,
        wordCount: message.wordCount,
        tokenCount: message.tokenCount,
        generating: message.generating,
        errorMessage: message.errorMessage,
        errorCode: message.errorCode,
        aiProvider: message.aiProvider,
        model: message.model,
        firstTokenLatency: message.firstTokenLatency,
        tokensUsed: message.tokensUsed,
        files,
        links
      };

      return messageDetail;
    } catch (error) {
      console.error('获取消息详情失败:', error);
      throw new Error('获取消息详情失败');
    }
  }

  // 更新消息
  async updateMessage(messageId: string, updates: Partial<ChatMessage>): Promise<void> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    const valueBucket: relationalStore.ValuesBucket = {};

    if (updates.content !== undefined) {
      valueBucket.content = updates.content;
      valueBucket.word_count = this.countWords(updates.content);
    }
    if (updates.contentParts !== undefined) {
      valueBucket.content_parts = updates.contentParts ? JSON.stringify(updates.contentParts) : null;
    }
    if (updates.tokenCount !== undefined) valueBucket.token_count = updates.tokenCount;
    if (updates.generating !== undefined) valueBucket.generating = updates.generating ? 1 : 0;
    if (updates.errorMessage !== undefined) valueBucket.error_message = updates.errorMessage;
    if (updates.errorCode !== undefined) valueBucket.error_code = updates.errorCode;
    if (updates.aiProvider !== undefined) valueBucket.ai_provider = updates.aiProvider;
    if (updates.model !== undefined) valueBucket.model = updates.model;
    if (updates.firstTokenLatency !== undefined) valueBucket.first_token_latency = updates.firstTokenLatency;
    if (updates.tokensUsed !== undefined) valueBucket.tokens_used = updates.tokensUsed;

    try {
      const predicates = new relationalStore.RdbPredicates('messages');
      predicates.equalTo('id', messageId);
      
      await rdbStore.update(valueBucket, predicates);
    } catch (error) {
      console.error('更新消息失败:', error);
      throw new Error('更新消息失败');
    }
  }

  // 删除消息
  async deleteMessage(messageId: string): Promise<void> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const predicates = new relationalStore.RdbPredicates('messages');
      predicates.equalTo('id', messageId);
      
      await rdbStore.delete(predicates);
    } catch (error) {
      console.error('删除消息失败:', error);
      throw new Error('删除消息失败');
    }
  }

  // 批量删除会话的所有消息
  async deleteMessagesBySessionId(sessionId: string): Promise<void> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const predicates = new relationalStore.RdbPredicates('messages');
      predicates.equalTo('session_id', sessionId);
      
      await rdbStore.delete(predicates);
    } catch (error) {
      console.error('删除会话消息失败:', error);
      throw new Error('删除会话消息失败');
    }
  }

  // 获取消息的文件列表
  async getMessageFiles(messageId: string): Promise<MessageFile[]> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const resultSet = await rdbStore.querySql(
        'SELECT * FROM message_files WHERE message_id = ? ORDER BY created_at ASC',
        [messageId]
      );

      const files: MessageFile[] = [];
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          files.push({
            id: resultSet.getString(resultSet.getColumnIndex('id')),
            messageId: resultSet.getString(resultSet.getColumnIndex('message_id')),
            name: resultSet.getString(resultSet.getColumnIndex('name')),
            fileType: resultSet.getString(resultSet.getColumnIndex('file_type')),
            storageKey: resultSet.getString(resultSet.getColumnIndex('storage_key')),
            fileSize: resultSet.getLong(resultSet.getColumnIndex('file_size')),
            createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at'))
          });
        } while (resultSet.goToNextRow());
      }

      resultSet.close();
      return files;
    } catch (error) {
      console.error('获取消息文件失败:', error);
      throw new Error('获取消息文件失败');
    }
  }

  // 创建消息文件
  async createMessageFile(messageId: string, file: CreateMessageFileInput): Promise<MessageFile> {
    const rdbStore = this.dbHelper.getRdbStore();
    const fileId = this.generateId();
    const now = Date.now();

    const messageFile: MessageFile = {
      id: fileId,
      messageId,
      name: file.name,
      fileType: file.fileType,
      storageKey: file.storageKey,
      fileSize: file.fileSize,
      createdAt: now
    };

    const valueBucket: relationalStore.ValuesBucket = {
      id: messageFile.id,
      message_id: messageFile.messageId,
      name: messageFile.name,
      file_type: messageFile.fileType || null,
      storage_key: messageFile.storageKey || null,
      file_size: messageFile.fileSize || null,
      created_at: messageFile.createdAt
    };

    try {
      await rdbStore.insert('message_files', valueBucket);
      return messageFile;
    } catch (error) {
      console.error('创建消息文件失败:', error);
      throw new Error('创建消息文件失败');
    }
  }

  // 获取消息的链接列表
  async getMessageLinks(messageId: string): Promise<MessageLink[]> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    try {
      const resultSet = await rdbStore.querySql(
        'SELECT * FROM message_links WHERE message_id = ? ORDER BY created_at ASC',
        [messageId]
      );

      const links: MessageLink[] = [];
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          links.push({
            id: resultSet.getString(resultSet.getColumnIndex('id')),
            messageId: resultSet.getString(resultSet.getColumnIndex('message_id')),
            url: resultSet.getString(resultSet.getColumnIndex('url')),
            title: resultSet.getString(resultSet.getColumnIndex('title')),
            storageKey: resultSet.getString(resultSet.getColumnIndex('storage_key')),
            createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at'))
          });
        } while (resultSet.goToNextRow());
      }

      resultSet.close();
      return links;
    } catch (error) {
      console.error('获取消息链接失败:', error);
      throw new Error('获取消息链接失败');
    }
  }

  // 创建消息链接
  async createMessageLink(messageId: string, link: CreateMessageLinkInput): Promise<MessageLink> {
    const rdbStore = this.dbHelper.getRdbStore();
    const linkId = this.generateId();
    const now = Date.now();

    const messageLink: MessageLink = {
      id: linkId,
      messageId,
      url: link.url,
      title: link.title,
      storageKey: link.storageKey,
      createdAt: now
    };

    const valueBucket: relationalStore.ValuesBucket = {
      id: messageLink.id,
      message_id: messageLink.messageId,
      url: messageLink.url,
      title: messageLink.title || null,
      storage_key: messageLink.storageKey || null,
      created_at: messageLink.createdAt
    };

    try {
      await rdbStore.insert('message_links', valueBucket);
      return messageLink;
    } catch (error) {
      console.error('创建消息链接失败:', error);
      throw new Error('创建消息链接失败');
    }
  }

  // 搜索消息
  async searchMessages(searchText: string, condition?: QueryCondition): Promise<PageResult<ChatMessage>> {
    const rdbStore = this.dbHelper.getRdbStore();
    
    let sql = 'SELECT * FROM messages WHERE content LIKE ?';
    const params: string[] = [`%${searchText}%`];

    // 添加排序
    const orderBy = condition?.orderBy || 'timestamp';
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
      const messages: ChatMessage[] = [];

      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          messages.push(this.parseMessageFromResultSet(resultSet));
        } while (resultSet.goToNextRow());
      }

      resultSet.close();

      // 获取总数
      const countResult = await rdbStore.querySql(
        'SELECT COUNT(*) as total FROM messages WHERE content LIKE ?',
        [`%${searchText}%`]
      );
      
      let total = 0;
      if (countResult.rowCount > 0) {
        countResult.goToFirstRow();
        total = countResult.getLong(countResult.getColumnIndex('total'));
      }
      countResult.close();

      const hasMore = condition?.limit ? (condition.offset || 0) + messages.length < total : false;

      return {
        data: messages,
        total,
        hasMore
      };
    } catch (error) {
      console.error('搜索消息失败:', error);
      throw new Error('搜索消息失败');
    }
  }

  // 工具方法：从结果集解析消息对象
  private parseMessageFromResultSet(resultSet: relationalStore.ResultSet): ChatMessage {
    const contentPartsStr = resultSet.getString(resultSet.getColumnIndex('content_parts'));
    let contentParts: MessageContentPart[] | undefined;
    
    if (contentPartsStr) {
      try {
        contentParts = JSON.parse(contentPartsStr);
      } catch (error) {
        console.error('解析消息内容部分失败:', error);
      }
    }

    return {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      sessionId: resultSet.getString(resultSet.getColumnIndex('session_id')),
      role: resultSet.getString(resultSet.getColumnIndex('role')) as 'user' | 'assistant' | 'system',
      content: resultSet.getString(resultSet.getColumnIndex('content')),
      contentParts,
      timestamp: resultSet.getLong(resultSet.getColumnIndex('timestamp')),
      wordCount: resultSet.getLong(resultSet.getColumnIndex('word_count')),
      tokenCount: resultSet.getLong(resultSet.getColumnIndex('token_count')),
      generating: resultSet.getLong(resultSet.getColumnIndex('generating')) === 1,
      errorMessage: resultSet.getString(resultSet.getColumnIndex('error_message')),
      errorCode: resultSet.getLong(resultSet.getColumnIndex('error_code')),
      aiProvider: resultSet.getString(resultSet.getColumnIndex('ai_provider')),
      model: resultSet.getString(resultSet.getColumnIndex('model')),
      firstTokenLatency: resultSet.getLong(resultSet.getColumnIndex('first_token_latency')),
      tokensUsed: resultSet.getLong(resultSet.getColumnIndex('tokens_used'))
    };
  }

  // 工具方法：计算文本字数
  private countWords(text: string): number {
    if (!text) return 0;
    // 简单的字数统计，可以根据需要进行优化
    return text.length;
  }

  // 工具方法：生成唯一ID
  private generateId(): string {
    return `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
} 