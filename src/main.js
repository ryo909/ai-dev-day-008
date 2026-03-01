/**
 * AI個人開発実験 — Dayテンプレート ロジック
 *
 * - meta.json から day/title/description/theme を読み込んで表示
 * - theme は CSS variables を適用
 * - 入力→処理→出力のベースを提供
 */

import meta from '../meta.json';
import { applyTheme } from './themes';
import './style.css';

applyTheme(meta.theme);

const headerBadge = document.getElementById('headerBadge');
const headerTitle = document.getElementById('headerTitle');
const headerDesc = document.getElementById('headerDesc');
const footerDay = document.getElementById('footerDay');
const actionBtn = document.getElementById('actionBtn');
const toolInput = document.getElementById('toolInput');
const toolOutput = document.getElementById('toolOutput');
const outputGroup = document.getElementById('outputGroup');

headerBadge.textContent = meta.day || 'DayXXX';
headerTitle.textContent = meta.title || 'Untitled Tool';
headerDesc.textContent = meta.description || '説明をここに';
footerDay.textContent = `${meta.day || 'DayXXX'} / #100日開発`;

actionBtn.addEventListener('click', () => {
  const input = toolInput.value.trim();

  if (!input) {
    showOutput('Please enter input text.', 'warning');
    return;
  }

  const result = processInput(input);
  showOutput(result, 'success');
});

function processInput(input) {
  const charCount = input.length;
  const wordCount = input.split(/\s+/).filter(Boolean).length;
  const lineCount = input.split('\n').length;

  return `Analysis:\n- Characters: ${charCount}\n- Words: ${wordCount}\n- Lines: ${lineCount}`;
}

function showOutput(content, type = 'info') {
  outputGroup.style.display = '';
  toolOutput.className = `output-area output-${type}`;
  toolOutput.textContent = content;

  outputGroup.style.animation = 'none';
  outputGroup.offsetHeight;
  outputGroup.style.animation = 'fadeSlideIn 0.25s ease';
}
