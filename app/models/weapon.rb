class Weapon < ActiveRecord::Base
  has_many :weapon_skills
  has_many :skills, through: :weapon_skills
end
