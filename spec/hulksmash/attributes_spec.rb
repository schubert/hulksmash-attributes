require "spec_helper"

describe HulkSmash::Attributes do

  describe ".hulk" do
    with_model :test_class do
      table do |t|
        t.string "color"
      end
      model do
        include HulkSmash::Attributes
      end
    end

    it "should yield a block into a smash class" do
      TestClass.class_eval do
        hulk do
        end
      end
      lambda {
        instance = TestClass.new("color" => "bar")
        instance.undo
      }.should_not raise_error

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

  describe "#initialize" do
    context "when ActiveModel::MassAssignmentSecurity" do
      with_model :test_with_mass_assignment_security do
        table do |t|
          t.string :color
          t.string :other_color
        end

        model do
          include HulkSmash::Attributes
          attr_accessible :color

          hulk do
            smash "MyColor", into: "color"
            smash "HisColor", into: "other_color"
          end
        end
      end

      it "should sanitize attributes after smashing" do
        instance = TestWithMassAssignmentSecurity.new("MyColor" => "blue", "YourColor" => "green")
        instance.should respond_to(:color)
        instance.attributes["color"].should == "blue"
        instance.should_not respond_to(:your_color)
      end

      it "should add smashed attributes to attr_accessible" do
        instance = TestWithMassAssignmentSecurity.new("HisColor" => "green")
        instance.attributes["other_color"].should == "green"
      end
    end
  end

end
