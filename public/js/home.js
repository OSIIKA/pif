const nameText = document.getElementById('name-text');
const editBtn = document.getElementById('edit-name-btn');
const editForm = document.getElementById('name-edit-form');
const cancelBtn = document.getElementById('cancel-name-btn');

// ユーザー名の表示枠を編集モードへ切り替え
editBtn.addEventListener('click', () => {
  nameText.style.display = 'none';
  editBtn.style.display = 'none';
  editForm.style.display = 'inline-flex';
});

// ユーザー名の変更をキャンセルして元に戻す
cancelBtn.addEventListener('click', () => {
  nameText.style.display = 'inline';
  editBtn.style.display = 'inline';
  editForm.style.display = 'none';
});



// ▼ ユーザーの所持ユニット一覧の表示/非表示
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

// ▼ イベント選択オーバーレイ
const eventOverlay = document.getElementById('event-overlay');
const eventClose = document.getElementById('event-close');

// 出撃メニューの「イベント」ボタンを押したら表示
sortieMenuButtons.forEach(btn => {
  btn.addEventListener('click', () => {
    const mode = btn.dataset.mode;
    if (mode === 'event' && eventOverlay) {
      sortieOverlay.style.display = 'none';
      eventOverlay.style.display = 'flex';
    }
  });
});

// イベント選択の閉じるボタン
if (eventClose && eventOverlay) {
  eventClose.addEventListener('click', () => {
    eventOverlay.style.display = 'none';   // イベント選択を閉じる
    sortieOverlay.style.display = 'flex';  // 出撃メニューを再表示
  });
}

// ▼ イベント情報の3秒ごとのスライドショー
document.addEventListener('DOMContentLoaded', () => {
  const eventDisplay = document.getElementById('current-event-text');
  
  // イベント配列が存在し、イベントがある場合のみ処理
  if (window.eventList && window.eventList.length > 0 && eventDisplay) {
    let currentIndex = 0;
    
    // 最初のイベントを表示
    const displayEvent = () => {
      const event = window.eventList[currentIndex];
      eventDisplay.textContent = event.name;
      eventDisplay.style.color = event.color;
    };
    
    displayEvent();
    
    // 3秒ごとにイベントを切り替え
    setInterval(() => {
      currentIndex = (currentIndex + 1) % window.eventList.length;
      displayEvent();
    }, 3000);
  }
});