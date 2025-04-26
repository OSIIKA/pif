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