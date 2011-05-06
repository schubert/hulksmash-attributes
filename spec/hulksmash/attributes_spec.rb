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

    end

    context "given a mapping with only a default" do
      with_model :test_default_class do
        table do |t|
          t.string "color"
        end
        model do
          include HulkSmash::Attributes

          hulk do
            default anything, into: ->(value) { value.upcase }
          end
        end
      end

      describe ".new" do
        subject { TestDefaultClass.new({"Something" => "else"}) }

        its(:attributes) { should == {"SOMETHING" => "else" }}
        its(:undo) { should == {"SOMETHING" => "else" }}
      end
    end

    context "given a mapping with hulk-approved constant or nil" do
      with_model :test_nil_class do
        table do |t|
          t.string "apple_pie"
        end
        model do
          include HulkSmash::Attributes

          hulk do
            smash "yourface", into: TINY_LITTLE_PIECES
            smash "yourhand", into: nil
            smash "apples", into: "apple_pie"
          end
        end
      end

      describe ".new" do
        subject { TestNilClass.new({"yourhand" => "theleftone", "yourface" => "oblivion", "apples" => "red_and_shiny"}) }

        its(:attributes) { should == {"apple_pie" => "red_and_shiny" }}
        its(:undo) { should == {"apples" => "red_and_shiny" }}
      end
    end

    context "given a mapping with an array of attributes" do
      with_model :test_array_class do
        table do |t|
          t.string "pie"
        end
        model do
          include HulkSmash::Attributes

          hulk do
            smash ["apples", "pecans"], into: "pie"
          end
        end
      end

      describe ".new" do
        context "given the first attribute" do
          subject { TestArrayClass.new({"apples" => "yummy"}) }

          it "should give the correct attributes and undo" do
            instance = subject
            instance.attributes.should == {"pie" => "yummy" }
            instance.undo.should == {"apples" => "yummy" }
          end
        end

        context "given the second attribute" do
          subject { TestArrayClass.new({"pecans" => "yummy"}) }

          it "should give the correct attributes and undo" do
            instance = subject
            instance.attributes.should == {"pie" => "yummy" }
            instance.undo.should == {"pecans" => "yummy" }
          end
        end
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

  describe "#attributes=" do
    with_model :test_attributes do
      table do |t|
        t.string :color
      end
      model do
        include HulkSmash::Attributes

        hulk do
          smash "MyColor", into: "color"
        end

      end
    end

    it "should re-smash new attributes" do
      instance = TestAttributes.new("MyColor" => "green")
      instance.attributes["color"].should == "green"
      instance.attributes = {"MyColor" => "blue"}
      instance.attributes["color"].should == "blue"
    end
  end

end
