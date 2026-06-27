class WeaponSkill < ActiveRecord::Base
  belongs_to :weapon
  belongs_to :skill
end