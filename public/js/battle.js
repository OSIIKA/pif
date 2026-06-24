// 🎬 画面の読み込みが100%完了した瞬間をトリガーにする
window.addEventListener('DOMContentLoaded', () => {

  // 🕵️‍♂️ 1. ERBで割り振ったIDを使って、演出用のコンテナを取得
  const container = document.getElementById('phase-anim-container');

  // 🛡️ ガード句：もしIDが見つからなければ、エラーを出さずに静かに終わる（安定性重視）
  if (!container) return;


  // 🚀 【第1幕：フロートイン】
  // 画面外（left: -100%）にいる要素を、画面中央（left: 50%）に移動させる
  // 1.5秒（ERBの transition: all 1.5s で指定）かけてスライドしてくる
  container.style.left = '50%';


  // ⏸️ 【第2幕：滞在（1.5秒待機）】
  // フロートインの「1.5秒」が完了した時点で、次のタイマーを起動させる
  setTimeout(() => {

    // 🚪 【第3幕：フロートアウト}
    // 中央（left: 50%）から、そのまま右の画面外（left: 200%）へ移動させる
    // これも1.5秒かけてスライドアウトしていく
    container.style.left = '200%';

  }, 1500); // <-- 「イン」が完了するまでの時間（1.5秒）をミリ秒で指定

});

// パレットからの新規ドラッグ開始
function handlePaletteDragStart(event) {
  const card = event.currentTarget || event.target.closest('.draggable-fleet-card');
  if (!card) return;
  const fleetData = {
    type: 'palette',
    fleet_num: card.dataset.fleetNum,
    fleet_name: card.dataset.fleetName,
    fleet_hp: card.dataset.fleetHp,
    fleet_max_hp: card.dataset.fleetMaxHp
  };
  event.dataTransfer.effectAllowed = 'copy';
  try {
    event.dataTransfer.setData('application/json', JSON.stringify(fleetData));
  } catch (e) {
    // 一部ブラウザではカスタム MIME タイプを受け付けないため、text/plain もセット
  }
  event.dataTransfer.setData('text/plain', JSON.stringify(fleetData));
  if (event.dataTransfer.setDragImage) {
    event.dataTransfer.setDragImage(card, card.offsetWidth / 2, card.offsetHeight / 2);
  }
}

// フォーム送信前に少なくとも1つの艦隊が配置されているかを確認する
window.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.draggable-fleet-card.available').forEach((card) => {
    card.addEventListener('dragstart', handlePaletteDragStart);
  });

  const battleForm = document.getElementById('battleStartForm');
  if (!battleForm) return;

  const allHiddenInputs = Array.from(battleForm.querySelectorAll('input[type="hidden"][name^="fleet_"][name$="_pos"]'));

  const findHexCell = (node) => {
    let current = node;
    while (current) {
      if (current.classList && current.classList.contains('hex-cell')) {
        return current;
      }
      current = current.parentNode;
    }
    return null;
  };

  const refreshFleetPositions = () => {
    allHiddenInputs.forEach((input) => { input.value = ''; });

    const placedIcons = document.querySelectorAll('.placed-fleet-icon');
    placedIcons.forEach((icon) => {
      const fleetNum = icon.dataset.fleetNum;
      const cell = findHexCell(icon);
      if (!fleetNum || !cell) return;

      const hiddenInput = document.getElementById(`input_fleet_${fleetNum}_pos`);
      if (!hiddenInput) return;

      hiddenInput.value = `${cell.dataset.col},${cell.dataset.row}`;
    });
  };

  battleForm.addEventListener('submit', (event) => {
    refreshFleetPositions();

    // 🔍 【デバッグ】フォーム送信時にhidden inputの値をコンソール出力
    console.log("=== フォーム送信直前の hidden input 値 ===");
    allHiddenInputs.forEach((input) => {
      console.log(`${input.name}: '${input.value}'`);
    });
    console.log("========================================");

    const anyPlaced = allHiddenInputs.some((input) => input.value.trim() !== '');
    if (!anyPlaced) {
      event.preventDefault();
      alert('⚠️ まずは1つ以上の艦隊を配置してから、戦闘開始を押してください。');
    }
  });
});

// 配置済みアイコンの再ドラッグ（位置調整）開始
function handlePlacedIconDragStart(event) {
  const icon = event.currentTarget || event.target.closest('.placed-fleet-icon');
  if (!icon) return;
  const cell = icon.closest('.hex-cell');
  if (!cell) return;
  const fleetData = {
    type: 'move',
    fleet_num: icon.dataset.fleetNum,
    fleet_name: icon.dataset.fleetName,
    from_col: cell.dataset.col,
    from_row: cell.dataset.row
  };
  event.dataTransfer.effectAllowed = 'move';
  event.dataTransfer.setData('application/json', JSON.stringify(fleetData));
  event.dataTransfer.setData('text/plain', JSON.stringify(fleetData));
}

// ドロップを許可する判定
function allowFleetDrop(event) {
  event.preventDefault();
}

// ドロップ時のメイン処理
function handleFleetDrop(event) {
  event.preventDefault();
  const dragDataJson = event.dataTransfer.getData('application/json') || event.dataTransfer.getData('text/plain');
  if (!dragDataJson) return;

  let data;
  try {
    data = JSON.parse(dragDataJson);
  } catch (e) {
    data = { type: 'palette', fleet_num: null, fleet_name: null, fleet_hp: 0, fleet_max_hp: 0 };
  }
  const targetCell = event.currentTarget.closest('.hex-cell') || event.target.closest('.hex-cell');
  if (!targetCell) return;

  // 重複チェック（ドロップ先にすでに別の艦隊がいる場合は弾く）
  const alreadyPlaced = targetCell.querySelector('.placed-fleet-icon');
  if (alreadyPlaced) {
    alert("⚠️ このマスには既に艦隊が配置されています。");
    return;
  }

  // ターゲットマスの中心座標を取得
  const targetX = targetCell.dataset.centerX;
  const targetY = targetCell.dataset.centerY;
  if (data.type === 'palette') {
    // -----------------------------------------------------------
    // 【パターンA: パレットからの新規配置】
    // -----------------------------------------------------------
    const newIcon = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    newIcon.setAttribute('class', 'placed-fleet-icon');
    newIcon.setAttribute('draggable', 'true');
    newIcon.addEventListener('dragstart', handlePlacedIconDragStart);
    newIcon.setAttribute('data-fleet-num', data.fleet_num);
    newIcon.setAttribute('data-fleet-name', data.fleet_name);
    newIcon.setAttribute('data-fleet-hp', data.fleet_hp || 0);
    newIcon.setAttribute('data-fleet-max-hp', data.fleet_max_hp || 0);
    newIcon.style.cursor = 'grab';

    const nameLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    nameLabel.setAttribute('x', targetX);
    nameLabel.setAttribute('y', parseFloat(targetY) - 12);
    nameLabel.setAttribute('fill', '#ffbc00');
    nameLabel.setAttribute('font-size', '11');
    nameLabel.setAttribute('font-weight', 'bold');
    nameLabel.setAttribute('text-anchor', 'middle');
    nameLabel.setAttribute('class', 'placed-fleet-icon-label');
    nameLabel.textContent = data.fleet_name;

    const hpLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    hpLabel.setAttribute('x', targetX);
    hpLabel.setAttribute('y', parseFloat(targetY) + 10);
    hpLabel.setAttribute('fill', '#88ffbc');
    hpLabel.setAttribute('font-size', '9');
    hpLabel.setAttribute('font-family', 'monospace');
    hpLabel.setAttribute('text-anchor', 'middle');
    hpLabel.setAttribute('class', 'placed-fleet-hp');
    hpLabel.textContent = `HP ${data.fleet_hp}/${data.fleet_max_hp}`;

    const hoverTitle = document.createElementNS('http://www.w3.org/2000/svg', 'title');
    hoverTitle.textContent = `${data.fleet_name} - HP ${data.fleet_hp}/${data.fleet_max_hp}`;

    newIcon.appendChild(hoverTitle);
    newIcon.appendChild(nameLabel);
    newIcon.appendChild(hpLabel);
    targetCell.appendChild(newIcon);

    // 元のパレットカードを「配置中」に更新してドラッグ不可にする
    const paletteCard = document.querySelector(`.draggable-fleet-card[data-fleet-num="${data.fleet_num}"]`);
    if (paletteCard) {
      paletteCard.style.opacity = '0.2';
      paletteCard.setAttribute('draggable', 'false');
      paletteCard.style.cursor = 'not-allowed';
      paletteCard.querySelector('.status-text').textContent = '配置中';
    }

  } else if (data.type === 'move') {
    // -----------------------------------------------------------
    // 【パターンB: 配置済みアイコンの位置調整（移動）】
    // -----------------------------------------------------------
    const sourceCell = document.querySelector(`.hex-cell[data-col="${data.from_col}"][data-row="${data.from_row}"]`);
    if (!sourceCell) return;

    const icon = sourceCell.querySelector('.placed-fleet-icon');
    if (!icon) return;

    // 新しいマスへ要素ごと引っ越し、座標を再セット
    targetCell.appendChild(icon);

    const iconLabel = icon.querySelector('.placed-fleet-icon-label');
    const hpLabel = icon.querySelector('.placed-fleet-hp');
    if (iconLabel) iconLabel.setAttribute('x', targetX);
    if (iconLabel) iconLabel.setAttribute('y', parseFloat(targetY) - 10);
    if (hpLabel) hpLabel.setAttribute('x', targetX);
    if (hpLabel) hpLabel.setAttribute('y', parseFloat(targetY) + 8);
  }
  // 📝 🟢 ここを追記：ドロップまたは移動が発生したら、フォームのhiddenに最新座標をセット
  // data.fleet_num（1〜6）に対応するhiddenを狙い撃ちして、「col,row」の文字列を入れる
  const hiddenInput = document.getElementById(`input_fleet_${data.fleet_num}_pos`);
  if (hiddenInput) {
    hiddenInput.value = `${targetCell.dataset.col},${targetCell.dataset.row}`;
  }
      
  // もし移動元のマス（古いマス）の記録を消す処理が必要な場合はここで行いますが、
  // 上記のように「最新のドロップ先」で上書きしちゃえば基本はOKです！
}