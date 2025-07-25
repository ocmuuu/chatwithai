import router from '@ohos.router';
import PreferencesUtil from '../utils/PreferencesUtil';
import { DEFAULT_PROVIDERS, ProviderConfig, AIProvider } from '../setups/DefaultConfig';

interface PlatformSettings {
  apiKey: string;
  apiUrl: string;
}

@Entry
@Component
struct SettingsPage {
  @State platformSettings: Map<string, PlatformSettings> = new Map();
  @State selectedProvider: AIProvider = AIProvider.DeepSeek;
  @State currentApiKey: string = '';
  @State currentApiUrl: string = '';
  // 第一栏宽度，复用INDEX页面的配置
  @State firstColumnWidth: number = 280;
  // 第一栏折叠状态
  @State isFirstColumnCollapsed: boolean = false;
  // 拖拽状态
  @State isDragging: boolean = false;
  // 拖拽开始时的宽度
  private dragStartWidth: number = 0;
  // 保存成功提示状态
  @State showSaveSuccess: boolean = false;

  async aboutToAppear() {
    try {
      await PreferencesUtil.init(getContext(this));
      
      // 加载INDEX页面保存的第一栏宽度配置和折叠状态
      this.firstColumnWidth = await PreferencesUtil.getFirstColumnWidth();
      this.isFirstColumnCollapsed = await PreferencesUtil.getFirstColumnCollapseState();
      
      // 先加载所有平台的设置
      await this.loadAllSettings();
      
      // 默认显示第一个平台的设置
      if (DEFAULT_PROVIDERS.length > 0) {
        this.selectedProvider = DEFAULT_PROVIDERS[0].id;
        // 加载完所有设置后再加载当前平台的设置
        this.loadCurrentProviderSettings();
      }
    } catch (error) {
      console.error('初始化设置页面失败:', error);
    }
  }

  // 加载所有平台的设置
  async loadAllSettings() {
    for (const provider of DEFAULT_PROVIDERS) {
      const apiKey = await PreferencesUtil.getApiKey(provider.id);
      const apiUrl = await PreferencesUtil.getApiUrl(provider.id) || this.getDefaultApiUrl(provider.id);
      
      this.platformSettings.set(provider.id, {
        apiKey: apiKey || '',
        apiUrl: apiUrl
      });
    }
  }

  // 获取默认API地址
  private getDefaultApiUrl(providerId: string): string {
    const defaultUrls: Record<string, string> = {
      'openai': 'https://api.openai.com',
      'azure': 'https://your-resource.openai.azure.com',
      'claude': 'https://api.anthropic.com',
      'gemini': 'https://generativelanguage.googleapis.com',
      'deepseek': 'https://api.deepseek.com',
      'siliconflow': 'https://api.siliconflow.cn',
      'volcengine': 'https://ark.cn-beijing.volces.com',
      'xAI': 'https://api.x.ai',
      'groq': 'https://api.groq.com',
      'chatglm-6b': 'https://open.bigmodel.cn',
      'ollama': 'http://localhost:11434',
      'lm-studio': 'http://localhost:1234',
      'perplexity': 'https://api.perplexity.ai'
    };
    return defaultUrls[providerId] || 'https://api.example.com';
  }

  // 加载当前选中平台的设置
  loadCurrentProviderSettings() {
    const settings = this.platformSettings.get(this.selectedProvider);
    if (settings) {
      this.currentApiKey = settings.apiKey;
      this.currentApiUrl = settings.apiUrl;
    }
  }

  // 保存当前平台的设置
  async saveCurrentProviderSettings() {
    try {
      await PreferencesUtil.saveApiKey(this.selectedProvider, this.currentApiKey);
      await PreferencesUtil.saveApiUrl(this.selectedProvider, this.currentApiUrl);
      
      // 更新本地缓存
      this.platformSettings.set(this.selectedProvider, {
        apiKey: this.currentApiKey,
        apiUrl: this.currentApiUrl
      });
      
      console.info(`${this.selectedProvider} 设置已保存`);
      
      // 显示保存成功提示
      this.showSaveSuccess = true;
      
      // 3秒后自动隐藏提示
      setTimeout(() => {
        this.showSaveSuccess = false;
      }, 3000);
      
    } catch (error) {
      console.error('保存设置失败:', error);
    }
  }

  // 重置当前平台的设置
  resetCurrentProviderSettings() {
    this.currentApiKey = '';
    this.currentApiUrl = this.getDefaultApiUrl(this.selectedProvider);
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

  // 获取平台显示名称
  private getProviderDisplayName(providerId: string): string {
    const provider = DEFAULT_PROVIDERS.find(p => p.id === providerId);
    return provider?.name || providerId;
  }

  // 获取平台图标
  private getProviderIcon(providerId: string): Resource {
    const iconMap: Record<string, Resource> = {
      'openai': $r('app.media.openai'),
      'azure': $r('app.media.azure'),
      'claude': $r('app.media.claude'),
      'gemini': $r('app.media.gemini'),
      'deepseek': $r('app.media.deepseek'),
      'siliconflow': $r('app.media.siliconflow'),
      'volcengine': $r('app.media.volcengine'),
      'xAI': $r('app.media.xAI'),
      'groq': $r('app.media.groq'),
      'chatglm-6b': $r('app.media.chatglm'),
      'ollama': $r('app.media.ollama'),
      'lm-studio': $r('app.media.lmstudio'),
      'perplexity': $r('app.media.perplexity'),
      'local': $r('app.media.icon')
    };
    return iconMap[providerId] || $r('app.media.deepseek');
  }

  build() {
    Column() {
      Row() {
        // 左侧平台列表
        Column() {
          // 标题栏
          Row() {
            Text('AI平台')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            
            Blank()
            
            // 返回按钮
            Button() {
              Text('← 返回')
                .fontSize(14)
                .fontColor('#007AFF')
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              router.back();
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

          List() {
            ForEach(DEFAULT_PROVIDERS, (provider: ProviderConfig) => {
              ListItem() {
                Column() {
                  Row() {
                    Image(this.getProviderIcon(provider.id))
                      .width(24)
                      .height(24)
                      .margin({ right: 12 })

                    Text(provider.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.selectedProvider === provider.id ? '#007AFF' : '#333333')
                      .layoutWeight(1)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    if (this.selectedProvider === provider.id) {
                      Text('●')
                        .fontSize(8)
                        .fontColor('#007AFF')
                        .margin({ left: 8 })
                    }
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Start)
                  .alignItems(VerticalAlign.Center)
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .backgroundColor(this.selectedProvider === provider.id ? '#E3F2FD' : '#FFFFFF')
                .alignItems(HorizontalAlign.Start)
              }
              .onClick(() => {
                if (this.selectedProvider !== provider.id) {
                  this.selectedProvider = provider.id;
                  this.loadCurrentProviderSettings();
                }
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

        // 右侧设置表单
        Column() {
          // 标题栏
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
            
            Text(`${this.getProviderDisplayName(this.selectedProvider)} 设置`)
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

          // 设置表单内容
          Column() {
            // API密钥设置
            Column() {
              Text('API密钥')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入API密钥', text: this.currentApiKey })
                .fontSize(14)
                .height(40)
                .backgroundColor('#F8F9FA')
                .borderRadius(8)
                .padding({ left: 12, right: 12 })
                .border({ width: 1, color: '#E0E0E0' })
                .type(InputType.Password)
                .onChange((value: string) => {
                  this.currentApiKey = value;
                })

              Text('用于验证访问AI服务的密钥，请从对应平台获取')
                .fontSize(12)
                .fontColor('#999999')
                .alignSelf(ItemAlign.Start)
                .margin({ top: 4 })
            }
            .width('100%')
            .margin({ bottom: 24 })
            .alignItems(HorizontalAlign.Start)

            // API地址设置
            Column() {
              Text('API地址')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入API地址', text: this.currentApiUrl })
                .fontSize(14)
                .height(40)
                .backgroundColor('#F8F9FA')
                .borderRadius(8)
                .padding({ left: 12, right: 12 })
                .border({ width: 1, color: '#E0E0E0' })
                .onChange((value: string) => {
                  this.currentApiUrl = value;
                })

              Text('默认使用官方地址，可修改为API转发服务地址')
                .fontSize(12)
                .fontColor('#999999')
                .alignSelf(ItemAlign.Start)
                .margin({ top: 4 })
            }
            .width('100%')
            .margin({ bottom: 32 })
            .alignItems(HorizontalAlign.Start)

            // 操作按钮
            Row() {
              Button('保存')
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#007AFF')
                .borderRadius(8)
                .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                .onClick(() => {
                  this.saveCurrentProviderSettings();
                })

              Button('重置为默认')
                .fontSize(14)
                .fontColor('#666666')
                .backgroundColor('#F0F0F0')
                .borderRadius(8)
                .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                .margin({ left: 12 })
                .onClick(() => {
                  this.resetCurrentProviderSettings();
                })

              Blank()

              Button('测试连接')
                .fontSize(14)
                .fontColor('#007AFF')
                .backgroundColor('#E3F2FD')
                .borderRadius(8)
                .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                .onClick(() => {
                  // TODO: 实现连接测试
                  console.info('测试连接功能暂未实现');
                })
            }
            .width('100%')

            Blank()

            // 说明文字
            Text('提示：修改设置后请点击"保存"按钮保存配置')
              .fontSize(12)
              .fontColor('#999999')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 16 })

            // 保存成功提示
            if (this.showSaveSuccess) {
              Row() {
                Text('✓ 保存成功')
                  .fontSize(14)
                  .fontColor('#4CAF50')
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .height(40)
              .backgroundColor('#E8F5E8')
              .borderRadius(8)
              .padding({ left: 12, right: 12 })
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .border({ width: 1, color: '#4CAF50' })
              .animation({
                duration: 300,
                curve: Curve.EaseInOut
              })
            }
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .height('100%')
        .backgroundColor('#FFFFFF')
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
} 