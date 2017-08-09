require 'fileutils'
require 'yaml'

class Waifus 
  def initialize
    getSettings
    Dir.mkdir @inDir unless Dir.exists? "art_in"
    Dir.mkdir @outDir unless Dir.exists? "art_out"
    all_files = Dir["#{@inDir}//**/*"].count { |file| File.file? (file) }
    i = 0
    dirs = Dir.glob("#{@inDir}/**/*").each do |dir|
      rawWay = dir[@inDir.length..-1]
      if File.directory? dir
        oDir = addDir(@outDir,rawWay )
        FileUtils.mkdir_p oDir unless Dir.exists? oDir
      else
        command = Command.new() 
        command.setModel(@model)
        command.setMode(@mode)
        command.setNoiseLevel(@level)
        command.setInput(dir)
        command.setOutput("#{@outDir}/#{rawWay[0..-4]}png")
        command.start
        i = i + 1
      end
      puts "Process: #{i} of #{all_files} files."
    end
  end

  def getSettings
    settings = YAML.load_file("wapro_set.yml") if File.exists? "wapro_set.yml"
    @rootDir = Dir.pwd
    @inDir = settings["in_dir"]
    @outDir = settings["out_dir"]
    @model = settings["model"]
    @mode = settings["mode"]
    @level = settings["level"]
  end

  def addDir(first, second)
    first + "/" + second
  end
end

class Command
  def initialize
    @keys = {
      command: "th",
      scripts: "waifu2x.lua",
      model: "",
      mode: "",
      noise_level: "",
      input: "",
      output: ""
    }
  end
  def start
    command = String.new
    @keys.each do |name, part|
      #puts " #{part}"
      command = command + " " + part
    end
    puts system(command)
  end
  def setInput(file)
    @keys[:input] = "-i " + "\"" + file.to_s + "\""
  end
  def setOutput(file)
    @keys[:output] = "-o " + "\"" + file.to_s + "\""
  end
  def setMode(mode)
    @keys[:mode] = "-m " + mode.to_s unless mode.nil?
  end
  def setModel(model)
    @keys[:model] = "-model_dir models/" + model.to_s unless model.nil?
  end
  def setNoiseLevel(level)
    @keys[:noise_level] = "-noise_level " + level.to_s unless level.nil?
  end
end
Waifus.new