# 📄 app/models/skill.rb
class Skill < ActiveRecord::Base
  # 1. どの艦船マスタ（Allfreet）がこのスキルを所持しているか
  # skill1_id, skill2_id, skill3_id に対して逆関連を定義することも可能ですが、現時点では必須ではありません。
end
