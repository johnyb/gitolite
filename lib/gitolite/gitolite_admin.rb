module Gitolite
  class GitoliteAdmin
    attr_accessor :gl_admin, :ssh_keys, :config

    CONF = "gitolite.conf"
    CONFDIR = "conf"
    KEYDIR = "keydir"

    #Intialize with the path to
    #the gitolite-admin repository
    def initialize(path, options = {})
      @gl_admin = Grit::Repo.new(path)

      @conf = options[:conf] || CONF
      @confdir = options[:confdir] || CONFDIR
      @keydir = options[:keydir] || KEYDIR

      @ssh_keys = load_keys(File.join(path, @keydir))
      @config = Config.new(File.join(path, @confdir, @conf))
    end

    #Writes all aspects out to the file system
    #will also stage all changes
    def save
      Dir.chdir(@gl_admin.working_dir)

      #Process config file
      new_conf = @config.to_file(@confdir)
      @gl_admin.add(new_conf)

      #Process ssh keys
      files = list_keys(@keydir).map{|f| File.basename f}
      keys = @ssh_keys.values.map{|f| f.map {|t| t.filename}}.flatten

      to_remove = (files - keys).map { |f| File.join(@keydir, f)}
      @gl_admin.remove(to_remove)

      @ssh_keys.each_value do |key|
        key.each do |k|
          @gl_admin.add(k.to_file(@keydir))
        end
      end
    end

    #commits all staged changes and pushes back
    #to origin
    def apply
      #TODO: generate a better commit message
      @gl_admin.commit_index("Commit by gitolite gem")
      @gl_admin.git.push({}, "origin", "master")
    end

    #Calls save and apply in order
    def save_and_apply
      self.save
      self.apply
    end

    def add_key(key)
      raise "Key must be of type Gitolite::SSHKey!" unless key.instance_of? Gitolite::SSHKey
      @ssh_keys[key.owner] << key
    end

    def rm_key(key)
      @ssh_keys[key.owner].delete key
    end

    private
      #Loads all .pub files in the gitolite-admin
      #keydir directory
      def load_keys(path)
        keys = Hash.new {|k,v| k[v] = []}

        list_keys(path).each do |key|
          new_key = SSHKey.from_file(File.join(path, key))
          owner = new_key.owner

          keys[owner] << new_key
        end

        keys
      end

      def list_keys(path)
        old_path = Dir.pwd
        Dir.chdir(path)
        keys = Dir.glob("**/*.pub")
        Dir.chdir(old_path)
        keys
      end
  end
end
