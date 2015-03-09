RecordNotFound = Class.new(StandardError)

class TodoRepo
  class << self
    def todos
      @todos ||= []
      @todos
    end

    def add(params)
      todo = Hashie.symbolize_keys!(params.to_hash)
      todo.merge!({id: SecureRandom.uuid})
      todos << todo
    end

    def find(id)
      todos.detect {|todo| todo[:id] == id}
    end

    def update(params)
      params = Hashie.symbolize_keys(params.to_hash)
      todo = find(params[:id])
      raise RecordNotFound.new unless todo

      todo.merge!(params)
    end

    def delete(id)
      todo = find(id)
      raise RecordNotFound.new unless todo

      todos.delete(todo)
    end
  end
end
