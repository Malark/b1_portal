class Gepek < ApplicationRecord
  self.table_name = '@GEPEK'

  def self.search_item(code)
    begin 
      query = <<-SQL 
        select *
        from dbo.[@GEPEK]
        where Code = '#{code}'
      SQL
      result = ActiveRecord::Base.connection.exec_query(query)
      if result.count > 0
        if result.count > 1
          puts "Csak egyetlen tétel lehetne az eredmény táblában! (@gepek.search_item)"
        end
        return result.first
      else
        return nil
      end
    end
  end  
end