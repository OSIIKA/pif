// i ボタンを押したときの処理
document.querySelectorAll('.unit-info-button').forEach(btn => {
  btn.addEventListener('click', () => {
    const data = JSON.parse(btn.dataset.unit);
    const body = document.getElementById('unit-detail-body');

    // 味方と敵でデータ構造が違うので吸収する
    const name = data.myfreet ? data.myfreet.name : data.name;
    const hp = data.myfreet ? data.myfreet.hp : data.hp;
    const max_hp = data.myfreet ? data.myfreet.max_hp : data.max_hp;
    const atk = data.myfreet ? data.myfreet.atk : data.atk;
    const info = data.myfreet ? data.myfreet.info : data.info;
    const level = data.level || null;
    const exp = data.exp || null;

    body.innerHTML = `
      <h3>${name}</h3>
      ${level ? `<p>Lv: ${level} / EXP: ${exp}</p>` : ""}
      <p>HP: ${hp} / ${max_hp}</p>
      <p>攻撃: ${atk}</p>
      <p>情報: ${info}</p>
    `;

    document.getElementById('unit-detail-overlay').style.display = 'flex';
  });
});

// 閉じるボタン
document.getElementById('overlay-close').addEventListener('click', () => {
  document.getElementById('unit-detail-overlay').style.display = 'none';
});
