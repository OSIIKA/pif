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
                const mainPanel = document.getElementById('detail-main-panel');
                const listContainer = document.getElementById('encyclopedia-list');
                const detailContent = document.getElementById('ship-detail-content');

                // ── 内部関数①：ステータスタブのHTMLを組み立てる ──
                const renderStatusTab = () => {
                  return `
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
                };

                // ── 内部関数②：入手方法（ガチャ）タブのHTMLを組み立てる ──
                const renderGachaTab = () => {
                  // データベースのフラグから確率の文字列を生成（空 or 偽なら「排出なし」）
                  const normalProb = selectedShip.normal ? `${selectedShip.normal}%` : '排出なし';
                  const rareProb = selectedShip.rare ? `${selectedShip.rare}%` : '排出なし';
                  const limitedProb = selectedShip.limited ? `${selectedShip.limited}%` : '排出なし';

                  return `
                    <h3 style="font-size: 1.3em; margin-top: 0; margin-bottom: 15px; border-bottom: 1px solid #444; padding-bottom: 8px;">🎲 入手方法・ガチャ排出確率</h3>
                    <p style="font-size: 0.9em; color: #aaa; margin-bottom: 20px;">各ガチャにおけるこの艦艇のストレートな排出確率です。</p>
                    
                    <table style="width: 100%; border-collapse: collapse;">
                      <tr style="border-bottom: 1px solid #333; background: rgba(255,255,255,0.02);">
                        <td style="padding: 12px; font-weight: bold;">🪙 ノーマルガチャ</td>
                        <td style="padding: 12px; text-align: right; font-weight: bold; color: ${selectedShip.normal ? '#4caf50' : '#888'};">${normalProb}</td>
                      </tr>
                      <tr style="border-bottom: 1px solid #333; background: rgba(255,255,255,0.04);">
                        <td style="padding: 12px; font-weight: bold;">💎 レアガチャ</td>
                        <td style="padding: 12px; text-align: right; font-weight: bold; color: ${selectedShip.rare ? '#2196f3' : '#888'};">${rareProb}</td>
                      </tr>
                      <tr style="border-bottom: 1px solid #333; background: rgba(255,255,255,0.02);">
                        <td style="padding: 12px; font-weight: bold;">🔥 期間限定ガチャ</td>
                        <td style="padding: 12px; text-align: right; font-weight: bold; color: ${selectedShip.limited ? '#ff9800' : '#888'};">${limitedProb}</td>
                      </tr>
                    </table>
                  `;
                };

                // 初期状態として「ステータス」タブの内容を表示
                if (mainPanel && detailContent) {
                  // リスト表示を非表示、詳細表示を表示
                  if (listContainer) listContainer.style.display = 'none';
                  detailContent.style.display = 'flex';
                  
                  mainPanel.innerHTML = renderStatusTab();
                  
                  // タブボタンの選択状態をリセット（ステータスをアクティブに）
                  const tabButtons = document.querySelectorAll('.detail-tab-btn');
                  tabButtons.forEach(btn => {
                    if (btn.dataset.tab === 'status') {
                      btn.style.background = '#333';
                      btn.style.color = '#fff';
                      btn.style.borderColor = '#555';
                    } else {
                      btn.style.background = '#222';
                      btn.style.color = '#aaa';
                      btn.style.borderColor = '#333';
                    }
                  });

                  // タブのクリックイベントをバインド
                  tabButtons.forEach(button => {
                    // 既存のイベントリスナーが重複しないよう、クローン化などでなくシンプルに毎回上書き
                    button.onclick = (e) => {
                      // スタイル切り替え
                      tabButtons.forEach(b => {
                        b.style.background = '#222';
                        b.style.color = '#aaa';
                        b.style.borderColor = '#333';
                      });
                      e.target.style.background = '#333';
                      e.target.style.color = '#fff';
                      e.target.style.borderColor = '#555';

                      // コンテンツ切り替え
                      if (e.target.dataset.tab === 'status') {
                        mainPanel.innerHTML = renderStatusTab();
                      } else if (e.target.dataset.tab === 'gacha') {
                        mainPanel.innerHTML = renderGachaTab();
                      }
                    };
                  });
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
  // 3. 詳細表示内の「戻る」ボタンをクリックしたらリスト表示に戻す
  const backBtn = document.getElementById('detail-back-btn');
  if (backBtn) {
    backBtn.addEventListener('click', () => {
      document.getElementById('encyclopedia-list').style.display = 'grid';
      document.getElementById('ship-detail-content').style.display = 'none';
    });
  }
});