import relationalStore from '@ohos.data.relationalStore';

export class DatabaseHelper {
  private static instance: DatabaseHelper;
  private rdbStore: relationalStore.RdbStore | null = null;
  private readonly databaseName = 'ChatWithAI.db';
  private readonly databaseVersion = 1;

  private constructor() {}

  public static getInstance(): DatabaseHelper {
    if (!DatabaseHelper.instance) {
      DatabaseHelper.instance = new DatabaseHelper();
    }
    return DatabaseHelper.instance;
  }

  // 初始化数据库
  public async initDatabase(context: Context): Promise<void> {
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: this.databaseName,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    try {
      this.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await this.createTables();
      console.info('数据库初始化成功');
    } catch (error) {
      console.error('数据库初始化失败:', error);
      throw new Error('数据库初始化失败');
    }
  }

  // 创建所有表
  private async createTables(): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    // 1. 会话表
    const createSessionsTable = `
      CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'chat',
        thread_name TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        starred INTEGER DEFAULT 0,
        avatar_key TEXT,
        pic_url TEXT
      )
    `;

    // 2. 消息表
    const createMessagesTable = `
      CREATE TABLE IF NOT EXISTS messages (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        content_parts TEXT,
        timestamp INTEGER NOT NULL,
        word_count INTEGER DEFAULT 0,
        token_count INTEGER DEFAULT 0,
        generating INTEGER DEFAULT 0,
        error_message TEXT,
        error_code INTEGER,
        ai_provider TEXT,
        model TEXT,
        first_token_latency INTEGER,
        tokens_used INTEGER,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    `;

    // 3. 会话线程表
    const createSessionThreadsTable = `
      CREATE TABLE IF NOT EXISTS session_threads (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    `;

    // 4. 线程消息关联表
    const createThreadMessagesTable = `
      CREATE TABLE IF NOT EXISTS thread_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        thread_id TEXT NOT NULL,
        message_id TEXT NOT NULL,
        message_order INTEGER NOT NULL,
        FOREIGN KEY (thread_id) REFERENCES session_threads (id) ON DELETE CASCADE,
        FOREIGN KEY (message_id) REFERENCES messages (id) ON DELETE CASCADE
      )
    `;

    // 5. 消息文件表
    const createMessageFilesTable = `
      CREATE TABLE IF NOT EXISTS message_files (
        id TEXT PRIMARY KEY,
        message_id TEXT NOT NULL,
        name TEXT NOT NULL,
        file_type TEXT,
        storage_key TEXT,
        file_size INTEGER,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (message_id) REFERENCES messages (id) ON DELETE CASCADE
      )
    `;

    // 6. 消息链接表
    const createMessageLinksTable = `
      CREATE TABLE IF NOT EXISTS message_links (
        id TEXT PRIMARY KEY,
        message_id TEXT NOT NULL,
        url TEXT NOT NULL,
        title TEXT,
        storage_key TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (message_id) REFERENCES messages (id) ON DELETE CASCADE
      )
    `;

    // 7. 设置表
    const createSettingsTable = `
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    `;

    // 8. 会话设置表
    const createSessionSettingsTable = `
      CREATE TABLE IF NOT EXISTS session_settings (
        session_id TEXT PRIMARY KEY,
        provider TEXT,
        model_id TEXT,
        max_context_message_count INTEGER,
        temperature REAL,
        top_p REAL,
        image_generate_num INTEGER,
        dalle_style TEXT,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    `;

    // 创建索引
    const createIndexes = [
      'CREATE INDEX IF NOT EXISTS idx_messages_session_id ON messages (session_id)',
      'CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages (timestamp)',
      'CREATE INDEX IF NOT EXISTS idx_sessions_updated_at ON sessions (updated_at)',
      'CREATE INDEX IF NOT EXISTS idx_session_threads_session_id ON session_threads (session_id)',
      'CREATE INDEX IF NOT EXISTS idx_thread_messages_thread_id ON thread_messages (thread_id)',
      'CREATE INDEX IF NOT EXISTS idx_message_files_message_id ON message_files (message_id)',
      'CREATE INDEX IF NOT EXISTS idx_message_links_message_id ON message_links (message_id)'
    ];

    try {
      // 执行建表语句
      await this.rdbStore.executeSql(createSessionsTable);
      await this.rdbStore.executeSql(createMessagesTable);
      await this.rdbStore.executeSql(createSessionThreadsTable);
      await this.rdbStore.executeSql(createThreadMessagesTable);
      await this.rdbStore.executeSql(createMessageFilesTable);
      await this.rdbStore.executeSql(createMessageLinksTable);
      await this.rdbStore.executeSql(createSettingsTable);
      await this.rdbStore.executeSql(createSessionSettingsTable);

      // 创建索引
      for (let i = 0; i < createIndexes.length; i++) {
        await this.rdbStore.executeSql(createIndexes[i]);
      }

      console.info('所有表创建成功');
    } catch (error) {
      console.error('创建表失败:', error);
      throw new Error('创建表失败');
    }
  }

  // 获取数据库实例
  public getRdbStore(): relationalStore.RdbStore {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }
    return this.rdbStore;
  }

  // 关闭数据库
  public async closeDatabase(): Promise<void> {
    if (this.rdbStore) {
      await this.rdbStore.close();
      this.rdbStore = null;
    }
  }

  // 清空所有数据（仅用于开发测试）
  public async clearAllData(): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    try {
      // 删除所有表的数据（按依赖关系顺序删除）
      await this.rdbStore.executeSql('DELETE FROM thread_messages');
      await this.rdbStore.executeSql('DELETE FROM message_files');
      await this.rdbStore.executeSql('DELETE FROM message_links');
      await this.rdbStore.executeSql('DELETE FROM messages');
      await this.rdbStore.executeSql('DELETE FROM session_threads');
      await this.rdbStore.executeSql('DELETE FROM sessions');
      
      console.info('所有数据已清空');
    } catch (error) {
      console.error('清空数据失败:', error);
      throw new Error('清空数据失败');
    }
  }
} 