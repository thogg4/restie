class Pass
  include Mongoid::Document

  embeds_many :notes

  field :pass
end
