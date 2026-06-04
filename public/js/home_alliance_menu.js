document.addEventListener("DOMContentLoaded", function() {
    const menuOpenBtn = document.getElementById("menu-open-btn");
    const menuCloseBtn = document.getElementById("menu-close-btn");
    const menuOverlay = document.getElementById("menu-overlay");
    const tabButtons = document.querySelectorAll(".tab-btn");
    const tabContents = document.querySelectorAll(".tab-content");

    // 👇 ここから新設の確認画面用のJavaScriptを追記！ 👇
    const leaveAllianceBtn = document.getElementById("leave-alliance-btn");
    const confirmOverlay = document.getElementById("confirm-overlay");
    const confirmCancelBtn = document.getElementById("confirm-cancel-btn");

    // 「同盟から脱退する」を押したら、最前面に最終確認を開く
    if (leaveAllianceBtn) {
        leaveAllianceBtn.addEventListener("click", function() {
          confirmOverlay.style.display = "flex";
        });
    }

    // 最終確認で「いいえ」を押したら、確認画面だけを閉じる
    if (confirmCancelBtn) {
        confirmCancelBtn.addEventListener("click", function() {
          confirmOverlay.style.display = "none";
        });
    }
    // 👆 ここまで追記 👆

    // メニューを開く
    menuOpenBtn.addEventListener("click", function() {
        menuOverlay.style.display = "flex";
    });

    // メニューを閉じる
    menuCloseBtn.addEventListener("click", function() {
        menuOverlay.style.display = "none";
    });

    // タブ切り替えの魔法
    tabButtons.forEach(btn => {
        btn.addEventListener("click", function() {
          // すべてのボタンの選択状態（色）をリセット
          tabButtons.forEach(b => {
            b.style.background = "#222";
            b.style.color = "#aaa";
          });
          // クリックされたボタンをアクティブ化
          this.style.background = "#333";
          this.style.color = "#fff";

          // すべてのコンテンツを一旦非表示にする
          tabContents.forEach(content => content.style.display = "none");
          
          // ボタンの data-tab に紐づくコンテンツだけをパッと表示
          const targetId = this.getAttribute("data-tab");
          document.getElementById(targetId).style.display = "block";
        });
    });
});