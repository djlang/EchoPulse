# EchoPulse 开发总结（截至 2026-04-29）

本文件总结近期对 EchoPulse（调音器 + 节拍器）功能的新增与优化，便于回溯实现思路与后续迭代方向。

## 调音器（Tuner）

### 1) 页面生命周期接通麦克风调音
- 进入调音详情页自动申请麦克风权限并启动引擎；退出页面停止引擎。
- 仍保留 Slider 作为“模拟频率偏差”调试入口。
- 相关文件：
  - `EchoPulse/Tuner/TunerDetailView.swift`
  - `EchoPulse/Tuner/TunerViewModel.swift`
  - `EchoPulse/Tuner/TunerEngine.swift`

### 2) iOS 17 麦克风权限 API 升级
- iOS 17+ 使用 `AVAudioApplication` 权限接口；iOS 17 以下回退 `AVAudioSession`。
- 相关文件：`EchoPulse/Tuner/TunerEngine.swift`

### 3) “选弦后标题不同步”修复
- 选中弦变化时立即同步当前音名显示（不依赖实时检测回调）。
- 音名显示使用完整 key（如 `E2` / `A2`），避免只取首字母导致歧义。
- 相关文件：`EchoPulse/Tuner/TunerViewModel.swift`

### 4) 不同乐器显示对应弦与标准频率
- 为 `InstrumentType` 增加每种乐器的弦序列与标准频率表：
  - 吉他：`E2 A2 D3 G3 B3 E4`
  - 尤克里里（High-G 标准）：`G4 C4 E4 A4`
- `TunerDetailView` 依据传入的 `instrument` 渲染底部弦按钮，并将 instrument 注入 `TunerViewModel`。
- 相关文件：
  - `EchoPulse/Tuner/InstrumentType.swift`
  - `EchoPulse/Tuner/TunerDetailView.swift`
  - `EchoPulse/Tuner/TunerViewModel.swift`

### 5) 进入调音详情页改为全屏翻页（隐藏 Tab）
- 在调音器入口页用 `fullScreenCover` 展示调音详情页，不再显示底部 Tab。
- 添加“关闭”按钮返回。
- 相关文件：`EchoPulse/Tuner/TunerView.swift`

### 6) 仪表盘刻度线与数值显示增强
- 增加沿半圆弧的主/次刻度线（贴合表盘弧线）。
- 底部中间数值改为随 `pitchOffset` 实时变化（`-12 / 0 / +18`）。
- 相关文件：`EchoPulse/Tuner/TunerDashboardView.swift`

## 节拍器（Metronome）

### 1) MVP：摆针式节拍 + 闪烁式样式切换（4/4）
- 提供：
  - BPM 显示与调节（40–240）
  - 开始/暂停
  - 声音开关（滴答声）
  - 样式：摆针 / 闪烁
- 相关文件：
  - `EchoPulse/MetronomeView.swift`
  - `EchoPulse/MetronomeViewModel.swift`

### 2) 生成 Click 声音（不依赖资源文件）
- 使用 `AVAudioEngine` + `AVAudioPlayerNode` 生成短促衰减正弦 burst 作为 click。
- 区分普通拍与重拍（accent）。
- 相关文件：`EchoPulse/MetronomeEngine.swift`

### 3) 摆针动画优化：连续扇动（TimelineView）
- 摆针改用 `TimelineView(.animation)` + 正弦函数生成连续摆动相位，避免“跳一下停一下”的离散动画问题。
- 摆动速度随 BPM 动态变化。
- 相关文件：`EchoPulse/MetronomeView.swift`

### 4) 机械节拍器图片叠加与摆针样式拟真
- 使用资源图 `metronome` 作为摆针区域背景。
- 摆针改为银色（金属质感），并将“摆锤”改为更接近真实机械节拍器的滑块（位置：从顶部向下约 1/3）。
- 相关文件：`EchoPulse/MetronomeView.swift`

### 5) 拍号支持（以“每分钟多少拍”为核心，6/8 按 2 大拍）
- 新增拍号选择：`2/4、3/4、4/4、6/8 (2)`。
- 其中 `6/8` 先按“每小节 2 大拍（strong-weak）”实现。
- 节拍循环与 UI 指示点数量随 `beatsPerBar` 变化；重拍（accent）跟随拍号配置。
- 相关文件：
  - `EchoPulse/MetronomeViewModel.swift`
  - `EchoPulse/MetronomeView.swift`

## 后续建议（可选）
- 节拍器：Tap Tempo、震动开关、更多音色、后台/中断恢复、更高精度的音频调度（预排未来 buffer）。
- 调音器：按乐器扩展更多调弦（Drop D、半音降等）、自动识别最接近弦、去抖/平滑、权限拒绝引导弹窗。

