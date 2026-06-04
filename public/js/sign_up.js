document.addEventListener('DOMContentLoaded', function() {
  const checkbox = document.getElementById('agree-checkbox');
  const errorMessage = document.getElementById('terms-error-message');

  // 1. 通常の新規登録ボタン（フォーム送信）を監視
  const registrationForm = document.querySelector('.signupform');
  if (registrationForm) {
    registrationForm.addEventListener('submit', function(event) {
      if (!checkbox.checked) {
        event.preventDefault(); // 送信を止める
        showError();
      }
    });
  }

  // 2. Google と X のソーシャルログインボタン（リンク）を監視
  const authButtons = document.querySelectorAll('a[href*="/auth/"]');
  authButtons.forEach(button => {
    button.addEventListener('click', function(event) {
      if (!checkbox.checked) {
        event.preventDefault(); // 認証画面への遷移を止める
        showError();
      }
    });
  });

  // エラーメッセージを表示する共通関数
  function showError() {
    if (errorMessage) {
      errorMessage.style.display = 'block';
      errorMessage.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }

  // チェックを入れたら自動的にエラーを消す親切設計
  if (checkbox) {
    checkbox.addEventListener('change', function() {
      if (checkbox.checked && errorMessage) {
        errorMessage.style.display = 'none';
      }
    });
  }
});