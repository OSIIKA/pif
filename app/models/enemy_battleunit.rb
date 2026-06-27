# 📄 app/models/enemy_battleunit.rb
class EnemyBattleunit < ActiveRecord::Base
  # 👑 旗艦・随伴艦（1〜6）のアソシエーション定義
  # すべて同じ「EnemyFreet」モデルを指すため、class_name と foreign_key を明示します。
  # optional: true をつけておくことで、随伴艦が6隻未満（空きスロットがある）でもエラーになりません。

  belongs_to :flagship,   class_name: 'EnemyFreet', foreign_key: :flagship_id,   optional: true
  belongs_to :sub_ship_1, class_name: 'EnemyFreet', foreign_key: :sub_ship_1_id, optional: true
  belongs_to :sub_ship_2, class_name: 'EnemyFreet', foreign_key: :sub_ship_2_id, optional: true
  belongs_to :sub_ship_3, class_name: 'EnemyFreet', foreign_key: :sub_ship_3_id, optional: true
  belongs_to :sub_ship_4, class_name: 'EnemyFreet', foreign_key: :sub_ship_4_id, optional: true
  belongs_to :sub_ship_5, class_name: 'EnemyFreet', foreign_key: :sub_ship_5_id, optional: true
  belongs_to :sub_ship_6, class_name: 'EnemyFreet', foreign_key: :sub_ship_6_id, optional: true
end