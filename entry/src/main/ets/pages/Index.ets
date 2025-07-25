import { DataService } from '../services/DataService';
import { AIService } from '../services/AIService';
import { ChatSession, ChatMessage, CreateMessageParams } from '../models/ChatModels';
import { InitData } from '../setups/InitData';
import { EnhancedMarkdownText } from '../utils/MarkdownItRenderer';
import PreferencesUtil from '../utils/PreferencesUtil';
import router from '@ohos.router';
import { AIProvider, DEFAULT_PROVIDERS, DEFAULT_MODELS, getProviderModels, ProviderConfig, ModelConfig } from '../setups/DefaultConfig';

@Entry
@Component
struct Index {
  // 当前选中的会话ID
  @State currentSessionId: string = '';
  // 用户输入的消息
  @State inputMessage: string = '';
  // 第一栏折叠状态
  @State isFirstColumnCollapsed: boolean = false;
  // 第一栏宽度
  @State firstColumnWidth: number = 280;
  // 拖拽状态
  @State isDragging: boolean = false;
  // 拖拽开始时的宽度
  private dragStartWidth: number = 0;
  // 数据服务实例
  private dataService = DataService.getInstance();
  // AI 服务实例
  private aiService = AIService.getInstance();
  // 对话会话列表数据
  @State chatSessions: ChatSession[] = [];
  // 当前会话的消息列表
  @State currentMessages: ChatMessage[] = [];
  // 消息列表滚动控制器
  private messageListScroller = new Scroller();
  // 本地下拉菜单状态
  @State showProviderMenu: boolean = false;
  @State showModelMenu: boolean = false;
  // 下拉菜单展开时隐藏输入框
  @State @Watch('onHideInputChange') hideInput: boolean = false;
  // 当前保存的AI平台和模型（用于传递给PlatformModelSelector）
  @State savedAiProvider: string = 'deepseek';
  @State savedAiModel: string = 'deepseek-chat';
  // 加载消息时的定时器ID
  private loadingTimerId: number | undefined;

  // 监听下拉菜单状态变化，触发滚动
  onHideInputChange(newVal: boolean, oldVal: boolean) {
    if (newVal !== oldVal) {
      if (newVal) {
        console.info('下拉菜单展开，滚动到底部确保可见性');
        // 菜单展开时立即滚动，延迟较短
        const delays: number[] = [50, 150, 300, 600, 1000];
        delays.forEach(d => {
          setTimeout(() => {
            console.info(`菜单展开 - 延迟 ${d}ms 后尝试滚动到底部`);
            this.scrollToBottom();
          }, d);
        });
      } else {
        console.info('下拉菜单关闭，恢复滚动位置');
        // 菜单关闭时需要更多时间等待布局恢复
        const delays: number[] = [50, 150, 300, 600, 1000];
        delays.forEach(d => {
          setTimeout(() => {
            console.info(`菜单关闭 - 延迟 ${d}ms 后尝试滚动到底部`);
            this.scrollToBottom();
          }, d);
        });
      }
    }
  }

  // 组件初始化
  async aboutToAppear() {
    try {
      // 初始化首选项
      await PreferencesUtil.init(getContext(this));
      
      // 加载保存的界面状态
      this.isFirstColumnCollapsed = await PreferencesUtil.getFirstColumnCollapseState();
      this.firstColumnWidth = await PreferencesUtil.getFirstColumnWidth();
      const savedSessionId = await PreferencesUtil.getSelectedSessionId();
      
      // 初始化数据库
      await this.dataService.initialize(getContext(this));
      // 初始化 AI 服务
      await this.aiService.initialize(getContext(this));
      
      // 从首选项加载保存的AI平台和模型选择
      console.info('=== 开始加载AI设置 ===');
      const savedProvider = await PreferencesUtil.getCurrentAiProvider();
      const savedModel = await PreferencesUtil.getCurrentAiModel();
      console.info('从首选项读取 - 平台:', savedProvider, '模型:', savedModel);
      
      // 设置AI平台和模型
      this.aiService.setCurrentProvider(savedProvider);
      this.aiService.setCurrentModel(savedModel);
      console.info('设置AI服务 - 平台:', savedProvider, '模型:', savedModel);
      
      // 更新状态变量，用于传递给PlatformModelSelector
      this.savedAiProvider = savedProvider;
      this.savedAiModel = savedModel;
      console.info('更新状态变量 - 平台:', this.savedAiProvider, '模型:', this.savedAiModel);
      
      console.info('=== AI设置加载完成 ===');
      
      // 加载会话列表
      await this.loadSessions();
      
      // 恢复选中的会话或选择第一个
      if (savedSessionId && this.chatSessions.find(session => session.id === savedSessionId)) {
        await this.switchSession(savedSessionId);
      } else if (this.chatSessions.length > 0) {
        await this.switchSession(this.chatSessions[0].id);
      }
    } catch (error) {
      console.error('初始化失败:', error);
    }
  }

  // 加载会话列表
  async loadSessions() {
    try {
      const result = await this.dataService.getAllSessions({
        orderBy: 'updated_at',
        orderDirection: 'DESC'
      });
      this.chatSessions = result.data;
    } catch (error) {
      console.error('加载会话列表失败:', error);
    }
  }

  // 加载当前会话的消息
  async loadCurrentMessages() {
    if (!this.currentSessionId) {
      return;
    }
    
    try {
      const result = await this.dataService.getMessagesBySessionId(this.currentSessionId, {
        orderBy: 'timestamp',
        orderDirection: 'ASC'
      });
      this.currentMessages = result.data;
      
      // 加载消息后滚动到底部
      if (this.currentMessages.length > 0) {
        setTimeout(() => {
          this.scrollToBottom();
        }, 200); // 给更多时间让UI完全渲染
      }
    } catch (error) {
      console.error('加载消息失败:', error);
    }
  }

  // 发送消息
  async sendMessage() {
    if (this.inputMessage.trim() === '' || !this.currentSessionId) {
      return;
    }
    
    const userContent = this.inputMessage;
    this.inputMessage = '';

    try {
      // 创建用户消息
      const userMessage = await this.dataService.createMessage({
        sessionId: this.currentSessionId,
        role: 'user',
        content: userContent
      });

      // 更新UI
      this.currentMessages.push(userMessage);
      
      // 滚动到底部显示新消息
      this.scrollToBottom();

      // 创建一个临时的加载消息
      const loadingMessage: ChatMessage = {
        id: 'loading_' + Date.now(),
        sessionId: this.currentSessionId,
        role: 'assistant',
        content: '0',
        timestamp: Date.now(),
        wordCount: 0,
        tokenCount: 0,
        generating: true,
        aiProvider: this.aiService.getCurrentProvider(),
        model: this.aiService.getCurrentModel()
      };

      // 先推入数组，再开始计时，确保第一秒能找到消息
      this.currentMessages.push(loadingMessage);
      
      // 启动读秒定时器，更新 loadingMessage.content
      const loadingStart = Date.now();
      const updateLoading = () => {
        const idx = this.currentMessages.findIndex(m => m.id === loadingMessage.id);
        if (idx !== -1) {
          const elapsed = Math.floor((Date.now() - loadingStart) / 1000);
          this.currentMessages[idx].content = `思考 ${elapsed} 秒`;
          // 触发 UI 更新
          this.currentMessages = [...this.currentMessages];
        }
      };
      updateLoading();
      this.loadingTimerId = setInterval(updateLoading, 1000);
      
      // 滚动到底部显示加载消息
      this.scrollToBottom();

      // 调用 AI 服务获取回复
      try {
        console.info('开始调用 AI 服务...');
        const aiReply = await this.aiService.sendMessage(this.currentMessages.slice(0, -1), userContent);
        console.info('AI 服务回复:', aiReply);

        // 移除加载消息
        const loadingIndex = this.currentMessages.findIndex(msg => msg.id === loadingMessage.id);
        if (loadingIndex !== -1) {
          this.currentMessages.splice(loadingIndex, 1);
        }
        // 清除定时器
        if (this.loadingTimerId) {
          clearInterval(this.loadingTimerId);
          this.loadingTimerId = undefined;
        }

        // 创建真实的AI回复消息
        const aiMessage = await this.dataService.createMessage({
          sessionId: this.currentSessionId,
          role: 'assistant',
          content: aiReply
        });
        
        // 记录使用的AI平台和模型信息并写回数据库
        const provider = this.aiService.getCurrentProvider();
        const model = this.aiService.getCurrentModel();
        aiMessage.aiProvider = provider;
        aiMessage.model = model;
        // 持久化到数据库
        await this.dataService.updateMessage(aiMessage.id, { aiProvider: provider, model: model });
        
        this.currentMessages.push(aiMessage);
        
        // 滚动到底部显示AI回复
        this.scrollToBottom();

        // 如果会话标题仍为默认值，则尝试自动生成标题
        const currentSession = this.chatSessions.find(s => s.id === this.currentSessionId);
        if (currentSession && currentSession.name === '新对话') {
          try {
            const newTitle = await this.aiService.generateTitle(userContent, aiReply);
            if (newTitle && newTitle.trim().length > 0) {
              await this.dataService.updateSession(this.currentSessionId, { name: newTitle });
              currentSession.name = newTitle;
              // 触发UI更新
              this.chatSessions = [...this.chatSessions];
              console.info('自动生成并更新会话标题:', newTitle);
            }
          } catch (titleError) {
            console.error('自动生成标题失败:', titleError);
          }
        }

      } catch (aiError) {
        console.error('AI 服务调用失败:', aiError);
        
        // 移除加载消息
        const loadingIndex = this.currentMessages.findIndex(msg => msg.id === loadingMessage.id);
        if (loadingIndex !== -1) {
          this.currentMessages.splice(loadingIndex, 1);
        }
        // 清除定时器
        if (this.loadingTimerId) {
          clearInterval(this.loadingTimerId);
          this.loadingTimerId = undefined;
        }

        // 安全地获取错误消息
        const errorMsg = (aiError instanceof Error) ? aiError.message : '未知错误';

        // 创建错误回复消息
        const errorMessage = await this.dataService.createMessage({
          sessionId: this.currentSessionId,
          role: 'assistant',
          content: `抱歉，我暂时无法回复您的消息。错误信息：${errorMsg}`
        });
        
        const errProvider = this.aiService.getCurrentProvider();
        const errModel = this.aiService.getCurrentModel();
        errorMessage.aiProvider = errProvider;
        errorMessage.model = errModel;
        await this.dataService.updateMessage(errorMessage.id, { aiProvider: errProvider, model: errModel });
        
        this.currentMessages.push(errorMessage);
        
        // 滚动到底部显示错误消息
        this.scrollToBottom();
      }

    } catch (error) {
      console.error('发送消息失败:', error);
    }
  }

  // 切换会话
  async switchSession(sessionId: string) {
    this.currentSessionId = sessionId;
    await this.loadCurrentMessages();
    
    // 保存选中的会话ID
    PreferencesUtil.saveSelectedSessionIdSync(sessionId);
  }

  // 切换第一栏折叠状态
  toggleFirstColumn() {
    this.isFirstColumnCollapsed = !this.isFirstColumnCollapsed;
    
    // 保存折叠状态
    PreferencesUtil.saveFirstColumnCollapseStateSync(this.isFirstColumnCollapsed);
    
    console.info('第一栏折叠状态:', this.isFirstColumnCollapsed);
  }

  // 双击重置宽度到默认值
  resetColumnWidth() {
    this.firstColumnWidth = 280; // 默认宽度
    PreferencesUtil.saveFirstColumnWidthSync(this.firstColumnWidth);
    console.info('第一栏宽度已重置为默认值:', this.firstColumnWidth);
  }



  // 创建新会话
  async createNewSession() {
    try {
      const newSession = await this.dataService.createSession({
        name: '新对话',
        type: 'chat'
      });
      
      // 重新加载会话列表
      await this.loadSessions();
      
      // 切换到新会话
      await this.switchSession(newSession.id);
    } catch (error) {
      console.error('创建新会话失败:', error);
    }
  }

  // 重置应用数据（开发测试用）
  async resetAppData() {
    try {
      console.info('=== 开始重置应用数据 ===');
      
      // 重置数据
      await InitData.resetAppData(getContext(this));
      
      // 重置 DataService 状态并重新初始化
      this.dataService = DataService.getInstance();
      this.dataService.resetForTesting();
      console.info('重新初始化 DataService...');
      await this.dataService.initialize(getContext(this));
      
      // 重新初始化 AI 服务
      this.aiService = AIService.getInstance();
      console.info('重新初始化 AIService...');
      await this.aiService.initialize(getContext(this));
      
      console.info('重新加载会话列表...');
      // 重新加载数据
      await this.loadSessions();
      console.info(`加载到 ${this.chatSessions.length} 个会话`);
      
      // 如果有会话，选择第一个
      if (this.chatSessions.length > 0) {
        console.info('切换到第一个会话:', this.chatSessions[0].name);
        await this.switchSession(this.chatSessions[0].id);
        console.info(`当前会话有 ${this.currentMessages.length} 条消息`);
      } else {
        console.warn('没有找到任何会话');
        this.currentSessionId = '';
        this.currentMessages = [];
      }
      
      console.info('=== 应用数据重置完成 ===');
    } catch (error) {
      console.error('重置应用数据失败:', error);
    }
  }

  // 格式化时间戳
  formatTimestamp(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    
    if (diff < 60000) { // 1分钟内
      return '刚刚';
    } else if (diff < 3600000) { // 1小时内
      return `${Math.floor(diff / 60000)}分钟前`;
    } else if (diff < 86400000) { // 1天内
      return `${Math.floor(diff / 3600000)}小时前`;
    } else {
      return `${Math.floor(diff / 86400000)}天前`;
    }
  }

  // 处理平台变化
  onProviderChange(provider: AIProvider) {
    console.info('=== 处理平台变化 ===');
    console.info('新平台:', provider);
    const providerString = provider.toString();
    
    // 设置AI服务
    this.aiService.setCurrentProvider(providerString);
    console.info('AI服务平台已设置为:', providerString);
    
    // 更新状态变量
    this.savedAiProvider = providerString;
    console.info('状态变量已更新 - savedAiProvider:', this.savedAiProvider);
    
    // 立即同步保存，避免应用退出前未完成写入
    PreferencesUtil.saveCurrentAiProviderSync(providerString);
    console.info('平台同步保存完成:', providerString);
    
    // 可以在这里添加平台切换的用户提示
    // 比如显示Toast提示用户是否已配置API密钥
  }

  // 处理模型变化
  onModelChange(model: string) {
    console.info('=== 处理模型变化 ===');
    console.info('新模型:', model);
    
    // 设置AI服务
    this.aiService.setCurrentModel(model);
    console.info('AI服务模型已设置为:', model);
    
    // 更新状态变量
    this.savedAiModel = model;
    console.info('状态变量已更新 - savedAiModel:', this.savedAiModel);
    
    // 使用同步方法立即持久化
    PreferencesUtil.saveCurrentAiModelSync(model);
    console.info('模型同步保存完成:', model);
  }

  // 获取平台对应的图标资源
  private getPlatformIcon(provider: string): Resource {
    switch (provider) {
      case 'openai':
        return $r('app.media.openai');
      case 'azure':
        return $r('app.media.azure');
      case 'claude':
        return $r('app.media.claude');
      case 'gemini':
        return $r('app.media.gemini');
      case 'deepseek':
        return $r('app.media.deepseek');
      case 'siliconflow':
        return $r('app.media.siliconflow');
      case 'volcengine':
        return $r('app.media.volcengine');
      case 'xAI':
        return $r('app.media.xAI');
      case 'groq':
        return $r('app.media.groq');
      case 'chatglm-6b':
        return $r('app.media.chatglm');
      case 'ollama':
        return $r('app.media.ollama');
      case 'lm-studio':
        return $r('app.media.lmstudio');
      case 'perplexity':
        return $r('app.media.perplexity');
      case 'local':
        return $r('app.media.icon');
      default:
        return $r('app.media.deepseek'); // 默认使用DeepSeek图标
    }
  }

  // 关闭下拉菜单
  private closeDropdownMenus() {
    this.showProviderMenu = false;
    this.showModelMenu = false;
    this.hideInput = false;
  }

  // 获取当前选中的提供商信息
  private getCurrentProviderInfo(): ProviderConfig | undefined {
    return DEFAULT_PROVIDERS.find(p => p.id === this.savedAiProvider);
  }

  // 获取当前提供商支持的模型
  private getAvailableModels(): ModelConfig[] {
    return getProviderModels(this.savedAiProvider as AIProvider);
  }

  // 获取当前选中的模型信息
  private getCurrentModelInfo(): ModelConfig | undefined {
    return DEFAULT_MODELS.find(m => m.id === this.savedAiModel && m.provider === this.savedAiProvider);
  }

  // 滚动到消息列表底部
  private scrollToBottom() {
    try {
      if (this.currentMessages.length > 0) {
        // 使用多种滚动方法确保成功
        try {
          // 方法1：直接滚动到底部边缘
          this.messageListScroller.scrollEdge(Edge.Bottom);
          console.info('使用scrollEdge方法滚动成功');
        } catch (scrollError) {
          console.warn('scrollEdge失败，尝试其他方法:', scrollError);
          try {
            // 方法2：滚动到最后一个元素
            this.messageListScroller.scrollToIndex(this.currentMessages.length - 1, true);
            console.info('使用scrollToIndex方法滚动成功');
          } catch (indexScrollError) {
            console.warn('scrollToIndex失败，尝试scrollTo方法:', indexScrollError);
            try {
              // 方法3：滚动到一个很大的位置
              this.messageListScroller.scrollTo({ xOffset: 0, yOffset: 999999 });
              console.info('使用scrollTo方法滚动成功');
            } catch (scrollToError) {
              console.error('所有滚动方法都失败了:', scrollToError);
            }
          }
        }
      }
    } catch (error) {
      console.error('滚动到底部失败:', error);
    }
  }

  build() {
    Row() {
      // 左侧对话列表
      Column() {
        // 标题栏
        Row() {
          Text('对话列表')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Blank()
          
          // 新建对话按钮
          Button() {
            Image($r('app.media.new'))
              .width(20)
              .height(20)
          }
          .width(32)
          .height(32)
          .backgroundColor('#fff')
          .borderRadius(16)
          .onClick(() => {
            this.createNewSession();
          })
        }
        .width('100%')
        .height(60)
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .backgroundColor('#F5F5F5')
        
        Divider()
          .color('#E0E0E0')
          .strokeWidth(1)
        
        // 对话会话列表
        List() {
          ForEach(this.chatSessions, (session: ChatSession) => {
            ListItem() {
              Column() {
                Row() {
                  Text(session.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.currentSessionId === session.id ? '#007AFF' : '#333333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  
                  Blank()
                  
                  Text(this.formatTimestamp(session.updatedAt))
                    .fontSize(12)
                    .fontColor('#999999')
                    .width(64)
                    .textAlign(TextAlign.End)
                }
                .width('100%')
                .margin({ bottom: 4 })
                
                Text(session.threadName || '暂无消息')
                  .fontSize(14)
                  .fontColor('#666666')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor(this.currentSessionId === session.id ? '#E3F2FD' : '#FFFFFF')
              .alignItems(HorizontalAlign.Start)
            }
            .onClick(() => {
              // 关闭下拉菜单
              this.closeDropdownMenus();
              this.switchSession(session.id);
            })
          })
        }
        .layoutWeight(1)
        .width('100%')
        .divider({
          strokeWidth: 1,
          color: '#F0F0F0'
        })
        
        // 底部宽度显示（仅在拖拽时显示）
        if (this.isDragging) {
          Row() {
            Text(`宽度: ${Math.round(this.firstColumnWidth)}px`)
              .fontSize(11)
              .fontColor('#666666')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#F0F0F0')
              .borderRadius(4)
          }
          .width('100%')
          .height(28)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .backgroundColor('#FAFAFA')
        }
      }
      .width(this.isFirstColumnCollapsed ? 0 : this.firstColumnWidth)
      .height('100%')
      .backgroundColor('#FAFAFA')
      .visibility(this.isFirstColumnCollapsed ? Visibility.None : Visibility.Visible)
      
      // 可拖拽的分割线手柄
      if (!this.isFirstColumnCollapsed) {
        Stack() {
          // 背景区域
          Column()
            .width(6)
            .height('100%')
            .backgroundColor('#F8F9FA')
          
          // 分割线
          Column()
            .width(1)
            .height('100%')
            .backgroundColor(this.isDragging ? '#007AFF' : '#E0E0E0')
          
          // 拖拽指示器（中间的小竖条）
          Column() {
            Column()
              .width(3)
              .height(40)
              .backgroundColor(this.isDragging ? '#007AFF' : '#E0E0E0')
              .borderRadius(1.5)
              .opacity(this.isDragging ? 0.8 : 0.4)
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
          }
          .justifyContent(FlexAlign.Center)
          .height('100%')
        }
        .width(6)
        .height('100%')
        .gesture(
          // 拖拽手势 - 调整宽度
          GestureGroup(GestureMode.Exclusive,
            PanGesture({ fingers: 1, direction: PanDirection.Horizontal })
              .onActionStart(() => {
                this.isDragging = true;
                this.dragStartWidth = this.firstColumnWidth; // 记录起始宽度
                console.info('开始拖拽调整宽度，起始宽度:', this.dragStartWidth);
              })
              .onActionUpdate((event: GestureEvent) => {
                if (!this.isFirstColumnCollapsed) {
                  // 基于起始宽度和偏移量计算新宽度
                  let newWidth = this.dragStartWidth + event.offsetX;
                  // 限制宽度范围：最小180px，最大500px
                  newWidth = Math.max(180, Math.min(500, newWidth));
                  this.firstColumnWidth = newWidth;
                }
              })
              .onActionEnd(() => {
                this.isDragging = false;
                // 保存新的宽度到本地存储
                PreferencesUtil.saveFirstColumnWidthSync(this.firstColumnWidth);
                console.info('拖拽结束，最终宽度:', this.firstColumnWidth);
              }),
            // 双击手势 - 重置宽度
            TapGesture({ count: 2 })
              .onAction(() => {
                this.resetColumnWidth();
              })
          )
        )
      }
      
      // 右侧对话区域
      Column() {
        // 对话历史区域
        Column() {
          // 当前会话标题
          Row() {
            // 第一栏折叠按钮
            Button() {
              Image(this.isFirstColumnCollapsed ? $r('app.media.show') : $r('app.media.hide'))
                .width(20)
                .height(20)
                .fillColor('#fff')
                .transition({
                  type: TransitionType.All,
                  scale: { x: 0.9, y: 0.9 },
                  opacity: 0.8
                })
            }
            .width(32)
            .height(32)
            .backgroundColor('#fff')
            .borderRadius(16)
            .margin({ right: 12 })
            .stateEffect(true)
            .onClick(() => {
              this.toggleFirstColumn();
            })
            .transition({
              type: TransitionType.All,
              scale: { x: 1.05, y: 1.05 }
            })
            
            Text(this.chatSessions.find(session => session.id === this.currentSessionId)?.name ?? '新对话')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
          .height(60)
          .padding({ left: 16, right: 16 })
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .backgroundColor('#F8F9FA')
          .flexShrink(0)
          
          Divider()
            .color('#E0E0E0')
            .strokeWidth(1)
          
          // 消息列表
          List({ scroller: this.messageListScroller }) {
            ForEach(this.currentMessages, (message: ChatMessage, index: number) => {
              ListItem() {
                Row() {
                  if (message.role === 'user') {
                    Blank()
                    
                    Row() {
                      Column() {
                        Text(message.content)
                          .fontSize(16)
                          .fontColor('#FFFFFF')
                          .padding(12)
                          .backgroundColor('#007AFF')
                          .borderRadius(12)
                          .margin({ bottom: 4 })
                        
                        Text(this.formatTimestamp(message.timestamp))
                          .fontSize(12)
                          .fontColor('#999999')
                          .alignSelf(ItemAlign.End)
                      }
                      .alignItems(HorizontalAlign.End)
                      .layoutWeight(1)
                      
                      // 用户头像
                      Image($r('app.media.user'))
                        .width(32)
                        .height(32)
                        .borderRadius(16)
                        .margin({ left: 8 })
                        .border({ width: 1, color: '#E0E0E0' })
                    }
                    .alignItems(VerticalAlign.Top)
                    .margin({ left: 60 })
                  } else {
                    Row() {
                      // AI平台头像
                      Image(this.getPlatformIcon(message.aiProvider || this.aiService.getCurrentProvider()))
                        .width(32)
                        .height(32)
                        .borderRadius(16)
                        .margin({ right: 8 })
                        .border({ width: 1, color: '#E0E0E0' })
                      
                      Column() {
                        Row() {
                          // 根据消息状态选择不同的显示组件
                          if (message.generating) {
                            // 加载状态显示简单文本
                            Text(message.content)
                              .fontSize(16)
                              .fontColor('#666666')
                              .padding(12)
                              .backgroundColor('#E8F4FD')
                              .borderRadius(12)
                              .margin({ bottom: 4 })
                          } else {
                            // 完成状态显示增强版 Markdown 渲染文本
                            Column() {
                              EnhancedMarkdownText({
                                content: message.content,
                                fontSize: 16,
                                fontColor: '#333333'
                              })
                            }
                            .padding(12)
                            .backgroundColor('#F1F1F1')
                            .borderRadius(12)
                            .margin({ bottom: 4 })
                            .alignItems(HorizontalAlign.Start)
                          }
                          
                          if (message.generating) {
                            // 在加载状态时，这里不再显示动画省略号，而是仅显示气泡内的倒计时
                          }
                        }
                        .alignItems(VerticalAlign.Bottom)
                        
                        Text(this.formatTimestamp(message.timestamp))
                          .fontSize(12)
                          .fontColor('#999999')
                          .alignSelf(ItemAlign.Start)
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                    }
                    .alignItems(VerticalAlign.Top)
                    .margin({ right: 60 })
                    
                    Blank()
                  }
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              }
            })
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
        }
        .layoutWeight(1)
        .width('100%')
        .onClick(() => {
          // 点击对话历史区域时关闭下拉菜单
          this.closeDropdownMenus();
        })
        
        Divider()
          .color('#E0E0E0')
          .strokeWidth(1)
        
        // AI平台与模型选择器（内嵌）
        Column() {
          Row() {
            Text('AI平台与模型')
              .fontSize(14)
              .fontColor('#666666')
              .fontWeight(FontWeight.Medium)
              .width(100)
              .padding({ left: 12, right: 4 })

            // 平台选择按钮
            Button() {
              Row() {
                Text(this.getCurrentProviderInfo()?.name || '未知')
                  .fontSize(13)
                  .fontColor('#333333')
                  .layoutWeight(1)
                  .textAlign(TextAlign.Start)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text('▼')
                  .fontSize(10)
                  .fontColor('#666666')
                  .rotate({ angle: this.showProviderMenu ? 180 : 0 })
                  .animation({ duration: 200, curve: Curve.EaseInOut })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
            }
            .width(100)
            .height(30)
            .backgroundColor('#F8F9FA')
            .borderRadius(4)
            .padding({ left: 6, right: 6 })
            .margin({ left: 8, right: 8 })
            .onClick(() => {
              this.showProviderMenu = !this.showProviderMenu;
              this.showModelMenu = false;
              this.hideInput = this.showProviderMenu || this.showModelMenu;
            })

            // 模型选择按钮
            Button() {
              Row() {
                Text(this.getCurrentModelInfo()?.name || '未知')
                  .fontSize(13)
                  .fontColor('#333333')
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .textAlign(TextAlign.Start)

                if (this.getCurrentModelInfo() && this.getCurrentModelInfo()!.supportVision) {
                  Text('👁️').fontSize(9).margin({ right: 2 });
                }
                if (this.getCurrentModelInfo() && this.getCurrentModelInfo()!.supportTools) {
                  Text('🔧').fontSize(9).margin({ right: 2 });
                }

                if (this.getCurrentModelInfo()) {
                  Text(`${(this.getCurrentModelInfo()!.contextWindow / 1000).toFixed(0)}K`)
                    .fontSize(11)
                    .fontColor('#999999')
                    .margin({ right: 4 });
                }

                Text('▼')
                  .fontSize(10)
                  .fontColor('#666666')
                  .rotate({ angle: this.showModelMenu ? 180 : 0 })
                  .animation({ duration: 200, curve: Curve.EaseInOut })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
            }
            .width(320)
            .height(30)
            .backgroundColor('#F8F9FA')
            .borderRadius(4)
            .padding({ left: 6, right: 6 })
            .onClick(() => {
              this.showModelMenu = !this.showModelMenu;
              this.showProviderMenu = false;
              this.hideInput = this.showProviderMenu || this.showModelMenu;
            })

            Blank()

            // 设置按钮
            Button() {
              Image($r('app.media.setting'))
                .width(16)
                .height(16)
                .fillColor('#666666')
            }
            .width(30)
            .height(30)
            .backgroundColor('#F8F9FA')
            .borderRadius(4)
            .margin({ left: 8 })
            .onClick(() => {
              // 关闭下拉菜单
              this.showProviderMenu = false;
              this.showModelMenu = false;
              this.hideInput = false;

              // 跳转到设置页面
              router.pushUrl({ url: 'pages/Platform' }).catch((error: Error) => {
                console.error('跳转到设置页面失败:', error.message);
              });
            })
          }
          .width('100%')
          .height(42)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .padding({ left: 4, right: 4, top: 6, bottom: 6 })
          .backgroundColor('#FFFFFF')
          .borderRadius(4)
          .border({ width: 1, color: '#E0E0E0' })
          .onClick(() => {
            this.closeDropdownMenus();
          })

          // 平台下拉菜单
          if (this.showProviderMenu) {
            List() {
              ForEach(DEFAULT_PROVIDERS, (provider: ProviderConfig) => {
                ListItem() {
                  Button() {
                    Row() {
                      Text(provider.name)
                        .fontSize(13)
                        .fontColor(this.savedAiProvider === provider.id ? '#007AFF' : '#333333')
                        .fontWeight(this.savedAiProvider === provider.id ? FontWeight.Medium : FontWeight.Normal)
                      Blank()
                      if (this.savedAiProvider === provider.id) {
                        Text('✓').fontSize(11).fontColor('#007AFF');
                      }
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .height(34)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.savedAiProvider === provider.id ? '#E3F2FD' : '#FFFFFF')
                  .borderRadius(4)
                  .onClick(() => {
                    if (this.savedAiProvider !== provider.id) {
                      this.onProviderChange(provider.id);
                      // 切换到新平台首个模型
                      const models = this.getAvailableModels();
                      if (models.length > 0) {
                        this.onModelChange(models[0].id);
                      }
                    }
                    this.showProviderMenu = false;
                    this.hideInput = false;
                  })
                }
              })
            }
            .width(200)
            .height(102)
            .backgroundColor('#FFFFFF')
            .borderRadius(4)
            .border({ width: 1, color: '#E0E0E0' })
            .padding(4)
            .margin({ left: 108, top: 4, bottom: 4 })
            .scrollBar(BarState.Auto)
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
            .animation({ duration: 200, curve: Curve.EaseInOut })
          }

          // 模型下拉菜单
          if (this.showModelMenu) {
            List() {
              ForEach(this.getAvailableModels(), (model: ModelConfig) => {
                ListItem() {
                  Button() {
                    Row() {
                      Text(model.name)
                        .fontSize(13)
                        .fontColor(this.savedAiModel === model.id ? '#007AFF' : '#333333')
                        .fontWeight(this.savedAiModel === model.id ? FontWeight.Medium : FontWeight.Normal)
                        .layoutWeight(1)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      if (model.supportVision) {
                        Text('👁️').fontSize(9).margin({ right: 4 });
                      }
                      if (model.supportTools) {
                        Text('🔧').fontSize(9).margin({ right: 4 });
                      }

                      Text(`${(model.contextWindow / 1000).toFixed(0)}K`)
                        .fontSize(10)
                        .fontColor('#999999')
                        .margin({ right: 8 });

                      if (this.savedAiModel === model.id) {
                        Text('✓').fontSize(11).fontColor('#007AFF');
                      }
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .height(34)
                  .backgroundColor(this.savedAiModel === model.id ? '#E3F2FD' : '#FFFFFF')
                  .borderRadius(4)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .onClick(() => {
                    if (this.savedAiModel !== model.id) {
                      this.onModelChange(model.id);
                    }
                    this.showModelMenu = false;
                    this.hideInput = false;
                  })
                }
              })
            }
            .width(400)
            .height(102)
            .backgroundColor('#FFFFFF')
            .borderRadius(4)
            .border({ width: 1, color: '#E0E0E0' })
            .padding(4)
            .margin({ left: 216, top: 4, bottom: 4 })
            .scrollBar(BarState.Auto)
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
            .animation({ duration: 200, curve: Curve.EaseInOut })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16, right: 16, top: 6, bottom: 6 })
        
        // 底部输入区域
        if (!this.hideInput) {
          Row() {
            TextArea({ placeholder: '输入消息...', text: this.inputMessage })
              .layoutWeight(1)
              .height(99)  // 固定3行高度
              .fontSize(16)
              .lineHeight(24)  // 增加行间距，提升可读性
              .backgroundColor('#F8F9FA')
              .borderRadius(12)
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .border({ width: 1, color: '#E0E0E0' })
              .maxLines(1024)  // 最多支持1024行
              .onChange((value: string) => {
                this.inputMessage = value;
                // 当用户开始输入时，确保可以看到输入框
                if (value.length > 0 && this.currentMessages.length > 0) {
                  setTimeout(() => {
                    this.scrollToBottom();
                  }, 50);
                }
              })
              .onFocus(() => {
                // 输入框获得焦点时关闭下拉菜单
                this.closeDropdownMenus();
              })
              .onClick(() => {
                // 点击输入框时关闭下拉菜单
                this.closeDropdownMenus();
              })
            
            Button('发送')
              .width(68)
              .height(99)  // 与输入框高度一致
              .fontSize(16)
              .backgroundColor('#007AFF')
              .fontColor('#FFFFFF')
              .borderRadius(12)
              .margin({ left: 12 })
              .enabled(this.inputMessage.trim().length > 0)
              .opacity(this.inputMessage.trim().length > 0 ? 1 : 0.5)
              .onClick(() => {
                this.sendMessage();
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 3, bottom: 8 })
          .backgroundColor('#FFFFFF')
        }
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}