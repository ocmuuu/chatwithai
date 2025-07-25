import dataPreferences from '@ohos.data.preferences'

// 首选项名称
const PREFERENCES_NAME = 'ChatWithAIPreferences'

// 存储键名接口
interface KeysInterface {
  IS_FIRST_COLUMN_COLLAPSED: string
  FIRST_COLUMN_WIDTH: string
  SELECTED_SESSION_ID: string
  CURRENT_AI_PROVIDER: string
  CURRENT_AI_MODEL: string
  THEME_MODE: string
  FONT_SIZE: string
  MARKDOWN_ENABLED: string
  AUTO_SAVE_ENABLED: string
  SEND_ON_ENTER: string
  API_KEY_PREFIX: string
  API_URL_PREFIX: string
}

// 存储键名
const KEYS: KeysInterface = {
  IS_FIRST_COLUMN_COLLAPSED: 'isFirstColumnCollapsed', // 第一栏是否折叠
  FIRST_COLUMN_WIDTH: 'firstColumnWidth', // 第一栏宽度
  SELECTED_SESSION_ID: 'selectedSessionId', // 当前选中的会话ID
  CURRENT_AI_PROVIDER: 'currentAiProvider', // 当前AI平台
  CURRENT_AI_MODEL: 'currentAiModel', // 当前AI模型
  THEME_MODE: 'themeMode', // 主题模式
  FONT_SIZE: 'fontSize', // 字体大小
  MARKDOWN_ENABLED: 'markdownEnabled', // Markdown渲染是否启用
  AUTO_SAVE_ENABLED: 'autoSaveEnabled', // 自动保存是否启用
  SEND_ON_ENTER: 'sendOnEnter', // 回车发送是否启用
  API_KEY_PREFIX: 'apiKey_', // API密钥前缀
  API_URL_PREFIX: 'apiUrl_' // API地址前缀
}

/**
 * 首选项工具类
 * 用于管理ChatWithAI应用的配置持久化
 */
export class PreferencesUtil {
  private static preferences: dataPreferences.Preferences | null = null

  /**
   * 检查是否已初始化
   * @returns 是否已初始化
   */
  static isInitialized(): boolean {
    return PreferencesUtil.preferences !== null
  }

  /**
   * 初始化首选项
   * @param context 应用上下文
   */
  static async init(context: Context): Promise<boolean> {
    try {
      PreferencesUtil.preferences = await dataPreferences.getPreferences(context, PREFERENCES_NAME)
      console.info('PreferencesUtil', 'ChatWithAI首选项初始化成功')
      return true
    } catch (error) {
      console.error('PreferencesUtil', 'ChatWithAI首选项初始化失败:', JSON.stringify(error))
      return false
    }
  }

  /**
   * 同步方式初始化首选项（可选）
   * @param context 应用上下文
   */
  static initSync(context: Context): boolean {
    try {
      const options: dataPreferences.Options = { name: PREFERENCES_NAME }
      PreferencesUtil.preferences = dataPreferences.getPreferencesSync(context, options)
      console.info('PreferencesUtil', 'ChatWithAI首选项同步初始化成功')
      return true
    } catch (error) {
      console.error('PreferencesUtil', 'ChatWithAI首选项同步初始化失败:', JSON.stringify(error))
      return false
    }
  }

  /**
   * 保存第一栏折叠状态
   * @param isCollapsed 是否折叠
   */
  static async saveFirstColumnCollapseState(isCollapsed: boolean): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      await PreferencesUtil.preferences.put(KEYS.IS_FIRST_COLUMN_COLLAPSED, isCollapsed)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存第一栏折叠状态: ${isCollapsed}`)
    } catch (error) {
      console.error('PreferencesUtil', '保存第一栏折叠状态失败:', JSON.stringify(error))
    }
  }

  /**
   * 同步保存第一栏折叠状态
   * @param isCollapsed 是否折叠
   */
  static saveFirstColumnCollapseStateSync(isCollapsed: boolean): void {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      PreferencesUtil.preferences.putSync(KEYS.IS_FIRST_COLUMN_COLLAPSED, isCollapsed)
      PreferencesUtil.preferences.flush() // 异步刷新到磁盘
      console.info('PreferencesUtil', `同步保存第一栏折叠状态: ${isCollapsed}`)
    } catch (error) {
      console.error('PreferencesUtil', '同步保存第一栏折叠状态失败:', JSON.stringify(error))
    }
  }

  /**
   * 获取第一栏折叠状态
   * @returns 折叠状态，默认为false
   */
  static async getFirstColumnCollapseState(): Promise<boolean> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return false
    }

    try {
      const isCollapsed = await PreferencesUtil.preferences.get(KEYS.IS_FIRST_COLUMN_COLLAPSED, false) as boolean
      console.info('PreferencesUtil', `获取第一栏折叠状态: ${isCollapsed}`)
      return isCollapsed
    } catch (error) {
      console.error('PreferencesUtil', '获取第一栏折叠状态失败:', JSON.stringify(error))
      return false
    }
  }

  /**
   * 同步获取第一栏折叠状态
   * @returns 折叠状态，默认为false
   */
  static getFirstColumnCollapseStateSync(): boolean {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return false
    }

    try {
      const isCollapsed = PreferencesUtil.preferences.getSync(KEYS.IS_FIRST_COLUMN_COLLAPSED, false) as boolean
      return isCollapsed
    } catch (error) {
      console.error('PreferencesUtil', '同步获取第一栏折叠状态失败:', JSON.stringify(error))
      return false
    }
  }

  /**
   * 保存第一栏宽度（像素）
   * @param width 宽度
   */
  static async saveFirstColumnWidth(width: number): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      await PreferencesUtil.preferences.put(KEYS.FIRST_COLUMN_WIDTH, width)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存第一栏宽度: ${width}px`)
    } catch (error) {
      console.error('PreferencesUtil', '保存第一栏宽度失败:', JSON.stringify(error))
    }
  }

  /**
   * 同步保存第一栏宽度（像素）
   * @param width 宽度
   */
  static saveFirstColumnWidthSync(width: number): void {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      PreferencesUtil.preferences.putSync(KEYS.FIRST_COLUMN_WIDTH, width)
      PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `同步保存第一栏宽度: ${width}px`)
    } catch (error) {
      console.error('PreferencesUtil', '同步保存第一栏宽度失败:', JSON.stringify(error))
    }
  }

  /**
   * 获取第一栏宽度（像素）
   * @returns 宽度，默认为280px
   */
  static async getFirstColumnWidth(): Promise<number> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return 280
    }

    try {
      const width = await PreferencesUtil.preferences.get(KEYS.FIRST_COLUMN_WIDTH, 280) as number
      console.info('PreferencesUtil', `获取第一栏宽度: ${width}px`)
      return width
    } catch (error) {
      console.error('PreferencesUtil', '获取第一栏宽度失败:', JSON.stringify(error))
      return 280
    }
  }

  /**
   * 同步获取第一栏宽度（像素）
   * @returns 宽度，默认为280px
   */
  static getFirstColumnWidthSync(): number {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return 280
    }

    try {
      const width = PreferencesUtil.preferences.getSync(KEYS.FIRST_COLUMN_WIDTH, 280) as number
      return width
    } catch (error) {
      console.error('PreferencesUtil', '同步获取第一栏宽度失败:', JSON.stringify(error))
      return 280
    }
  }

  /**
   * 保存当前选中的会话ID
   * @param sessionId 会话ID
   */
  static async saveSelectedSessionId(sessionId: string): Promise<void> {
    if (!PreferencesUtil.preferences) {
      return
    }

    try {
      await PreferencesUtil.preferences.put(KEYS.SELECTED_SESSION_ID, sessionId)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存选中的会话ID: ${sessionId}`)
    } catch (error) {
      console.error('PreferencesUtil', '保存选中的会话ID失败:', JSON.stringify(error))
    }
  }

  /**
   * 同步保存当前选中的会话ID
   * @param sessionId 会话ID
   */
  static saveSelectedSessionIdSync(sessionId: string): void {
    if (!PreferencesUtil.preferences) {
      return
    }

    try {
      PreferencesUtil.preferences.putSync(KEYS.SELECTED_SESSION_ID, sessionId)
      PreferencesUtil.preferences.flush() // 异步刷新到磁盘
      console.info('PreferencesUtil', `同步保存选中的会话ID: ${sessionId}`)
    } catch (error) {
      console.error('PreferencesUtil', '同步保存选中的会话ID失败:', JSON.stringify(error))
    }
  }

  /**
   * 获取当前选中的会话ID
   * @returns 会话ID，如果没有则返回空字符串
   */
  static async getSelectedSessionId(): Promise<string> {
    if (!PreferencesUtil.preferences) {
      return ''
    }

    try {
      const sessionId = await PreferencesUtil.preferences.get(KEYS.SELECTED_SESSION_ID, '') as string
      return sessionId
    } catch (error) {
      console.error('PreferencesUtil', '获取选中的会话ID失败:', JSON.stringify(error))
      return ''
    }
  }

  /**
   * 同步获取当前选中的会话ID
   * @returns 会话ID，如果没有则返回空字符串
   */
  static getSelectedSessionIdSync(): string {
    if (!PreferencesUtil.preferences) {
      return ''
    }

    try {
      const sessionId = PreferencesUtil.preferences.getSync(KEYS.SELECTED_SESSION_ID, '') as string
      return sessionId
    } catch (error) {
      console.error('PreferencesUtil', '同步获取选中的会话ID失败:', JSON.stringify(error))
      return ''
    }
  }

  /**
   * 保存主题模式
   * @param themeMode 主题模式 ('light' | 'dark' | 'system')
   */
  static async saveThemeMode(themeMode: string): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      await PreferencesUtil.preferences.put(KEYS.THEME_MODE, themeMode)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存主题模式: ${themeMode}`)
    } catch (error) {
      console.error('PreferencesUtil', '保存主题模式失败:', JSON.stringify(error))
    }
  }

  /**
   * 同步保存主题模式
   * @param themeMode 主题模式
   */
  static saveThemeModeSync(themeMode: string): void {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      PreferencesUtil.preferences.putSync(KEYS.THEME_MODE, themeMode)
      PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `同步保存主题模式: ${themeMode}`)
    } catch (error) {
      console.error('PreferencesUtil', '同步保存主题模式失败:', JSON.stringify(error))
    }
  }

  /**
   * 获取主题模式
   * @returns 主题模式，默认为'system'
   */
  static async getThemeMode(): Promise<string> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return 'system'
    }

    try {
      const themeMode = await PreferencesUtil.preferences.get(KEYS.THEME_MODE, 'system') as string
      console.info('PreferencesUtil', `获取主题模式: ${themeMode}`)
      return themeMode
    } catch (error) {
      console.error('PreferencesUtil', '获取主题模式失败:', JSON.stringify(error))
      return 'system'
    }
  }

  /**
   * 同步获取主题模式
   * @returns 主题模式，默认为'system'
   */
  static getThemeModeSync(): string {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return 'system'
    }

    try {
      const themeMode = PreferencesUtil.preferences.getSync(KEYS.THEME_MODE, 'system') as string
      return themeMode
    } catch (error) {
      console.error('PreferencesUtil', '同步获取主题模式失败:', JSON.stringify(error))
      return 'system'
    }
  }

  /**
   * 保存字体大小
   * @param fontSize 字体大小
   */
  static async saveFontSize(fontSize: number): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      await PreferencesUtil.preferences.put(KEYS.FONT_SIZE, fontSize)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存字体大小: ${fontSize}`)
    } catch (error) {
      console.error('PreferencesUtil', '保存字体大小失败:', JSON.stringify(error))
    }
  }

  /**
   * 同步保存字体大小
   * @param fontSize 字体大小
   */
  static saveFontSizeSync(fontSize: number): void {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      PreferencesUtil.preferences.putSync(KEYS.FONT_SIZE, fontSize)
      PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `同步保存字体大小: ${fontSize}`)
    } catch (error) {
      console.error('PreferencesUtil', '同步保存字体大小失败:', JSON.stringify(error))
    }
  }

  /**
   * 获取字体大小
   * @returns 字体大小，默认为16
   */
  static async getFontSize(): Promise<number> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return 16
    }

    try {
      const fontSize = await PreferencesUtil.preferences.get(KEYS.FONT_SIZE, 16) as number
      console.info('PreferencesUtil', `获取字体大小: ${fontSize}`)
      return fontSize
    } catch (error) {
      console.error('PreferencesUtil', '获取字体大小失败:', JSON.stringify(error))
      return 16
    }
  }

  /**
   * 同步获取字体大小
   * @returns 字体大小，默认为16
   */
  static getFontSizeSync(): number {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return 16
    }

    try {
      const fontSize = PreferencesUtil.preferences.getSync(KEYS.FONT_SIZE, 16) as number
      return fontSize
    } catch (error) {
      console.error('PreferencesUtil', '同步获取字体大小失败:', JSON.stringify(error))
      return 16
    }
  }

  /**
   * 保存Markdown渲染启用状态
   * @param enabled 是否启用Markdown渲染
   */
  static async saveMarkdownEnabled(enabled: boolean): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      await PreferencesUtil.preferences.put(KEYS.MARKDOWN_ENABLED, enabled)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存Markdown渲染启用状态: ${enabled}`)
    } catch (error) {
      console.error('PreferencesUtil', '保存Markdown渲染启用状态失败:', JSON.stringify(error))
    }
  }

  /**
   * 同步保存Markdown渲染启用状态
   * @param enabled 是否启用Markdown渲染
   */
  static saveMarkdownEnabledSync(enabled: boolean): void {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      PreferencesUtil.preferences.putSync(KEYS.MARKDOWN_ENABLED, enabled)
      PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `同步保存Markdown渲染启用状态: ${enabled}`)
    } catch (error) {
      console.error('PreferencesUtil', '同步保存Markdown渲染启用状态失败:', JSON.stringify(error))
    }
  }

  /**
   * 获取Markdown渲染启用状态
   * @returns Markdown渲染启用状态，默认为true
   */
  static async getMarkdownEnabled(): Promise<boolean> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return true
    }

    try {
      const enabled = await PreferencesUtil.preferences.get(KEYS.MARKDOWN_ENABLED, true) as boolean
      console.info('PreferencesUtil', `获取Markdown渲染启用状态: ${enabled}`)
      return enabled
    } catch (error) {
      console.error('PreferencesUtil', '获取Markdown渲染启用状态失败:', JSON.stringify(error))
      return true
    }
  }

  /**
   * 同步获取Markdown渲染启用状态
   * @returns Markdown渲染启用状态，默认为true
   */
  static getMarkdownEnabledSync(): boolean {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return true
    }

    try {
      const enabled = PreferencesUtil.preferences.getSync(KEYS.MARKDOWN_ENABLED, true) as boolean
      return enabled
    } catch (error) {
      console.error('PreferencesUtil', '同步获取Markdown渲染启用状态失败:', JSON.stringify(error))
      return true
    }
  }

  /**
   * 保存自动保存启用状态
   * @param enabled 是否启用自动保存
   */
  static async saveAutoSaveEnabled(enabled: boolean): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      await PreferencesUtil.preferences.put(KEYS.AUTO_SAVE_ENABLED, enabled)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存自动保存启用状态: ${enabled}`)
    } catch (error) {
      console.error('PreferencesUtil', '保存自动保存启用状态失败:', JSON.stringify(error))
    }
  }

  /**
   * 同步保存自动保存启用状态
   * @param enabled 是否启用自动保存
   */
  static saveAutoSaveEnabledSync(enabled: boolean): void {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      PreferencesUtil.preferences.putSync(KEYS.AUTO_SAVE_ENABLED, enabled)
      PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `同步保存自动保存启用状态: ${enabled}`)
    } catch (error) {
      console.error('PreferencesUtil', '同步保存自动保存启用状态失败:', JSON.stringify(error))
    }
  }

  /**
   * 获取自动保存启用状态
   * @returns 自动保存启用状态，默认为true
   */
  static async getAutoSaveEnabled(): Promise<boolean> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return true
    }

    try {
      const enabled = await PreferencesUtil.preferences.get(KEYS.AUTO_SAVE_ENABLED, true) as boolean
      console.info('PreferencesUtil', `获取自动保存启用状态: ${enabled}`)
      return enabled
    } catch (error) {
      console.error('PreferencesUtil', '获取自动保存启用状态失败:', JSON.stringify(error))
      return true
    }
  }

  /**
   * 同步获取自动保存启用状态
   * @returns 自动保存启用状态，默认为true
   */
  static getAutoSaveEnabledSync(): boolean {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return true
    }

    try {
      const enabled = PreferencesUtil.preferences.getSync(KEYS.AUTO_SAVE_ENABLED, true) as boolean
      return enabled
    } catch (error) {
      console.error('PreferencesUtil', '同步获取自动保存启用状态失败:', JSON.stringify(error))
      return true
    }
  }

  /**
   * 保存回车发送启用状态
   * @param enabled 是否启用回车发送
   */
  static async saveSendOnEnterEnabled(enabled: boolean): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      await PreferencesUtil.preferences.put(KEYS.SEND_ON_ENTER, enabled)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存回车发送启用状态: ${enabled}`)
    } catch (error) {
      console.error('PreferencesUtil', '保存回车发送启用状态失败:', JSON.stringify(error))
    }
  }

  /**
   * 同步保存回车发送启用状态
   * @param enabled 是否启用回车发送
   */
  static saveSendOnEnterEnabledSync(enabled: boolean): void {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      PreferencesUtil.preferences.putSync(KEYS.SEND_ON_ENTER, enabled)
      PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `同步保存回车发送启用状态: ${enabled}`)
    } catch (error) {
      console.error('PreferencesUtil', '同步保存回车发送启用状态失败:', JSON.stringify(error))
    }
  }

  /**
   * 获取回车发送启用状态
   * @returns 回车发送启用状态，默认为true
   */
  static async getSendOnEnterEnabled(): Promise<boolean> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return true
    }

    try {
      const enabled = await PreferencesUtil.preferences.get(KEYS.SEND_ON_ENTER, true) as boolean
      console.info('PreferencesUtil', `获取回车发送启用状态: ${enabled}`)
      return enabled
    } catch (error) {
      console.error('PreferencesUtil', '获取回车发送启用状态失败:', JSON.stringify(error))
      return true
    }
  }

  /**
   * 同步获取回车发送启用状态
   * @returns 回车发送启用状态，默认为true
   */
  static getSendOnEnterEnabledSync(): boolean {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return true
    }

    try {
      const enabled = PreferencesUtil.preferences.getSync(KEYS.SEND_ON_ENTER, true) as boolean
      return enabled
    } catch (error) {
      console.error('PreferencesUtil', '同步获取回车发送启用状态失败:', JSON.stringify(error))
      return true
    }
  }

  /**
   * 检查是否有保存的状态
   * @returns 是否有保存的状态
   */
  static hasSavedState(): boolean {
    if (!PreferencesUtil.preferences) {
      return false
    }

    try {
      const hasCollapsedState = PreferencesUtil.preferences.hasSync(KEYS.IS_FIRST_COLUMN_COLLAPSED)
      const hasSessionId = PreferencesUtil.preferences.hasSync(KEYS.SELECTED_SESSION_ID)
      const hasWidth = PreferencesUtil.preferences.hasSync(KEYS.FIRST_COLUMN_WIDTH)
      return hasCollapsedState || hasSessionId || hasWidth
    } catch (error) {
      console.error('PreferencesUtil', '检查保存状态失败:', JSON.stringify(error))
      return false
    }
  }

  /**
   * 清除所有保存的数据
   */
  static async clear(): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      await PreferencesUtil.preferences.clear()
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', 'ChatWithAI配置数据清除成功')
    } catch (error) {
      console.error('PreferencesUtil', 'ChatWithAI配置数据清除失败:', JSON.stringify(error))
    }
  }

  /**
   * 获取所有存储的数据（用于调试）
   */
  static async getAllData(): Promise<Record<string, dataPreferences.ValueType>> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return {}
    }

    try {
      const allData = await PreferencesUtil.preferences.getAll()
      console.info('PreferencesUtil', 'ChatWithAI所有配置数据:', JSON.stringify(allData))
      return allData as Record<string, dataPreferences.ValueType>
    } catch (error) {
      console.error('PreferencesUtil', '获取所有配置数据失败:', JSON.stringify(error))
      return {}
    }
  }

  /**
   * 导出配置数据（用于备份）
   */
  static async exportSettings(): Promise<string> {
    const allData = await PreferencesUtil.getAllData()
    return JSON.stringify(allData, null, 2)
  }

  /**
   * 导入配置数据（用于恢复）
   * @param settingsJson 配置数据JSON字符串
   */
  static async importSettings(settingsJson: string): Promise<boolean> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return false
    }

    try {
      const settingsData: Record<string, dataPreferences.ValueType> = JSON.parse(settingsJson)
      
      // 清除现有数据
      await PreferencesUtil.preferences.clear()
      
      // 导入新数据
      const keys = Object.keys(settingsData)
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i]
        await PreferencesUtil.preferences.put(key, settingsData[key])
      }
      
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', 'ChatWithAI配置数据导入成功')
      return true
    } catch (error) {
      console.error('PreferencesUtil', 'ChatWithAI配置数据导入失败:', JSON.stringify(error))
      return false
    }
  }

  /**
   * 保存API密钥
   * @param providerId 平台ID
   * @param apiKey API密钥
   */
  static async saveApiKey(providerId: string, apiKey: string): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      const key = KEYS.API_KEY_PREFIX + providerId
      await PreferencesUtil.preferences.put(key, apiKey)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存${providerId}的API密钥成功`)
    } catch (error) {
      console.error('PreferencesUtil', `保存${providerId}的API密钥失败:`, JSON.stringify(error))
    }
  }

  /**
   * 同步保存API密钥
   * @param providerId 平台ID
   * @param apiKey API密钥
   */
  static saveApiKeySync(providerId: string, apiKey: string): void {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      const key = KEYS.API_KEY_PREFIX + providerId
      PreferencesUtil.preferences.putSync(key, apiKey)
      PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `同步保存${providerId}的API密钥成功`)
    } catch (error) {
      console.error('PreferencesUtil', `同步保存${providerId}的API密钥失败:`, JSON.stringify(error))
    }
  }

  /**
   * 获取API密钥
   * @param providerId 平台ID
   * @returns API密钥，如果没有则返回空字符串
   */
  static async getApiKey(providerId: string): Promise<string> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return ''
    }

    try {
      const key = KEYS.API_KEY_PREFIX + providerId
      const apiKey = await PreferencesUtil.preferences.get(key, '') as string
      console.info('PreferencesUtil', `获取${providerId}的API密钥成功`)
      return apiKey
    } catch (error) {
      console.error('PreferencesUtil', `获取${providerId}的API密钥失败:`, JSON.stringify(error))
      return ''
    }
  }

  /**
   * 同步获取API密钥
   * @param providerId 平台ID
   * @returns API密钥，如果没有则返回空字符串
   */
  static getApiKeySync(providerId: string): string {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return ''
    }

    try {
      const key = KEYS.API_KEY_PREFIX + providerId
      const apiKey = PreferencesUtil.preferences.getSync(key, '') as string
      return apiKey
    } catch (error) {
      console.error('PreferencesUtil', `同步获取${providerId}的API密钥失败:`, JSON.stringify(error))
      return ''
    }
  }

  /**
   * 保存API地址
   * @param providerId 平台ID
   * @param apiUrl API地址
   */
  static async saveApiUrl(providerId: string, apiUrl: string): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      const key = KEYS.API_URL_PREFIX + providerId
      await PreferencesUtil.preferences.put(key, apiUrl)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存${providerId}的API地址成功`)
    } catch (error) {
      console.error('PreferencesUtil', `保存${providerId}的API地址失败:`, JSON.stringify(error))
    }
  }

  /**
   * 同步保存API地址
   * @param providerId 平台ID
   * @param apiUrl API地址
   */
  static saveApiUrlSync(providerId: string, apiUrl: string): void {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      const key = KEYS.API_URL_PREFIX + providerId
      PreferencesUtil.preferences.putSync(key, apiUrl)
      PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `同步保存${providerId}的API地址成功`)
    } catch (error) {
      console.error('PreferencesUtil', `同步保存${providerId}的API地址失败:`, JSON.stringify(error))
    }
  }

  /**
   * 获取API地址
   * @param providerId 平台ID
   * @returns API地址，如果没有则返回空字符串
   */
  static async getApiUrl(providerId: string): Promise<string> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return ''
    }

    try {
      const key = KEYS.API_URL_PREFIX + providerId
      const apiUrl = await PreferencesUtil.preferences.get(key, '') as string
      console.info('PreferencesUtil', `获取${providerId}的API地址成功`)
      return apiUrl
    } catch (error) {
      console.error('PreferencesUtil', `获取${providerId}的API地址失败:`, JSON.stringify(error))
      return ''
    }
  }

  /**
   * 同步获取API地址
   * @param providerId 平台ID
   * @returns API地址，如果没有则返回空字符串
   */
  static getApiUrlSync(providerId: string): string {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return ''
    }

    try {
      const key = KEYS.API_URL_PREFIX + providerId
      const apiUrl = PreferencesUtil.preferences.getSync(key, '') as string
      return apiUrl
    } catch (error) {
      console.error('PreferencesUtil', `同步获取${providerId}的API地址失败:`, JSON.stringify(error))
      return ''
    }
  }

  /**
   * 清除指定平台的API设置
   * @param providerId 平台ID
   */
  static async clearProviderApiSettings(providerId: string): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      const apiKeyKey = KEYS.API_KEY_PREFIX + providerId
      const apiUrlKey = KEYS.API_URL_PREFIX + providerId
      
      await PreferencesUtil.preferences.delete(apiKeyKey)
      await PreferencesUtil.preferences.delete(apiUrlKey)
      await PreferencesUtil.preferences.flush()
      
      console.info('PreferencesUtil', `清除${providerId}的API设置成功`)
    } catch (error) {
      console.error('PreferencesUtil', `清除${providerId}的API设置失败:`, JSON.stringify(error))
    }
  }

  /**
   * 保存当前AI平台
   * @param provider AI平台
   */
  static async saveCurrentAiProvider(provider: string): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      await PreferencesUtil.preferences.put(KEYS.CURRENT_AI_PROVIDER, provider)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存当前AI平台: ${provider}`)
    } catch (error) {
      console.error('PreferencesUtil', '保存当前AI平台失败:', JSON.stringify(error))
    }
  }

  /**
   * 同步保存当前AI平台
   * @param provider AI平台
   */
  static saveCurrentAiProviderSync(provider: string): void {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      console.info('PreferencesUtil', `准备保存AI平台到键 "${KEYS.CURRENT_AI_PROVIDER}": ${provider}`)
      PreferencesUtil.preferences.putSync(KEYS.CURRENT_AI_PROVIDER, provider)
      
      // 使用异步flush但不等待，在后台执行
      PreferencesUtil.preferences.flush().then(() => {
        console.info('PreferencesUtil', `AI平台已刷新到磁盘: ${provider}`)
      }).catch((error: Error) => {
        console.error('PreferencesUtil', 'AI平台刷新到磁盘失败:', JSON.stringify(error))
      })
      
      console.info('PreferencesUtil', `同步保存当前AI平台: ${provider}`)
      
      // 验证保存结果
      const savedValue = PreferencesUtil.preferences.getSync(KEYS.CURRENT_AI_PROVIDER, 'NOT_FOUND')
      console.info('PreferencesUtil', `验证保存结果 - 读取到的值: ${savedValue}`)
    } catch (error) {
      console.error('PreferencesUtil', '同步保存当前AI平台失败:', JSON.stringify(error))
    }
  }

  /**
   * 获取当前AI平台
   * @returns AI平台，默认为'deepseek'
   */
  static async getCurrentAiProvider(): Promise<string> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return 'deepseek'
    }

    try {
      console.info('PreferencesUtil', `准备从键 "${KEYS.CURRENT_AI_PROVIDER}" 读取AI平台`)
      const provider = await PreferencesUtil.preferences.get(KEYS.CURRENT_AI_PROVIDER, 'deepseek') as string
      console.info('PreferencesUtil', `获取当前AI平台: ${provider}`)
      
      // 检查是否使用了默认值
      if (provider === 'deepseek') {
        const hasKey = await PreferencesUtil.preferences.has(KEYS.CURRENT_AI_PROVIDER)
        console.info('PreferencesUtil', `键是否存在: ${hasKey}, 值: ${provider}`)
      }
      
      return provider
    } catch (error) {
      console.error('PreferencesUtil', '获取当前AI平台失败:', JSON.stringify(error))
      return 'deepseek'
    }
  }

  /**
   * 同步获取当前AI平台
   * @returns AI平台，默认为'deepseek'
   */
  static getCurrentAiProviderSync(): string {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return 'deepseek'
    }

    try {
      const provider = PreferencesUtil.preferences.getSync(KEYS.CURRENT_AI_PROVIDER, 'deepseek') as string
      return provider
    } catch (error) {
      console.error('PreferencesUtil', '同步获取当前AI平台失败:', JSON.stringify(error))
      return 'deepseek'
    }
  }

  /**
   * 保存当前AI模型
   * @param model AI模型
   */
  static async saveCurrentAiModel(model: string): Promise<void> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      await PreferencesUtil.preferences.put(KEYS.CURRENT_AI_MODEL, model)
      await PreferencesUtil.preferences.flush()
      console.info('PreferencesUtil', `保存当前AI模型: ${model}`)
    } catch (error) {
      console.error('PreferencesUtil', '保存当前AI模型失败:', JSON.stringify(error))
    }
  }

  /**
   * 同步保存当前AI模型
   * @param model AI模型
   */
  static saveCurrentAiModelSync(model: string): void {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return
    }

    try {
      console.info('PreferencesUtil', `准备保存AI模型到键 "${KEYS.CURRENT_AI_MODEL}": ${model}`)
      PreferencesUtil.preferences.putSync(KEYS.CURRENT_AI_MODEL, model)
      
      // 使用异步flush但不等待，在后台执行
      PreferencesUtil.preferences.flush().then(() => {
        console.info('PreferencesUtil', `AI模型已刷新到磁盘: ${model}`)
      }).catch((error: Error) => {
        console.error('PreferencesUtil', 'AI模型刷新到磁盘失败:', JSON.stringify(error))
      })
      
      console.info('PreferencesUtil', `同步保存当前AI模型: ${model}`)
      
      // 验证保存结果
      const savedValue = PreferencesUtil.preferences.getSync(KEYS.CURRENT_AI_MODEL, 'NOT_FOUND')
      console.info('PreferencesUtil', `验证保存结果 - 读取到的值: ${savedValue}`)
    } catch (error) {
      console.error('PreferencesUtil', '同步保存当前AI模型失败:', JSON.stringify(error))
    }
  }

  /**
   * 获取当前AI模型
   * @returns AI模型，默认为'deepseek-chat'
   */
  static async getCurrentAiModel(): Promise<string> {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return 'deepseek-chat'
    }

    try {
      console.info('PreferencesUtil', `准备从键 "${KEYS.CURRENT_AI_MODEL}" 读取AI模型`)
      const model = await PreferencesUtil.preferences.get(KEYS.CURRENT_AI_MODEL, 'deepseek-chat') as string
      console.info('PreferencesUtil', `获取当前AI模型: ${model}`)
      
      // 检查是否使用了默认值
      if (model === 'deepseek-chat') {
        const hasKey = await PreferencesUtil.preferences.has(KEYS.CURRENT_AI_MODEL)
        console.info('PreferencesUtil', `键是否存在: ${hasKey}, 值: ${model}`)
      }
      
      return model
    } catch (error) {
      console.error('PreferencesUtil', '获取当前AI模型失败:', JSON.stringify(error))
      return 'deepseek-chat'
    }
  }

  /**
   * 同步获取当前AI模型
   * @returns AI模型，默认为'deepseek-chat'
   */
  static getCurrentAiModelSync(): string {
    if (!PreferencesUtil.preferences) {
      console.error('PreferencesUtil', '首选项未初始化')
      return 'deepseek-chat'
    }

    try {
      const model = PreferencesUtil.preferences.getSync(KEYS.CURRENT_AI_MODEL, 'deepseek-chat') as string
      return model
    } catch (error) {
      console.error('PreferencesUtil', '同步获取当前AI模型失败:', JSON.stringify(error))
      return 'deepseek-chat'
    }
  }
}

export default PreferencesUtil 