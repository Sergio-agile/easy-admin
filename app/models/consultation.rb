class Consultation < ApplicationRecord
  belongs_to :patient
  has_rich_text :notes_before
  has_rich_text :notes_after
  has_rich_text :notes_to_send
end
