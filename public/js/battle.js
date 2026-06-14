// パレットからの新規ドラッグ開始
function handlePaletteDragStart(event) {
  const card = event.target;
  const fleetData = {
    type: 'palette',
    fleet_num: card.dataset.fleetNum,
    fleet_name: card.dataset.fleetName
  };
  event.dataTransfer.setData('application/json', JSON.stringify(fleetData));
}

// 配置済みアイコンの再ドラッグ（位置調整）開始
function handlePlacedIconDragStart(event) {
  const icon = event.target;
  const cell = icon.closest('.hex-cell');
  const fleetData = {
    type: 'move',
    fleet_num: icon.dataset.fleetNum,
    fleet_name: icon.dataset.fleetName,
    from_col: cell.dataset.col,
    from_row: cell.dataset.row
  };
  event.dataTransfer.setData('application/json', JSON.stringify(fleetData));
}

// ドロップを許可する判定
function allowFleetDrop(event) {
  event.preventDefault();
}

// ドロップ時のメイン処理
function handleFleetDrop(event) {
  event.preventDefault();
  const dragDataJson = event.dataTransfer.getData('application/json');
  if (!dragDataJson) return;

  const data = JSON.parse(dragDataJson);
  const targetCell = event.currentTarget;

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
    const newIcon = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    newIcon.setAttribute('x', targetX);
    newIcon.setAttribute('y', parseFloat(targetY) - 6); // 座標表示と被らないように少し上へ
    newIcon.setAttribute('fill', '#ffbc00');
    newIcon.setAttribute('font-size', '11');
    newIcon.setAttribute('font-weight', 'bold');
    newIcon.setAttribute('text-anchor', 'middle');
    newIcon.setAttribute('class', 'placed-fleet-icon');
    newIcon.setAttribute('draggable', 'true');
    newIcon.setAttribute('ondragstart', 'handlePlacedIconDragStart(event)');
    newIcon.setAttribute('data-fleet-num', data.fleet_num);
    newIcon.setAttribute('data-fleet-name', data.fleet_name);
    newIcon.style.cursor = 'grab';
    newIcon.textContent = data.fleet_name;

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
    icon.setAttribute('x', targetX);
    icon.setAttribute('y', parseFloat(targetY) - 6);
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