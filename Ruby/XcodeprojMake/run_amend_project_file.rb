require 'pathname'

class AmendProjectFile

  XCODE_PROJ_NAME = 'OunaClass.xcodeproj'
  FILE_NAME = 'project.pbxproj'

  def initialize
    current_path = Pathname.new(File.dirname(__FILE__)).parent.realpath
    puts "current_path = #{current_path}"

    @project_root = "#{current_path}/basePro"
    @project_path = "#{@project_root}/#{XCODE_PROJ_NAME}"
    @file_path = "#{@project_path}/#{FILE_NAME}"
  end


  def output
    @modify_result = ""
    is_build_rules_line = false
    File.open(@file_path,"r+") { |file|
      file.each_line { |line|
        # print "#{file.lineno}.", line

        if line.to_s.include?("buildRules")
          is_build_rules_line = true
          print "#{file.lineno}.", line
          next
        end

        if is_build_rules_line
          is_build_rules_line = false
          next
        end

        if line.to_s.include?("refType = 0;")
          print "#{file.lineno}.", line
          next
        end

        if line.to_s.include?("Compile Sources")
          print "#{file.lineno}.", line
          next
        end

        if line.to_s.include?("Link Binary With Libraries")
          print "#{file.lineno}.", line
          next
        end

        if line.to_s.include?("Copy Bundle Resources")
          print "#{file.lineno}.", line
          next
        end

        @modify_result += line
      }
    }
    self
  end

  def input
    File.open(@file_path,"w"){ |file|

      if @modify_result.empty?
        return
      end

      file.write @modify_result
    }
  end

end

amend = AmendProjectFile.new
amend.output.input

# 此类主要负责修改Qt转化后的工程使其标准化

