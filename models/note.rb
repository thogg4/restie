class Note
  include Mongoid::Document

  embedded_in :pass

  field :title
  field :body
end
