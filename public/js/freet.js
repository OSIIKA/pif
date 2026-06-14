// モーダルを開く（対象のスロット名をhiddenにセット）
function openSelectionModal(slotType) {
  document.getElementById('modalSlotType').value = slotType;
  document.getElementById('fleetModalOverlay').style.display = 'flex';
  document.getElementById('modalSearchInput').focus();
}

// モーダルを閉じる
function closeSelectionModal() {
  document.getElementById('fleetModalOverlay').style.display = 'none';
  document.getElementById('modalSearchInput').value = ''; // 検索窓をリセット
  filterModalShips(); // 絞り込みもリセット
}

// 選択してフォームを自動送信
function submitModalSelection(userMyfreetId) {
  document.getElementById('modalUserMyfreetId').value = userMyfreetId;
  document.getElementById('modalFleetForm').submit();
}

// 🔍 リアルタイム絞り込みロジック
function filterModalShips() {
  const keyword = document.getElementById('modalSearchInput').value.toLowerCase();
  const cards = document.querySelectorAll('.modal-ship-card');
    
  cards.forEach(card => {
    const shipName = card.getAttribute('data-name').toLowerCase();
    if (shipName.includes(keyword)) {
      card.style.display = 'flex'; // マッチしたら表示
    } else {
      card.style.display = 'none';  // マッチしなければ隠す
    }
  });
}