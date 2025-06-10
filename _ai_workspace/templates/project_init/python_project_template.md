# 🐍 Python プロジェクト初期化テンプレート

**用途**: 新規Pythonプロジェクトの迅速な初期化  
**対象**: AI/ML、WebUI、自動化スクリプト等  
**所要時間**: 10-15分

---

## 📁 ディレクトリ構造テンプレート

```
project_name/
├── README.md              # プロジェクト概要
├── requirements.txt       # Python依存関係
├── .env.example          # 環境変数テンプレート
├── .gitignore            # Git除外設定
├── Makefile              # 自動化コマンド
├── setup.py              # パッケージ設定（必要に応じて）
├── config/               # 設定ファイル
│   ├── settings.json     # アプリケーション設定
│   └── logging.conf      # ログ設定
├── scripts/              # 実行スクリプト
│   ├── setup.sh          # 初期セットアップ
│   ├── start.sh          # アプリケーション起動
│   └── test.sh           # テスト実行
├── src/                  # ソースコード
│   ├── __init__.py
│   ├── main.py           # メインアプリケーション
│   ├── utils/            # ユーティリティ
│   │   ├── __init__.py
│   │   └── helpers.py
│   └── models/           # データモデル（AI/ML用）
│       ├── __init__.py
│       └── base.py
├── tests/                # テストコード
│   ├── __init__.py
│   ├── test_main.py
│   └── conftest.py       # pytest設定
├── docs/                 # ドキュメント
│   ├── installation.md
│   ├── usage.md
│   └── api.md
├── output/               # 生成ファイル
├── logs/                 # ログファイル
└── venv/                 # Python仮想環境
```

---

## 🚀 初期化コマンド

### **1. 基本構造作成**
```bash
# プロジェクトディレクトリ作成
cd ~/Development/active_projects
mkdir project_name && cd project_name

# ディレクトリ構造作成
mkdir -p {config,scripts,src/{utils,models},tests,docs,output,logs}

# Python初期ファイル作成
touch src/__init__.py src/main.py src/utils/__init__.py src/utils/helpers.py
touch src/models/__init__.py src/models/base.py
touch tests/__init__.py tests/test_main.py tests/conftest.py

# 基本ファイル作成
touch README.md requirements.txt .env.example .gitignore Makefile
touch config/settings.json config/logging.conf
touch scripts/{setup.sh,start.sh,test.sh}
touch docs/{installation.md,usage.md,api.md}

# Python仮想環境作成
python -m venv venv
source venv/bin/activate
```

### **2. 基本ファイル内容設定**
```bash
# .gitignore設定
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# 環境・設定
.env
.venv
venv/
ENV/
env/
*.key
*.pem
config/local_*

# ログ・出力
logs/
*.log
output/temp_*

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF

# requirements.txt基本設定
cat > requirements.txt << 'EOF'
# 基本パッケージ
requests>=2.31.0
python-dotenv>=1.0.0

# ログ・ユーティリティ
loguru>=0.7.0
click>=8.1.0

# 開発・テスト
pytest>=7.4.0
black>=23.0.0
flake8>=6.0.0

# AI/ML（必要に応じてコメントアウト解除）
# torch>=2.0.0
# transformers>=4.30.0
# numpy>=1.24.0
# pandas>=2.0.0
# matplotlib>=3.7.0
# pillow>=10.0.0
# opencv-python>=4.8.0

# WebUI（必要に応じてコメントアウト解除）
# gradio>=3.40.0
# streamlit>=1.25.0
# flask>=2.3.0
# fastapi>=0.100.0
# uvicorn>=0.23.0
EOF

# .env.example設定
cat > .env.example << 'EOF'
# === アプリケーション設定 ===
DEBUG=true
LOG_LEVEL=INFO
PORT=8000

# === API キー（実際の値は.envに設定） ===
OPENAI_API_KEY=your_openai_api_key_here
HUGGINGFACE_TOKEN=your_hf_token_here

# === データベース（必要に応じて） ===
DATABASE_URL=sqlite:///./app.db

# === 外部サービス（必要に応じて） ===
REDIS_URL=redis://localhost:6379
WEBHOOK_URL=https://your-webhook-url.com
EOF
```

---

## 📄 ファイルテンプレート

### **README.md**
```markdown
# 🚀 プロジェクト名

**概要**: [プロジェクトの概要を1-2行で記載]

## 🎯 主な機能

- [機能1]
- [機能2]
- [機能3]

## 🔧 セットアップ

### 必要な環境
- Python 3.8+
- [その他の要件]

### インストール手順
```bash
# リポジトリクローン
git clone [repository_url]
cd project_name

# 仮想環境構築
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 依存関係インストール
pip install -r requirements.txt

# 環境変数設定
cp .env.example .env
# .env ファイルを編集して必要なAPIキー等を設定

# 初期セットアップ
bash scripts/setup.sh
```

## 🚀 使用方法

### 基本的な使用方法
```bash
# アプリケーション起動
bash scripts/start.sh

# または直接実行
python src/main.py
```

### 主要コマンド
```bash
# テスト実行
make test

# コード品質チェック
make lint

# セキュリティチェック
make security
```

## 📁 プロジェクト構造

```
[ディレクトリ構造を記載]
```

## 🔒 セキュリティ注意事項

- APIキーは `.env` ファイルに設定（`.env.example` を参考）
- 機密情報は **絶対に** コミットしない
- 定期的にセキュリティチェックを実行

## 📚 ドキュメント

- [インストールガイド](docs/installation.md)
- [使用方法](docs/usage.md)
- [API仕様](docs/api.md)

## 🤝 開発

### 開発環境セットアップ
```bash
# 開発用パッケージインストール
pip install -r requirements-dev.txt

# pre-commit設定
pre-commit install
```

### コントリビューション
1. フォークしてブランチ作成
2. 変更を実装
3. テスト実行・パス確認
4. プルリクエスト作成

## 📄 ライセンス

[ライセンス情報]

## 🙋‍♂️ サポート

問題や質問がある場合は [Issues](link) で報告してください。
```

### **src/main.py**
```python
#!/usr/bin/env python3
"""
メインアプリケーション

使用方法:
    python src/main.py [options]

環境変数:
    DEBUG: デバッグモード有効化
    LOG_LEVEL: ログレベル (DEBUG/INFO/WARNING/ERROR)
"""

import os
import sys
from pathlib import Path

# プロジェクトルートをパスに追加
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from src.utils.helpers import setup_logging, load_config
from dotenv import load_dotenv

# 環境変数読み込み
load_dotenv()

def main():
    """メイン関数"""
    # ログ設定
    logger = setup_logging()
    logger.info("アプリケーション開始")
    
    try:
        # 設定読み込み
        config = load_config()
        logger.info(f"設定読み込み完了: {config}")
        
        # メイン処理
        logger.info("メイン処理開始")
        
        # TODO: ここに実際の処理を実装
        
        logger.info("処理完了")
        
    except Exception as e:
        logger.error(f"エラーが発生しました: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### **src/utils/helpers.py**
```python
"""
ユーティリティ関数

よく使う共通処理をここに実装
"""

import json
import os
from pathlib import Path
from typing import Dict, Any
from loguru import logger

def setup_logging():
    """ログ設定をセットアップ"""
    log_level = os.getenv("LOG_LEVEL", "INFO")
    
    # ログファイル設定
    log_file = Path("logs") / "app.log"
    log_file.parent.mkdir(exist_ok=True)
    
    # ログフォーマット設定
    logger.add(
        log_file,
        rotation="10 MB",
        retention="1 week",
        level=log_level,
        format="{time:YYYY-MM-DD HH:mm:ss} | {level} | {name}:{function}:{line} | {message}"
    )
    
    return logger

def load_config() -> Dict[str, Any]:
    """設定ファイルを読み込み"""
    config_file = Path("config") / "settings.json"
    
    if not config_file.exists():
        logger.warning(f"設定ファイルが見つかりません: {config_file}")
        return {}
    
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        logger.error(f"設定ファイル読み込みエラー: {e}")
        return {}

def save_output(data: Any, filename: str, output_dir: str = "output") -> Path:
    """出力データを保存"""
    output_path = Path(output_dir)
    output_path.mkdir(exist_ok=True)
    
    file_path = output_path / filename
    
    try:
        if isinstance(data, (dict, list)):
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
        else:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(str(data))
        
        logger.info(f"出力保存完了: {file_path}")
        return file_path
        
    except Exception as e:
        logger.error(f"出力保存エラー: {e}")
        raise
```

### **Makefile**
```makefile
# Python プロジェクト用 Makefile

.PHONY: help setup start test lint security clean install

# デフォルトターゲット
help:
	@echo "利用可能なコマンド:"
	@echo "  setup     - 初期セットアップ"
	@echo "  start     - アプリケーション起動"
	@echo "  test      - テスト実行"
	@echo "  lint      - コード品質チェック"
	@echo "  security  - セキュリティチェック"
	@echo "  clean     - 一時ファイル削除"
	@echo "  install   - 依存関係インストール"

# 初期セットアップ
setup:
	python -m venv venv
	source venv/bin/activate && pip install --upgrade pip
	source venv/bin/activate && pip install -r requirements.txt
	chmod +x scripts/*.sh
	mkdir -p logs output
	cp .env.example .env
	@echo "✅ セットアップ完了"
	@echo "💡 .env ファイルを編集してAPIキー等を設定してください"

# 依存関係インストール
install:
	source venv/bin/activate && pip install -r requirements.txt

# アプリケーション起動
start:
	source venv/bin/activate && python src/main.py

# テスト実行
test:
	source venv/bin/activate && python -m pytest tests/ -v

# コード品質チェック
lint:
	source venv/bin/activate && flake8 src/ tests/
	source venv/bin/activate && black --check src/ tests/

# セキュリティチェック
security:
	@echo "🔒 セキュリティチェック実行中..."
	@grep -r "api.*key\|token\|secret\|password" . \
		--exclude-dir=venv --exclude-dir=.git --exclude="*.md" \
		--exclude=".env.example" || echo "✅ 暴露なし"
	@find . -name "*.env" -o -name "*.key" | xargs ls -la 2>/dev/null || true

# 一時ファイル削除
clean:
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type f -name "*.log" -delete
	find output/ -name "temp_*" -delete 2>/dev/null || true
	@echo "✅ クリーンアップ完了"

# 開発環境リセット
reset:
	rm -rf venv/
	make setup
```

---

## 🔒 セキュリティベストプラクティス

### **必須設定**
```bash
# ファイル権限設定
chmod 600 .env config/*.json
chmod +x scripts/*.sh

# Gitフック設定（pre-commit）
pip install pre-commit
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8

  - repo: local
    hooks:
      - id: check-secrets
        name: Check for secrets
        entry: bash -c 'grep -r "api.*key\|token\|secret" . --exclude-dir=venv --exclude-dir=.git || exit 0'
        language: system
        pass_filenames: false
EOF

pre-commit install
```

---

## 🚀 使用方法

このテンプレートを使用して新しいプロジェクトを作成:

```bash
# テンプレートをコピー
cp -r _ai_workspace/templates/project_init/ ~/Development/active_projects/new_project
cd ~/Development/active_projects/new_project

# 初期化実行
make setup

# 開発開始
make start
```

**重要**: プロジェクト作成後は必ず `.env` ファイルを編集してAPIキー等を設定してください。 