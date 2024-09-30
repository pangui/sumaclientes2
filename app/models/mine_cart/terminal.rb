# frozen_string_literal: true
module MineCart

  class Terminal

    FORMATS = {
      reset: 0,
      bold: 1,
      faint: 2,
      italic: 3,
      underline: 4,
      black: 30,
      black_bg: 40,
      red: 31,
      red_bg: 41,
      green: 32,
      green_bg: 42,
      yellow: 33,
      yellow_bg: 43,
      blue: 34,
      blue_bg: 44,
      magenta: 35,
      magenta_bg: 45,
      cyan: 36,
      cyan_bg: 46,
      light_gray: 37,
      light_gray_bg: 47,
      gray: 90,
      gray_bg: 100,
      light_red: 91,
      light_red_bg: 101,
      light_green: 92,
      light_green_bg: 102,
      light_yellow: 93,
      light_yellow_bg: 103,
      light_blue: 94,
      light_blue_bg: 104,
      light_magenta: 95,
      light_magenta_bg: 105,
      light_cyan: 96,
      light_cyan_bg: 106,
      white: 97,
      white_bg: 107
    }.freeze
    DEBUG = false

    class << self

      def enclosed(path)
        path = path.strip
        path =  path[1..-2] if path =~ /^'.*'$/
        path =  path[1..-2] if path =~ /^".*"$/
        path = path.gsub(/[^\\]'/, "\\\\'").strip
        path.gsub(' ', '\\ ')
      end

      def absolute_path_exists?(path)
        absolute_dir_exists?(path) or absolute_file_exists?(path)
      end

      def absolute_dir_exists?(dir)
        return false if dir.blank?
        return false unless dir =~ %r{^/}

        dir = dir.gsub(%r{^(.+)/$}, '\1')
        `[ -d '#{dir}' ] && echo y || echo n`.strip == 'y'
      end

      def absolute_file_exists?(file)
        return false if file.blank?
        return false unless file =~ %r{^/}

        `[ -f '#{file}' ] && echo y || echo n`.strip == 'y'
      end

    end

    def initialize(working_dir = nil, logger_enabled: true)
      if working_dir.blank?
        @working_dir = Rails.root.to_s
      else
        raise "Path not found #{working_dir}" unless Terminal.absolute_dir_exists?(working_dir)

        @working_dir = working_dir
      end
      @initial_dir = working_dir
      @logger_enabled = logger_enabled
      @quiet = false
      @user = `whoami`.strip
    end

    def reset
      cd(@initial_dir)
      self
    end

    def quiet
      @quiet = true
      self
    end

    def pwd
      @working_dir
    end

    def enclosed(path)
      Terminal.enclosed(path)
    end

    def cd(target_path)
      target_path = absolute_path(target_path.to_s)
      return @working_dir if @working_dir == target_path

      if Terminal.absolute_dir_exists?(target_path)
        run("cd #{Terminal.enclosed(target_path)}")
        @working_dir = target_path
        return @working_dir
      end
      raise "Path not found! (cd #{Terminal.enclosed(target_path)})"
    end

    def absolute_path(path)
      return path if path =~ %r{^/}

      File.expand_path("#{@working_dir}/#{path}")
    end

    def run(command, command_log = nil)
      if !@quiet && @logger_enabled
        dir = @working_dir.gsub("/home/#{@user}", '~')
        prompt = log_format(' ', :black_bg)
        prompt += log_format('', :black, :blue_bg)
        prompt += log_format(" #{dir} ", :blue_bg)
        prompt += log_format('', :blue)
        command_log ||= command
        if command =~ /^\s*#/
          # comment command
          log_command("#{prompt} #{command_log}")
        else
          # real command
          start = Time.zone.now
          c = `cd #{Terminal.enclosed(@working_dir)} && #{command}`
          finish = Time.zone.now
          log_command("#{prompt} #{command_log}", start, finish)
          # real command
          Rails.logger.debug{ "REAL_CMD: cd '#{@working_dir}' && #{command}\n\n" } if DEBUG
        end
        return c.try(:chomp)
      end
      return if command =~ /^\s*#/

      `cd #{Terminal.enclosed(@working_dir)} && #{command}`.chomp
    ensure
      @quiet = false
    end

    def log_command(command, start = 0, finish = 0)
      time = "(#{(finish - start).round(1)})".ljust(5)
      shell_time = log_format(" shell #{time}", :black_bg, :bold)
      detail = log_format(command, :green)
      Rails.logger.info "#{shell_time}#{detail}"
    end

    def run_detached(command)
      log_command("(bg) #{command}") if @logger_enabled
      pid = spawn(command)
      Process.detach(pid)
    end

    def all_paths(directory, type: :file)
      cd(directory)
      cmd = %(find -type #{type == :file ? 'f' : 'd'})
      cmd += %( | sed -E 's/^\\.\\///g')
      cmd += %( | sort)
      run(cmd).split
    end

    def insert_around_match(file, offset, match: nil, line: nil, inserted_file: nil)
      references = run(%(grep -n "#{match}" #{file})).split("\n")
      references = references.reverse if offset <= 0
      references.each do |reference|
        insert_at = reference.split(':').first.to_i
        insert_at += offset
        line = escape(line, %i[line_break double_quotes])
        run(%(sed -i '#{insert_at}i'"#{line}" #{file}))
      end
    end

    def insert_before_match(file, match: nil, line: nil, inserted_file: nil)
      insert_around_match(file, 0, match:, line:, inserted_file:)
    end

    def insert_after_match(file, match: nil, line: nil, inserted_file: nil)
      insert_around_match(file, 1, match:, line:, inserted_file:)
    end

    def escape(txt, *chars)
      txt = txt.gsub("\n", '\\n') if :line_break.in? chars
      txt = txt.gsub('"', '\"') if :double_quotes.in? chars
      txt = txt.gsub('.', '\\.') if :dots.in? chars
      txt
    end

    def touch(file)
      run("touch #{enclosed(file)}")
    end

    def cat(file)
      run("cat #{enclosed(file)}")
    end

    def rm(path)
      return unless path_exists?(path)

      recursive = dir_exists?(path) ? 'r' : ''
      run("rm -f#{recursive} #{enclosed(path)}")
    end

    def relative_path(path)
      # remove trailing slash for non-root paths
      path = path.gsub(%r{^(.+)/$}, '\1')
      # return dot as relative shortcut
      return '.' if @working_dir == path
      return path unless path =~ %r{^/}
      # try to relativize path if @working_dir contains it
      return ::Regexp.last_match(1) if path =~ %r{^#{@working_dir}/(.*)$}

      path
    end

    def mv(from, to)
      rm(to) if path_exists?(to)
      run("mv #{enclosed(from)} #{enclosed(to)}")
    end

    def mkdir(dir)
      return if path_exists?(dir)

      run("mkdir -p #{enclosed(dir)}")
    end

    def cp(original, copy)
      flag = dir_exists?(original) ? ' -fr' : ''
      flag = ' -fr' if original =~ /\*/
      destination_dir = File.dirname(copy)
      mkdir(destination_dir) unless dir_exists?(destination_dir)
      run("cp#{flag} #{enclosed(original)} #{enclosed(copy)}")
    end

    def chmod(mask, file)
      run("chmod #{mask} #{enclosed(file)}")
    end

    def chown(owner, file)
      run("chown #{owner} #{enclosed(file)}")
    end

    def sed(regex, path)
      run("sed -i -E '#{regex}' '#{path}'")
    end

    def path_exists?(path)
      dir_exists?(path) or file_exists?(path)
    end

    def dir_exists?(dir)
      Terminal.absolute_dir_exists?(absolute_path(dir))
    end

    def file_exists?(file)
      Terminal.absolute_file_exists?(absolute_path(file))
    end

    def unbundled_run(command, command_log = nil)
      if file_exists? '.ruby-version'
        ruby_version = quiet.run('cat .ruby-version')
        shims = quiet.run("RBENV_VERSION=#{ruby_version} rbenv shims")
        shims = shims.split("\n").map{|f| File.basename(f) }
        bin = command.split.first
        if bin.in? shims
          real_bin = quiet.run("RBENV_VERSION=#{ruby_version} rbenv which #{bin}")
          command = command.gsub(/^#{bin}( ?.*)$/, '\1')
          command = "RBENV_VERSION=#{ruby_version} #{real_bin} #{command}"
        end
      end
      Bundler.with_unbundled_env{ run(command, command_log) }
    end

    # consolidate next two methods
    def rake(task)
      bundle = Rails.env.production? ? '/usr/local/bin/bundle' : `which bundle`.strip
      run("RAILS_ENV=#{Rails.env} #{bundle} exec rake #{task}")
    end

    def bundle_exec(command)
      # sometimes $PATH doesn't include /usr/local/bin and
      # both bundle and rake task fail
      bundle_executable = `cd '#{Rails.root}' && which bundle`.strip
      run("RAILS_ENV=#{Rails.env} #{bundle_executable} exec #{command}")
    end

    def md5sum(file)
      run("md5sum #{enclosed(file)}")
    end

    def compress_folder(source: nil, destination: nil, filename: '')
      source = source.strip.gsub(%r{/\z}, '')
      destination ||= source
      destination = destination.strip.gsub(%r{/\z}, '')
      run("cd #{enclosed(source)} && tar -czf #{enclosed(filename)} * && cd -")
      mv("#{source}/#{filename}".to_s, enclosed(destination).to_s) if destination != source
    end

    def secure_file_name(str, convert_case = nil)
      [
        %w[á a],
        %w[Á A],
        %w[é e],
        %w[É E],
        %w[í i],
        %w[Í I],
        %w[ó o],
        %w[Ó O],
        %w[ú u],
        %w[Ú U],
        %w[ñ n],
        %w[Ñ N],
        ['[^A-Za-z0-9\s.]', '']
      ].each do |from, to|
        regexp = Regexp.new(from)
        str = str.gsub(regexp, to)
      end
      convert_case ? str.send(convert_case) : str
    end

    def log_format(text, *options)
      "\e[#{options.map{|o| FORMATS[o] }.compact.join(';')}m#{text}\e[0m"
    end

    def wc(file)
      output = run("wc #{enclosed(file)}")
      output.split.first.to_i
    end

  end

end
