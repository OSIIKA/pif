# 📄 app/models/story.rb
class Story < ActiveRecord::Base
  # ストーリーの各エピソードは、ステップごとに分かれている
  # 例: episode=1, step=1,2,3,4,5,6,7,8,9,10
  #     episode=2, step=1,2,3,4,5,6,7,8,9,10
  #     episode=3, step=1,2,3,4,5,6,7,8,9,10
  #     episode=4, step=1,2,3,4,5,6,7,8,9,10
  #     episode=5, step=1,2,...
  #     episode=6,...
  #     episode=7,...
  #     episode=8,...
  #     episode=9,...
  #     episode=10,...
  # 戦闘発生判定
  def battle?
    battle != 0
  end

  # 表示スタイル（必要なら拡張）
  def style_name
    case style
    when 0 then "通常"
    when 1 then "立ち絵"
    when 2 then "特殊演出"
    else "不明"
    end
  end
end