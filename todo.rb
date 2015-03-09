require 'grape'
require 'securerandom'
require_relative 'todo_repo'

class TodoAPI < Grape::API
  format :json

  before do
    header 'Access-Control-Allow-Origin', '*'
    header 'access-control-allow-headers', 'Content-Type'
  end

  options do
    header 'Access-Control-Allow-Methods', 'GET,HEAD,POST,PATCH,DELETE,OPTIONS,PUT'
  end

  get do
    TodoRepo.todos
  end

  delete do
    TodoRepo.delete_all
  end

  route_param :id do
    options do
      header 'Access-Control-Allow-Methods', 'GET,HEAD,POST,PATCH,DELETE,OPTIONS,PUT'
    end

    get do
      todo = TodoRepo.find(params[:id])
      error!('foo', 404) unless todo
      todo
    end

    patch do
      begin
        TodoRepo.update(params)
      rescue RecordNotFound
        error!("Record not found with id '#{params[:id]}'", 404)
      end
    end

    delete do
      begin
        TodoRepo.delete(params[:id])
      rescue RecordNotFound
        error!("Record not found with id '#{params[:id]}'", 404)
      end
    end
  end

  params do
    requires :title, type: String
  end
  post do
    params.merge!(completed: false)
    TodoRepo.add(params, request.base_url)
  end
end
