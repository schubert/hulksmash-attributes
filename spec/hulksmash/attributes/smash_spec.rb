require "spec_helper"

describe HulkSmash::Attributes::Smash do
  let(:hulk) do
    HulkSmash::Attributes::Smash.new do
    end
  end
  
  describe "#smash" do
    subject { hulk.smash(*something) }
    context "when no :into is provided" do
      let(:something) { ["color"] }

      it "should get angry" do
        lambda {
          subject
        }.should raise_error(HulkSmash::Angry)
      end
    end
    
    context "when only an :into is provided" do
      let(:something) { ["color", {into: "colour"}] }
      subject { hulk.smash(*something) }
      
      it "should smash the attribute into the specified attribute" do
        subject.using("color" => "blue").should have_key("colour")
      end
      
      it "should pass through the value and not modify it" do
        subject.using("color" => "blue")["colour"].should == "blue"
      end
    end
    
    context "when a using lambda is provided" do
      let(:reverse_color) { ->(value) { value.reverse } }
      let(:something) { ["color", {into: "colour", using: reverse_color}] }
      subject { hulk.smash(*something) }

      it "should smash the value using the lambda when coming in" do
        subject.using("color" => "blue")["colour"].should == "eulb"
      end
    end
    
    context "when an undo lambda is provided" do
      let(:upcase_color) { ->(value) { value.upcase } }
      let(:capitalize_color) { ->(value) { value.capitalize } }
      let(:something) { ["color", {into: "colour", using: upcase_color, undo: capitalize_color}] }
      subject { hulk.smash(*something) }

      it "should smash the value using the lambda when coming in" do
        subject.undo("colour" => "BLUE")["color"].should == "Blue"
      end
    end
  end
  
end