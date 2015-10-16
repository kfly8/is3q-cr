require "amethyst"

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


  view "hello", "#{__DIR__}/views"
  def index
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
