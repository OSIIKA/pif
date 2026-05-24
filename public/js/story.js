// ログボタンを押したらログオーバーレイを表示
document.getElementById('log-button').addEventListener('click', function(e) {
    e.stopPropagation(); // 背景クリック扱いにしない
    document.getElementById('log-overlay').style.display = 'flex';
});

// ログ閉じるボタン
document.getElementById('log-close').addEventListener('click', function(e) {
    e.stopPropagation();
    document.getElementById('log-overlay').style.display = 'none';
});
let autoMode = window.storyConfig.auto === true;
let autoTimer = null;

// オートボタン
document.getElementById('auto-button').addEventListener('click', function(e) {
    e.stopPropagation();

    const autoNow = window.storyConfig.auto === true;
    document.getElementById('auto-value').value = autoNow ? "off" : "on";
});


// ページ読み込み時にオート中なら自動進行
window.addEventListener('load', function() {
    const autoNow = window.storyConfig.auto === true;

    if (autoNow) {
    setTimeout(() => {
        // ログオーバーレイが開いている時は進まない
        if (document.getElementById('log-overlay').style.display === 'flex') return;

        window.location.href = "/story";
    }, 1500); // ← 好みで調整
    }
});


document.addEventListener('click', function(e) {
    // メッセージウィンドウ内のクリックは許可（次へ進む）
    // UI ボタンを押したときは次へ進まない
    if (e.target.closest('.story-ui-button')) return;
    // ログオーバーレイが開いている時は進まない
    if (document.getElementById('log-overlay').style.display === 'flex') return;
    // ★オート中はタップで進まない
    if (autoMode) return;
    // 次のメッセージへ
    window.location.href = "/story";
});