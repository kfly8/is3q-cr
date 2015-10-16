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
  def hello
    @name = "World"
    respond_to do |format|
      format.html { render "hello" }
    end
  end
end

class HelloWorldApp < Base::App
  routes.draw do
    all "/",      "world#hello"
    get "/hello", "world#hello"
    register WorldController
  end
end

app = HelloWorldApp.new
app.serve
