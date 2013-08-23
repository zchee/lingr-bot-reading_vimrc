# -*- encoding: UTF-8 -*-

require "net/http"
require 'mechanize'
require "uri"
require "json"
require 'erb'


class Chop
	def initialize(url)
		@chop = nil
		if /https:\/\/raw.github.com\// =~ url
			agent = Mechanize.new
			agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
			@chop = post_code("c", agent.get(url).body)
		end
	end

	def post_code(lang, code)
		uri = URI.parse("http://chopapp.com/code_snips")
		
		http = Net::HTTP.new(uri.host, uri.port)
		header = {
		  "user-agent" => "Ruby/#{RUBY_VERSION} MyHttpClient"
		}
		body = "language=#{lang}&code=#{ERB::Util.url_encode code}"
		response = http.post(uri.path, body, header)
		JSON.parse(response.body)
	end

	def post_comment(line, text)
		id = @chop["token"]
		uri = URI.parse("http://chopapp.com/notes")
		
		http = Net::HTTP.new(uri.host, uri.port)
		header = {
		  "user-agent" => "Ruby/#{RUBY_VERSION} MyHttpClient"
		}
		body = "code_snip_id=#{id}&isNew=0&line_start=#{line-1}&line_end=#{line-1}&text=#{ERB::Util.url_encode text}"
		response = http.post(uri.path, body, header)
		JSON.parse(response.body)
	end

	def url
		@chop ? "http://chopapp.com/##{@chop['token']}" : ""
	end
end



class ReadingVimrc
	attr_reader :start_link
	def initialize
		@start_link = ""
		@is_running_ = false
		@messages = []
		@restore_cache = []
		@chop = nil
	end

	def running?
		@is_running_
	end

	def start(link = "")
		@is_running_ = true
		@start_link = link
		reset
	end

	def stop
		@is_running_ = false
	end
	
	def reset
		@restore_cache = @messages
		@messages = []
	end

	def members
		@messages.map {|mes| mes[:name] }.uniq
	end

	def messages
		@messages
	end

	def status
		running? ? "started" : "stopped"
	end

	def add(message)
		if running?
			@messages << message
			puts message
			if @chop && /L\d+[\s　]+.+/ =~ message[:text]
				name = message[:name]
				line = message[:text][/L(\d+).*/, 1].to_i
				comment = message[:text][/L\d+[\ 　]+(.*)/, 1]
				puts name
				puts line
				puts comment
				@chop.post_comment(line, "#{name} > #{comment}")
			end
		end
	end

	def restore
		@restore_cache, @messages = @messages, @restore_cache
	end

	def chop(url)
		if running?
			@chop = Chop.new(url)
		end
		chop_url
	end
	
	def chop_url
		@chop ? @chop.url : ""
	end
end

