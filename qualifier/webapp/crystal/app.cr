require "amethyst"
require "mysql"
require "json"

class Config
  json_mapping({
    database: { type: DatabaseConfig }
  })
end

class DatabaseConfig
  json_mapping({
    dbname: String
    host:   String
    port:   Int32
    username: String
    password: String
  })
end

class Isucon3Controller < Base::Controller
  actions :index

  def setting
    path   = File.dirname(__FILE__) + "/../config/#{ ENV["ISUCON_ENV"]? || "local" }.json"
    ret    = File.read(path)
    return Config.from_json(ret)
  end

  def connection
    conf = setting

    MySQL.connect(
      conf.database.host,
      conf.database.username,
      conf.database.password,
      conf.database.dbname,
      conf.database.port,
      nil
    )
  end

  view "hello", "#{__DIR__}/views"
  def index
    mysql = connection
    ret = mysql.query("SELECT RAND()")

    @name = ret
    respond_to do |format|
      format.html { render "hello" }
    end
  end
end

class Isucon3App < Base::App
  routes.draw do
    get "/",      "isucon3#index"
    register Isucon3Controller
  end
end

app = Isucon3App.new
app.serve
