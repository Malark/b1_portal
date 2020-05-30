class ITT1 < ApplicationRecord
  self.table_name = 'ITT1'

  def self.search_iso_component(father)
    begin 
      query = <<-SQL 
        select *
        from ITT1
        inner join OITM on ITT1.Code = OITM.ItemCode
        where ITT1.Father = '#{father}'
        and OITM.U_HABTIPUS = 'ISO'
      SQL
      result = ActiveRecord::Base.connection.exec_query(query)
      if result.count > 0
        if result.count > 1
          puts "Csak egyetlen tétel lehetne az eredmény táblában! (search_iso_component)"
        end
        return result.first
      else
        return nil
      end
    end
  end  


  def self.search_poliol_component(father)
    begin 
      query = <<-SQL 
        select *
        from ITT1
        inner join OITM on ITT1.Code = OITM.ItemCode
        where ITT1.Father = '#{father}'
        and OITM.U_HABTIPUS = 'POLIOL'
      SQL
      result = ActiveRecord::Base.connection.exec_query(query)
      if result.count > 0
        if result.count > 1
          puts "Csak egyetlen tétel lehetne az eredmény táblában! (search_poliol_component)"
        end
        return result.first
      else
        return nil
      end
    end
  end  


  def self.search_additives(father)
    begin 
      query = <<-SQL 
        select *
        from ITT1
        inner join OITM on ITT1.Code = OITM.ItemCode
        where ITT1.Father = '#{father}'
        and OITM.U_HABTIPUS is null
      SQL

      results = ActiveRecord::Base.connection.exec_query(query)
      if results.count > 0
        return results
      else
        return nil
      end

    end
  end    


end