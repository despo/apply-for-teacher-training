module EthnicityHelper
  def select_ethnic_options
    option = Struct.new(:id, :label)
    
    #This will be pulled from a translation file 
    {
      :asian=>"Asian or Asian British",
      :black=>"Black, African, Black British or Caribbean",
      :mixed=>"Mixed or multiple ethnic groups",
      :white=>"White",
      :other=>"Another ethnic group",
      :prefer_not_to_say=>"Prefer not to say",
    }.map { |id, label| option.new(id, label) }
  end

  def find_etnicity(key)
    #This will be pulled from a translation file 
    {
      "asian"=>"Asian or Asian British",
      "black"=>"Black, African, Black British or Caribbean",
      "mixed"=>"Mixed or multiple ethnic groups",
      "white"=>"White",
      "other"=>"Another ethnic group",
      "prefer_not_to_say"=>"Prefer not to say",
    }[key]
  end
end
