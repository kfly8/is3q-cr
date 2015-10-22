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

alias MySQLRowType =  Nil | String | Int32 | Int64 | Float64 | Bool | Time | MySQL::Types::Date

class MySQLResultInflator

  def initialize(@columns)
  end

  def to_rows(result : Array(Array(MySQLRowType))?)
    result.not_nil!.map { |v| to_row(v) }
  end

  def to_row(row_data : Array(MySQLRowType))
    row = {} of String => MySQLRowType
    @columns.each_index do |index|
      col = @columns[index]
      val = row_data[index]
      row[col] = val
    end
    return row
  end
end

SCHEMA = {
  :users => ["id", "username", "password", "salt", "last_access"],
}

$users = MySQLResultInflator.new(SCHEMA[:users])


class Isucon3Controller < Base::Controller
  actions :index

  def setting
    path   = File.dirname(__FILE__) + "/../config/#{ ENV["ISUCON_ENV"]? || "local" }.json"
    ret    = File.read(path)
    return Config.from_json(ret)
  end

  def connection
    return $mysql if $mysql
    conf = setting

    $mysql = MySQL.connect(
      conf.database.host,
      conf.database.username,
      conf.database.password,
      conf.database.dbname,
      conf.database.port,
      nil
    )
  end

  def get_user
    mysql = connection.not_nil!
#    user_id = session["user_id"]
    user_id = 1 # TODO:
    if user_id
      ret   = mysql.query("SELECT * FROM users WHERE id=%d" % user_id)
      users = $users.to_rows(ret)
      return users.first if users.first?
    end
  end


  view "hello", "#{__DIR__}/views"
  def index
    mysql = connection.not_nil!
    ret = mysql.query("SELECT RAND()")
    mret = MySQLResultInflator.new(["rand"])
    rows = mret.to_rows(ret)

    user = get_user
    puts user

    @name = rows[0]? ? rows[0]["rand"] : ""
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
