# 📄 app/models/allfreet_skill.rb
class AllfreetSkill < ActiveRecord::Base
  belongs_to :allfreet
  belongs_to :skill
end