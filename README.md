# EchoPulse - 智能乐器工具箱

EchoPulse 是一款基于 **SwiftUI** 开发的单机版音乐辅助工具，集成了高精度的**吉他/尤克里里调音器**与**专业节拍器**。

## 📂 项目结构解析
- **Models**: 乐器数据模型
- **ViewModels**: 调音与节拍逻辑控制
- **Views**: SwiftUI 界面实现

## 🚀 当前开发进度
- [x] 项目基础骨架 (TabView + Navigation)
- [x] MVVM 架构基础实现
- [x] 自定义 Shape 动态仪表盘 UI
- [ ] 麦克风实时采样接入

## 📦 依赖管理
- **AudioKit**: 用于高性能音频采集与实时音高分析 (Pitch Detection)。
- **SoundpipeAudioKit**: 增强型音频处理算法。

## 💡 技术实现细节
- 采用 **PitchTap** 进行实时频率采样。
- 频率转化逻辑：使用对数公式将 Hz 转化为 Cents，实现仪表盘指针的平滑偏移。
