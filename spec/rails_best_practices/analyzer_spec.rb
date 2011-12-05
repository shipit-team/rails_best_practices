require 'spec_helper'

describe RailsBestPractices::Analyzer do
  subject { RailsBestPractices::Analyzer.new(".") }

  describe "expand_dirs_to_files" do
    it "should expand all files in spec directory" do
      dir = File.dirname(__FILE__)
      subject.expand_dirs_to_files(dir).should be_include(dir + '/analyzer_spec.rb')
    end
  end

  describe "file_sort" do
    it "should get models first, then mailers" do
      files = ["app/controllers/users_controller.rb", "app/mailers/user_mailer.rb", "app/models/user.rb", "app/views/users/index.html.haml", "lib/user.rb"]
      subject.file_sort(files).should == ["app/models/user.rb", "app/mailers/user_mailer.rb", "app/controllers/users_controller.rb", "app/views/users/index.html.haml", "lib/user.rb"]
    end
  end

  describe "file_ignore" do
    it "should ignore lib" do
      files = ["app/controllers/users_controller.rb", "app/mailers/user_mailer.rb", "app/models/user.rb", "app/views/users/index.html.haml", "lib/user.rb"]
      subject.file_ignore(files, 'lib/').should == ["app/controllers/users_controller.rb", "app/mailers/user_mailer.rb", "app/models/user.rb", "app/views/users/index.html.haml"]
    end
  end

  describe "output_terminal_errors" do
    it "should output errors in terminal" do
      check1 = RailsBestPractices::Reviews::LawOfDemeterReview.new
      check2 = RailsBestPractices::Reviews::UseQueryAttributeReview.new
      runner = RailsBestPractices::Core::Runner.new(:reviews => [check1, check2])
      check1.add_error "law of demeter", "app/models/user.rb", 10
      check2.add_error "use query attribute", "app/models/post.rb", 100
      subject.runner = runner
      subject.instance_variable_set("@options", {"without-color" => false})

      $origin_stdout = $stdout
      $stdout = StringIO.new
      subject.output_terminal_errors
      result = $stdout.string
      $stdout = $origin_stdout
      result.should == ["app/models/user.rb:10 - law of demeter".red, "app/models/post.rb:100 - use query attribute".red, "\nPlease go to http://rails-bestpractices.com to see more useful Rails Best Practices.".green, "\nFound 2 warnings.".red].join("\n") + "\n"
    end
  end
end