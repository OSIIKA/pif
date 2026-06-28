document.addEventListener("DOMContentLoaded", function() {
    const previewBar = document.getElementById("chat-preview-bar");
    const overlay = document.getElementById("chat-overlay");
    const closeBtn = document.getElementById("chat-close-btn");
    const scrollArea = document.getElementById("chat-history-scroll");

    // チャットを最下部までスクロールさせる関数
    function scrollToBottom() {
      if (scrollArea) {
        scrollArea.scrollTop = scrollArea.scrollHeight;
      }
    }

    // 開く処理
    previewBar.addEventListener("click", function() {
      overlay.style.display = "flex";
      scrollToBottom();
    });

    // 閉じる処理
    closeBtn.addEventListener("click", function() {
      overlay.style.display = "none";
      // URLのパラメータ (?chat=open) を綺麗に消して通常URLに戻すおもてなし
      if (window.location.search.includes("chat=open")) {
        window.history.replaceState({}, document.title, window.location.pathname);
      }
    });

    // 🌟 魔法の判定：URLに ?chat=open が入っていたら最初から開く＆最下部スクロール
    if (window.location.search.includes("chat=open")) {
      overlay.style.display = "flex";
      scrollToBottom();
    }
});
// 最新チャットを取得して画面に反映
function loadChats() {
  fetch('/chat/global')
    .then(res => res.json())
    .then(data => {
      const box = document.getElementById('global-chat-box');
      box.innerHTML = '';

      data.forEach(chat => {
        const line = document.createElement('div');
        line.textContent = `${chat.time} | ${chat.user}: ${chat.body}`;
        box.appendChild(line);
      });
    });
}

// チャット送信
function sendChat() {
  const text = document.getElementById('chat-input').value;
  if (!text.trim()) return;

  fetch('/home/chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `chat_body=${encodeURIComponent(text)}`
  }).then(() => {
    document.getElementById('chat-input').value = '';
    loadChats(); // 即時反映
  });
}

// 2秒ごとにチャット更新
setInterval(loadChats, 2000);

// 初回ロード
loadChats();