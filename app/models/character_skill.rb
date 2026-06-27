# 📄 app/models/character_skill.rb
class CharacterSkill < ActiveRecord::Base
  belongs_to :character
  belongs_to :skill
end