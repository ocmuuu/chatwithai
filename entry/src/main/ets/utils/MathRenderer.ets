/**
 * 数学公式渲染器
 * 支持基本的LaTeX数学公式渲染
 * 符合ArkTS规范
 */

export class MathRenderer {
  
  /**
   * 解析并渲染数学公式
   */
  public static renderMath(latex: string): string {
    let result = latex;
    
    // 处理上标和下标
    result = MathRenderer.processSuperAndSubscripts(result);
    
    // 处理分数
    result = MathRenderer.processFractions(result);
    
    // 处理根号
    result = MathRenderer.processSquareRoots(result);
    
    // 处理数学符号
    result = MathRenderer.processMathSymbols(result);
    
    // 处理常用函数
    result = MathRenderer.processMathFunctions(result);
    
    return result;
  }
  
  /**
   * 处理上标和下标
   */
  private static processSuperAndSubscripts(text: string): string {
    // 处理上标 ^{}
    text = text.replace(/\^{([^}]+)}/g, (match: string, content: string) => {
      return MathRenderer.toSuperscript(content);
    });
    
    // 处理单字符上标 ^x
    text = text.replace(/\^([a-zA-Z0-9])/g, (match: string, char: string) => {
      return MathRenderer.toSuperscript(char);
    });
    
    // 处理下标 _{}
    text = text.replace(/_{([^}]+)}/g, (match: string, content: string) => {
      return MathRenderer.toSubscript(content);
    });
    
    // 处理单字符下标 _x
    text = text.replace(/_([a-zA-Z0-9])/g, (match: string, char: string) => {
      return MathRenderer.toSubscript(char);
    });
    
    return text;
  }
  
  /**
   * 处理分数
   */
  private static processFractions(text: string): string {
    // 简单分数处理 \frac{a}{b}
    return text.replace(/\\frac{([^}]+)}{([^}]+)}/g, (match: string, numerator: string, denominator: string) => {
      return `(${numerator})/(${denominator})`;
    });
  }
  
  /**
   * 处理根号
   */
  private static processSquareRoots(text: string): string {
    // 处理根号 \sqrt{x}
    return text.replace(/\\sqrt{([^}]+)}/g, (match: string, content: string) => {
      return `√(${content})`;
    });
  }
  
  /**
   * 处理数学符号
   */
  private static processMathSymbols(text: string): string {
    // 希腊字母
    text = text.replace(/\\alpha\b/g, 'α');
    text = text.replace(/\\beta\b/g, 'β');
    text = text.replace(/\\gamma\b/g, 'γ');
    text = text.replace(/\\delta\b/g, 'δ');
    text = text.replace(/\\epsilon\b/g, 'ε');
    text = text.replace(/\\zeta\b/g, 'ζ');
    text = text.replace(/\\eta\b/g, 'η');
    text = text.replace(/\\theta\b/g, 'θ');
    text = text.replace(/\\iota\b/g, 'ι');
    text = text.replace(/\\kappa\b/g, 'κ');
    text = text.replace(/\\lambda\b/g, 'λ');
    text = text.replace(/\\mu\b/g, 'μ');
    text = text.replace(/\\nu\b/g, 'ν');
    text = text.replace(/\\xi\b/g, 'ξ');
    text = text.replace(/\\omicron\b/g, 'ο');
    text = text.replace(/\\pi\b/g, 'π');
    text = text.replace(/\\rho\b/g, 'ρ');
    text = text.replace(/\\sigma\b/g, 'σ');
    text = text.replace(/\\tau\b/g, 'τ');
    text = text.replace(/\\upsilon\b/g, 'υ');
    text = text.replace(/\\phi\b/g, 'φ');
    text = text.replace(/\\chi\b/g, 'χ');
    text = text.replace(/\\psi\b/g, 'ψ');
    text = text.replace(/\\omega\b/g, 'ω');
    
    // 大写希腊字母
    text = text.replace(/\\Alpha\b/g, 'Α');
    text = text.replace(/\\Beta\b/g, 'Β');
    text = text.replace(/\\Gamma\b/g, 'Γ');
    text = text.replace(/\\Delta\b/g, 'Δ');
    text = text.replace(/\\Epsilon\b/g, 'Ε');
    text = text.replace(/\\Zeta\b/g, 'Ζ');
    text = text.replace(/\\Eta\b/g, 'Η');
    text = text.replace(/\\Theta\b/g, 'Θ');
    text = text.replace(/\\Iota\b/g, 'Ι');
    text = text.replace(/\\Kappa\b/g, 'Κ');
    text = text.replace(/\\Lambda\b/g, 'Λ');
    text = text.replace(/\\Mu\b/g, 'Μ');
    text = text.replace(/\\Nu\b/g, 'Ν');
    text = text.replace(/\\Xi\b/g, 'Ξ');
    text = text.replace(/\\Omicron\b/g, 'Ο');
    text = text.replace(/\\Pi\b/g, 'Π');
    text = text.replace(/\\Rho\b/g, 'Ρ');
    text = text.replace(/\\Sigma\b/g, 'Σ');
    text = text.replace(/\\Tau\b/g, 'Τ');
    text = text.replace(/\\Upsilon\b/g, 'Υ');
    text = text.replace(/\\Phi\b/g, 'Φ');
    text = text.replace(/\\Chi\b/g, 'Χ');
    text = text.replace(/\\Psi\b/g, 'Ψ');
    text = text.replace(/\\Omega\b/g, 'Ω');
    
    // 数学运算符
    text = text.replace(/\\pm\b/g, '±');
    text = text.replace(/\\mp\b/g, '∓');
    text = text.replace(/\\times\b/g, '×');
    text = text.replace(/\\div\b/g, '÷');
    text = text.replace(/\\cdot\b/g, '⋅');
    text = text.replace(/\\ast\b/g, '*');
    text = text.replace(/\\star\b/g, '⋆');
    text = text.replace(/\\circ\b/g, '∘');
    text = text.replace(/\\bullet\b/g, '∙');
    
    // 关系符号
    text = text.replace(/\\leq\b/g, '≤');
    text = text.replace(/\\geq\b/g, '≥');
    text = text.replace(/\\neq\b/g, '≠');
    text = text.replace(/\\approx\b/g, '≈');
    text = text.replace(/\\equiv\b/g, '≡');
    text = text.replace(/\\sim\b/g, '∼');
    text = text.replace(/\\simeq\b/g, '≃');
    text = text.replace(/\\cong\b/g, '≅');
    text = text.replace(/\\propto\b/g, '∝');
    
    // 集合符号
    text = text.replace(/\\in\b/g, '∈');
    text = text.replace(/\\notin\b/g, '∉');
    text = text.replace(/\\subset\b/g, '⊂');
    text = text.replace(/\\supset\b/g, '⊃');
    text = text.replace(/\\subseteq\b/g, '⊆');
    text = text.replace(/\\supseteq\b/g, '⊇');
    text = text.replace(/\\cap\b/g, '∩');
    text = text.replace(/\\cup\b/g, '∪');
    text = text.replace(/\\emptyset\b/g, '∅');
    text = text.replace(/\\varnothing\b/g, '∅');
    
    // 逻辑符号
    text = text.replace(/\\land\b/g, '∧');
    text = text.replace(/\\lor\b/g, '∨');
    text = text.replace(/\\lnot\b/g, '¬');
    text = text.replace(/\\exists\b/g, '∃');
    text = text.replace(/\\forall\b/g, '∀');
    text = text.replace(/\\neg\b/g, '¬');
    text = text.replace(/\\wedge\b/g, '∧');
    text = text.replace(/\\vee\b/g, '∨');
    
    // 箭头
    text = text.replace(/\\leftarrow\b/g, '←');
    text = text.replace(/\\rightarrow\b/g, '→');
    text = text.replace(/\\leftrightarrow\b/g, '↔');
    text = text.replace(/\\Leftarrow\b/g, '⇐');
    text = text.replace(/\\Rightarrow\b/g, '⇒');
    text = text.replace(/\\Leftrightarrow\b/g, '⇔');
    text = text.replace(/\\uparrow\b/g, '↑');
    text = text.replace(/\\downarrow\b/g, '↓');
    text = text.replace(/\\updownarrow\b/g, '↕');
    
    // 微积分符号
    text = text.replace(/\\partial\b/g, '∂');
    text = text.replace(/\\nabla\b/g, '∇');
    text = text.replace(/\\infty\b/g, '∞');
    text = text.replace(/\\int\b/g, '∫');
    text = text.replace(/\\sum\b/g, '∑');
    text = text.replace(/\\prod\b/g, '∏');
    text = text.replace(/\\lim\b/g, 'lim');
    
    // 其他常用符号
    text = text.replace(/\\sqrt\b/g, '√');
    text = text.replace(/\\angle\b/g, '∠');
    text = text.replace(/\\perp\b/g, '⊥');
    text = text.replace(/\\parallel\b/g, '∥');
    text = text.replace(/\\therefore\b/g, '∴');
    text = text.replace(/\\because\b/g, '∵');
    text = text.replace(/\\degree\b/g, '°');
    
    return text;
  }
  
  /**
   * 处理数学函数
   */
  private static processMathFunctions(text: string): string {
    text = text.replace(/\\sin\b/g, 'sin');
    text = text.replace(/\\cos\b/g, 'cos');
    text = text.replace(/\\tan\b/g, 'tan');
    text = text.replace(/\\sec\b/g, 'sec');
    text = text.replace(/\\csc\b/g, 'csc');
    text = text.replace(/\\cot\b/g, 'cot');
    text = text.replace(/\\sinh\b/g, 'sinh');
    text = text.replace(/\\cosh\b/g, 'cosh');
    text = text.replace(/\\tanh\b/g, 'tanh');
    text = text.replace(/\\log\b/g, 'log');
    text = text.replace(/\\ln\b/g, 'ln');
    text = text.replace(/\\exp\b/g, 'exp');
    text = text.replace(/\\arcsin\b/g, 'arcsin');
    text = text.replace(/\\arccos\b/g, 'arccos');
    text = text.replace(/\\arctan\b/g, 'arctan');
    text = text.replace(/\\max\b/g, 'max');
    text = text.replace(/\\min\b/g, 'min');
    
    return text;
  }
  
  /**
   * 转换为上标字符
   */
  private static toSuperscript(text: string): string {
    let result = '';
    for (let i = 0; i < text.length; i++) {
      const char = text.charAt(i);
      switch (char) {
        case '0': result += '⁰'; break;
        case '1': result += '¹'; break;
        case '2': result += '²'; break;
        case '3': result += '³'; break;
        case '4': result += '⁴'; break;
        case '5': result += '⁵'; break;
        case '6': result += '⁶'; break;
        case '7': result += '⁷'; break;
        case '8': result += '⁸'; break;
        case '9': result += '⁹'; break;
        case '+': result += '⁺'; break;
        case '-': result += '⁻'; break;
        case '=': result += '⁼'; break;
        case '(': result += '⁽'; break;
        case ')': result += '⁾'; break;
        case 'a': result += 'ᵃ'; break;
        case 'b': result += 'ᵇ'; break;
        case 'c': result += 'ᶜ'; break;
        case 'd': result += 'ᵈ'; break;
        case 'e': result += 'ᵉ'; break;
        case 'f': result += 'ᶠ'; break;
        case 'g': result += 'ᵍ'; break;
        case 'h': result += 'ʰ'; break;
        case 'i': result += 'ⁱ'; break;
        case 'j': result += 'ʲ'; break;
        case 'k': result += 'ᵏ'; break;
        case 'l': result += 'ˡ'; break;
        case 'm': result += 'ᵐ'; break;
        case 'n': result += 'ⁿ'; break;
        case 'o': result += 'ᵒ'; break;
        case 'p': result += 'ᵖ'; break;
        case 'r': result += 'ʳ'; break;
        case 's': result += 'ˢ'; break;
        case 't': result += 'ᵗ'; break;
        case 'u': result += 'ᵘ'; break;
        case 'v': result += 'ᵛ'; break;
        case 'w': result += 'ʷ'; break;
        case 'x': result += 'ˣ'; break;
        case 'y': result += 'ʸ'; break;
        case 'z': result += 'ᶻ'; break;
        default: result += char; break;
      }
    }
    return result;
  }
  
  /**
   * 转换为下标字符
   */
  private static toSubscript(text: string): string {
    let result = '';
    for (let i = 0; i < text.length; i++) {
      const char = text.charAt(i);
      switch (char) {
        case '0': result += '₀'; break;
        case '1': result += '₁'; break;
        case '2': result += '₂'; break;
        case '3': result += '₃'; break;
        case '4': result += '₄'; break;
        case '5': result += '₅'; break;
        case '6': result += '₆'; break;
        case '7': result += '₇'; break;
        case '8': result += '₈'; break;
        case '9': result += '₉'; break;
        case '+': result += '₊'; break;
        case '-': result += '₋'; break;
        case '=': result += '₌'; break;
        case '(': result += '₍'; break;
        case ')': result += '₎'; break;
        case 'a': result += 'ₐ'; break;
        case 'e': result += 'ₑ'; break;
        case 'h': result += 'ₕ'; break;
        case 'i': result += 'ᵢ'; break;
        case 'j': result += 'ⱼ'; break;
        case 'k': result += 'ₖ'; break;
        case 'l': result += 'ₗ'; break;
        case 'm': result += 'ₘ'; break;
        case 'n': result += 'ₙ'; break;
        case 'o': result += 'ₒ'; break;
        case 'p': result += 'ₚ'; break;
        case 'r': result += 'ᵣ'; break;
        case 's': result += 'ₛ'; break;
        case 't': result += 'ₜ'; break;
        case 'u': result += 'ᵤ'; break;
        case 'v': result += 'ᵥ'; break;
        case 'x': result += 'ₓ'; break;
        default: result += char; break;
      }
    }
    return result;
  }
  
  /**
   * 检测文本是否包含数学公式
   */
  public static containsMath(text: string): boolean {
    // 检测数学公式的常见模式
    const patterns = [
      /\$[^$\n\r]{1,100}\$/,       // $...$（长度限制）
      /\$\$[\s\S]*?\$\$/,          // $$...$$
      /\\[a-zA-Z]+/,               // LaTeX命令 如 \alpha, \frac, etc.
      /\^{.*?}/,                   // 上标
      /_{.*?}/                     // 下标
    ];
    
    // 检查基本模式
    for (let i = 0; i < patterns.length; i++) {
      if (patterns[i].test(text)) {
        return true;
      }
    }
    
    // 检查LaTeX行内公式 \(...\) - 使用与解析器相同的严格条件
    const hasLatexInline = text.includes('\\(') && text.includes('\\)');
    const hasMathSymbols = /\\[a-zA-Z]+|[\^_{}]|\d+/.test(text);
    if (hasLatexInline && hasMathSymbols) {
      // 进一步检查是否有有效的LaTeX行内公式
      const latexInlinePattern = /\\\(([^)]*(?:[^\\)][^)]*)*)\\\)/g;
      const matches = text.match(latexInlinePattern);
      if (matches && matches.length > 0) {
        // 验证匹配的内容是否有效
        for (let j = 0; j < matches.length; j++) {
          const match = matches[j];
          const content = match.substring(2, match.length - 2); // 去掉 \( 和 \)
          if (content.trim() && content.length <= 200) {
            return true;
          }
        }
      }
    }
    
    // 检查LaTeX块级公式 \[...\]
    if (text.includes('\\[') && text.includes('\\]')) {
      const latexBlockPattern = /\\\[[\s\S]*?\\\]/;
      if (latexBlockPattern.test(text)) {
        return true;
      }
    }
    
    return false;
  }
}

/**
 * 数学公式显示组件
 */
@Component
export struct MathText {
  @Prop content: string = '';
  @Prop fontSize: number = 16;
  @Prop fontColor: string = '#333333';
  @Prop isInline: boolean = true;
  
  build() {
    Text(MathRenderer.renderMath(this.content))
      .fontSize(this.fontSize)
      .fontColor(this.fontColor)
      .fontFamily('serif') // 使用serif字体，数学公式看起来更专业
      .backgroundColor(this.isInline ? 'transparent' : '#F8F9FA')
      .padding(this.isInline ? { left: 2, right: 2 } : { left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(this.isInline ? 2 : 4)
      .border(this.isInline ? undefined : { width: 1, color: '#E0E0E0' })
  }
} 