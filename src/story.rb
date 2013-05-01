class Story
  attr_reader :id, :desc

  def initialize(id, desc)
    @id = id
    @desc = desc
  end
end