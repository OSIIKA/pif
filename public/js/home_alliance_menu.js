document.addEventListener("DOMContentLoaded", function() {
  // ==========================================
  // 📝 1. 既存の変数（メニュー開閉・タブ切り替え用）※そのまま残します！
  // ==========================================
  const menuOpenBtn = document.getElementById("menu-open-btn"); 
  const menuCloseBtn = document.getElementById("menu-close-btn"); 
  const menuOverlay = document.getElementById("menu-overlay"); 
  const tabButtons = document.querySelectorAll(".tab-btn"); 
  const tabContents = document.querySelectorAll(".tab-content"); 

  // ==========================================
  // 💥 2. 今回使う変数（脱退・解散・カスタム確認画面用）
  // ==========================================
  const confirmOverlay = document.getElementById('confirm-overlay');
  const confirmCancelBtn = document.getElementById('confirm-cancel-btn');
  const confirmText = document.getElementById('confirm-text');
  const confirmForm = document.getElementById('confirm-form');
  const confirmSubmitBtn = document.getElementById('confirm-submit-btn');

  const leaveAllianceBtn = document.getElementById('leave-alliance-btn');
  const openDisbandOverlayBtn = document.getElementById('open-disband-overlay-btn');

  // ==========================================
  // ⚙️ 3. メニューの開閉・タブ切り替えロジック（既存の処理）
  // ==========================================
  if (menuOpenBtn && menuOverlay) {
    menuOpenBtn.addEventListener("click", function() {
      menuOverlay.style.display = "flex";
    });
  }

  if (menuCloseBtn && menuOverlay) {
    menuCloseBtn.addEventListener("click", function() {
      menuOverlay.style.display = "none";
    });
  }

  tabButtons.forEach(button => {
    button.addEventListener("click", function() {
      const targetTab = this.getAttribute("data-tab");

      tabButtons.forEach(btn => btn.classList.remove("active"));
      tabContents.forEach(content => content.style.display = "none");

      this.classList.add("active");
      const targetContent = document.getElementById(`tab-${targetTab}`);
      if (targetContent) {
        targetContent.style.display = "block";
      }
    });
  });

  // ==========================================
  // 🏃 4. 脱退ボタンが押されたときの処理（文字を脱退用にトランスフォーム）
  // ==========================================
  if (leaveAllianceBtn && confirmOverlay) {
    leaveAllianceBtn.addEventListener('click', () => {
      confirmText.innerHTML = `本当にこの同盟を脱退しますか？<br><span style="font-size: 12px; color: #888;">（脱退すると同盟チャットの履歴などは見られなくなります）</span>`;
      confirmForm.action = '/alliance/leave';
      confirmSubmitBtn.innerText = 'はい、脱退します';
      confirmOverlay.style.display = 'flex';
    });
  }

  // ==========================================
  // 💥 5. 解散ボタンが押されたときの処理（文字を解散用にトランスフォーム）
  // ==========================================
  if (openDisbandOverlayBtn && confirmOverlay) {
    openDisbandOverlayBtn.addEventListener('click', () => {
      confirmText.innerHTML = `本当にこの同盟を解散しますか？<br><span style="font-size: 12px; color: #ff4d4f; font-weight: bold;">⚠️ この操作は絶対に取り消せません。</span>`;
      confirmForm.action = '/alliance/disband';
      confirmSubmitBtn.innerText = 'はい、解散します';
      confirmOverlay.style.display = 'flex';
    });
  }

  // ==========================================
  // ❌ 6. 確認画面の「いいえ」が押されたときの処理（共通）
  // ==========================================
  if (confirmCancelBtn && confirmOverlay) {
    confirmCancelBtn.addEventListener('click', () => {
      confirmOverlay.style.display = 'none';
    });
  }
  // ==========================================
  // ❌ 7. メンバー追放確認画面の処理（開閉）
  // ==========================================
  window.openKickModal = function(userId, userName) {
    document.getElementById('kickTargetId').value = userId;
    document.getElementById('kickTargetName').innerText = userName;
    document.getElementById('kickModal').style.display = 'flex';
    }
  window.closeKickModal = function() {
    document.getElementById('kickModal').style.display = 'none';
  }
});