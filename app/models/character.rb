# 📄 app/models/character.rb
class Character < ActiveRecord::Base
  has_many :character_skills
  has_many :skills, through: :character_skills
end