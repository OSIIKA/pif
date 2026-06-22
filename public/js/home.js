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

// これは全艦艇データを引っ張ってきて図鑑モーダルに表示するためのコード
document.addEventListener('DOMContentLoaded', () => {
  const openBtn = document.getElementById('open-encyclopedia-btn');
  const closeBtn = document.getElementById('close-encyclopedia-btn');
  const overlay = document.getElementById('encyclopedia-overlay');
  const listContainer = document.getElementById('encyclopedia-list');

  // 1. 図鑑ボタンを押したら、データを引っ張ってきてモーダルを開く
  if (openBtn && overlay) {
    openBtn.addEventListener('click', async () => {
      overlay.style.display = 'flex'; // オーバーレイを表示

      // すでにリストが読み込まれていたら、何度もAPIを叩かないようにする（エコ設計）
      if (listContainer && listContainer.children.length === 0) {
        try {
          // 先ほど作ったコントローラーの窓口（API）にデータを買いに行く
          const response = await fetch('/api/ships');
          if (!response.ok) throw new Error('データの取得に失敗しました');
          
          const ships = await response.json(); // JSONデータをJavaScriptの配列に変換

          // データベースから届いた艦艇データを1つずつカードにして画面に並べる（簡易情報のみ）
          listContainer.innerHTML = ships.map(ship => `
            <div class="ship-card" data-id="${ship.id}" style="background: #333; border: 1px solid #444; border-radius: 6px; padding: 15px; text-align: center; cursor: pointer;">
              <img src="${ship.image_url || '/images/default-ship.png'}" alt="${ship.name}" style="width: 100%; height: auto; border-radius: 4px; margin-bottom: 10px;">
              <div style="font-weight: bold; font-size: 1.1em; margin-bottom: 5px;">${ship.name || '不明'}</div>
              <div style="color: #aaa; font-size: 0.9em;">ステージ: ${ship.stage || '不明'}</div>
            </div>
          `).join('');

          // カードクリック時に詳細モーダルを開くイベントを設定
          listContainer.querySelectorAll('.ship-card').forEach(card => {
            card.addEventListener('click', () => {
              const shipId = parseInt(card.dataset.id);
              const selectedShip = ships.find(s => s.id === shipId);

              if (selectedShip) {
                const detailContent = document.getElementById('ship-detail-content');
                const detailOverlay = document.getElementById('ship-detail-overlay');

                // 戦闘に関連するカラムのみを詳細に表示（空なら「不明」）
                if (detailContent && detailOverlay) {
                  detailContent.innerHTML = `
                    <div style="text-align: center; margin-bottom: 20px;">
                      <img src="${selectedShip.image_url || '/images/default-ship.png'}" alt="${selectedShip.name}" style="width: 60%; height: auto; border-radius: 6px;">
                      <h3 style="font-size: 1.5em; margin: 10px 0 5px 0;">${selectedShip.name || '不明'}</h3>
                      <span style="background: #444; padding: 2px 8px; border-radius: 4px; font-size: 0.9em;">ステージ: ${selectedShip.stage || '不明'}</span>
                    </div>
                    <table style="width: 100%; border-collapse: collapse; margin-bottom: 15px;">
                      <tr style="border-bottom: 1px solid #333;">
                        <td style="padding: 8px; color: #aaa;">HP</td>
                        <td style="padding: 8px; text-align: right; font-weight: bold;">${selectedShip.hp || '不明'} / ${selectedShip.max_hp || '不明'}</td>
                      </tr>
                      <tr style="border-bottom: 1px solid #333;">
                        <td style="padding: 8px; color: #aaa;">攻撃力 (ATK)</td>
                        <td style="padding: 8px; text-align: right; font-weight: bold; color: #ff4d4f;">${selectedShip.atk || '不明'}</td>
                      </tr>
                      <tr style="border-bottom: 1px solid #333;">
                        <td style="padding: 8px; color: #aaa;">レア度</td>
                        <td style="padding: 8px; text-align: right;">${selectedShip.rarity || '不明'}</td>
                      </tr>
                    </table>
                    <div style="background: #252525; padding: 12px; border-radius: 4px; font-size: 0.95em; line-height: 1.5; color: #ddd;">
                      <strong style="color: #fff; display: block; margin-bottom: 5px;">艦艇情報</strong>
                      ${selectedShip.info || '詳細情報はありません。'}
                    </div>
                  `;
                  detailOverlay.style.display = 'flex';
                }
              }
            });
          });

        } catch (error) {
          if (listContainer) {
            listContainer.innerHTML = `<div style="color: #ff4d4f; grid-column: 1/-1; text-align: center;">図鑑データの読み込みに失敗しました。</div>`;
          }
          console.error(error);
        }
      }
    });
  }

  // 2. 閉じる（×）ボタンを押したらモーダルを閉じる
  if (closeBtn && overlay) {
    closeBtn.addEventListener('click', () => {
      overlay.style.display = 'none';
    });
  }
  // 3. 詳細オーバーレイ（2枚目の壁）の閉じるボタンを押したら閉じる
  const closeDetailBtn = document.getElementById('close-detail-btn');
  const detailOverlay = document.getElementById('ship-detail-overlay');
  if (closeDetailBtn && detailOverlay) {
    closeDetailBtn.addEventListener('click', () => {
      detailOverlay.style.display = 'none';
    });
  }
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