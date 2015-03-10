require 'rack/test'
require 'minitest/autorun'
require_relative '../lib/todo.rb'

class TodoAPITest < MiniTest::Test
  include Rack::Test::Methods

  def setup
    TodoRepo.delete_all
  end

  def app
    TodoAPI.new
  end

  def test_get_root_returns_empty_list
    get '/'
    assert last_response.ok?
    assert_equal JSON.parse(last_response.body), []
  end

  def test_post_to_root_creates_new_todo
    post '/', {title: 'foo'}
    assert last_response.created?

    created_todo = JSON.parse(last_response.body)
    assert_equal 'foo', created_todo['title']
    assert_equal false, created_todo['completed']
    assert_match (/http:\/\/example.org\/\w/), created_todo['url']
  end

  def test_new_posts_have_an_url_that_can_be_followed
    post '/', {title: 'foo'}
    assert last_response.created?

    created_todo = JSON.parse(last_response.body)

    get created_todo['url']
    assert last_response.ok?
    retrieved_todo = JSON.parse(last_response.body)

    assert_equal retrieved_todo, created_todo
  end

  def test_delete_todo
    post '/', {title: 'foo'}
    assert last_response.created?

    todo_url = JSON.parse(last_response.body)['url']

    delete todo_url
    assert last_response.ok?

    get todo_url
    assert last_response.not_found?
  end

  def test_updates_an_existing_todo
    post '/', {title: 'foo'}
    assert last_response.created?

    todo_url = JSON.parse(last_response.body)['url']

    patch todo_url, {title: 'updated'}
    assert last_response.ok?

    get todo_url
    retrieved_todo = JSON.parse(last_response.body)
    assert_equal 'updated', retrieved_todo['title']
  end

  def test_delete_all_todos
    post '/', {title: 'foo'}
    post '/', {title: 'foo2'}

    get '/'
    todos = JSON.parse(last_response.body)
    assert_equal 2, todos.size

    delete '/'
    assert last_response.ok?

    get '/'
    todos = JSON.parse(last_response.body)
    assert todos.empty?
  end

  def test_returns_not_found_status_for_inexistent_id
    get '/foo'
    assert last_response.not_found?

    patch '/foo'
    assert last_response.not_found?

    delete '/foo'
    assert last_response.not_found?
  end
end
