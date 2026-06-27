# 📄 app/models/enemy_freet.rb
class EnemyFreet < ActiveRecord::Base
  # 📂 マスタデータ（Allfreet）との紐付け
  # これにより「enemy_freet.allfreet.name」のようにマスタのデータにアクセスできるようになります
  # ※もしマスタのモデル名が「AllFreet」など大文字交じりの場合は、適宜名前に合わせてください
  belongs_to :allfreet, foreign_key: :allfreet_id
end