# Day008 — Draft Tightener

> 文章を短く整えて、投稿しやすい形に圧縮するライティングツール。

## 使い方

1. ページを開く
2. 入力欄にテキストを入れる
3. 実行して結果を確認する

## Story

- [制作ストーリー](./STORY.md)

## Demo

🌐 [GitHub Pages](https://ryo909.github.io/ai-dev-day-008/)

## Auto Pipeline

```bash
bash scripts/auto_pipeline.sh
```

```bash
# payload確認のみ（Webhook送信なし）
DRY_RUN=1 YT_DISABLED=1 bash scripts/auto_pipeline.sh

# YouTubeルートもpayloadに含める
DRY_RUN=1 YT_DISABLED=0 bash scripts/auto_pipeline.sh
```

---

Day008 / #100日開発
