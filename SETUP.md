# 港股 / 个股深度研判库 · 网站部署说明

本目录（vault 内的 `.site/`）是 Quartz v5 站点项目，把 Obsidian vault 发布为可浏览的网站，并托管每只股票的仪表盘。

## 架构

```
vault (Obsidian, iCloud 同步)
├── stocks/tencent/
│   ├── 00-...06-*.md     报告正文
│   ├── data.json         图表数据
│   └── dashboard.html    仪表盘 (A)
├── case-studies/  operators/  patterns/  playbooks/  INDEX.md
└── .site/                          ← Quartz 项目（本目录，在 vault 内）
    ├── quartz.config.yaml          ← 站点配置
    ├── content/                    ← 软链接 vault 内容（绝对路径）
    │   ├── stocks -> vault/stocks
    │   ├── case-studies -> ...
    │   └── ...
    ├── node_modules.nosync/         ← 177MB 依赖，iCloud 跳过（.nosync 机制）
    ├── node_modules -> node_modules.nosync   ← 软链接，npm 照常用
    └── public/                     ← 构建产物（.gitignore）
```

**iCloud 不背锅**：`node_modules` 真实内容在 `node_modules.nosync/`（177MB / 7221 文件），macOS iCloud 会跳过任何 `.nosync` 结尾的文件/文件夹；`node_modules` 只是个软链接。其余 Quartz 源码（几 MB）正常同步，跟着 vault 走。

- **A 仪表盘**：`stocks/tencent/dashboard.html`，自包含 HTML + ECharts，fetch 同目录 `data.json` 渲染图表。
- **B 站点**：Quartz 渲染报告 .md 为网页，原生支持 `[[wikilink]]`、全文搜索、图谱视图、反向链接、暗色模式。

## 前置依赖

- Node.js ≥ 20（本机已装 v23.11.0）
- 网络可访问 GitHub（首次安装插件需克隆 ~45 个社区插件仓库）

## 首次启动

```bash
VAULT="/Users/spacey/Library/Mobile Documents/iCloud~md~obsidian/Documents/AIGC/StockAnalysis"
cd "$VAULT/.site"

# 1. 装依赖（已执行，新机器需重跑；装完记得做 .nosync 软链接见下）
npm install

# 2. 安装 Quartz 社区插件（从 lockfile，首次约 5—10 分钟）
npx quartz plugin install

# 3. 本地预览（默认 http://localhost:8080）
npx quartz build --serve
```

> 新机器装完依赖后，务必做 `.nosync` 处理避免 iCloud 同步 177MB：
> ```bash
> cd "$VAULT/.site"
> mv node_modules node_modules.nosync
> ln -s node_modules.nosync node_modules
> ```

## 日常使用

```bash
cd "/Users/spacey/Library/Mobile Documents/iCloud~md~obsidian/Documents/AIGC/StockAnalysis/.site"
./serve.sh
```
`serve.sh` 启动 Quartz 自带服务器（处理 clean URL，让报告间 `[[wikilink]]` 双链可跳转），并把仪表盘文件放到与报告同目录。浏览器打开：
- 仪表盘：http://localhost:8080/stocks/tencent/dashboard.html
- 七问总纲：http://localhost:8080/stocks/tencent/00-tencent-seven-questions-summary
- 首页/导航：http://localhost:8080/

仅构建（不启动 server，产物在 `public/`）：
```bash
./build.sh
```

## 软链接修复

若 vault 路径变化导致链接断开，重建：
```bash
cd "/Users/spacey/Library/Mobile Documents/iCloud~md~obsidian/Documents/AIGC/StockAnalysis/.site/content"
VAULT="/Users/spacey/Library/Mobile Documents/iCloud~md~obsidian/Documents/AIGC/StockAnalysis"
ln -sf "$VAULT/stocks" stocks
ln -sf "$VAULT/case-studies" case-studies
ln -sf "$VAULT/operators" operators
ln -sf "$VAULT/patterns" patterns
ln -sf "$VAULT/playbooks" playbooks
ln -sf "$VAULT/INDEX.md" INDEX.md
```

## 配置要点（quartz.config.yaml）

- `pageTitle`: 港股 / 个股深度研判库
- `locale`: zh-CN
- `ignorePatterns`: 排除 `openspec/`、`_templates/`、`.claude/`、`.DS_Store`、`.obsidian`
- 默认启用：obsidian-flavored-markdown（[[wikilink]]）、search、graph、backlinks、darkmode、explorer

## 加新股票仪表盘

1. 在 vault `stocks/<ticker>/` 下写报告 .md（用 `[[...]]` 互链）
2. 写 `stocks/<ticker>/data.json`（参考 `stocks/tencent/data.json` 的 schema：meta/kpi/price/valuation/pressure/regulatory/shareholders/buyback）
3. 复制 `stocks/tencent/dashboard.html` 改名，调整 fetch 路径与组件组合
4. `npx quartz build --serve` 自动生效

## 仅看仪表盘（不开 Quartz）

```bash
cd "<vault>/stocks/tencent"
python3 -m http.server 8080
# 浏览器打开 http://localhost:8080/dashboard.html
```
注意：双击直接打开 dashboard.html 会因 CORS 拦截 fetch，需用本地 server。

## 维护

- 数据过期：`data.json` 与报告内的"数据截止日"需手动同步；财报季更新。
- vault 不含 node_modules（Quartz 项目在 vault 外，不污染 iCloud 同步）。
- 部署到 GitHub Pages：`npx quartz sync` 或手动传 `public/`。
