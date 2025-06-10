# 🔍 現状調査インベントリ

**調査日時**: 2024年1月  
**調査範囲**: システム全体のMCP設定・プロジェクトファイル  
**調査ステータス**: 🔄 進行中

---

## 📋 MCP設定の現状

### 🔧 発見されたMCP設定ファイル
**場所**: `/Users/shingoyamaguchi02/.cursor/mcp.json`

### 📊 現在の設定内容
```json
{
  "mcpServers": {
    "n8n-workflow-builder": {
      "command": "npx",
      "args": ["-y", "@kernel.salacoste/n8n-workflow-builder"],
      "env": {
        "N8N_HOST": "http://localhost:5678/api/v1/",
        "N8N_API_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "READ_ONLY": "false"
      }
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
      "env": {
        "PUPPETEER_EXECUTABLE_PATH": "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y", "@modelcontextprotocol/server-filesystem",
        "/Users/shingoyamaguchi02/Desktop",
        "/Users/shingoyamaguchi02/Documents", 
        "/Users/shingoyamaguchi02/Downloads",
        "/Users/shingoyamaguchi02/Library/Mobile Documents/com~apple~CloudDocs"
      ]
    },
    "airtable": {
      "command": "npx",
      "args": ["@felores/airtable-mcp-server"],
      "env": {
        "AIRTABLE_API_KEY": "patn[MASKED_API_KEY].."
      }
    },
    "notionApi": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "OPENAPI_MCP_HEADERS": "{\"Authorization\": \"Bearer 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\", \"Notion-Version\": \"2022-06-28\" }"
      }
    }
  }
}
```

### ⚠️ MCP設定の問題点
1. **セキュリティ**: APIキーが平文で記載
2. **パス設定**: Development フォルダがfilesystem MCPに含まれていない
3. **設定管理**: バックアップが存在しない
4. **環境依存**: Mac固有のパス設定（Chrome等）

---

## 🚀 プロジェクトの現状

### 📁 発見されたプロジェクト

#### **flux-lab** 
- **場所**: `/Users/shingoyamaguchi02/flux-lab/`
- **種類**: FLUX.1 WebUI プロジェクト
- **ステータス**: ✅ アクティブ
- **特記事項**: メインプロジェクトとして稼働中

#### **llama-lab**
- **場所**: `/Users/shingoyamaguchi02/llama-lab/`
- **種類**: LLaMA実験環境
- **ステータス**: ✅ アクティブ
- **特記事項**: Python 3.13 venv環境を使用

#### **sd-lab**
- **場所**: `/Users/shingoyamaguchi02/sd-lab/`
- **種類**: Stable Diffusion プロジェクト
- **ステータス**: ✅ アクティブ

### 📍 プロジェクトの配置
```
/Users/shingoyamaguchi02/
├── flux-lab/                   # メインプロジェクト
├── llama-lab/                  # LLaMA実験
├── sd-lab/                     # Stable Diffusion
└── Development/                # 現在の作業エリア
    ├── Development_Mac/        # 空フォルダ
    └── Development _Drive      # バイナリファイル
```

---

## 🔍 散乱ファイル・設定の調査

### ✅ 確認済み項目
- [x] MCP設定ファイル場所特定: `/Users/shingoyamaguchi02/.cursor/mcp.json`
- [x] メインプロジェクト確認: flux-lab, llama-lab, sd-lab
- [x] 現在のディレクトリ構造確認

### ⏳ 調査継続中
- [x] 各プロジェクトの詳細構造
- [x] 依存関係・環境設定
- [x] 設定ファイルの散在状況
- [ ] 重複ファイルの確認

### 📁 プロジェクト詳細構造

#### **flux-lab** (18 items)
```
flux-lab/
├── .cursorrules              # Cursor設定
├── FLUX_OPERATION_GUIDE.md   # 操作ガイド
├── FLUX_SETUP_GUIDE.md       # セットアップガイド
├── flux_webui.py             # メインWebUI (12.3KB)
├── Makefile                  # 自動化コマンド
├── output/                   # 生成ファイル (11 items)
├── README.md                 # プロジェクト説明
├── scripts/                  # 実行スクリプト (5 items)
├── server.log                # サーバーログ
├── setup/                    # セットアップ (4 items)
├── simple_test.py            # テストコード
├── STATUS.md                 # プロジェクト状況
├── test_server.py            # サーバーテスト
├── tests/                    # テスト (3 items)
├── venv/                     # Python仮想環境 (7 items)
└── wav_to_mp4_converter.py   # 音声変換ツール
```

#### **llama-lab** (20 items)
```
llama-lab/
├── .cursorrules              # Cursor設定
├── .pytest_cache/            # Pytestキャッシュ (6 items)
├── .venv/                    # Python仮想環境 (8 items, Python 3.13)
├── conversations/            # 会話ログ (5 items)
├── docs/                     # ドキュメント (3 items)
├── download_reliable_model.py # モデルダウンロード (3.5KB)
├── instructions.md           # 指示書
├── Makefile                  # 自動化コマンド (13KB)
├── models/                   # AIモデル (4 items)
├── output/                   # 出力ファイル (12 items)
├── README.md                 # プロジェクト説明 (7KB)
├── scripts/                  # 実行スクリプト (10 items)
├── setup/                    # セットアップ (5 items)
├── test_models.py            # モデルテスト (3KB)
├── tests/                    # テスト (4 items)
├── webui/                    # WebUIコンポーネント (33 items)
├── webui_pro_advanced.py     # 高度なWebUI (25KB)
└── workflow_state.md         # ワークフロー状態
```

#### **sd-lab** (13 items)
```
sd-lab/
├── .cursorrules              # Cursor設定
├── .pytest_cache/            # Pytestキャッシュ (6 items)
├── .venv/                    # Python仮想環境 (8 items)
├── instructions.md           # 指示書
├── Makefile                  # 自動化コマンド
├── models/                   # AIモデル (4 items)
├── output/                   # 出力ファイル (3 items)
├── scripts/                  # 実行スクリプト (3 items)
├── setup/                    # セットアップ (4 items)
├── tests/                    # テスト (5 items)
└── workflow_state.md         # ワークフロー状態
```

---

## 📊 依存関係マップ（詳細版）

### 🔗 技術スタック詳細
```
MCP設定 (/Users/shingoyamaguchi02/.cursor/mcp.json)
├── n8n-workflow-builder
│   ├── command: npx @kernel.salacoste/n8n-workflow-builder
│   ├── N8N_HOST: http://localhost:5678/api/v1/
│   └── N8N_API_KEY: [MASKED]
├── puppeteer  
│   ├── command: npx @modelcontextprotocol/server-puppeteer
│   └── CHROME_PATH: /Applications/Google Chrome.app/Contents/MacOS/Google Chrome
├── filesystem
│   ├── command: npx @modelcontextprotocol/server-filesystem
│   └── 監視対象: Desktop, Documents, Downloads, iCloud Drive
├── airtable
│   ├── command: npx @felores/airtable-mcp-server  
│   └── AIRTABLE_API_KEY: [MASKED]
└── notionApi
    ├── command: npx @notionhq/notion-mcp-server
    └── NOTION_API_KEY: [MASKED] (Bearer token)

AI/MLプロジェクト環境
├── flux-lab (Python 3.11 + venv)
│   ├── 依存関係: FLUX.1, Gradio, PyTorch
│   ├── 主要ファイル: flux_webui.py (12.3KB)
│   ├── 出力: output/ (11 items)
│   └── 設定: .cursorrules, Makefile
├── llama-lab (Python 3.13 + .venv)  
│   ├── 依存関係: LLaMA, HuggingFace, Gradio
│   ├── 主要ファイル: webui_pro_advanced.py (25KB)
│   ├── 出力: output/ (12 items)
│   └── 設定: .cursorrules, Makefile (13KB)
└── sd-lab (Python + .venv)
    ├── 依存関係: Stable Diffusion
    ├── 出力: output/ (3 items)
    └── 設定: .cursorrules, Makefile
```

### 🌐 API・サービス依存関係詳細
```
外部API接続
├── N8N Workflow Automation
│   ├── エンドポイント: localhost:5678/api/v1/
│   ├── 認証: JWT Token
│   └── 用途: ワークフロー自動化
├── Notion API  
│   ├── エンドポイント: api.notion.com
│   ├── 認証: Bearer Token (ntn_...)
│   ├── バージョン: 2022-06-28
│   └── 用途: ドキュメント管理
├── Airtable API
│   ├── エンドポイント: api.airtable.com
│   ├── 認証: API Key (patn[MASKED_API_KEY]..)
│   └── 用途: データベース操作
└── Google Chrome (Puppeteer)
    ├── 実行ファイル: /Applications/Google Chrome.app/...
    └── 用途: Web自動化・スクレイピング

ローカルサービス
├── Python仮想環境
│   ├── flux-lab/venv/ (Python 3.11)
│   ├── llama-lab/.venv/ (Python 3.13) 
│   └── sd-lab/.venv/ (Python バージョン不明)
├── NPX パッケージ管理
│   ├── MCP サーバー群の実行
│   └── 動的パッケージインストール
└── Makefile自動化
    ├── 各プロジェクトに個別Makefile
    └── プロジェクト管理・実行コマンド
```

### 🔄 ファイル・設定の相互依存
```
設定ファイル分散状況
├── .cursorrules (各プロジェクトに個別)
│   ├── flux-lab/.cursorrules
│   ├── llama-lab/.cursorrules  
│   └── sd-lab/.cursorrules
├── Makefile (各プロジェクトに個別)
│   ├── flux-lab/Makefile
│   ├── llama-lab/Makefile (13KB, 最大)
│   └── sd-lab/Makefile
├── workflow_state.md (共通パターン)
│   ├── llama-lab/workflow_state.md
│   └── sd-lab/workflow_state.md
└── バックアップ状況
    ├── MCP設定: ~/Development/backup_20250607_111906/
    └── プロジェクト: 個別バックアップなし
```

---

## 🚨 優先課題・リスク

### 🔴 高優先度
1. **セキュリティ**: APIキー暴露リスク
2. **バックアップ**: 設定の単一障害点
3. **パス管理**: 開発フォルダが統一されていない

### 🟡 中優先度
1. **設定分散**: 各プロジェクトに個別設定が散在
2. **環境依存**: Mac固有設定が混在
3. **管理複雑性**: プロジェクトが複数場所に分散

### 🟢 低優先度
1. **最適化**: キャッシュ・一時ファイル整理
2. **ドキュメント**: 運用手順の明文化

---

## 🔄 次のアクション

### immediate
- [ ] 各プロジェクトの詳細構造調査
- [ ] 現在の設定ファイル完全バックアップ
- [ ] セキュリティ設定改善計画

### short-term
- [ ] 依存関係の完全マップ作成
- [ ] 重複・不要ファイル特定
- [ ] 移行優先順位付け

---

**📝 調査メモ**
- MCP設定は一箇所に集約されている（良好）
- プロジェクトは3つとも明確に分離されている（良好）
- APIキーの平文保存が最大のセキュリティリスク
- パス設定がMac固有で移植時に調整が必要 