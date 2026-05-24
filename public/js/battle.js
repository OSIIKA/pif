function updateHpBar(bar, newHp, maxHp) {
    console.log(`読み込み確認 ID: ${bar.getAttribute('data-id')} HP: ${newHp}/${maxHp}`);
    bar.setAttribute('data-hp', newHp); // HTMLのデータ属性を更新
    const percentage = (newHp / maxHp) * 100;
    bar.style.width = `${percentage}%`; // CSS変数ではなく直接幅を設定
}
  
// 初期設定（必要に応じて）
document.querySelectorAll('.hp-bar-fill').forEach(bar => {
    const hp = parseFloat(bar.getAttribute('data-hp'));
    const maxHp = parseFloat(bar.getAttribute('data-max-hp'));
    updateHpBar(bar, hp, maxHp);
});
// 攻撃アニメーションを発火させる関数
function playAttackAnimation(attackerId, defenderId, damage) {
  const attacker = document.getElementById(`unit-${attackerId}`);
  const defender = document.getElementById(`unit-${defenderId}`);

  // 攻撃側を光らせる
  attacker.classList.add("attack-flash");
  setTimeout(() => attacker.classList.remove("attack-flash"), 200);

  // 被弾側を揺らす
  defender.classList.add("hit-shake");
  setTimeout(() => defender.classList.remove("hit-shake"), 300);

  // ダメージ数字を表示
  const dmg = document.createElement("div");
  dmg.className = "damage-popup";
  dmg.textContent = `-${damage}`;
  defender.appendChild(dmg);

  setTimeout(() => dmg.remove(), 800);
}
