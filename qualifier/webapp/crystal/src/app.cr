require "amethyst"

class WorldController < Base::Controller
  actions :hello

  view "hello", "#{__DIR__}/../views"
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
