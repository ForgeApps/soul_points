require 'rest_client'
require 'uri'
require 'time'
require 'soul_points/version'
require 'json'
require 'yaml'
require 'soul_points/helpers'

# A Ruby class to call the MySoulPoints REST API.  
#
class SoulPoints::Client
    include SoulPoints::Helpers

  def self.version
    SoulPoints::VERSION
  end

  def self.gem_version_string
    "soul_points-gem/#{version}"
  end

  def self.api_enpoint
    "http://mysoulpoints.com"
  end

  attr_accessor :host, :user, :password

  def initialize
      @credentials = {}
  end

  def run_command( command, args )
    load_credentials if command != 'store_api_key' && command != 'help'
    raise InvalidCommand unless self.respond_to?(command)
    self.send(command, args)
  end

  def store_api_key( args )
    @api_key = args[0]
    @credentials = {
        :api_key  => @api_key
    }
    write_credentials 
  end

  def help( args )
    puts 'Usage:'
    puts '$ soul_points show mcphat             #Displays soul points for user mcphat'
  end

  # Show your current soul points
  def show( args )
      subdomain = args[0]
    soul_points = JSON.parse( RestClient.get 'http://' + subdomain + '.mysoulpoints.com', :accept => :json )
    puts '(' + soul_points['soul_point']['current'].to_s + '/' + soul_points['soul_point']['max'].to_s + ') ' + sprintf( "%0.1f", ( soul_points['soul_point']['current'].to_f / soul_points['soul_point']['max'].to_f ) * 100 ) + "%"
  end

  def me( args )
    me = JSON.parse( RestClient.get 'http://mysoulpoints.com/me.json?auth_token=' + @credentials[:api_key], :accept => :json )
    puts me['email']
    puts '(' + me['soul_points']['current'].to_s + '/' + me['soul_points']['max'].to_s + ') ' + sprintf( "%0.1f", ( me['soul_points']['current'].to_f / me['soul_points']['max'].to_f ) * 100 ) + "%"
  end

  def gain( args )
      resp = RestClient.post 'http://mysoulpoints.com/events.json', :event => { :value => args[0], :description => args[1] }, :auth_token => @credentials[:api_key], :accept => :json

      if args[0].to_i > 0
        puts "You \033[1;32mgained\033[0m #{args[0].to_i.abs} soul points - \"#{args[1]}\"."
      else
        puts "You \033[1;31mlost\033[0m #{args[0].to_i.abs} soul points - \"#{args[1]}\"."
      end

      me(args)
  end

  # Pretty much just an alias for gain, with negative number
  def lose( args )
      args[0] = args[0].to_i * -1 
      gain( args )
  end

  def load_credentials
    @credentials = read_credentials 
    if !@credentials || @credentials[:api_key].nil?
        couldnt_find_credentials
        exit
    end
  end

  def couldnt_find_credentials
    puts "Could not find your credentials. To save your credentials run: \n$ soul_points store_api_key YOUR_KEY_HERE\n"
  end

  def credentials_file
    "#{home_directory}/.soul_points"
  end

  def read_credentials
    YAML::load( File.read(credentials_file) ) if File.exists?(credentials_file) 
  end
 
  def write_credentials
    File.open(credentials_file, 'w') do |f|
      f.puts @credentials.to_yaml
    end
    set_credentials_permissions
  end

  def set_credentials_permissions
    FileUtils.chmod 0700, File.dirname(credentials_file)
    FileUtils.chmod 0600, credentials_file
  end

  ##################
  
  def soul_points_headers   # :nodoc:
    {
      'X-SoulPoints-API-Version' => '1',
      'User-Agent'           => self.class.gem_version_string,
      'X-Ruby-Version'       => RUBY_VERSION,
      'X-Ruby-Platform'      => RUBY_PLATFORM
    }
  end

  def escape(value)  # :nodoc:
    escaped = URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    escaped.gsub('.', '%2E') # not covered by the previous URI.escape
  end

  private

end
