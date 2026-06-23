document.addEventListener('DOMContentLoaded', () => {
  const nameText = document.getElementById('name-text');
  const editBtn = document.getElementById('edit-name-btn');
  const editForm = document.getElementById('name-edit-form');
  const cancelBtn = document.getElementById('cancel-name-btn');

  // ユーザー名の表示枠を編集モードへ切り替え（要素が存在する場合のみ）
  if (editBtn && nameText && editForm) {
    editBtn.addEventListener('click', () => {
      nameText.style.display = 'none';
      editBtn.style.display = 'none';
      editForm.style.display = 'inline-flex';
    });
  }

  // ユーザー名の変更をキャンセルして元に戻す（要素が存在する場合のみ）
  if (cancelBtn && nameText && editBtn && editForm) {
    cancelBtn.addEventListener('click', () => {
      nameText.style.display = 'inline';
      editBtn.style.display = 'inline';
      editForm.style.display = 'none';
    });
  }

  // ▼ ユーザーの所持ユニット一覧の表示/非表示
  const toggleUnitsButton = document.getElementById('toggle-units');
  const unitsDiv = document.querySelector('.units');

  if (toggleUnitsButton && unitsDiv) {
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

  if (toggleStorysButton && storysDiv) {
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

  if (sortieButton && sortieOverlay) {
    sortieButton.addEventListener('click', () => {
      sortieOverlay.style.display = 'flex';
    });
  }

  if (sortieClose && sortieOverlay) {
    sortieClose.addEventListener('click', () => {
      sortieOverlay.style.display = 'none';
    });
  }

  if (sortieOverlay && sortieMenuButtons.length > 0) {
    sortieMenuButtons.forEach(btn => {
      btn.addEventListener('click', () => {
        const mode = btn.dataset.mode;
        console.log('選択されたモード:', mode);
        sortieOverlay.style.display = 'none';
      });
    });
  }

  // ▼ ストーリー選択オーバーレイ
  const storyOverlay = document.getElementById('story-overlay');
  const storyClose = document.getElementById('story-close');

  if (storyOverlay && sortieMenuButtons.length > 0) {
    sortieMenuButtons.forEach(btn => {
      btn.addEventListener('click', () => {
        const mode = btn.dataset.mode;
        if (mode === 'story') {
          sortieOverlay.style.display = 'none';
          storyOverlay.style.display = 'flex';
        }
      });
    });
  }

  if (storyClose && storyOverlay && sortieOverlay) {
    storyClose.addEventListener('click', () => {
      storyOverlay.style.display = 'none';
      sortieOverlay.style.display = 'flex';
    });
  }

  // ▼ イベント選択オーバーレイ
  const eventOverlay = document.getElementById('event-overlay');
  const eventClose = document.getElementById('event-close');

  if (eventOverlay && sortieMenuButtons.length > 0) {
    sortieMenuButtons.forEach(btn => {
      btn.addEventListener('click', () => {
        const mode = btn.dataset.mode;
        if (mode === 'event' && eventOverlay) {
          sortieOverlay.style.display = 'none';
          eventOverlay.style.display = 'flex';
        }
      });
    });
  }

  if (eventClose && eventOverlay && sortieOverlay) {
    eventClose.addEventListener('click', () => {
      eventOverlay.style.display = 'none';
      sortieOverlay.style.display = 'flex';
    });
  }

  // ▼ イベント情報の3秒ごとのスライドショー
  const eventDisplay = document.getElementById('current-event-text');

  if (!eventDisplay) return;

  if (window.eventList && window.eventList.length > 0) {
    let currentIndex = 0;

    const displayEvent = () => {
      const event = window.eventList[currentIndex];
      eventDisplay.textContent = event.name;
      eventDisplay.style.color = event.color || '#fff';
    };

    displayEvent();

    setInterval(() => {
      currentIndex = (currentIndex + 1) % window.eventList.length;
      displayEvent();
    }, 3000);
  } else {
    eventDisplay.textContent = '現在開催中のイベントはありません';
    eventDisplay.style.color = '#aaa';
  }
});