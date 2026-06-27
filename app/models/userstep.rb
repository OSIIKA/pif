# 📄 app/models/usersteps.rb
class Usersteps < ActiveRecord::Base
  belongs_to :user

  # 現在のステップ名（必要なら拡張）
  def step_name
    "ステップ #{limited_gacha_step}"
  end

  # ステップを進める（後から仕様変更しやすい）
  def advance_step(amount = 1)
    self.limited_gacha_step += amount
    save
  end

  # ステップをリセット
  def reset_step
    self.limited_gacha_step = 1
    save
  end
end
