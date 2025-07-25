// 聊天会话模型
export interface ChatSession {
  id: string;
  name: string;
  type: 'chat' | 'picture';
  threadName?: string;
  createdAt: number;
  updatedAt: number;
  starred: boolean;
  avatarKey?: string;
  picUrl?: string;
}

// 聊天消息模型
export interface ChatMessage {
  id: string;
  sessionId: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  contentParts?: MessageContentPart[];
  timestamp: number;
  wordCount: number;
  tokenCount: number;
  generating: boolean;
  errorMessage?: string;
  errorCode?: number;
  aiProvider?: string;
  model?: string;
  firstTokenLatency?: number;
  tokensUsed?: number;
}

// 消息内容部分
export interface MessageContentPart {
  type: 'text' | 'image';
  text?: string;
  storageKey?: string;
}

// 会话线程模型
export interface SessionThread {
  id: string;
  sessionId: string;
  name: string;
  createdAt: number;
}

// 线程消息关联
export interface ThreadMessage {
  id: number;
  threadId: string;
  messageId: string;
  messageOrder: number;
}

// 消息文件模型
export interface MessageFile {
  id: string;
  messageId: string;
  name: string;
  fileType?: string;
  storageKey?: string;
  fileSize?: number;
  createdAt: number;
}

// 消息链接模型
export interface MessageLink {
  id: string;
  messageId: string;
  url: string;
  title?: string;
  storageKey?: string;
  createdAt: number;
}

// 设置模型
export interface Setting {
  key: string;
  value: string;
  updatedAt: number;
}

// 会话设置模型
export interface SessionSettings {
  sessionId: string;
  provider?: string;
  modelId?: string;
  maxContextMessageCount?: number;
  temperature?: number;
  topP?: number;
  imageGenerateNum?: number;
  dalleStyle?: string;
}

// 会话详情模型（包含消息列表）
export interface SessionDetail extends ChatSession {
  messages: ChatMessage[];
  threads?: SessionThread[];
  settings?: SessionSettings;
}

// 消息详情模型（包含文件和链接）
export interface MessageDetail extends ChatMessage {
  files?: MessageFile[];
  links?: MessageLink[];
}

// 创建会话的参数
export interface CreateSessionParams {
  name: string;
  type: 'chat' | 'picture';
  threadName?: string;
  starred?: boolean;
  settings?: SessionSettingsInput;
}

// 创建消息的参数
export interface CreateMessageParams {
  sessionId: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  contentParts?: MessageContentPart[];
  files?: CreateMessageFileInput[];
  links?: CreateMessageLinkInput[];
}

// 创建消息文件的输入参数
export interface CreateMessageFileInput {
  name: string;
  fileType?: string;
  storageKey?: string;
  fileSize?: number;
}

// 创建消息链接的输入参数
export interface CreateMessageLinkInput {
  url: string;
  title?: string;
  storageKey?: string;
}

// 会话设置输入参数
export interface SessionSettingsInput {
  provider?: string;
  modelId?: string;
  maxContextMessageCount?: number;
  temperature?: number;
  topP?: number;
  imageGenerateNum?: number;
  dalleStyle?: string;
}

// 查询条件
export interface QueryCondition {
  limit?: number;
  offset?: number;
  orderBy?: string;
  orderDirection?: 'ASC' | 'DESC';
  searchText?: string;
}

// 分页结果
export interface PageResult<T> {
  data: T[];
  total: number;
  hasMore: boolean;
}

// 数据统计结果
export interface DbStats {
  sessionCount: number;
  messageCount: number;
  settingCount: number;
  dbSize: string;
}

// 导出数据结构
export interface ExportData {
  sessions: ChatSession[];
  messages: MessagesBySession;
  settings: SettingsMap;
  exportTime: number;
}

// 按会话ID索引的消息映射
export class MessagesBySession {
  private data: Map<string, ChatMessage[]> = new Map();

  get(sessionId: string): ChatMessage[] | undefined {
    return this.data.get(sessionId);
  }

  set(sessionId: string, messages: ChatMessage[]): void {
    this.data.set(sessionId, messages);
  }

  has(sessionId: string): boolean {
    return this.data.has(sessionId);
  }

  keys(): string[] {
    return Array.from(this.data.keys());
  }

  values(): ChatMessage[][] {
    return Array.from(this.data.values());
  }

  entries(): [string, ChatMessage[]][] {
    return Array.from(this.data.entries());
  }
}

// 设置键值映射
export class SettingsMap {
  private data: Map<string, string> = new Map();

  get(key: string): string | undefined {
    return this.data.get(key);
  }

  set(key: string, value: string): void {
    this.data.set(key, value);
  }

  has(key: string): boolean {
    return this.data.has(key);
  }

  keys(): string[] {
    return Array.from(this.data.keys());
  }

  values(): string[] {
    return Array.from(this.data.values());
  }

  entries(): [string, string][] {
    return Array.from(this.data.entries());
  }

  delete(key: string): boolean {
    return this.data.delete(key);
  }

  clear(): void {
    this.data.clear();
  }

  size(): number {
    return this.data.size;
  }
} 