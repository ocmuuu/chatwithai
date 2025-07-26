import http from '@ohos.net.http';
import { SettingsInit } from '../setups/SettingsInit';
import { ChatMessage } from '../models/ChatModels';
import PreferencesUtil from '../utils/PreferencesUtil';
import { AIProvider, getProviderConfig } from '../setups/DefaultConfig';

/**
 * 平台信息接口
 */
interface PlatformInfo {
  name: string;
  website: string;
  description: string;
}

/**
 * AI平台配置接口
 */
interface AIConfig {
  apiKey: string;
  baseUrl: string;
}

/**
 * AI API 请求接口
 */
export interface AIRequest {
  messages: AIMessage[];
  model: string;
  temperature?: number;
  max_tokens?: number;
  stream?: boolean;
}

/**
 * AI 消息接口
 */
export interface AIMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

/**
 * AI API 响应接口
 */
export interface AIResponse {
  id: string;
  object: string;
  created: number;
  model: string;
  choices: AIChoice[];
  usage?: AIUsage;
}

/**
 * AI 选择接口
 */
export interface AIChoice {
  index: number;
  message: AIMessage;
  finish_reason: string;
}

/**
 * AI 使用统计接口
 */
export interface AIUsage {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
}

/**
 * AI 错误详情接口
 */
export interface AIErrorDetail {
  message: string;
  type: string;
  code?: string;
}

/**
 * AI 错误响应接口
 */
export interface AIError {
  error: AIErrorDetail;
}

/**
 * AI 服务类
 */
export class AIService {
  private static instance: AIService;
  private context: Context | null = null;

  // 新增：当前AI平台和模型
  private currentProvider: string = 'deepseek';
  private currentModel: string = 'deepseek-chat';

  public getCurrentProvider(): string {
    return this.currentProvider;
  }

  public getCurrentModel(): string {
    return this.currentModel;
  }

  public setCurrentProvider(provider: string): void {
    this.currentProvider = provider;
    console.info(`切换到平台: ${provider}`);
  }

  /**
   * 检查当前平台是否可用（已配置API密钥）
   */
  public async isCurrentProviderAvailable(): Promise<boolean> {
    return await this.checkApiKeyConfigured(this.currentProvider);
  }

  public setCurrentModel(model: string): void {
    this.currentModel = model;
    console.info(`切换到模型: ${model}`);
  }

  /**
   * 根据平台获取API主机地址
   */
  private getApiHostForProvider(provider: string): string {
    // 使用 DefaultConfig 中的配置
    const providerEnum = provider as AIProvider;
    const config = getProviderConfig(providerEnum);
    
    console.info(`获取 ${provider} 的API主机，配置存在: ${config ? '是' : '否'}`);
    
    if (config) {
      console.info(`使用配置中的API主机: ${config.apiHost}`);
      return config.apiHost;
    }
    
    // 兜底逻辑，保持向后兼容
    let fallbackHost: string;
    switch (provider) {
      case 'deepseek':
        fallbackHost = 'https://api.deepseek.com';
        break;
      case 'openai':
        fallbackHost = 'https://api.openai.com';
        break;
      case 'claude':
        fallbackHost = 'https://api.anthropic.com';
        break;
      case 'gemini':
        fallbackHost = 'https://generativelanguage.googleapis.com';
        break;
      case 'siliconflow':
        fallbackHost = 'https://api.siliconflow.cn';
        break;
      case 'volcengine':
        fallbackHost = 'https://ark.cn-beijing.volces.com';
        break;
      case 'xAI':
        fallbackHost = 'https://api.x.ai';
        break;
      case 'groq':
        fallbackHost = 'https://api.groq.com/openai';
        break;
      case 'chatglm-6b':
        fallbackHost = 'https://open.bigmodel.cn/api/paas/v4/';
        break;
      default:
        fallbackHost = 'https://api.deepseek.com'; // 默认使用DeepSeek
        break;
    }
    
    console.info(`使用兜底API主机: ${fallbackHost}`);
    return fallbackHost;
  }

  /**
   * 获取API路径
   */
  private getApiPathForProvider(provider: string): string {
    const providerEnum = provider as AIProvider;
    const config = getProviderConfig(providerEnum);
    
    if (config && config.apiPath) {
      console.info(`使用配置中的API路径: ${config.apiPath}`);
      return config.apiPath;
    }
    
    // 特殊提供商的默认路径
    let defaultPath: string;
    switch (provider) {
      case 'claude':
        defaultPath = '/v1/messages';
        break;
      case 'gemini':
        defaultPath = '/v1beta/models';
        break;
      case 'volcengine':
        // 确保 volcengine 有正确的路径
        defaultPath = '/api/v3/chat/completions';
        break;
      default:
        defaultPath = '/v1/chat/completions';
        break;
    }
    
    console.info(`使用默认API路径: ${defaultPath}`);
    return defaultPath;
  }

  /**
   * 构建完整的 API URL
   */
  private buildApiUrl(provider: string, baseUrl: string): string {
    console.info(`构建API URL - 提供商: ${provider}, 基础URL: ${baseUrl}`);
    
    const providerEnum = provider as AIProvider;
    const config = getProviderConfig(providerEnum);
    
    let url = baseUrl;
    
    // 确保 baseUrl 不以 / 结尾
    if (url.endsWith('/')) {
      url = url.slice(0, -1);
    }
    
    // 添加 API 路径
    const apiPath = this.getApiPathForProvider(provider);
    url += apiPath;
    
    // Gemini 特殊处理：需要在 URL 中指定模型并添加 generateContent
    if (provider === 'gemini') {
      url += `/${this.currentModel}:generateContent`;
    }
    
    // 添加查询参数
    const queryParams: string[] = [];
    
    // 为 Azure 添加 API 版本参数
    if (config && config.apiVersion) {
      queryParams.push(`api-version=${config.apiVersion}`);
    }
    
    // 拼接查询参数
    if (queryParams.length > 0) {
      url += '?' + queryParams.join('&');
    }
    
    console.info(`构建的完整API URL: ${url}`);
    return url;
  }

  /**
   * 检查指定平台是否已配置API密钥
   */
  private async checkApiKeyConfigured(provider: string): Promise<boolean> {
    if (!this.context) {
      return false;
    }

    try {
      const apiKey = await PreferencesUtil.getApiKey(provider);
      return typeof apiKey === 'string' && apiKey.length > 0;
    } catch (error) {
      console.error(`检查 ${provider} API密钥配置失败:`, error);
      return false;
    }
  }

  /**
   * 获取平台配置提示信息
   */
  private getConfigurationMessage(provider: string): string {
    let info: PlatformInfo | null = null;
    
    // 使用switch语句代替对象字面量映射
    switch (provider) {
      case 'openai':
        info = {
          name: 'OpenAI',
          website: 'https://platform.openai.com/api-keys',
          description: 'GPT系列模型的官方提供商，功能强大，支持多种任务'
        };
        break;
      case 'claude':
        info = {
          name: 'Anthropic Claude',
          website: 'https://console.anthropic.com',
          description: '由Anthropic开发，注重安全性和可控性的AI助手'
        };
        break;
      case 'gemini':
        info = {
          name: 'Google Gemini',
          website: 'https://makersuite.google.com/app/apikey',
          description: 'Google开发的多模态大语言模型，支持文本和视觉理解'
        };
        break;
      case 'siliconflow':
        info = {
          name: 'SiliconFlow',
          website: 'https://cloud.siliconflow.cn',
          description: '提供多种开源模型的高性能AI服务平台'
        };
        break;
      case 'volcengine':
        info = {
          name: '火山引擎',
          website: 'https://www.volcengine.com/product/ark',
          description: '字节跳动旗下的AI服务平台，提供豆包等模型'
        };
        break;
      case 'xAI':
        info = {
          name: 'xAI Grok',
          website: 'https://console.x.ai',
          description: '马斯克创立的xAI公司开发的Grok系列模型'
        };
        break;
      case 'groq':
        info = {
          name: 'Groq',
          website: 'https://console.groq.com/keys',
          description: '专注于高速AI推理的服务平台'
        };
        break;
      case 'chatglm-6b':
        info = {
          name: 'ChatGLM',
          website: 'https://open.bigmodel.cn',
          description: '清华大学和智谱AI开发的中文优化大语言模型'
        };
        break;
      default:
        break;
    }

    if (!info) {
      return `❗ 需要配置 ${provider} API 密钥\n\n请先在应用设置中配置相应的API密钥。`;
    }
    
    return `🔐 需要配置 ${info.name} API 密钥

**关于 ${info.name}：**
${info.description}

**配置步骤：**
1. 📱 访问 ${info.name} 官网: ${info.website}
2. 🔑 创建账户并获取API密钥
3. ⚙️ 在本应用设置中配置API密钥
4. ✅ 配置完成后即可使用 ${info.name} 的所有模型

**临时方案：**
如需立即体验AI对话，建议切换到已配置的 **DeepSeek** 平台，该平台提供优质的AI服务。

---
💡 提示：每个平台都有其独特的优势，配置多个平台可以体验不同模型的特色功能。`;
  }

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): AIService {
    if (!AIService.instance) {
      AIService.instance = new AIService();
    }
    return AIService.instance;
  }

  /**
   * 初始化服务
   */
  public async initialize(context: Context): Promise<void> {
    this.context = context;
  }

  /**
   * 发送消息到 AI API
   */
  public async sendMessage(
    messages: ChatMessage[], 
    userMessage: string
  ): Promise<string> {
    if (!this.context) {
      throw new Error('AI 服务未初始化');
    }

    // 首先检查当前平台是否已配置API密钥
    const isConfigured = await this.checkApiKeyConfigured(this.currentProvider);
    if (!isConfigured) {
      console.info(`${this.currentProvider} 平台未配置API密钥，返回配置提示`);
      return this.getConfigurationMessage(this.currentProvider);
    }

    try {
      // 获取当前平台的配置
      const apiKey = await PreferencesUtil.getApiKey(this.currentProvider);
      const apiUrl = await PreferencesUtil.getApiUrl(this.currentProvider);
      
      if (typeof apiKey !== 'string' || apiKey.length === 0) {
        throw new Error(`${this.currentProvider} 未配置 API Key`);
      }
      
      const baseUrl = typeof apiUrl === 'string' && apiUrl.length > 0 
        ? apiUrl 
        : this.getApiHostForProvider(this.currentProvider);
      
      const config: AIConfig = {
        apiKey: apiKey,
        baseUrl: baseUrl
      };

      // 获取应用设置
      const settings = await SettingsInit.loadSettings(this.context);

      // 构建 API 请求消息列表
      const apiMessages = this.buildAPIMessages(messages, userMessage, settings.maxContextMessages);

      // 构建请求体
      const requestBody: AIRequest = {
        model: this.currentModel, // 使用用户选择的模型
        messages: apiMessages,
        temperature: settings.temperature,
        max_tokens: settings.maxTokens,
        stream: false
      };

      console.info(`发送 ${this.currentProvider} API 请求:`, JSON.stringify(requestBody, null, 2));

      // 发送 HTTP 请求
      const response = await this.makeHTTPRequest(config, requestBody);
      
      // 解析响应
      const aiResponse = this.parseResponse(response);
      
      console.info('收到 DeepSeek API 响应:', JSON.stringify(aiResponse, null, 2));

      // 提取回复内容
      if (aiResponse.choices && aiResponse.choices.length > 0) {
        const content = aiResponse.choices[0].message.content;
        return content || '抱歉，我无法生成回复。';
      } else {
        throw new Error('API 响应格式错误');
      }

    } catch (error) {
      console.error('AI 服务调用失败:', error);
      
      if (error.message) {
        throw new Error(`AI 服务调用失败: ${error.message}`);
      } else {
        throw new Error('AI 服务调用失败: 未知错误');
      }
    }
  }

  /**
   * 构建 API 消息列表
   */
  private buildAPIMessages(
    messages: ChatMessage[], 
    userMessage: string, 
    maxContextMessages: number
  ): AIMessage[] {
    const apiMessages: AIMessage[] = [];

    // 添加系统消息
    apiMessages.push({
      role: 'system',
      content: '你是一个智能助手，请用中文回复用户的问题。你可以帮助用户解答问题、提供建议、进行对话等。请在回复中适当使用 Markdown 格式来提高可读性，例如使用 **粗体**、*斜体*、`代码`、## 标题 和 > 引用 等格式。'
    });

    // 获取最近的消息作为上下文
    const recentMessages = messages.slice(-maxContextMessages);
    
    // 添加历史消息到上下文
    for (const message of recentMessages) {
      if (message.role === 'user' || message.role === 'assistant') {
        apiMessages.push({
          role: message.role,
          content: message.content
        });
      }
    }

    // 添加当前用户消息
    apiMessages.push({
      role: 'user',
      content: userMessage
    });

    return apiMessages;
  }

  /**
   * 发送 HTTP 请求
   */
  private async makeHTTPRequest(config: AIConfig, requestBody: AIRequest): Promise<string> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      
      // 使用新的 URL 构建方法
      let url = this.buildApiUrl(this.currentProvider, config.baseUrl);
      
      // 为 Gemini 添加 API Key 参数
      if (this.currentProvider === 'gemini') {
        const separator = url.includes('?') ? '&' : '?';
        url += `${separator}key=${config.apiKey}`;
      }
      
      // 根据提供商构建请求头
      const headers = this.buildRequestHeaders(config.apiKey);
      
      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: JSON.stringify(requestBody),
        expectDataType: http.HttpDataType.STRING,
        usingCache: false,
        priority: 1,
        connectTimeout: 30000,
        readTimeout: 60000
      };

      console.info(`发送 ${this.currentProvider} API 请求到: ${url}`);

      httpRequest.request(url, options, (err, data) => {
        if (err) {
          console.error('HTTP 请求失败:', err);
          httpRequest.destroy();
          reject(new Error(`网络请求失败: ${err.message || '未知错误'}`));
          return;
        }

        if (data.responseCode !== 200) {
          console.error('HTTP 响应状态码错误:', data.responseCode);
          console.error('响应内容:', data.result);
          httpRequest.destroy();
          
          // 尝试解析错误信息
          try {
            if (typeof data.result === 'string') {
              const errorResponse: AIError = JSON.parse(data.result);
              reject(new Error(`API 错误 (${data.responseCode}): ${errorResponse.error.message}`));
            } else {
              reject(new Error(`HTTP 错误: ${data.responseCode}`));
            }
          } catch (parseError) {
            reject(new Error(`HTTP 错误: ${data.responseCode}`));
          }
          return;
        }

        httpRequest.destroy();
        resolve(data.result as string);
      });
    });
  }

  /**
   * 构建请求头
   */
  private buildRequestHeaders(apiKey: string): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'User-Agent': 'ChatWithAI/1.0.0'
    };

    // 根据提供商设置不同的授权头
    switch (this.currentProvider) {
      case 'claude':
        headers['x-api-key'] = apiKey;
        headers['anthropic-version'] = '2023-06-01';
        break;
      case 'gemini':
        // Gemini 使用 URL 参数传递 API Key，这里不设置 Authorization
        break;
      default:
        headers['Authorization'] = `Bearer ${apiKey}`;
        break;
    }

    return headers;
  }

  /**
   * 解析 API 响应
   */
  private parseResponse(responseText: string): AIResponse {
    try {
      const response: AIResponse = JSON.parse(responseText);
      
      if (!response.choices || response.choices.length === 0) {
        throw new Error('API 响应中没有找到有效的回复');
      }

      return response;
    } catch (error) {
      console.error('解析 API 响应失败:', error);
      console.error('原始响应:', responseText);
      throw new Error('API 响应格式错误');
    }
  }

  /**
   * 测试 API 连接
   */
  public async testConnection(): Promise<boolean> {
    if (!this.context) {
      return false;
    }

    try {
      const testMessage = await this.sendMessage([], '你好');
      return testMessage.length > 0;
    } catch (error) {
      console.error('API 连接测试失败:', error);
      return false;
    }
  }

  /**
   * 根据首轮对话内容自动生成10~20字的中文标题
   */
  public async generateTitle(userMessage: string, aiReply: string): Promise<string> {
    if (!this.context) {
      return userMessage.slice(0, 20);
    }

    // 若当前平台未配置 API Key 则降级使用截取内容
    const isConfigured = await this.checkApiKeyConfigured(this.currentProvider);
    if (!isConfigured) {
      return userMessage.slice(0, 20);
    }

    try {
      const apiKey = await PreferencesUtil.getApiKey(this.currentProvider);
      const apiUrl = await PreferencesUtil.getApiUrl(this.currentProvider);
      const baseUrl = (apiUrl && apiUrl.length > 0) ? apiUrl : this.getApiHostForProvider(this.currentProvider);

      const config: AIConfig = { apiKey: apiKey!, baseUrl };

      // 构造用于生成标题的对话上下文
      const apiMessages: AIMessage[] = [
        {
          role: 'system',
          content: '你是一个标题生成器，请根据下面的对话内容生成一个10到20字的中文标题，用于概括对话主题，不使用引号或多余标点，只返回标题本身。'
        },
        { role: 'user', content: userMessage },
        { role: 'assistant', content: aiReply }
      ];

      const requestBody: AIRequest = {
        model: this.currentModel,
        messages: apiMessages,
        temperature: 0.3,
        max_tokens: 20,
        stream: false
      };

      const responseText = await this.makeHTTPRequest(config, requestBody);
      const aiResponse = this.parseResponse(responseText);

      if (aiResponse.choices && aiResponse.choices.length > 0) {
        let title = aiResponse.choices[0].message.content.trim();
        // 清理可能的引号和句号，并限制长度
        title = title.replace(/["'“”‘’]/g, '').replace(/[。!?！？]/g, '').slice(0, 20);
        return title;
      }

      return userMessage.slice(0, 20);
    } catch (error) {
      console.error('生成标题失败:', error);
      return userMessage.slice(0, 20);
    }
  }
} 