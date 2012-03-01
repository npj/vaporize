module Vaporize
  class Database
    class Record
      
      attr_accessor :id, :path, :bucket, :content_type, :updated_at
      
      def self.create(path, bucket, content_type, updated_at, db)
        new([ nil, path, bucket, content_type, updated_at ], db).save
      end
      
      def initialize(row, db)
        @id, @path, @bucket, @content_type, @updated_at = row
        @db = db
        
        @updated_at = deserialize(@updated_at)
      end
      
      def save
        if id
          @db.execute("UPDATE files SET path=?, bucket=?, content_type=?, updated_at=? WHERE id=?", path, bucket, content_type, serialize(updated_at), id)
        else
          @db.execute("INSERT INTO files (path, bucket, content_type, updated_at) VALUES (?, ?, ?, ?)", path, bucket, content_type, serialize(updated_at))
          id = @db.last_insert_row_id
        end
      end
      
      def destroy
        if id
          @db.execute("DELETE FROM files WHERE id=?", id)
        end
      end
      
      private
      
        def serialize(dt)
          dt.to_i
        end
        
        def deserialize(dt)
          Time.at(dt)
        end
    end
    
    def initialize(datafile)
      @db = SQLite3::Database.new(datafile)
      create_schema
    end
    
    def reset
      @db.execute("DROP TABLE files")
      create_schema
    end
    
    def find(path)
      sql = "SELECT * FROM files WHERE path=?"
      
      if row = @db.get_first_row(sql, path)
        return Record.new(row, @db)
      end
    end
    
    def update(path, attributes = { })
      if record = find(path)
        record.updated_at   = attributes[:updated_at]
        record.content_type = attributes[:content_type]
        record.bucket       = attributes[:bucket]
        record.save
      else
        Record.create(path, attributes[:bucket], attributes[:content_type], attributes[:updated_at], @db)
      end
    end
    
    private
    
      def create_schema
        tables = @db.execute("SELECT name FROM sqlite_master WHERE type = 'table' AND NOT name = 'sqlite_sequence'");
        unless tables.flatten.include?("files")
          sql = %{
            CREATE TABLE files (
              id           INTEGER PRIMARY KEY,
              path         VARCHAR(255),
              bucket       VARCHAR(255), 
              content_type VARCHAR(255),
              updated_at   INT 
            );
          }
          @db.execute(sql)
        end
      end
  end
end