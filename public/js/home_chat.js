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