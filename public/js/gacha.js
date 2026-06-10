// いま何枚目のカードを見ているかを覚えておく変数（最初は0枚目）
let currentCardIndex = 0;

// 画面上にある「gacha-card」という名前のついたカードの山をすべて取得する
const cards = document.querySelectorAll('.gacha-card');
// 最後の全員集合画面の枠を取得する
const summary = document.getElementById('final-summary');

// 「👉 次へ」ボタンが押されたときに動く処理
function nextCard() {
  // 1. いま表示されているカードを「非表示（none）」にする
  cards[currentCardIndex].style.display = 'none';

  // 2. カウンターを1つ進める
  currentCardIndex++;

  // 3. もし、まだカードが残っているなら（10枚目未満なら）
  if (currentCardIndex < cards.length) {
    // 次のカードを「表示（block）」にする
    cards[currentCardIndex].style.display = 'block';
  } else {
    // 4. 10枚全部めくり終わったら、11画面目の「全員集合画面」を表示する！
    summary.style.display = 'block';
  }
}