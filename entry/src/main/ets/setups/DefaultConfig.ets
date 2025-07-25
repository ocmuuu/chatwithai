/**
 * 应用默认配置
 * 包含AI模型配置、UI设置、聊天参数等默认值
 */

// AI提供商枚举
export enum AIProvider {
  DeepSeek = 'deepseek',
  SiliconFlow = 'siliconflow',
  VolcEngine = 'volcengine',
  OpenAI = 'openai',
  Azure = 'azure',
  ChatGLM = 'chatglm-6b',
  Claude = 'claude',
  Gemini = 'gemini',
  Ollama = 'ollama',
  Groq = 'groq',
  LMStudio = 'lm-studio',
  Perplexity = 'perplexity',
  XAI = 'xAI',
  Local = 'local'
}

// 聊天模式
export enum ChatMode {
  Chat = 'chat',
  Picture = 'picture',
  Assistant = 'assistant'
}

// 主题模式
export enum ThemeMode {
  Light = 'light',
  Dark = 'dark',
  System = 'system'
}

// 语言设置
export enum Language {
  ZH_CN = 'zh-CN',
  EN_US = 'en-US',
  JA_JP = 'ja-JP',
  KO_KR = 'ko-KR'
}

// AI模型配置
export interface ModelConfig {
  id: string;
  name: string;
  provider: AIProvider;
  maxTokens: number;
  contextWindow: number;
  supportVision: boolean;
  supportTools: boolean;
}

// AI提供商配置
export interface ProviderConfig {
  id: AIProvider;
  name: string;
  apiHost: string;
  apiKeyRequired: boolean;
  supportedModels: string[];
  description: string;
}

// 应用设置接口
export interface AppSettings {
  // AI配置
  defaultProvider: AIProvider;
  defaultModel: string;
  temperature: number;
  maxTokens: number;
  maxContextMessages: number;
  
  // UI配置
  theme: ThemeMode;
  language: Language;
  fontSize: number;
  showWordCount: boolean;
  showTokenCount: boolean;
  
  // 聊天配置
  autoSave: boolean;
  enableMarkdown: boolean;
  enableCodeHighlight: boolean;
  sendOnEnter: boolean;
  
  // 隐私配置
  allowTracking: boolean;
  saveHistory: boolean;
}

// 默认AI模型配置
export const DEFAULT_MODELS: ModelConfig[] = [
  // OpenAI 模型
  {
    id: 'gpt-4.1',
    name: 'GPT-4.1',
    provider: AIProvider.OpenAI,
    maxTokens: 32768,
    contextWindow: 1047576,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'gpt-4o',
    name: 'GPT-4o',
    provider: AIProvider.OpenAI,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'gpt-4o-mini',
    name: 'GPT-4o Mini',
    provider: AIProvider.OpenAI,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'o4-mini',
    name: 'o4-mini',
    provider: AIProvider.OpenAI,
    maxTokens: 100000,
    contextWindow: 200000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'o3-mini',
    name: 'o3-mini',
    provider: AIProvider.OpenAI,
    maxTokens: 200000,
    contextWindow: 200000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'o1-mini',
    name: 'o1-mini',
    provider: AIProvider.OpenAI,
    maxTokens: 128000,
    contextWindow: 128000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'o3',
    name: 'o3',
    provider: AIProvider.OpenAI,
    maxTokens: 100000,
    contextWindow: 200000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'o1',
    name: 'o1',
    provider: AIProvider.OpenAI,
    maxTokens: 100000,
    contextWindow: 200000,
    supportVision: true,
    supportTools: true
  },
  
  // Claude 模型
  {
    id: 'claude-opus-4-0',
    name: 'Claude Opus 4.0',
    provider: AIProvider.Claude,
    maxTokens: 32000,
    contextWindow: 200000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'claude-sonnet-4-0',
    name: 'Claude Sonnet 4.0',
    provider: AIProvider.Claude,
    maxTokens: 64000,
    contextWindow: 200000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'claude-3-7-sonnet-latest',
    name: 'Claude 3.7 Sonnet',
    provider: AIProvider.Claude,
    maxTokens: 4096,
    contextWindow: 200000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'claude-3-5-sonnet-latest',
    name: 'Claude 3.5 Sonnet',
    provider: AIProvider.Claude,
    maxTokens: 4096,
    contextWindow: 200000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'claude-3-5-haiku-latest',
    name: 'Claude 3.5 Haiku',
    provider: AIProvider.Claude,
    maxTokens: 4096,
    contextWindow: 200000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'claude-3-opus-latest',
    name: 'Claude 3 Opus',
    provider: AIProvider.Claude,
    maxTokens: 4096,
    contextWindow: 200000,
    supportVision: true,
    supportTools: false
  },
  
  // Gemini 模型
  {
    id: 'gemini-2.5-flash-preview-05-20',
    name: 'Gemini 2.5 Flash Preview',
    provider: AIProvider.Gemini,
    maxTokens: 8192,
    contextWindow: 1000000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'gemini-2.5-pro-preview-06-05',
    name: 'Gemini 2.5 Pro Preview',
    provider: AIProvider.Gemini,
    maxTokens: 8192,
    contextWindow: 2000000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'gemini-2.0-flash-exp',
    name: 'Gemini 2.0 Flash Exp',
    provider: AIProvider.Gemini,
    maxTokens: 8192,
    contextWindow: 1000000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'gemini-2.0-flash-thinking-exp',
    name: 'Gemini 2.0 Flash Thinking Exp',
    provider: AIProvider.Gemini,
    maxTokens: 8192,
    contextWindow: 1000000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'gemini-2.0-flash-thinking-exp-1219',
    name: 'Gemini 2.0 Flash Thinking Exp 1219',
    provider: AIProvider.Gemini,
    maxTokens: 8192,
    contextWindow: 1000000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'gemini-1.5-pro-latest',
    name: 'Gemini 1.5 Pro',
    provider: AIProvider.Gemini,
    maxTokens: 8192,
    contextWindow: 2000000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'gemini-1.5-flash-latest',
    name: 'Gemini 1.5 Flash',
    provider: AIProvider.Gemini,
    maxTokens: 8192,
    contextWindow: 1000000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'gemini-1.5-pro-exp-0827',
    name: 'Gemini 1.5 Pro Exp 0827',
    provider: AIProvider.Gemini,
    maxTokens: 8192,
    contextWindow: 2000000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'gemini-1.5-flash-exp-0827',
    name: 'Gemini 1.5 Flash Exp 0827',
    provider: AIProvider.Gemini,
    maxTokens: 8192,
    contextWindow: 1000000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'gemini-1.5-flash-8b-exp-0924',
    name: 'Gemini 1.5 Flash 8B Exp',
    provider: AIProvider.Gemini,
    maxTokens: 8192,
    contextWindow: 1000000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'gemini-pro',
    name: 'Gemini Pro',
    provider: AIProvider.Gemini,
    maxTokens: 2048,
    contextWindow: 32768,
    supportVision: false,
    supportTools: false
  },
  
  // DeepSeek 模型
  {
    id: 'deepseek-chat',
    name: 'DeepSeek Chat',
    provider: AIProvider.DeepSeek,
    maxTokens: 4096,
    contextWindow: 64000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'deepseek-coder',
    name: 'DeepSeek Coder',
    provider: AIProvider.DeepSeek,
    maxTokens: 4096,
    contextWindow: 64000,
    supportVision: false,
    supportTools: false
  },
  {
    id: 'deepseek-reasoner',
    name: 'DeepSeek Reasoner',
    provider: AIProvider.DeepSeek,
    maxTokens: 4096,
    contextWindow: 64000,
    supportVision: false,
    supportTools: true
  },
  
  // SiliconFlow 模型
  {
    id: 'deepseek-ai/DeepSeek-V3',
    name: 'DeepSeek V3',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 64000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'deepseek-ai/DeepSeek-R1',
    name: 'DeepSeek R1',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 64000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'Pro/deepseek-ai/DeepSeek-R1',
    name: 'DeepSeek R1 Pro',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 64000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'Pro/deepseek-ai/DeepSeek-V3',
    name: 'DeepSeek V3 Pro',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 64000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'Qwen/Qwen2.5-7B-Instruct',
    name: 'Qwen 2.5 7B',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 32000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'Qwen/Qwen2.5-14B-Instruct',
    name: 'Qwen 2.5 14B',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 32000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'Qwen/Qwen2.5-32B-Instruct',
    name: 'Qwen 2.5 32B',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 32000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'Qwen/Qwen2.5-72B-Instruct',
    name: 'Qwen 2.5 72B',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 32000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'Qwen/Qwen2.5-VL-32B-Instruct',
    name: 'Qwen 2.5 VL 32B',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'Qwen/Qwen2.5-VL-72B-Instruct',
    name: 'Qwen 2.5 VL 72B',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'Qwen/QVQ-72B-Preview',
    name: 'QVQ 72B Preview',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'Qwen/QwQ-32B',
    name: 'QwQ 32B',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 32000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'Pro/Qwen/Qwen2.5-VL-7B-Instruct',
    name: 'Qwen 2.5 VL 7B Pro',
    provider: AIProvider.SiliconFlow,
    maxTokens: 4096,
    contextWindow: 32000,
    supportVision: true,
    supportTools: false
  },
  
  // VolcEngine 模型
  {
    id: 'deepseek-v3-250324',
    name: 'DeepSeek V3',
    provider: AIProvider.VolcEngine,
    maxTokens: 4096,
    contextWindow: 64000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'deepseek-r1-250528',
    name: 'DeepSeek R1',
    provider: AIProvider.VolcEngine,
    maxTokens: 4096,
    contextWindow: 16384,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'doubao-1-5-thinking-pro-250415',
    name: '豆包 1.5 Thinking Pro',
    provider: AIProvider.VolcEngine,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  {
    id: 'doubao-1.5-vision-pro-250328',
    name: '豆包 1.5 Vision Pro',
    provider: AIProvider.VolcEngine,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: true,
    supportTools: false
  },
  
  // xAI 模型
  {
    id: 'grok-3-beta',
    name: 'Grok 3 Beta',
    provider: AIProvider.XAI,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'grok-3-mini-beta',
    name: 'Grok 3 Mini Beta',
    provider: AIProvider.XAI,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'grok-2-vision-1212',
    name: 'Grok 2 Vision',
    provider: AIProvider.XAI,
    maxTokens: 4096,
    contextWindow: 8192,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'grok-2-image-1212',
    name: 'Grok 2 Image',
    provider: AIProvider.XAI,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  {
    id: 'grok-2-1212',
    name: 'Grok 2',
    provider: AIProvider.XAI,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  {
    id: 'grok-vision-beta',
    name: 'Grok Vision Beta',
    provider: AIProvider.XAI,
    maxTokens: 4096,
    contextWindow: 8192,
    supportVision: true,
    supportTools: false
  },
  {
    id: 'grok-beta',
    name: 'Grok Beta',
    provider: AIProvider.XAI,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  
  // Perplexity 模型
  {
    id: 'sonar',
    name: 'Sonar',
    provider: AIProvider.Perplexity,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  {
    id: 'sonar-pro',
    name: 'Sonar Pro',
    provider: AIProvider.Perplexity,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  {
    id: 'sonar-reasoning',
    name: 'Sonar Reasoning',
    provider: AIProvider.Perplexity,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  {
    id: 'sonar-reasoning-pro',
    name: 'Sonar Reasoning Pro',
    provider: AIProvider.Perplexity,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  {
    id: 'sonar-deep-research',
    name: 'Sonar Deep Research',
    provider: AIProvider.Perplexity,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  
  // Groq 模型
  {
    id: 'llama-3.2-1b-preview',
    name: 'Llama 3.2 1B Preview',
    provider: AIProvider.Groq,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  {
    id: 'llama-3.2-3b-preview',
    name: 'Llama 3.2 3B Preview',
    provider: AIProvider.Groq,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  {
    id: 'llama-3.2-11b-text-preview',
    name: 'Llama 3.2 11B Text Preview',
    provider: AIProvider.Groq,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  {
    id: 'llama-3.2-90b-text-preview',
    name: 'Llama 3.2 90B Text Preview',
    provider: AIProvider.Groq,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: false
  },
  
  // ChatGLM 模型
  {
    id: 'glm-4-air',
    name: 'GLM-4 Air',
    provider: AIProvider.ChatGLM,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'glm-4-plus',
    name: 'GLM-4 Plus',
    provider: AIProvider.ChatGLM,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'glm-4-flash',
    name: 'GLM-4 Flash',
    provider: AIProvider.ChatGLM,
    maxTokens: 4096,
    contextWindow: 128000,
    supportVision: false,
    supportTools: true
  },
  {
    id: 'glm-4v-plus-0111',
    name: 'GLM-4V Plus',
    provider: AIProvider.ChatGLM,
    maxTokens: 4096,
    contextWindow: 16000,
    supportVision: true,
    supportTools: true
  },
  {
    id: 'glm-4v-flash',
    name: 'GLM-4V Flash',
    provider: AIProvider.ChatGLM,
    maxTokens: 4096,
    contextWindow: 16000,
    supportVision: true,
    supportTools: true
  }
];

// 默认AI提供商配置
export const DEFAULT_PROVIDERS: ProviderConfig[] = [
  {
    id: AIProvider.DeepSeek,
    name: 'DeepSeek',
    apiHost: 'https://api.deepseek.com',
    apiKeyRequired: true,
    supportedModels: ['deepseek-chat', 'deepseek-coder', 'deepseek-reasoner'],
    description: '由深度求索开发的高性能大语言模型，特别擅长代码生成和推理任务'
  },
  {
    id: AIProvider.SiliconFlow,
    name: 'SiliconFlow',
    apiHost: 'https://api.siliconflow.cn',
    apiKeyRequired: true,
    supportedModels: ['deepseek-ai/DeepSeek-V3', 'deepseek-ai/DeepSeek-R1', 'Pro/deepseek-ai/DeepSeek-R1', 'Pro/deepseek-ai/DeepSeek-V3', 'Qwen/Qwen2.5-7B-Instruct', 'Qwen/Qwen2.5-14B-Instruct', 'Qwen/Qwen2.5-32B-Instruct', 'Qwen/Qwen2.5-72B-Instruct', 'Qwen/Qwen2.5-VL-32B-Instruct', 'Qwen/Qwen2.5-VL-72B-Instruct', 'Qwen/QVQ-72B-Preview', 'Qwen/QwQ-32B', 'Pro/Qwen/Qwen2.5-VL-7B-Instruct'],
    description: 'SiliconFlow 提供的高性能AI模型服务平台'
  },
  {
    id: AIProvider.VolcEngine,
    name: 'VolcEngine',
    apiHost: 'https://ark.cn-beijing.volces.com',
    apiKeyRequired: true,
    supportedModels: ['deepseek-v3-250324', 'deepseek-r1-250528', 'doubao-1-5-thinking-pro-250415', 'doubao-1.5-vision-pro-250328'],
    description: '火山引擎提供的AI模型服务'
  },
  {
    id: AIProvider.OpenAI,
    name: 'OpenAI',
    apiHost: 'https://api.openai.com',
    apiKeyRequired: true,
    supportedModels: ['gpt-4.1', 'gpt-4o', 'gpt-4o-mini', 'o4-mini', 'o3-mini', 'o1-mini', 'o3', 'o1'],
    description: 'OpenAI 开发的 GPT 系列模型，功能全面，应用广泛'
  },
  {
    id: AIProvider.Claude,
    name: 'Anthropic Claude',
    apiHost: 'https://api.anthropic.com/v1',
    apiKeyRequired: true,
    supportedModels: ['claude-opus-4-0', 'claude-sonnet-4-0', 'claude-3-7-sonnet-latest', 'claude-3-5-sonnet-latest', 'claude-3-5-haiku-latest', 'claude-3-opus-latest'],
    description: 'Anthropic 开发的 Claude 模型，注重安全性和可控性'
  },
  {
    id: AIProvider.Gemini,
    name: 'Google Gemini',
    apiHost: 'https://generativelanguage.googleapis.com',
    apiKeyRequired: true,
    supportedModels: ['gemini-2.5-flash-preview-05-20', 'gemini-2.5-pro-preview-06-05', 'gemini-2.0-flash-exp', 'gemini-2.0-flash-thinking-exp', 'gemini-2.0-flash-thinking-exp-1219', 'gemini-1.5-pro-latest', 'gemini-1.5-flash-latest', 'gemini-1.5-pro-exp-0827', 'gemini-1.5-flash-exp-0827', 'gemini-1.5-flash-8b-exp-0924', 'gemini-pro'],
    description: 'Google 开发的多模态大语言模型'
  },
  {
    id: AIProvider.Azure,
    name: 'Azure OpenAI',
    apiHost: 'https://<resource_name>.openai.azure.com',
    apiKeyRequired: true,
    supportedModels: [],
    description: 'Microsoft Azure 提供的 OpenAI 服务'
  },
  {
    id: AIProvider.XAI,
    name: 'xAI',
    apiHost: 'https://api.x.ai',
    apiKeyRequired: true,
    supportedModels: ['grok-3-beta', 'grok-3-mini-beta', 'grok-2-vision-1212', 'grok-2-image-1212', 'grok-2-1212', 'grok-vision-beta', 'grok-beta'],
    description: 'xAI 开发的 Grok 系列模型'
  },
  {
    id: AIProvider.Perplexity,
    name: 'Perplexity',
    apiHost: 'https://api.perplexity.ai',
    apiKeyRequired: true,
    supportedModels: ['sonar', 'sonar-pro', 'sonar-reasoning', 'sonar-reasoning-pro', 'sonar-deep-research'],
    description: 'Perplexity 提供的搜索增强大语言模型'
  },
  {
    id: AIProvider.Groq,
    name: 'Groq',
    apiHost: 'https://api.groq.com/openai',
    apiKeyRequired: true,
    supportedModels: ['llama-3.2-1b-preview', 'llama-3.2-3b-preview', 'llama-3.2-11b-text-preview', 'llama-3.2-90b-text-preview'],
    description: 'Groq 提供的高速推理大语言模型服务'
  },
  {
    id: AIProvider.ChatGLM,
    name: 'ChatGLM',
    apiHost: 'https://open.bigmodel.cn/api/paas/v4/',
    apiKeyRequired: true,
    supportedModels: ['glm-4-air', 'glm-4-plus', 'glm-4-flash', 'glm-4v-plus-0111', 'glm-4v-flash'],
    description: '清华大学和智谱AI开发的中文优化大语言模型'
  },
  {
    id: AIProvider.Ollama,
    name: 'Ollama',
    apiHost: 'http://127.0.0.1:11434',
    apiKeyRequired: false,
    supportedModels: [],
    description: '本地部署的开源大语言模型运行环境'
  },
  {
    id: AIProvider.LMStudio,
    name: 'LM Studio',
    apiHost: 'http://127.0.0.1:1234',
    apiKeyRequired: false,
    supportedModels: [],
    description: '本地部署的大语言模型开发工具'
  },
  {
    id: AIProvider.Local,
    name: 'Local',
    apiHost: 'http://127.0.0.1:8080',
    apiKeyRequired: false,
    supportedModels: [],
    description: '本地部署的自定义大语言模型服务'
  }
];

// 默认应用设置
export const DEFAULT_SETTINGS: AppSettings = {
  // AI配置
  defaultProvider: AIProvider.DeepSeek,
  defaultModel: 'deepseek-chat',
  temperature: 0.7,
  maxTokens: 4096,
  maxContextMessages: 20,
  
  // UI配置
  theme: ThemeMode.System,
  language: Language.ZH_CN,
  fontSize: 16,
  showWordCount: true,
  showTokenCount: false,
  
  // 聊天配置
  autoSave: true,
  enableMarkdown: true,
  enableCodeHighlight: true,
  sendOnEnter: true,
  
  // 隐私配置
  allowTracking: false,
  saveHistory: true
};

// 默认会话名称模板
export const DEFAULT_SESSION_NAMES = [
  '新的对话',
  '编程助手',
  '学习助手',
  '创意写作',
  '问题解答',
  '翻译助手',
  '代码审查',
  '头脑风暴'
];

// 欢迎消息结构
export interface WelcomeMessage {
  greeting: string;
  introduction: string;
  capabilities: string;
}

// 欢迎消息映射
export interface WelcomeMessageMap {
  zh_CN: WelcomeMessage;
  en_US: WelcomeMessage;
}

// 欢迎消息模板
export const WELCOME_MESSAGES: WelcomeMessageMap = {
  zh_CN: {
    greeting: '🎉 欢迎使用 ChatwithAI！',
    introduction: '我是你的AI助手，可以帮助你解答问题、协助工作、进行创作等。有什么我可以帮助你的吗？',
    capabilities: `我具备以下功能：

💬 **智能对话**：自然流畅的多轮对话
📝 **文本创作**：写作、翻译、摘要等
🤔 **问题解答**：各领域知识问答
💡 **创意思考**：头脑风暴、方案建议
📚 **学习辅助**：概念解释、习题解答
🛠️ **代码编程**：编程语言支持和调试

你可以随时提问，我会尽力为你提供有帮助的回答！`
  },
  en_US: {
    greeting: '🎉 Welcome to ChatwithAI!',
    introduction: 'I\'m your AI assistant, ready to help you with questions, work, and creativity. How can I assist you today?',
    capabilities: `Here are my capabilities:

💬 **Smart Conversations**: Natural and fluent multi-turn dialogues
📝 **Text Creation**: Writing, translation, summarization, and more
🤔 **Q&A**: Knowledge-based question answering across various domains
💡 **Creative Thinking**: Brainstorming and solution suggestions
📚 **Learning Support**: Concept explanations and problem solving
🛠️ **Code Programming**: Programming language support and debugging

Feel free to ask me anything, and I'll do my best to provide helpful answers!`
  }
};

// 对话示例结构
export interface ConversationSample {
  name: string;
  userMessage: string;
  assistantReply: string;
}

// 示例对话集合
export interface SampleConversations {
  coding: ConversationSample;
  learning: ConversationSample;
}

// 示例对话模板
export const SAMPLE_CONVERSATIONS: SampleConversations = {
  coding: {
    name: '编程助手示例',
    userMessage: '请帮我写一个 HarmonyOS 的 Hello World 程序',
    assistantReply: `好的！这里是一个简单的 HarmonyOS Hello World 程序：

\`\`\`typescript
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}
\`\`\`

这个程序会在屏幕中央显示 "Hello World" 文本。`
  },
  learning: {
    name: '学习助手示例',
    userMessage: '什么是人工智能？',
    assistantReply: `人工智能（Artificial Intelligence，AI）是计算机科学的一个分支，致力于创造能够像人类一样思考、学习和解决问题的机器。

主要特点包括：
• **机器学习**：从数据中学习和改进
• **自然语言处理**：理解和生成人类语言
• **计算机视觉**：识别和分析图像
• **推理决策**：基于信息做出判断

AI 已广泛应用于搜索引擎、推荐系统、自动驾驶、医疗诊断等领域。`
  }
};

// 获取默认设置
export function getDefaultSettings(): AppSettings {
  return {
    defaultProvider: DEFAULT_SETTINGS.defaultProvider,
    defaultModel: DEFAULT_SETTINGS.defaultModel,
    temperature: DEFAULT_SETTINGS.temperature,
    maxTokens: DEFAULT_SETTINGS.maxTokens,
    maxContextMessages: DEFAULT_SETTINGS.maxContextMessages,
    theme: DEFAULT_SETTINGS.theme,
    language: DEFAULT_SETTINGS.language,
    fontSize: DEFAULT_SETTINGS.fontSize,
    showWordCount: DEFAULT_SETTINGS.showWordCount,
    showTokenCount: DEFAULT_SETTINGS.showTokenCount,
    autoSave: DEFAULT_SETTINGS.autoSave,
    enableMarkdown: DEFAULT_SETTINGS.enableMarkdown,
    enableCodeHighlight: DEFAULT_SETTINGS.enableCodeHighlight,
    sendOnEnter: DEFAULT_SETTINGS.sendOnEnter,
    allowTracking: DEFAULT_SETTINGS.allowTracking,
    saveHistory: DEFAULT_SETTINGS.saveHistory
  };
}

// 获取支持的模型列表
export function getSupportedModels(provider?: AIProvider): ModelConfig[] {
  if (provider) {
    return DEFAULT_MODELS.filter(model => model.provider === provider);
  }
  let result: ModelConfig[] = [];
  for (let i = 0; i < DEFAULT_MODELS.length; i++) {
    result.push(DEFAULT_MODELS[i]);
  }
  return result;
}

// 获取欢迎消息
export function getWelcomeMessages(language: Language = Language.ZH_CN): WelcomeMessage {
  if (language === Language.ZH_CN) {
    return WELCOME_MESSAGES.zh_CN;
  } else if (language === Language.EN_US) {
    return WELCOME_MESSAGES.en_US;
  } else {
    return WELCOME_MESSAGES.zh_CN;
  }
}

// 获取示例对话
export function getSampleConversations(): SampleConversations {
  return {
    coding: {
      name: SAMPLE_CONVERSATIONS.coding.name,
      userMessage: SAMPLE_CONVERSATIONS.coding.userMessage,
      assistantReply: SAMPLE_CONVERSATIONS.coding.assistantReply
    },
    learning: {
      name: SAMPLE_CONVERSATIONS.learning.name,
      userMessage: SAMPLE_CONVERSATIONS.learning.userMessage,
      assistantReply: SAMPLE_CONVERSATIONS.learning.assistantReply
    }
  };
}

// 获取随机会话名称
export function getRandomSessionName(): string {
  const index = Math.floor(Math.random() * DEFAULT_SESSION_NAMES.length);
  return DEFAULT_SESSION_NAMES[index];
}

// 获取提供商配置
export function getProviderConfig(provider: AIProvider): ProviderConfig | undefined {
  return DEFAULT_PROVIDERS.find(p => p.id === provider);
}

// 获取所有提供商配置
export function getAllProviders(): ProviderConfig[] {
  let result: ProviderConfig[] = [];
  for (let i = 0; i < DEFAULT_PROVIDERS.length; i++) {
    result.push(DEFAULT_PROVIDERS[i]);
  }
  return result;
}

// 获取提供商支持的模型
export function getProviderModels(provider: AIProvider): ModelConfig[] {
  return DEFAULT_MODELS.filter(model => model.provider === provider);
} 