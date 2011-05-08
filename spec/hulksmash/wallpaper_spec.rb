require "spec_helper"

describe "WallPaper" do
  before do
    class Wallpaper
      include HulkSmash::Attributes

      hulk do
        smash ["Color", "Colour"], into: "color",
                                   using: ->(value) { value.downcase },
                                   undo: ->(value) { value.upcase }
        smash "FlowerPrint", into: nil
      
        default ->(key) { key.camelize }, into: ->(key) { key.underscore } 
      end
    end
  end
  
  it "should match the documentation" do
    wallpaper = Wallpaper.new("Colour" => "BLUE", "FlowerPrint" => "daisies", "CakeAndPie" => "yes please")
    wallpaper.attributes.should == {"color" => "blue", "cake_and_pie" => "yes please"}
    wallpaper.undo.should == {"Colour" => "BLUE", "CakeAndPie" => "yes please"}
  end
end