class ApkChannelPackaging
  require 'zip'
  def initialize()
    @now_path = Dir::pwd
    @apk_out_path = File.expand_path('../apks', __FILE__)
    @temp_out_path = File.expand_path('../temp', __FILE__)
    Dir.mkdir 'apks' unless File::exist? @apk_out_path
    Dir.mkdir 'temp' unless File::exist? @temp_out_path
    @template = 'channel_'
  end

  def listConfigs
    configs = []
    File.foreach(File.expand_path('../config', __FILE__)) { |line| configs << line.gsub(/\n|\r\n/,'')}
    configs
  end

  def listApks
    apks = []
    Dir::foreach(Dir::pwd) {|f| apks<<f if f =~ /.apk$/}
    apks
  end

  def start
    apks = listApks()
    configs = listConfigs()
    apks.each do |apk|
      configs.each do |config|
        makeApks apk,config
      end
    end
  end

  def makeApks file,config
    new_file_name = file.split('.').join("_#{config}_.")
    ori_path = File.join(@now_path,file)
    new_file_path = File.join(@apk_out_path,new_file_name)
    temp_files = []
    FileUtils.cp ori_path, new_file_path
    Zip::File.open(new_file_path, Zip::File::CREATE) do |zipfile|
      temp_file = File.new(File.join(@temp_out_path,"temp_apk_#{config}"), 'w+')
      temp_files << temp_file.path
      zipfile.add("META-INF/#{@template}#{config}", temp_file.path)
      temp_file.close
    end
    cleanTempFile temp_files
  end

  def cleanTempFile temp_files
    temp_files.each {|file| File.delete file}
  end
end

packaging = ApkChannelPackaging.new
packaging.start
