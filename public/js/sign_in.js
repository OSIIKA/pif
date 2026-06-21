document.addEventListener('DOMContentLoaded', () => {
  // 新規登録エリアの中にエラーメッセージが存在するか確認
  const signupArea = document.querySelector('.signup-content-area');
  const hasSignupError = signupArea && signupArea.querySelector('.error-message');

  // エラーがあれば「新規登録」タブを自動で選択状態にする
  if (hasSignupError) {
    const signupTab = document.getElementById('tab-signup');
    if (signupTab) signupTab.checked = true;
  }
});