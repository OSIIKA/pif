# 📄 app/models/skill.rb
class Skill < ActiveRecord::Base
  has_many :allfreet_skills
  has_many :weapon_skills
  has_many :character_skills

  has_many :allfreets, through: :allfreet_skills
  has_many :weapons, through: :weapon_skills
  has_many :characters, through: :character_skills
end
