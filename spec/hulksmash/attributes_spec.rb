require "spec_helper"

describe HulkSmash::Attributes do
  with_model :test_class do
    table do |t|
      t.string "color"
    end
    model do
      include HulkSmash::Attributes
    end
  end
  
  describe ".hulk" do
    it "should yield a block into a smash class" do
      TestClass.class_eval do
        hulk do
        end
      end
    end
    
    context "given a defined mapping" do
      before do
        TestClass.class_eval do
          hulk do
            smash "Colour", into: "color",
                            using: ->(value) {
                              value.downcase
                            },
                            undo: ->(value) {
                              value.upcase
                            }
          end
        end
      end

      describe ".undo" do
        subject { TestClass.undo({"color" => "blue"}) }

        its(:attributes) { should == {"color" => "blue"} }
        its(:undo) { should == {"Colour" => "BLUE"} }
        its(:color) { should == "blue" }
      end
      
      describe ".new" do
        subject { TestClass.new({"Colour" => "Blue"}) }
        
        its(:attributes) { should == {"color" => "blue" }}
      end
      
      describe "#undo" do
        subject { TestClass.new({"Colour" => "Blue"}).undo }
        
        it { should == {"Colour" => "BLUE"} }
      end
      
      it "should be a 'smashing' success" do
        true.should be_true
      end
      
    end
  end
  
end