/**
 * 基于自定义解析器的 Markdown 渲染器
 * 完全符合 ArkTS 类型安全要求
 */

import { MathRenderer, MathText } from './MathRenderer';

export interface EnhancedMarkdownElement {
  type: 'text' | 'heading' | 'code_block' | 'code_inline' | 'bold' | 'italic' | 'list_item' | 'quote' | 'link' | 'paragraph' | 'br' | 'hr' | 'math_inline' | 'math_block';
  content: string;
  level?: number;
  language?: string;
  url?: string;
  children?: EnhancedMarkdownElement[];
}

export interface InlinePattern {
  type: 'code_inline' | 'bold' | 'italic' | 'link' | 'math_inline';
  regex: RegExp;
}

export interface InlineMatch {
  type: 'code_inline' | 'bold' | 'italic' | 'link' | 'math_inline';
  content: string;
  start: number;
  end: number;
  url?: string;
}

export interface CodeBlockResult {
  element: EnhancedMarkdownElement;
  nextIndex: number;
}

export class MarkdownItRenderer {

  /**
   * 解析 markdown 文本为元素数组
   */
  public static parseMarkdown(text: string): EnhancedMarkdownElement[] {
    const elements: EnhancedMarkdownElement[] = [];
    const lines = text.split('\n');
    let i = 0;

    while (i < lines.length) {
      const line = lines[i];
      
      // 跳过空行
      if (line.trim() === '') {
        i++;
        continue;
      }

      // 解析块级数学公式 $$...$$ 
      if (line.trim().startsWith('$$')) {
        const mathBlockResult = MarkdownItRenderer.parseMathBlock(lines, i, '$$');
        elements.push(mathBlockResult.element);
        i = mathBlockResult.nextIndex;
        continue;
      }

      // 解析块级数学公式 \[...\] - 必须是独立行且精确匹配
      if (line.trim() === '\\[') {
        const mathBlockResult = MarkdownItRenderer.parseMathBlock(lines, i, '\\[');
        elements.push(mathBlockResult.element);
        i = mathBlockResult.nextIndex;
        continue;
      }

      // 解析代码块
      if (line.trim().startsWith('```')) {
        const codeBlockResult = MarkdownItRenderer.parseCustomCodeBlock(lines, i);
        elements.push(codeBlockResult.element);
        i = codeBlockResult.nextIndex;
        continue;
      }

      // 解析标题
      if (line.startsWith('#')) {
        const headingElement = MarkdownItRenderer.parseHeading(line);
        elements.push(headingElement);
        i++;
        continue;
      }

      // 解析引用
      if (line.trim().startsWith('>')) {
        const quoteElement = MarkdownItRenderer.parseQuote(line);
        elements.push(quoteElement);
        i++;
        continue;
      }

      // 解析列表项
      if (line.trim().match(/^[\-\*\+]\s/) || line.trim().match(/^\d+\.\s/)) {
        const listElement = MarkdownItRenderer.parseListItem(line);
        elements.push(listElement);
        i++;
        continue;
      }

      // 解析水平分割线
      if (line.trim().match(/^(\*{3,}|-{3,}|_{3,})$/)) {
        const hrElement: EnhancedMarkdownElement = {
          type: 'hr',
          content: ''
        };
        elements.push(hrElement);
        i++;
        continue;
      }

      // 解析普通文本（包含行内格式和数学公式）
      const inlineElements = MarkdownItRenderer.parseCustomInlineElements(line);
      elements.push(...inlineElements);
      i++;
    }

    return elements;
  }

  /**
   * 解析代码块
   */
  private static parseCustomCodeBlock(lines: string[], startIndex: number): CodeBlockResult {
    const startLine = lines[startIndex];
    const language = startLine.replace('```', '').trim();
    const codeLines: string[] = [];
    
    let i = startIndex + 1;
    while (i < lines.length && !lines[i].trim().startsWith('```')) {
      codeLines.push(lines[i]);
      i++;
    }

    const element: EnhancedMarkdownElement = {
      type: 'code_block',
      content: codeLines.join('\n'),
      language: language || 'text'
    };

    const result: CodeBlockResult = {
      element: element,
      nextIndex: i + 1
    };

    return result;
  }

  /**
   * 解析块级数学公式
   */
  private static parseMathBlock(lines: string[], startIndex: number, delimiter: string): CodeBlockResult {
    const codeLines: string[] = [];
    let endDelimiter: string;
    
    // 确定结束分隔符
    if (delimiter === '$$') {
      endDelimiter = '$$';
    } else if (delimiter === '\\[') {
      endDelimiter = '\\]';
    } else {
      endDelimiter = delimiter;
    }
    
    let i = startIndex + 1;
    while (i < lines.length) {
      const currentLine = lines[i].trim();
      if (currentLine === endDelimiter) {
        break;
      }
      codeLines.push(lines[i]);
      i++;
    }

    const element: EnhancedMarkdownElement = {
      type: 'math_block',
      content: codeLines.join('\n')
    };

    const result: CodeBlockResult = {
      element: element,
      nextIndex: i + 1
    };

    return result;
  }

  /**
   * 解析标题
   */
  private static parseHeading(line: string): EnhancedMarkdownElement {
    const match = line.match(/^(#{1,6})\s+(.+)$/);
    if (match) {
      const rawContent = match[2].trim();
      const children = MarkdownItRenderer.parseCustomInlineElements(rawContent);

      const element: EnhancedMarkdownElement = {
        type: 'heading',
        content: rawContent,
        level: match[1].length,
        children: children
      };
      return element;
    }
    
    const fallbackElement: EnhancedMarkdownElement = {
      type: 'text',
      content: line
    };
    return fallbackElement;
  }

  /**
   * 解析引用
   */
  private static parseQuote(line: string): EnhancedMarkdownElement {
    const content = line.replace(/^\s*>\s?/, '');
    const element: EnhancedMarkdownElement = {
      type: 'quote',
      content: content
    };
    return element;
  }

  /**
   * 解析列表项
   */
  private static parseListItem(line: string): EnhancedMarkdownElement {
    const content = line.replace(/^\s*[\-\*\+]|^\s*\d+\./, '').trim();

    // 解析行内格式，作为子元素
    const children = MarkdownItRenderer.parseCustomInlineElements(content);

    const element: EnhancedMarkdownElement = {
      type: 'list_item',
      content: content,
      children: children
    };
    return element;
  }

  /**
   * 解析行内元素
   */
  private static parseCustomInlineElements(text: string): EnhancedMarkdownElement[] {
    const elements: EnhancedMarkdownElement[] = [];
    
    // 基本解析模式
    const codePattern: InlinePattern = { type: 'code_inline', regex: /`([^`]+)`/g };
    const mathInlinePattern1: InlinePattern = { type: 'math_inline', regex: /\$([^$\n\r]{1,100})\$/g };
    const boldPattern1: InlinePattern = { type: 'bold', regex: /\*\*([\s\S]+?)\*\*/g };
    const boldPattern2: InlinePattern = { type: 'bold', regex: /__([\s\S]+?)__/g };
    const italicPattern1: InlinePattern = { type: 'italic', regex: /\*([\s\S]+?)\*/g };
    const italicPattern2: InlinePattern = { type: 'italic', regex: /_([\s\S]+?)_/g };
    const linkPattern: InlinePattern = { type: 'link', regex: /\[([^\]]+)\]\(([^)]+)\)/g };
    
    const patterns: InlinePattern[] = [
      codePattern,        // 代码优先级最高
      mathInlinePattern1, // $...$
      boldPattern1,
      boldPattern2,
      italicPattern1,
      italicPattern2,
      linkPattern
    ];

    // 只有当文本包含完整的LaTeX行内公式模式时才添加 \(...\) 支持
    // 使用更严格的检测：必须包含 \( 和 \)，且中间有内容，且内容包含数学符号
    const hasLatexInline = text.includes('\\(') && text.includes('\\)');
    const hasMathSymbols = /\\[a-zA-Z]+|[\^_{}]|\d+/.test(text); // 包含LaTeX命令、上下标或数字
    
    if (hasLatexInline && hasMathSymbols) {
      // 更精确的LaTeX行内公式正则：确保匹配成对的 \( 和 \)
      const mathInlinePattern2: InlinePattern = { 
        type: 'math_inline', 
        regex: /\\\(([^)]*(?:[^\\)][^)]*)*)\\\)/g 
      };
      patterns.splice(2, 0, mathInlinePattern2); // 在$...$之后插入
    }

    // 收集所有匹配项
    const matches: InlineMatch[] = [];
    
    for (const pattern of patterns) {
      pattern.regex.lastIndex = 0;
      let match: RegExpExecArray | null;
      while ((match = pattern.regex.exec(text)) !== null) {
        // 对于LaTeX行内公式，进行额外验证
        if (pattern.type === 'math_inline' && match[0].startsWith('\\(')) {
          const content = match[1];
          // 确保内容不为空且包含有意义的数学内容
          if (!content.trim() || content.length > 200) {
            continue; // 跳过空内容或过长内容
          }
        }
        
        const matchObj: InlineMatch = {
          type: pattern.type,
          content: match[1],
          start: match.index,
          end: match.index + match[0].length,
          url: match[2] // 用于链接
        };
        matches.push(matchObj);
      }
    }

    // 如果没有找到任何格式，返回纯文本
    if (matches.length === 0) {
      const textElement: EnhancedMarkdownElement = {
        type: 'text',
        content: text
      };
      elements.push(textElement);
      return elements;
    }

    // 按开始位置排序
    matches.sort((a, b) => a.start - b.start);

    let lastIndex = 0;

    // 处理匹配项，构建元素列表
    for (const match of matches) {
      // 如果本匹配与上一匹配存在重叠，说明已被更长或更早的格式占用，直接跳过，
      // 以避免例如 **bold** 被 *italic* 二次解析导致显示异常
      if (match.start < lastIndex) {
        continue;
      }
      // 添加匹配之前的普通文本
      if (match.start > lastIndex) {
        const plainText = text.substring(lastIndex, match.start);
        if (plainText.length > 0) {
          const textElement: EnhancedMarkdownElement = {
            type: 'text',
            content: plainText
          };
          elements.push(textElement);
        }
      }

      // 添加格式化元素
      const formattedElement: EnhancedMarkdownElement = {
        type: match.type,
        content: match.content,
        url: match.url
      };
      elements.push(formattedElement);

      lastIndex = match.end;
    }

    // 添加剩余的普通文本
    if (lastIndex < text.length) {
      const remainingText = text.substring(lastIndex);
      if (remainingText.length > 0) {
        const textElement: EnhancedMarkdownElement = {
          type: 'text',
          content: remainingText
        };
        elements.push(textElement);
      }
    }

    return elements;
  }
}

/**
 * 增强的 Markdown 文本组件
 */
@Component
export struct EnhancedMarkdownText {
  @Prop content: string = '';
  @Prop fontSize: number = 16;
  @Prop fontColor: string = '#333333';
  
  build() {
    Column({ space: 8 }) {
      ForEach(this.groupElements(MarkdownItRenderer.parseMarkdown(this.content)), (group: EnhancedMarkdownElement[], groupIndex: number) => {
        this.buildElementGroup(group)
      })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  aboutToAppear() {
    // 调试：输出原始 Markdown 内容
    console.info('[RAW MD]', this.content);
  }

  /**
   * 将行内元素组合成组，以便在同一行中显示
   */
  private groupElements(elements: EnhancedMarkdownElement[]): EnhancedMarkdownElement[][] {
    const groups: EnhancedMarkdownElement[][] = [];
    let currentGroup: EnhancedMarkdownElement[] = [];

    for (const element of elements) {
      if (element.type === 'heading' || element.type === 'code_block' || 
          element.type === 'quote' || element.type === 'list_item' || element.type === 'hr' || element.type === 'math_block') {
        // 块级元素：如果当前组有内容，先添加到结果中
        if (currentGroup.length > 0) {
          groups.push(currentGroup);
          currentGroup = [];
        }
        // 块级元素单独成组
        groups.push([element]);
      } else {
        // 行内元素：添加到当前组
        currentGroup.push(element);
      }
    }

    // 添加最后一组
    if (currentGroup.length > 0) {
      groups.push(currentGroup);
    }

    return groups;
  }

  @Builder
  buildElementGroup(group: EnhancedMarkdownElement[]) {
    if (group.length === 1) {
      // 单个元素（通常是块级元素）
      this.buildElement(group[0])
    } else {
      // 多个行内元素，在同一行中显示
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Baseline }) {
        ForEach(group, (element: EnhancedMarkdownElement, index: number) => {
          this.buildInlineElement(element)
        })
      }
      .width('100%')
    }
  }
  
  @Builder
  buildElement(element: EnhancedMarkdownElement) {
    if (element.type === 'heading') {
      this.buildHeading(element)
    } else if (element.type === 'code_block') {
      this.buildCodeBlock(element)
    } else if (element.type === 'quote') {
      this.buildQuote(element)
    } else if (element.type === 'list_item') {
      this.buildListItem(element)
    } else if (element.type === 'hr') {
      this.buildHorizontalRule()
    } else if (element.type === 'math_block') {
      this.buildMathBlock(element)
    } else {
      this.buildInlineElement(element)
    }
  }
  
  @Builder
  buildHeading(element: EnhancedMarkdownElement) {
    if (element.children && element.children.length > 0) {
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Baseline }) {
        ForEach(element.children, (child: EnhancedMarkdownElement, idx: number) => {
          this.buildHeadingInlineElement(child, this.getHeadingSize(element.level || 1))
        })
      }
      .margin({ top: 16, bottom: 8 })
      .width('100%')
    } else {
      Text(element.content)
        .fontSize(this.getHeadingSize(element.level || 1))
        .fontWeight(FontWeight.Bold)
        .fontColor(this.fontColor)
        .margin({ top: 16, bottom: 8 })
        .width('100%')
    }
  }

  // 针对标题的行内元素渲染，统一采用标题字号
  @Builder
  private buildHeadingInlineElement(element: EnhancedMarkdownElement, fontSize: number) {
    if (element.type === 'bold') {
      Text(element.content)
        .fontSize(fontSize)
        .fontColor(this.fontColor)
        .fontWeight(FontWeight.Bold)
    } else if (element.type === 'italic') {
      Text(element.content)
        .fontSize(fontSize)
        .fontColor(this.fontColor)
        .fontStyle(FontStyle.Italic)
    } else if (element.type === 'code_inline') {
      Text(element.content)
        .fontSize(fontSize - 1)
        .fontColor('#D73A49')
        .fontFamily('monospace')
        .backgroundColor('#F6F8FA')
        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
        .borderRadius(3)
    } else if (element.type === 'link') {
      Text(element.content)
        .fontSize(fontSize)
        .fontColor('#007AFF')
        .decoration({ type: TextDecorationType.Underline })
        .onClick(() => {
          console.info('链接点击:', element.url);
        })
    } else if (element.type === 'math_inline') {
      MathText({ 
        content: element.content, 
        fontSize: fontSize, 
        fontColor: this.fontColor, 
        isInline: true 
      })
    } else {
      // 普通文本
      Text(element.content)
        .fontSize(fontSize)
        .fontColor(this.fontColor)
        .fontWeight(FontWeight.Bold)
    }
  }
  
  @Builder
  buildCodeBlock(element: EnhancedMarkdownElement) {
    Column() {
      if (element.language && element.language !== 'text') {
        Text(element.language)
          .fontSize(12)
          .fontColor('#666666')
          .backgroundColor('#F0F0F0')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius({ topLeft: 6, topRight: 6 })
          .alignSelf(ItemAlign.Start)
      }
      
      Text(element.content)
        .fontSize(14)
        .fontColor('#333333')
        .fontFamily('monospace')
        .backgroundColor('#F8F8F8')
        .padding(12)
        .borderRadius(element.language && element.language !== 'text' ? 
          { bottomLeft: 6, bottomRight: 6 } : 6)
        .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 8, bottom: 8 })
  }
  
  @Builder
  buildQuote(element: EnhancedMarkdownElement) {
    Row() {
      Divider()
        .vertical(true)
        .strokeWidth(3)
        .color('#007AFF')
        .height('100%')
      
      Text(element.content)
        .fontSize(this.fontSize)
        .fontColor('#666666')
        .fontStyle(FontStyle.Italic)
        .padding({ left: 12 })
        .layoutWeight(1)
    }
    .backgroundColor('#F8F9FA')
    .padding(12)
    .borderRadius(6)
    .margin({ top: 4, bottom: 4 })
    .width('100%')
  }
  
  @Builder
  buildListItem(element: EnhancedMarkdownElement) {
    Row() {
      Text('•')
        .fontSize(this.fontSize)
        .fontColor(this.fontColor)
        .margin({ right: 8 })

      // 渲染子元素，如果不存在子元素则回退为纯文本
      if (element.children && element.children.length > 0) {
        Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Baseline }) {
          ForEach(element.children, (child: EnhancedMarkdownElement, index: number) => {
            this.buildInlineElement(child)
          })
        }
        .layoutWeight(1)
      } else {
        Text(element.content)
          .fontSize(this.fontSize)
          .fontColor(this.fontColor)
          .layoutWeight(1)
      }
    }
    .alignItems(VerticalAlign.Top)
    .padding({ left: 16, top: 2, bottom: 2 })
    .width('100%')
  }

  @Builder
  buildMathBlock(element: EnhancedMarkdownElement) {
    MathText({ 
      content: element.content, 
      fontSize: this.fontSize + 2, 
      fontColor: this.fontColor, 
      isInline: false 
    })
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  buildInlineElement(element: EnhancedMarkdownElement) {
    if (element.type === 'bold') {
      Text(element.content)
        .fontSize(this.fontSize)
        .fontColor(this.fontColor)
        .fontWeight(FontWeight.Bold)
    } else if (element.type === 'italic') {
      Text(element.content)
        .fontSize(this.fontSize)
        .fontColor(this.fontColor)
        .fontStyle(FontStyle.Italic)
    } else if (element.type === 'code_inline') {
      Text(element.content)
        .fontSize(this.fontSize - 1)
        .fontColor('#D73A49')
        .fontFamily('monospace')
        .backgroundColor('#F6F8FA')
        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
        .borderRadius(3)
    } else if (element.type === 'link') {
      Text(element.content)
        .fontSize(this.fontSize)
        .fontColor('#007AFF')
        .decoration({ type: TextDecorationType.Underline })
        .onClick(() => {
          console.info('链接点击:', element.url);
          // 这里可以添加打开链接的逻辑
        })
    } else if (element.type === 'math_inline') {
      MathText({ 
        content: element.content, 
        fontSize: this.fontSize, 
        fontColor: this.fontColor, 
        isInline: true 
      })
    } else {
      // 普通文本
      Text(element.content)
        .fontSize(this.fontSize)
        .fontColor(this.fontColor)
    }
  }
  
  @Builder
  buildHorizontalRule() {
    Divider()
      .strokeWidth(2)
      .color('#E0E0E0')
      .margin({ top: 16, bottom: 16 })
  }
  
  private getHeadingSize(level: number): number {
    const sizes = [24, 22, 20, 18, 16, 14];
    return sizes[level - 1] || 16;
  }
} 