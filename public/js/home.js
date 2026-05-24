// ▼ ユニット一覧の表示/非表示
const toggleUnitsButton = document.getElementById('toggle-units');
const unitsDiv = document.querySelector('.units');

if (toggleUnitsButton) {
  toggleUnitsButton.addEventListener('click', () => {
    if (unitsDiv.style.display === 'none') {
      unitsDiv.style.display = 'block';
      toggleUnitsButton.textContent = '隠す';
    } else {
      unitsDiv.style.display = 'none';
      toggleUnitsButton.textContent = '表示する';
    }
  });
}

// ▼ ストーリー一覧の表示/非表示
const toggleStorysButton = document.getElementById('toggle-storys');
const storysDiv = document.querySelector('.storys');

if (toggleStorysButton) {
  toggleStorysButton.addEventListener('click', () => {
    if (storysDiv.style.display === 'none') {
      storysDiv.style.display = 'block';
      toggleStorysButton.textContent = '隠す';
    } else {
      storysDiv.style.display = 'none';
      toggleStorysButton.textContent = '表示する';
    }
  });
}

// ▼ 出撃メニュー（オーバーレイ）
const sortieButton = document.getElementById('sortie-button');
const sortieOverlay = document.getElementById('sortie-overlay');
const sortieClose = document.getElementById('sortie-close');
const sortieMenuButtons = document.querySelectorAll('.sortie-menu-button');

// 出撃ボタン → オーバーレイ表示
if (sortieButton) {
  sortieButton.addEventListener('click', () => {
    sortieOverlay.style.display = 'flex';
  });
}

// 閉じるボタン → オーバーレイ非表示
if (sortieClose) {
  sortieClose.addEventListener('click', () => {
    sortieOverlay.style.display = 'none';
  });
}

// メニューの各ボタン
sortieMenuButtons.forEach(btn => {
  btn.addEventListener('click', () => {
    const mode = btn.dataset.mode;
    console.log('選択されたモード:', mode);

    // 将来ここで画面遷移を実装する
    sortieOverlay.style.display = 'none';
  });
});
// ▼ ストーリー選択オーバーレイ
const storyOverlay = document.getElementById('story-overlay');
const storyClose = document.getElementById('story-close');

// 出撃メニューの「ストーリー」ボタンを押したら表示
sortieMenuButtons.forEach(btn => {
  btn.addEventListener('click', () => {
    const mode = btn.dataset.mode;

    if (mode === 'story') {
      sortieOverlay.style.display = 'none';
      storyOverlay.style.display = 'flex';
    }
  });
});

// ストーリー選択の閉じるボタン
if (storyClose) {
  storyClose.addEventListener('click', () => {
    storyOverlay.style.display = 'none';   // ストーリー選択を閉じる
    sortieOverlay.style.display = 'flex';  // 出撃メニューを再表示
  });
}
