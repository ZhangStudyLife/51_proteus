# 实验报告工作流程规范（微机原理与接口技术）

## 1. 固定基础信息
以下信息在本课程所有实验中默认复用：

- 课程：微机原理与接口技术
- 学院：自动化学院
- 专业：自动化(新工科试验班)
- 学生姓名：张跃哲
- 学号：张跃哲
- 指导教师：金朝阳
- 报告语言：中文
- LaTeX 引擎：XeLaTeX

统一配置文件：`REPORT_PROFILE.json`

## 2. 根目录与实验目录规范
根目录示例：

- `01_single_led/`
- `02_xxx/`
- `03_xxx/`
- `REPORT_PROFILE.json`
- `REPORT_WORKFLOW_STANDARD.md`

每个实验目录建议结构：

- `NN_experiment_name/`
- `NN_experiment_name/NN_experiment_name.A51`
- `NN_experiment_name/NN_experiment_name.LST`
- `NN_experiment_name/doc/ReportTemplate.docx`
- `NN_experiment_name/doc/ExperimentGuide.doc(.docx)`
- `NN_experiment_name/doc/img/`（原理图、实验截图）
- `NN_experiment_name/doc/output/latex/`（LaTeX 工程）
- `NN_experiment_name/doc/output/ExperimentN_Report.pdf`（最终 PDF）

## 3. 每次实验标准流程

1. 在根目录创建新实验文件夹，命名采用 `NN_实验关键词`（例如 `02_led_rotate`）。
2. 放入程序文件（`.A51`、`.LST`）和教师文档（模板、实验指导书）。
3. 在 `doc/img/` 放入 Proteus 原理图截图和必要实验现象截图。
4. 复制上一实验可用的 LaTeX 工程到新实验：
   - 来源：上一实验 `doc/output/latex/`
   - 目标：新实验 `doc/output/latex/`
5. 修改 `main.tex` 中实验标题、完成日期，并确认个人信息字段保持为固定值。
6. 修改 `sections/` 下实验正文内容：
   - 实验要求与目的
   - 原理图与硬件说明
   - 流程图
   - 代码与逐段解释
   - 调试记录与结果分析
7. 运行编译脚本生成 PDF，检查格式与内容后提交。

## 4. 生成与编译规范
在实验目录 `doc/output/latex/` 中执行：

```bat
build_report.bat
```

默认输出：

- `doc/output/Experiment1_Report.pdf`（或按实验编号命名）

## 5. 质量检查清单（提交前）

- 封面字段无“待填写”。
- 目录页码与章节编号正常。
- 原理图清晰，图题完整。
- 代码为完整版本，且逐段解释与源码一致。
- 实验要求 1~4 均有明确对应说明。
- PDF 可正常打开，页面无明显溢出或乱码。

## 6. 后续复用建议

- 新实验默认复用 `REPORT_PROFILE.json` 中的个人/课程信息。
- 仅在变动时修改：实验标题、实验内容、完成日期、实验结果。
- 建议每次实验都保留 `build_report.bat`，保证一键构建。
