module DataMapper
  
  def queryx(*args)
    sql = args[0]
    results = []
    repository = self.repository
    bind_values = nil
    
    repository.adapter.send(:with_connection) do |connection|
      command = connection.create_command(sql)
      begin
        reader = command.execute_reader(*bind_values)
        
        while (reader.next!)
          result = {}
          reader.fields.each_with_index do |f,i|
            result[f.to_sym] = reader.values[i]
          end
          results << result
        end
      ensure
        reader.close if reader
      end
    end
    results
  end
  
  module Model
    #
    # Find instances by manually providing SQL
    #
    # @param sql<String>   an SQL query to execute
    # @param <Array>    an Array containing a String (being the SQL query to
    #   execute) and the parameters to the query.
    #   example: ["SELECT name FROM users WHERE id = ?", id]
    # @param query<DataMapper::Query>  a prepared Query to execute.
    # @param opts<Hash>     an options hash.
    #     :repository<Symbol> the name of the repository to execute the query
    #       in. Defaults to self.default_repository_name.
    #     :reload<Boolean>   whether to reload any instances found that already
    #      exist in the identity map. Defaults to false.
    #     :properties<Array>  the Properties of the instance that the query
    #       loads. Must contain DataMapper::Properties.
    #       Defaults to self.properties.
    #
    # @note
    #   A String, Array or Query is required.
    # @return <Collection> the instance matched by the query.
    #
    # @example
    #   MyClass.find_by_sql(["SELECT id FROM my_classes WHERE county = ?",
    #     selected_county], :properties => MyClass.property[:id],
    #     :repository => :county_repo)
    #
    # -
    # @api public
    def find_by_sqlx(*args)
      sql = nil
      query = nil
      bind_values = []
      properties = nil
      do_reload = false
      repository_name = default_repository_name
      args.each do |arg|
        if arg.is_a?(String)
          sql = arg
        elsif arg.is_a?(Array)
          sql = arg.first
          bind_values = arg[1..-1]
        elsif arg.is_a?(DataMapper::Query)
          query = arg
        elsif arg.is_a?(Hash)
          repository_name = arg.delete(:repository) if arg.include?(:repository)
          properties = Array(arg.delete(:properties)) if arg.include?(:properties)
          do_reload = arg.delete(:reload) if arg.include?(:reload)
          raise "unknown options to #find_by_sql: #{arg.inspect}" unless arg.empty?
        end
      end

      repository = repository(repository_name)
      raise "#find_by_sql only available for Repositories served by a DataObjectsAdapter" unless repository.adapter.is_a?(DataMapper::Adapters::DataObjectsAdapter)

      if query
        sql = repository.adapter.send(:read_statement, query)
        bind_values = query.bind_values
      end

      raise "#find_by_sql requires a query of some kind to work" unless sql

      properties ||= self.properties(repository.name)

      Collection.new(Query.new(repository, self)) do |collection|
        repository.adapter.send(:with_connection) do |connection|
          command = connection.create_command(sql)

          begin
            reader = command.execute_reader(*bind_values)

            while(reader.next!)
              puts reader.values
            #  collection.load(reader.values)
            end
          ensure
            reader.close if reader
          end
        end
      end
    end
  end # module Model
end # module DataMapper
