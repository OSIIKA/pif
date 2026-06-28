// これは全艦艇データを引っ張ってきて図鑑モーダルに表示するためのコード
document.addEventListener('DOMContentLoaded', () => {
  const openBtn = document.getElementById('open-encyclopedia-btn');
  const closeBtn = document.getElementById('close-encyclopedia-btn');
  const overlay = document.getElementById('encyclopedia-overlay');
  const listContainer = document.getElementById('encyclopedia-list');

  // 1. 図鑑ボタンを押したら、データを引っ張ってきてモーダルを開く
  if (openBtn && overlay) {
    // 図鑑を開くボタンを押したら、オーバーレイを表示する
    openBtn.addEventListener('click', async () => {
      overlay.style.display = 'flex';

      // すでにリストが読み込まれていたら、何度もAPIを叩かないようにする（エコ設計）
      if (listContainer && listContainer.children.length === 0) {
        try {
          // APIから艦艇辞書を取得する
          const response = await fetch('/api/ships');
          if (!response.ok) throw new Error('データの取得に失敗しました');
          // JSON艦艇辞書データをJavaScriptの配列に変換
          const ships = await response.json();

          // 艦艇一覧をカードとして表示する
          listContainer.innerHTML = ships.map(ship => `
            <div class="ship-card" data-id="${ship.id}" style="background: #333; border: 1px solid #444; border-radius: 6px; padding: 15px; text-align: center; cursor: pointer;">
              <img src="${ship.image_url || '/images/default-ship.png'}" alt="${ship.name}" style="width: 100%; height: auto; border-radius: 4px; margin-bottom: 10px;">
              <div style="font-weight: bold; font-size: 1.1em; margin-bottom: 5px;">${ship.name || '不明'}</div>
              <div style="color: #aaa; font-size: 0.9em;">ステージ: ${ship.stage || '不明'}</div>
            </div>
          `).join('');

          // カードクリックで詳細画面へ移動
          listContainer.querySelectorAll('.ship-card').forEach(card => {
            card.addEventListener('click', () => {
              const shipId = parseInt(card.dataset.id);
              const selectedShip = ships.find(s => s.id === shipId);

              if (selectedShip) {
                // 詳細表示に使うDOMを取得する
                const mainPanel = document.getElementById('detail-main-panel');
                const listContainer = document.getElementById('encyclopedia-list');
                const detailContent = document.getElementById('ship-detail-content');

                // ステータスタブのHTMLを組み立てる関数
                const renderStatusTab = () => {
                  return `
                    <div style="text-align: center; margin-bottom: 20px;">
                      <!-- 艦艇画像と名前 -->
                      <img src="${selectedShip.image_url || '/images/default-ship.png'}" alt="${selectedShip.name}" style="width: 60%; height: auto; border-radius: 6px;">
                      <h3 style="font-size: 1.5em; margin: 10px 0 5px 0;">${selectedShip.name || '不明'}</h3>
                      <span style="background: #444; padding: 2px 8px; border-radius: 4px; font-size: 0.9em;">ステージ: ${selectedShip.stage || '不明'}</span>
                    </div>
                    <!-- 艦艇ステータス -->
                    <table style="width: 100%; border-collapse: collapse; margin-bottom: 15px;">
                      <!-- 艦艇HP -->
                      <tr style="border-bottom: 1px solid #333;">
                        <td style="padding: 8px; color: #aaa;">HP</td>
                        <td style="padding: 8px; text-align: right; font-weight: bold;">${selectedShip.hp || '不明'} / ${selectedShip.max_hp || '不明'}</td>
                      </tr>
                      <!-- 艦艇攻撃力 -->
                      <tr style="border-bottom: 1px solid #333;">
                        <td style="padding: 8px; color: #aaa;">攻撃力 (ATK)</td>
                        <td style="padding: 8px; text-align: right; font-weight: bold; color: #ff4d4f;">${selectedShip.atk || '不明'}</td>
                      </tr>
                      <!-- 艦艇スピード -->
                      <tr style="border-bottom: 1px solid #333;">
                        <td style="padding: 8px; color: #aaa;">スピード (SPD)</td>
                        <td style="padding: 8px; text-align: right; font-weight: bold; color: #40a9ff;">${selectedShip.speed || '不明'}</td>
                      </tr>
                      <!-- 艦艇レア度 -->
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

                // 入手方法（ガチャ）タブのHTMLを組み立てる関数
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

                
                if (mainPanel && detailContent) {
                  if (listContainer)
                  // リスト一覧を非表示
                  listContainer.style.display = 'none';
                  // 詳細枠を表示
                  detailContent.style.display = 'flex';
                  // 最初にステータスタブを表示する
                  mainPanel.innerHTML = renderStatusTab();
                  
                  // タブボタンの見た目を「ステータスをアクティブ」に揃える
                  const tabButtons = document.querySelectorAll('.detail-tab-btn');
                  tabButtons.forEach(btn => {
                    if (btn.dataset.tab === 'status') {
                      btn.classList.add("active");
                    } else {
                      btn.classList.remove("active");
                    }
                  });

                  // タブクリックで中身を切り替える
                  tabButtons.forEach(btn => {
                    // 既存のイベントリスナーが重複しないよう毎回上書き
                    btn.addEventListener('click', () => {
                      // まず全タブを「非選択の見た目」に戻す
                      tabButtons.forEach(b => b.classList.remove('active'));
                      // クリックされたタブだけ「選択中の見た目」にする
                      btn.classList.add('active');
                      // コンテンツ切り替え
                      if (btn.dataset.tab === 'status') {
                        mainPanel.innerHTML = renderStatusTab();
                      } else if (btn.dataset.tab === 'gacha') {
                        mainPanel.innerHTML = renderGachaTab();
                      }
                    });
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