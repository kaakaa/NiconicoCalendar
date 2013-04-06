# coding:utf-8
require 'yaml'
require 'sinatra'
require 'active_record'
require 'haml'
require 'composite_primary_keys'
require 'sinatra/reloader'


ActiveRecord::Base.configurations = YAML.load_file('database_niconico.yml')
ActiveRecord::Base.establish_connection('development')

class Calendar < ActiveRecord::Base
  self.primary_keys =[:name, :date]
end

class NicoCalendar
    attr_accessor :nicocal

    def initialize(calendar)
      @nicocal = {}
      @nicocal.default = []
      calendar.each do |day|
        if(@nicocal.key?(day.name))
          @nicocal[day.name].fill(NicoState.new(day.state,day.comment),day.date[-2..-1].to_i,1)
        else
          ini = []
          ini.fill(NicoState.new(0,''),0..30)
          ini.fill(NicoState.new(day.state,day.comment),day.date[-2..-1].to_i,1)
          @nicocal[day.name] = ini
        end
      end
      @nicocal
    end
end

class NicoState
  attr_accessor :state, :comment

  def initialize(state, comment)
    @state = state
    @comment = comment
  end
end

class NiconicoCalendar < Sinatra::Base
  register Sinatra::Reloader
  use Rack::MethodOverride
  set :views, File.dirname(__FILE__) + "/views"
  set :public_dir, File.dirname(__FILE__) + "/public"

  get '/niconico/:year/:month' do
    nico_calendar = NicoCalendar.new(Calendar.where('name like ? and date like ?','%',sprintf('%s-%s-%s',params[:year],params[:month],'%%')).all)
    @calendar = nico_calendar.nicocal
    @name_list = []
    @calendar.each_pair do |name, state|
      @name_list << name
    end
    @year = params[:year]
    @month = params[:month]
    haml :index
  end

  post '/niconico/*/new' do
    calendar = Calendar.new
    calendar.name = params[:name]
    calendar.date = Date.today.to_s
    calendar.state = 0
    calendar.comment = ''
    calendar.save
    redirect '/niconico/' + params[:year] + '/' + params[:month]
  end

  post '/niconico/*/regist' do
    c = Calendar.find([params[:name],params[:year]+'-'+params[:month]+'-'+sprintf("%02d",params[:day].to_i-1)]) rescue nil
    if !c.nil?
      c.delete
    end
    cal = Calendar.new(:name => params[:name], :state => params[:state], :date => params[:year] + "-" + params[:month] + "-" + sprintf("%02d",(params[:day].to_i-1)), :comment => "")
    cal.save
    
    redirect '/niconico/' + params[:year] + '/' + params[:month]
  end

  delete '/niconico/*/del' do
    del_data = Calendar.where('name = ? AND date like ?',params[:name], sprintf('%s-%s-%s',params[:year],params[:month],'%%')).all
    del_data.each do |day|
      day.destroy
    end
    redirect '/niconico/' + params[:year] + '/' + params[:month]
  end
end
